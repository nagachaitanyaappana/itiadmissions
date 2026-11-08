package com.server.frontend.controller;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.time.Duration;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Same-origin gateway: browser -> Frontend -> Backend.
 *
 * <p>The Backend URL and service credential remain server-side. Public candidate
 * registration/reference routes are explicitly allowlisted. Existing-candidate
 * reads and edits require a successful DOB + SSC identity check bound to the
 * Frontend HTTP session. All other routes require the official-user access token.
 */
@RestController
public class BackendGatewayController {
    static final String CANDIDATE_SESSION_ATTRIBUTE = "verifiedCandidateRegid";
    static final String CANDIDATE_SESSION_VERIFIED_AT_ATTRIBUTE = "verifiedCandidateAt";
    private static final long CANDIDATE_SESSION_TTL_MILLIS = 30L * 60L * 1000L;
    private static final int MAX_BODY_BYTES = 6 * 1024 * 1024;
    private static final Set<String> METHODS =
            Set.of("GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS");
    private static final Set<String> REQUEST_HEADERS =
            Set.of("accept", "content-type", "if-match", "if-none-match", "range");
    private static final Set<String> RESPONSE_HEADERS =
            Set.of("content-type", "content-disposition", "cache-control", "etag",
                    "last-modified", "accept-ranges", "content-range");
    private static final Pattern CANDIDATE_REGID = Pattern.compile("^/api/student/(\\d+)$");
    private static final Pattern CANDIDATE_PHOTO = Pattern.compile("^/api/student/photo/(\\d+)$");
    private static final Pattern CANDIDATE_MARKS = Pattern.compile("^/api/student/marks/(\\d+)$");
    private static final Pattern CANDIDATE_UPDATE = Pattern.compile("^/api/student/update/(\\d+)$");
    private static final Pattern CANDIDATE_TRADE_SELECTION =
            Pattern.compile("^/admission/student-trade-selection/(\\d+)(?:/[A-Za-z0-9_-]+|/dist/[A-Za-z0-9_-]+)?$");

    private final RestTemplate rest;
    private final String backendBaseUrl;
    private final String internalApiSecret;
    private final ObjectMapper objectMapper;

