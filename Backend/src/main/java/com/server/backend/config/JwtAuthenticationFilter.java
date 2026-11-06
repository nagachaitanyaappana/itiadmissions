package com.server.backend.config;

import com.server.backend.service.Auth.JwtTokenService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/** Validates JWTs forwarded by the trusted Frontend gateway. */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 30)
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    public static final String CLAIMS_ATTRIBUTE = JwtAuthenticationFilter.class.getName() + ".claims";
    private final JwtTokenService tokens;

    public JwtAuthenticationFilter(JwtTokenService tokens) {
        this.tokens = tokens;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        String header = request.getHeader("Authorization");
        if (header == null || !header.startsWith("Bearer ")) {
            chain.doFilter(request, response);
            return;
        }
        try {
            Claims claims = tokens.verify(header.substring(7).trim());
            request.setAttribute(CLAIMS_ATTRIBUTE, claims);
            chain.doFilter(request, response);
        } catch (JwtException | IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired access token");
        }
    }
}
