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
 * Restricts the credential-checking endpoint to the trusted Frontend process.
 *
 * <p>This is deliberately scoped to /api/auth/login while the browser-to-Frontend
 * gateway migration is in progress. Applying it to all business APIs before that
 * migration would break existing candidate and official browser workflows.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 20)
public class InternalServiceAuthenticationFilter extends OncePerRequestFilter {

    public static final String HEADER_NAME = "X-Internal-Service-Key";

    private final String configuredSecret;

    public InternalServiceAuthenticationFilter(
            @Value("${app.internal-auth.secret:}") String configuredSecret) {
        this.configuredSecret = configuredSecret == null ? "" : configuredSecret;
    }

    @Override
    protected boolean shouldNotFilter(HttpServletRequest request) {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        return !("/api/auth/login".equals(path) && "POST".equalsIgnoreCase(request.getMethod()));
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {
        if (configuredSecret.length() < 32) {
            response.sendError(HttpServletResponse.SC_SERVICE_UNAVAILABLE,
                    "Backend internal authentication is not configured");
            return;
        }

        String supplied = request.getHeader(HEADER_NAME);
        if (supplied == null || !MessageDigest.isEqual(
                configuredSecret.getBytes(StandardCharsets.UTF_8),
                supplied.getBytes(StandardCharsets.UTF_8))) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "A trusted Frontend service credential is required");
            return;
        }

        filterChain.doFilter(request, response);
    }
}
