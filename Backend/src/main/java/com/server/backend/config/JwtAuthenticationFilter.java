package com.server.backend.config;

import com.server.backend.service.Auth.JwtTokenService;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletRequestWrapper;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.core.Ordered;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;
import java.util.Enumeration;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Validates official-user access tokens forwarded by the trusted Frontend
 * gateway. The gateway's service credential is checked by
 * InternalServiceAuthenticationFilter before this filter runs.
 */
@Component
@Order(Ordered.HIGHEST_PRECEDENCE + 30)
public class JwtAuthenticationFilter extends OncePerRequestFilter {
    public static final String CLAIMS_ATTRIBUTE = JwtAuthenticationFilter.class.getName() + ".claims";

    private static final Pattern STUDENT_REGID = Pattern.compile("^/api/student/(\\d+)$");
    private static final Pattern STUDENT_PHOTO = Pattern.compile("^/api/student/photo/(\\d+)$");
    private static final Pattern STUDENT_MARKS = Pattern.compile("^/api/student/marks/(\\d+)$");
    private static final Pattern STUDENT_UPDATE = Pattern.compile("^/api/student/update/(\\d+)$");
    private static final Pattern TRADE_SELECTION = Pattern.compile("^/admission/student-trade-selection/(\\d+)$");

    private final JwtTokenService tokens;

    public JwtAuthenticationFilter(JwtTokenService tokens) {
        this.tokens = tokens;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response,
                                    FilterChain chain) throws ServletException, IOException {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        boolean gatewayRequest = Boolean.TRUE.equals(
                request.getAttribute(InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE));
        String header = request.getHeader("Authorization");

        if (header == null || !header.startsWith("Bearer ")) {
            if (!gatewayRequest) {
                // Compatibility for legacy Frontend server-side controllers. In
                // production, Backend is bound to a private interface so these
                // requests can only originate from the Frontend host.
                chain.doFilter(request, response);
                return;
            }
            if (isPublicCandidatePath(request.getMethod(), path)) {
                chain.doFilter(request, response);
                return;
            }
            String candidateRegid = candidateRegid(request.getMethod(), path);
            String suppliedCandidateRegid = request.getHeader("X-Candidate-Regid");
            if (candidateRegid != null && candidateRegid.equals(suppliedCandidateRegid)) {
                chain.doFilter(request, response);
                return;
            }
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                    "An authenticated official or verified candidate session is required");
            return;
        }

        try {
            Claims claims = tokens.verify(header.substring(7).trim());
            if (!authorized(claims, request, path)) {
                response.sendError(HttpServletResponse.SC_FORBIDDEN,
                        "Your role or organization scope does not permit this operation");
                return;
            }
            request.setAttribute(CLAIMS_ATTRIBUTE, claims);
            chain.doFilter(withTrustedIdentityHeaders(request, claims), response);
        } catch (JwtException | IllegalArgumentException ex) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid or expired access token");
        }
    }

    private static boolean isPublicCandidatePath(String method, String path) {
        if ("GET".equalsIgnoreCase(method)) {
            return "/api/student/apply-gate".equals(path)
                    || "/api/student/verify-identity".equals(path)
                    || "/api/student/castes".equals(path)
                    || "/api/districts".equals(path)
                    || "/api/reports/current-admission-phase".equals(path)
                    || path.matches("^/api/student/subcastes/[A-Za-z0-9_-]+$")
                    || path.matches("^/admission/eligible-itis/[A-Za-z0-9_-]+$")
                    || path.matches("^/admission/iti/[A-Za-z0-9_-]+/(info|trades)$");
        }
        return "POST".equalsIgnoreCase(method)
                && ("/api/student/save".equals(path) || "/api/student/register".equals(path));
    }

    private static String candidateRegid(String method, String path) {
        Matcher matcher;
        if ("GET".equalsIgnoreCase(method)) {
            matcher = STUDENT_REGID.matcher(path);
            if (matcher.matches()) return matcher.group(1);
            matcher = STUDENT_MARKS.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        if ("GET".equalsIgnoreCase(method) || "POST".equalsIgnoreCase(method)) {
            matcher = STUDENT_PHOTO.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        if ("PUT".equalsIgnoreCase(method)) {
            matcher = STUDENT_UPDATE.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        if (Set.of("GET", "POST", "PUT", "DELETE").contains(method.toUpperCase())) {
            matcher = TRADE_SELECTION.matcher(path);
            if (matcher.matches()) return matcher.group(1);
        }
        return null;
    }

    private static boolean authorized(Claims claims, HttpServletRequest request, String path) {
        String role = claim(claims, "roleId");
        String insCode = claim(claims, "insCode");
        if (role == null || role.isBlank()) return false;

        if (path.startsWith("/api/dv/")) {
            if (path.endsWith("/approve-iti") || path.endsWith("/reject-iti")) {
                return "4".equals(role) && hasScope(insCode);
            }
            if (path.endsWith("/approve") || path.endsWith("/reject") || path.endsWith("/list")) {
                return "3".equals(role) && hasScope(insCode);
            }
            if (path.endsWith("/lookup")) {
                return ("3".equals(role) || "4".equals(role)) && hasScope(insCode);
            }
            return "2".equals(role) || "3".equals(role) || "4".equals(role) || "10".equals(role);
        }

        if (path.startsWith("/admission/add-trade/")) {
            String[] parts = path.split("/");
            return "4".equals(role) && hasScope(insCode)
                    && parts.length > 3 && insCode.equalsIgnoreCase(parts[3]);
        }

        if ("/api/shift-unit-permitted".equals(path)) {
            return "4".equals(role) && hasScope(insCode);
        }

        if (path.startsWith("/api/admission/")) {
            return ("3".equals(role) || "4".equals(role)) && hasScope(insCode);
        }

        if (path.equals("/api/student/all") || path.startsWith("/api/student/delete/")
                || path.startsWith("/api/student/hallticket/")) {
            return "2".equals(role) || "10".equals(role);
        }

        if (path.startsWith("/admin/")) {
            return "2".equals(role) || "10".equals(role);
        }

        // All other business endpoints require a signed official identity.
        return true;
    }

    private static HttpServletRequest withTrustedIdentityHeaders(HttpServletRequest request, Claims claims) {
        String role = claim(claims, "roleId");
        String insCode = claim(claims, "insCode");
        String itiCode = "4".equals(role) ? insCode : null;
        String distCode = "3".equals(role) ? insCode : null;

        return new HttpServletRequestWrapper(request) {
            @Override
            public String getHeader(String name) {
                if (name == null) return super.getHeader(null);
                return switch (name.toLowerCase()) {
                    case "x-role-id" -> role;
                    case "x-ins-code" -> insCode;
                    case "x-iti-code" -> itiCode;
                    case "x-dist-code" -> distCode;
                    default -> super.getHeader(name);
                };
            }

            @Override
            public Enumeration<String> getHeaders(String name) {
                String value = getHeader(name);
                return value == null ? Collections.emptyEnumeration()
                        : Collections.enumeration(Collections.singleton(value));
            }
        };
    }

    private static boolean hasScope(String value) {
        return value != null && !value.isBlank();
    }

    private static String claim(Claims claims, String name) {
        Object value = claims.get(name);
        return value == null ? null : String.valueOf(value);
    }
}
