package com.server.frontend.security;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.stereotype.Component;

/**
 * Builds trusted server-to-server headers for legacy Frontend proxy controllers.
 * The browser never supplies the bearer token or internal service key directly:
 * the Frontend reads its HttpOnly access-token cookie and server configuration.
 */
@Component
public class BackendApiRequestSupport {

    @Value("${app.internal-auth.secret:}")
    private String internalSecret;

    public HttpHeaders headers(HttpServletRequest request) {
        HttpHeaders headers = new HttpHeaders();
        if (internalSecret != null && !internalSecret.isBlank()) {
            headers.set("X-Internal-Service-Key", internalSecret.trim());
        }
        String token = accessToken(request);
        if (token != null) {
            headers.setBearerAuth(token);
        }
        return headers;
    }

    public HttpEntity<Void> entity(HttpServletRequest request) {
        return new HttpEntity<>(headers(request));
    }

    public <T> HttpEntity<T> entity(HttpServletRequest request, T body) {
        return new HttpEntity<>(body, headers(request));
    }

    public static String accessToken(HttpServletRequest request) {
        if (request == null || request.getCookies() == null) return null;
        for (Cookie cookie : request.getCookies()) {
            if ("ITIAP_ACCESS_TOKEN".equals(cookie.getName())
                    && cookie.getValue() != null && !cookie.getValue().isBlank()) {
                return cookie.getValue();
            }
        }
        return null;
    }

    public static String role(HttpServletRequest request) {
        if (request == null) return "";
        var session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("roleId");
        return value == null ? "" : String.valueOf(value).trim();
    }

    public static String scope(HttpServletRequest request) {
        if (request == null) return "";
        var session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("insCode");
        return value == null ? "" : String.valueOf(value).trim();
    }
}
