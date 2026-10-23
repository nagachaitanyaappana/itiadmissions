package com.server.frontend.controller.admission;

import java.util.LinkedHashMap;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

@Controller
@RequestMapping("/VerifyApplication")
public class OnlineApplicationVerificationController {

    private final RestTemplate rest = new RestTemplate();

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    @GetMapping
    public String page(HttpServletRequest request, Model model) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return "redirect:/?error=session";
        }
        String role = sessionValue(session, "roleId");
        if ("3".equals(role)) {
            return "checkmeritschedule/verifyApplication";
        }
        if (!"4".equals(role)) {
            return "redirect:/?error=session";
        }

        Map<String, Object> window = backendGet(backendBaseUrl + "/api/dv/window-status");
        int phase = parsePhase(window.get("phase"));
        if (phase <= 1) {
            model.addAttribute("phase2RoleMessage",
                    "Online application verification for an ITI login is available in Phase 2 and later.");
            return "admission/phase2RoleRequired";
        }
        return "checkmeritschedule/verifyApplication";
    }

    @GetMapping("/api/lookup")
    @ResponseBody
    public ResponseEntity<Object> lookup(@RequestParam String regid, HttpServletRequest request) {
        Scope scope = requireScope(request);
        if (scope.error() != null) {
            return scope.error();
        }
        UriComponentsBuilder url = UriComponentsBuilder
                .fromUriString(backendBaseUrl + "/api/dv/lookup")
                .queryParam("regid", regid);
        if (scope.iti()) {
            url.queryParam("itiCode", scope.code());
        } else {
            url.queryParam("distCode", scope.code());
        }
        return backendExchange(url.toUriString(), HttpMethod.GET, null);
    }

    @PostMapping("/api/approve")
    @ResponseBody
    public ResponseEntity<Object> approve(@RequestBody Map<String, Object> payload,
                                          HttpServletRequest request) {
        Scope scope = requireScope(request);
        if (scope.error() != null) {
            return scope.error();
        }
        Map<String, Object> body = trustedPayload(payload, request, scope);
        String path = scope.iti() ? "/api/dv/approve-iti" : "/api/dv/approve";
        return backendExchange(backendBaseUrl + path, HttpMethod.POST, body);
    }

    @PostMapping("/api/reject")
    @ResponseBody
    public ResponseEntity<Object> reject(@RequestBody Map<String, Object> payload,
                                         HttpServletRequest request) {
        Scope scope = requireScope(request);
        if (scope.error() != null) {
            return scope.error();
        }
        Map<String, Object> body = trustedPayload(payload, request, scope);
        String path = scope.iti() ? "/api/dv/reject-iti" : "/api/dv/reject";
        return backendExchange(backendBaseUrl + path, HttpMethod.POST, body);
    }

    private Scope requireScope(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return new Scope(false, "", ResponseEntity.status(401)
                    .body(Map.of("message", "Login is required.")));
        }
        String role = sessionValue(session, "roleId");
        String code = sessionValue(session, "insCode");
        if (code == null || code.isBlank()) {
            return new Scope(false, "", ResponseEntity.status(403)
                    .body(Map.of("message", "The logged-in account has no admission scope configured.")));
        }
        if ("3".equals(role)) {
            return new Scope(false, code, null);
        }
        if (!"4".equals(role)) {
            return new Scope(false, "", ResponseEntity.status(403)
                    .body(Map.of("message", "District or ITI login is required.")));
        }
        Map<String, Object> window = backendGet(backendBaseUrl + "/api/dv/window-status");
        if (parsePhase(window.get("phase")) <= 1) {
            return new Scope(true, code, ResponseEntity.status(403)
                    .body(Map.of("message", "ITI verification is available only in Phase 2 and later.")));
        }
        return new Scope(true, code, null);
    }

    private Map<String, Object> trustedPayload(Map<String, Object> payload,
                                               HttpServletRequest request, Scope scope) {
        Map<String, Object> body = new LinkedHashMap<>(payload);
        body.remove("distCode");
        body.remove("itiCode");
        body.put("username", sessionValue(request.getSession(false), "username"));
        if (scope.iti()) {
            body.put("itiCode", scope.code());
        } else {
            body.put("distCode", scope.code());
        }
        return body;
    }

    private Map<String, Object> backendGet(String url) {
        ResponseEntity<Map<String, Object>> response = rest.exchange(url, HttpMethod.GET, null,
                new ParameterizedTypeReference<Map<String, Object>>() {});
        Map<String, Object> body = response.getBody();
        if (body == null) {
            throw new IllegalStateException("The verification service returned an empty response.");
        }
        return body;
    }

    private ResponseEntity<Object> backendExchange(String url, HttpMethod method, Object body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            ResponseEntity<Object> response = rest.exchange(url, method,
                    new HttpEntity<>(body, headers), new ParameterizedTypeReference<Object>() {});
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (HttpStatusCodeException exception) {
            return ResponseEntity.status(exception.getStatusCode())
                    .body(exception.getResponseBodyAs(Object.class));
        }
    }

    private static int parsePhase(Object phase) {
        try {
            return Integer.parseInt(String.valueOf(phase));
        } catch (NumberFormatException exception) {
            throw new IllegalStateException("The current admission phase is not configured.", exception);
        }
    }

    private static String sessionValue(HttpSession session, String key) {
        Object value = session == null ? null : session.getAttribute(key);
        return value == null ? null : String.valueOf(value);
    }

    private record Scope(boolean iti, String code, ResponseEntity<Object> error) {}
}
