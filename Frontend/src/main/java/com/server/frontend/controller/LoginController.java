package com.server.frontend.controller;

import java.util.HashMap;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Cookie;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

/**
 * Handles the officials login form on the home page.
 * Validates captcha (session-scoped), then delegates credential checking
 * to the Backend /api/auth/login endpoint.
 */
@Controller
public class LoginController {

    private final RestTemplate rest;

    public LoginController(RestTemplate rest) {
        this.rest = rest;
    }
    @Value("${backend.api.base-url}/api/auth/login")
    private String AUTH_URL;

    @Value("${app.internal-auth.secret:}")
    private String internalApiSecret;

    // Developer shortcut is disabled by default; enable only in trusted local development.
    @Value("${app.auth.dev-login-enabled:false}")
    private boolean devLoginEnabled;

    @Value("${server.servlet.session.cookie.secure:false}")
    private boolean secureCookie;

    @GetMapping("/Login")
    public String loginPage() {
        return "jsp/Login";
    }

    @PostMapping("/iti/login.do")
    public String login(@RequestParam("uname") String uname,
                        @RequestParam("pwd") String pwd,
                        @RequestParam(value = "captcha", required = false) String captcha,
                        @RequestParam(value = "redirect", required = false) String redirectTo,
                        @RequestParam(value = "dev", required = false, defaultValue = "false") boolean devLogin,
                        HttpServletRequest request, jakarta.servlet.http.HttpServletResponse response) {

        // Login is a state-changing browser operation; reject cross-origin form posts.
        if (!BackendGatewayController.sameOrigin(request)) {
            return devLogin ? "redirect:/dev/login?error=origin" : "redirect:/?error=origin";
        }

        // Consume the session captcha after one attempt. The developer shortcut is
        // available only when explicitly enabled in trusted local development.
        if (!(devLogin && devLoginEnabled) && !CaptchaController.consumeForLogin(request, captcha)) {
            HttpSession stale = request.getSession(false);
            if (stale != null) {
                stale.removeAttribute("sessionUser");
            }
            return devLogin ? "redirect:/dev/login?error=captcha" : "redirect:/?error=captcha";
        }

        // 2. credentials are checked by the backend
        Map<String, Object> result = callAuthBackend(request, uname, pwd);
        if (result == null) {
            return devLogin ? "redirect:/dev/login?error=server" : "redirect:/?error=server";
        }
        if (!Boolean.TRUE.equals(result.get("success"))) {
            Object msg = result.get("message");
            String err = "inactive".equalsIgnoreCase(String.valueOf(msg)) || (msg != null && msg.toString().contains("inactive"))
                    ? "inactive" : "invalid";
            return devLogin ? "redirect:/dev/login?error=" + err : "redirect:/?error=" + err;
        }

        // 3. Prevent session fixation: rotate the session identifier after
        // successful authentication before storing any authenticated identity.
        HttpSession session = request.getSession(true);
        request.changeSessionId();
        Object accessToken = result.get("accessToken");
        if (!(accessToken instanceof String token) || token.isBlank()) {
            session.invalidate();
            return devLogin ? "redirect:/dev/login?error=server" : "redirect:/?error=server";
        }
        Cookie accessCookie = new Cookie("ITIAP_ACCESS_TOKEN", token);
        accessCookie.setHttpOnly(true);
        accessCookie.setSecure(secureCookie);
        accessCookie.setPath("/");
        accessCookie.setMaxAge(15 * 60);
        accessCookie.setAttribute("SameSite", "Lax");
        response.addCookie(accessCookie);
        BackendGatewayController.clearCandidateSession(session);
        // Never keep the bearer token in the general session map that JSPs may
        // expose to views. The token lives only in the HttpOnly access cookie.
        Map<String, Object> safeSessionUser = new HashMap<>(result);
        safeSessionUser.remove("accessToken");
        safeSessionUser.remove("expiresAt");
        safeSessionUser.remove("tokenType");
        session.setAttribute("sessionUser", safeSessionUser);
        session.setAttribute("username", result.get("username"));
        session.setAttribute("userName", result.get("username"));
        session.setAttribute("roleId", result.get("roleId"));
        session.setAttribute("insCode", result.get("insCode"));
        session.setAttribute("fullName", result.get("fullName"));
        session.setAttribute("itiName", result.get("itiName"));
        session.setAttribute("distName", result.get("distName"));
        session.setAttribute("loginCount", result.get("loginCount"));
        session.setAttribute("lastLogins", result.get("lastLogins"));
        // 4. land back on the page the user came from (used by the /dev index)
        return "redirect:" + safeRedirect(redirectTo, devLogin ? "/dev" : "/authHome");
    }