    public BackendGatewayController(
            @Value("${backend.api.base-url}") String backendBaseUrl,
            @Value("${backend.gateway.connect-timeout:3s}") Duration connectTimeout,
            @Value("${backend.gateway.read-timeout:30s}") Duration readTimeout,
            @Value("${app.internal-auth.secret:}") String internalApiSecret,
            ObjectMapper objectMapper) {
        this.backendBaseUrl = backendBaseUrl;
        this.internalApiSecret = internalApiSecret == null ? "" : internalApiSecret.trim();
        this.objectMapper = objectMapper;
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connectTimeout);
        factory.setReadTimeout(readTimeout);
        this.rest = new RestTemplate(factory);
    }

    @RequestMapping("/backend/**")
    public ResponseEntity<byte[]> proxy(HttpServletRequest request) throws IOException {
        String requestPath = request.getRequestURI().substring(request.getContextPath().length());
        if (!requestPath.startsWith("/backend/")) return ResponseEntity.badRequest().build();

        String path = requestPath.substring("/backend".length());
        if (!safePath(path)) return ResponseEntity.badRequest().build();

        String methodName = request.getMethod().toUpperCase();
        if (!METHODS.contains(methodName)) return ResponseEntity.status(405).build();
        if (internalApiSecret.length() < 32) return ResponseEntity.status(503).build();

        boolean publicCandidateRequest = isPublicCandidateRequest(methodName, path);
        String pathRegid = candidateRegid(methodName, path);
        String accessToken = cookie(request, "ITIAP_ACCESS_TOKEN");
        HttpSession frontendSession = request.getSession(false);
        String candidateRegid = verifiedCandidateRegid(frontendSession);

        boolean candidateSessionMatches = pathRegid != null && pathRegid.equals(candidateRegid);
        boolean hasOfficialSession = frontendSession != null
                && frontendSession.getAttribute("sessionUser") != null;
        boolean officialRequest = hasOfficialSession && accessToken != null
                && !accessToken.isBlank() && accessToken.length() <= 8192;

        if (!publicCandidateRequest && !candidateSessionMatches && !officialRequest) {
            return ResponseEntity.status(401).build();
        }
        // Browser-origin writes must be same-origin. This protects both the
        // public candidate forms and the session-authenticated official APIs.
        if (requiresCsrf(methodName) && !sameOrigin(request)) {
            return ResponseEntity.status(403).build();
        }

        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Service-Key", internalApiSecret);
        if (candidateSessionMatches) {
            // This value is derived from the server-side session, never copied
            // from a browser-supplied header or query parameter. Candidate-scoped
            // access takes precedence over any stale official token cookie.
            headers.set("X-Candidate-Regid", candidateRegid);
        } else if (officialRequest && !publicCandidateRequest) {
            // Public candidate/reference routes must remain public even when the
            // same browser happens to carry an official access-token cookie.
            headers.setBearerAuth(accessToken);
        }
        for (String name : REQUEST_HEADERS) {
            String value = request.getHeader(name);
            if (value != null) headers.set(name, value);
        }

        String target = UriComponentsBuilder.fromUriString(backendBaseUrl)
                .path(path).query(request.getQueryString()).build(true).toUriString();
        HttpMethod method = HttpMethod.valueOf(methodName);
        byte[] body = new byte[0];
        if (method != HttpMethod.GET && method != HttpMethod.HEAD && method != HttpMethod.OPTIONS) {
            if (request.getContentLengthLong() > MAX_BODY_BYTES) {
                return ResponseEntity.status(413).build();
            }
            try {
                body = readLimited(request.getInputStream());
            } catch (PayloadTooLargeException ex) {
                return ResponseEntity.status(413).build();
            }
        }

        // A fresh identity check replaces any previous candidate binding. A
        // failed check must never leave the old candidate authorized.
        boolean candidateIdentityCheck = "POST".equals(methodName)
                && ("/api/student/apply-gate".equals(path)
                    || "/api/student/verify-identity".equals(path));
        boolean registrationIdLookup = "POST".equals(methodName)
                && "/api/student/lookup-regid".equals(path);
        boolean captchaProtectedCheck = candidateIdentityCheck || registrationIdLookup;
        boolean publicRegistrationWrite = "POST".equals(methodName)
                && ("/api/student/save".equals(path) || "/api/student/register".equals(path)
                    || "/api/student/lookup-regid".equals(path));
        if (captchaProtectedCheck || publicRegistrationWrite) {
            HttpSession existing = request.getSession(false);
            if (!consumeCaptchaProof(existing, captchaProtectedCheck)) {
                if (existing != null) clearCandidateSession(existing);
                return ResponseEntity.status(403).build();
            }
            // A new identity attempt must not inherit a previously verified candidate session.
            if (captchaProtectedCheck && existing != null) {
                clearCandidateSession(existing);
            }
        }

        try {
            ResponseEntity<byte[]> upstream = rest.exchange(
                    target, method, new HttpEntity<>(body, headers), byte[].class);
            if (candidateIdentityCheck) bindCandidateSession(request, path, upstream);
            return response(upstream.getStatusCode(), upstream.getHeaders(), upstream.getBody());
        } catch (org.springframework.web.client.HttpStatusCodeException ex) {
            if (captchaProtectedCheck) {
                HttpSession existing = request.getSession(false);
                if (existing != null) clearCandidateSession(existing);
            }
            return response(ex.getStatusCode(), ex.getResponseHeaders(), ex.getResponseBodyAsByteArray());
        } catch (RestClientException ex) {
            return ResponseEntity.status(502).build();
        }
    }

    static boolean consumeCaptchaProof(HttpSession session, boolean consumeAll) {
        return consumeCaptchaProof(session, consumeAll, System.currentTimeMillis());
    }

    static boolean consumeCaptchaProof(HttpSession session, boolean consumeAll, long nowMillis) {
        if (session == null) return false;
        Object verifiedAt = session.getAttribute(CaptchaController.VERIFIED_AT_KEY);
        Object usesValue = session.getAttribute(CaptchaController.VERIFIED_USES_KEY);
        long verifiedMillis = verifiedAt instanceof Number number ? number.longValue() : 0L;
        int uses = usesValue instanceof Number number ? number.intValue() : 0;
        if (verifiedMillis <= 0L || nowMillis < verifiedMillis
                || nowMillis - verifiedMillis > 5 * 60 * 1000L || uses <= 0) {
            session.removeAttribute(CaptchaController.VERIFIED_AT_KEY);
            session.removeAttribute(CaptchaController.VERIFIED_USES_KEY);
            return false;
        }
        if (consumeAll) {
            session.removeAttribute(CaptchaController.VERIFIED_AT_KEY);
            session.removeAttribute(CaptchaController.VERIFIED_USES_KEY);
        } else if (uses == 1) {
            session.removeAttribute(CaptchaController.VERIFIED_AT_KEY);
            session.removeAttribute(CaptchaController.VERIFIED_USES_KEY);
        } else {
            session.setAttribute(CaptchaController.VERIFIED_USES_KEY, uses - 1);
        }
        return true;
    }

    private static byte[] readLimited(InputStream input) throws IOException {
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        byte[] buffer = new byte[8192];
        int total = 0;
        int count;
        while ((count = input.read(buffer)) != -1) {
            total += count;
            if (total > MAX_BODY_BYTES) throw new PayloadTooLargeException();
            output.write(buffer, 0, count);
        }
        return output.toByteArray();
    }

    private static final class PayloadTooLargeException extends IOException {
        private static final long serialVersionUID = 1L;
    }

    private void bindCandidateSession(HttpServletRequest request, String path,
                                      ResponseEntity<byte[]> upstream) {
        if (!upstream.getStatusCode().is2xxSuccessful() || upstream.getBody() == null) return;
        try {
            Map<String, Object> body = objectMapper.readValue(
                    upstream.getBody(), new TypeReference<Map<String, Object>>() {});
            Object regid = null;
            if ("/api/student/apply-gate".equals(path)) {
                if ("ok".equals(String.valueOf(body.get("status")))
                        && body.get("record") instanceof Map<?, ?> record) {
                    regid = record.get("regid");
                }
            } else {
                regid = body.get("regid");
            }
            if (regid != null && String.valueOf(regid).matches("\\d+")) {
                // Candidate identity verification elevates an anonymous session to a
                // candidate-scoped session. Rotate the identifier before storing that
                // authority to prevent session fixation.
                request.getSession(true);
                request.changeSessionId();
                HttpSession candidateSession = request.getSession(false);
                candidateSession.setAttribute(CANDIDATE_SESSION_ATTRIBUTE, String.valueOf(regid));
                candidateSession.setAttribute(CANDIDATE_SESSION_VERIFIED_AT_ATTRIBUTE,
                        System.currentTimeMillis());
            }
        } catch (Exception ignored) {
            HttpSession existing = request.getSession(false);
            if (existing != null) clearCandidateSession(existing);
        }
    }

    static String verifiedCandidateRegid(HttpSession session) {
        if (session == null) return null;
        Object value = session.getAttribute(CANDIDATE_SESSION_ATTRIBUTE);
        Object verifiedAtValue = session.getAttribute(CANDIDATE_SESSION_VERIFIED_AT_ATTRIBUTE);
        long verifiedAt = verifiedAtValue instanceof Number number ? number.longValue() : 0L;
        long now = System.currentTimeMillis();
        if (verifiedAt <= 0L || now < verifiedAt || now - verifiedAt > CANDIDATE_SESSION_TTL_MILLIS) {
            clearCandidateSession(session);
            return null;
        }
        String regid = value == null ? null : String.valueOf(value);
        return regid != null && regid.matches("\\d+") ? regid : null;
    }

    static void clearCandidateSession(HttpSession session) {
        if (session == null) return;
        session.removeAttribute(CANDIDATE_SESSION_ATTRIBUTE);
        session.removeAttribute(CANDIDATE_SESSION_VERIFIED_AT_ATTRIBUTE);
    }

    private static ResponseEntity<byte[]> response(
            org.springframework.http.HttpStatusCode status, HttpHeaders source, byte[] body) {
        HttpHeaders safe = new HttpHeaders();
        if (source != null) source.forEach((name, values) -> {
            if (RESPONSE_HEADERS.contains(name.toLowerCase())) safe.put(name, values);
        });
        return new ResponseEntity<>(body, safe, status);
    }

    private static String cookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) if (name.equals(cookie.getName())) return cookie.getValue();
        return null;
    }

    static boolean requiresCsrf(String method) {
        return !("GET".equalsIgnoreCase(method) || "HEAD".equalsIgnoreCase(method)
                || "OPTIONS".equalsIgnoreCase(method));
    }

    public static boolean sameOrigin(HttpServletRequest request) {
        String origin = request.getHeader("Origin");
        if (origin == null || origin.isBlank()) {
            return "same-origin".equalsIgnoreCase(request.getHeader("Sec-Fetch-Site"));
        }
        try {
            URI uri = URI.create(origin);
            int originPort = uri.getPort() < 0
                    ? ("https".equalsIgnoreCase(uri.getScheme()) ? 443 : 80) : uri.getPort();
            int requestPort = request.getServerPort();
            return uri.getScheme() != null
                    && uri.getScheme().equalsIgnoreCase(request.getScheme())
                    && uri.getHost() != null
                    && uri.getHost().equalsIgnoreCase(request.getServerName())
                    && originPort == requestPort;
        } catch (IllegalArgumentException ex) {
            return false;
        }
    }

    static boolean isPublicCandidateRequest(String method, String path) {
        if ("GET".equalsIgnoreCase(method)) {
            return "/api/student/castes".equals(path)
                    || "/api/dsc/caste-list".equals(path)
                    || "/api/districts".equals(path)
                    || "/api/reports/current-admission-phase".equals(path)
                    || path.matches("^/api/student/subcastes/[A-Za-z0-9_-]+$")
                    || path.matches("^/api/iti/by-govt-pvt/[A-Za-z0-9_-]+$")
                    || path.matches("^/admission/trade/[A-Za-z0-9_-]+/details$")
                    || path.matches("^/admission/eligible-itis/[A-Za-z0-9_-]+$")
                    || path.matches("^/admission/iti/[A-Za-z0-9_-]+/(info|trades)$");
        }
        return "POST".equalsIgnoreCase(method)
                && ("/api/student/apply-gate".equals(path)
                    || "/api/student/verify-identity".equals(path)
                    || "/api/student/save".equals(path)
                    || "/api/student/register".equals(path)
                    || "/api/student/lookup-regid".equals(path));
    }

    static String candidateRegid(String method, String path) {
        Matcher matcher;
        if ("GET".equalsIgnoreCase(method)) {
            matcher = CANDIDATE_REGID.matcher(path);
            if (matcher.matches()) return matcher.group(1);
            matcher = CANDIDATE_MARKS.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        if ("GET".equalsIgnoreCase(method) || "POST".equalsIgnoreCase(method)) {
            matcher = CANDIDATE_PHOTO.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        if ("PUT".equalsIgnoreCase(method)) {
            matcher = CANDIDATE_UPDATE.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        if (Set.of("GET", "POST", "PUT", "DELETE").contains(method.toUpperCase())) {
            matcher = CANDIDATE_TRADE_SELECTION.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        return null;
    }

    static boolean safePath(String path) {
        if (path == null || !path.startsWith("/") || path.startsWith("//")
                || path.contains("\\") || path.contains("..") || path.indexOf(0) >= 0
                || path.chars().anyMatch(ch -> ch == 13 || ch == 10)
                || path.matches("(?i).*%(2f|5c|2e|25).*")) return false;
        String lower = path.toLowerCase();
        return !lower.startsWith("/actuator") && !lower.startsWith("/swagger")
                && !lower.startsWith("/v3/api-docs") && !lower.startsWith("/error")
                && !lower.startsWith("/api/auth");
    }
}
