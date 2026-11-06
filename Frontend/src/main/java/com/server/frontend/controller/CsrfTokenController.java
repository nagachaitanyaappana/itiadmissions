package com.server.frontend.controller;

import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Issues a session-bound synchronizer token for same-origin state-changing
 * requests sent through the Frontend Backend Gateway.
 */
@RestController
public class CsrfTokenController {

    static final String SESSION_ATTRIBUTE = "ITIAP_CSRF_TOKEN";
    private static final SecureRandom RANDOM = new SecureRandom();

    @GetMapping("/api/csrf")
    public ResponseEntity<Map<String, String>> token(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return ResponseEntity.status(401).build();
        }

        String token = (String) session.getAttribute(SESSION_ATTRIBUTE);
        if (token == null || token.length() < 40) {
            byte[] bytes = new byte[32];
            RANDOM.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute(SESSION_ATTRIBUTE, token);
        }

        return ResponseEntity.ok()
                .cacheControl(CacheControl.noStore())
                .body(Map.of("token", token));
    }
}
