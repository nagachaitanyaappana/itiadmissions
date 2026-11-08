package com.server.backend.config;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * Verifies the Frontend-to-Backend service credential for every application
 * endpoint. Only documentation, health and framework error paths are excluded.
 * This prevents browser clients from bypassing the Frontend gateway by calling
 * a Backend route that does not use the /api or /admission prefix.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 20)
public class InternalServiceAuthenticationFilter extends OncePerRequestFilter {

    public static final String HEADER_NAME = "X-Internal-Service-Key";
    public static final String AUTHENTICATED_ATTRIBUTE =
            InternalServiceAuthenticationFilter.class.getName() + ".authenticated";

    private final String configuredSecret;

    public InternalServiceAuthenticationFilter(
            @Value("${app.internal-auth.secret:}") String configuredSecret) {
        this.configuredSecret = configuredSecret == null ? "" : configuredSecret;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        // Health and framework error dispatches are intentionally public.
        // API documentation still requires the Frontend service credential.
        return path.equals("/error") || path.equals("/actuator/health");
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        String supplied = request.getHeader(HEADER_NAME);

        if (configuredSecret.length() < 32) {
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Backend internal authentication is not configured");
            return;
        }
        if (supplied == null || !MessageDigest.isEqual(
                configuredSecret.getBytes(StandardCharsets.UTF_8),
                supplied.getBytes(StandardCharsets.UTF_8))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "A trusted Frontend service credential is required");
            return;
        }

        request.setAttribute(AUTHENTICATED_ATTRIBUTE, Boolean.TRUE);
        filterChain.doFilter(request, response);
    }
}