    /** Only same-site relative paths are honoured, so the param can't be used as an open redirect. */
    private static String safeRedirect(String redirectTo, String fallback) {
        if (redirectTo == null) {
            return fallback;
        }
        String target = redirectTo.trim();
        if (target.startsWith("/") && !target.startsWith("//") && !target.contains(":")) {
            return target;
        }
        return fallback;
    }

    @GetMapping("/logout")
    public String logout(HttpServletRequest request, jakarta.servlet.http.HttpServletResponse response) {
        HttpSession activeSession = request.getSession(false);
        if (activeSession != null) {
            activeSession.invalidate();
        }
        Cookie expired = new Cookie("ITIAP_ACCESS_TOKEN", "");
        expired.setHttpOnly(true);
        expired.setSecure(secureCookie);
        expired.setPath("/");
        expired.setMaxAge(0);
        expired.setAttribute("SameSite", "Lax");
        response.addCookie(expired);
        return "redirect:/";
    }

    private Map<String, Object> callAuthBackend(HttpServletRequest request, String uname, String pwd) {
        try {
            Map<String, String> payload = new HashMap<>();
            payload.put("username", uname == null ? "" : uname.trim());
            payload.put("password", pwd == null ? "" : pwd);
            payload.put("ip", request.getRemoteAddr() == null ? "" : request.getRemoteAddr());
            payload.put("sessionId", request.getSession().getId());
            if (internalApiSecret == null || internalApiSecret.length() < 32) {
                org.slf4j.LoggerFactory.getLogger(LoginController.class)
                        .error("Internal API authentication is not configured; refusing Backend login call.");
                return null;
            }
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.set("X-Internal-Service-Key", internalApiSecret);
            ResponseEntity<AuthResponse> response =
                    rest.postForEntity(AUTH_URL, new HttpEntity<>(payload, headers), AuthResponse.class);
            AuthResponse body = response.getBody();
            return body == null ? null : body.toMap();
        } catch (Exception e) {
            org.slf4j.LoggerFactory.getLogger(LoginController.class)
                    .warn("Auth backend call failed ({}): {}", AUTH_URL, e.toString());
            return null;
        }
    }

    /** Typed view of the backend /api/auth/login JSON body. */
    public static class AuthResponse {
        private Boolean success;
        private String message;
        private Object username;
        private Object roleId;
        private Object insCode;
        private Object fullName;
        private Object itiName;
        private Object distName;
        private Object loginCount;
        private Object lastLogins;
        private String accessToken;
        private String expiresAt;
        private String tokenType;

        public Boolean getSuccess() {
            return success;
        }

        public void setSuccess(Boolean success) {
            this.success = success;
        }

        public String getMessage() {
            return message;
        }

        public void setMessage(String message) {
            this.message = message;
        }

        public Object getUsername() {
            return username;
        }

        public void setUsername(Object username) {
            this.username = username;
        }

        public Object getRoleId() {
            return roleId;
        }

        public void setRoleId(Object roleId) {
            this.roleId = roleId;
        }

        public Object getInsCode() {
            return insCode;
        }

        public void setInsCode(Object insCode) {
            this.insCode = insCode;
        }

        public Object getFullName() {
            return fullName;
        }

        public void setFullName(Object fullName) {
            this.fullName = fullName;
        }

        public Object getItiName() {
            return itiName;
        }

        public void setItiName(Object itiName) {
            this.itiName = itiName;
        }

        public Object getDistName() {
            return distName;
        }

        public void setDistName(Object distName) {
            this.distName = distName;
        }

        public Object getLoginCount() {
            return loginCount;
        }

        public void setLoginCount(Object loginCount) {
            this.loginCount = loginCount;
        }

        public Object getLastLogins() {
            return lastLogins;
        }

        public String getAccessToken() { return accessToken; }
        public void setAccessToken(String accessToken) { this.accessToken = accessToken; }
        public String getExpiresAt() { return expiresAt; }
        public void setExpiresAt(String expiresAt) { this.expiresAt = expiresAt; }
        public String getTokenType() { return tokenType; }
        public void setTokenType(String tokenType) { this.tokenType = tokenType; }


        public void setLastLogins(Object lastLogins) {
            this.lastLogins = lastLogins;
        }

        Map<String, Object> toMap() {
            Map<String, Object> map = new HashMap<>();
            map.put("success", success);
            map.put("message", message);
            map.put("username", username);
            map.put("roleId", roleId);
            map.put("insCode", insCode);
            map.put("fullName", fullName);
            map.put("itiName", itiName);
            map.put("distName", distName);
            map.put("loginCount", loginCount);
            map.put("lastLogins", lastLogins);
            map.put("accessToken", accessToken);
            map.put("expiresAt", expiresAt);
            map.put("tokenType", tokenType);
            return map;
        }
    }
}
