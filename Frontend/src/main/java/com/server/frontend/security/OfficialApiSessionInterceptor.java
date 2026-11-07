package com.server.frontend.security;

import java.io.IOException;
import java.util.Map;
import java.util.Set;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import com.server.frontend.controller.BackendGatewayController;

/**
 * Protects legacy same-origin server-side API proxy controllers. These routes
 * do not pass through /backend/**, so they need their own session, role and
 * CSRF checks before they call the private Backend service.
 */
@Component
public class OfficialApiSessionInterceptor implements HandlerInterceptor {

    private static final Map<String, Set<String>> ROLE_RULES = Map.ofEntries(
            Map.entry("/ReservationEntry", Set.of("3", "2", "10")),
            Map.entry("/SeatCorrection", Set.of("3", "2", "10")),
            Map.entry("/ScheduleEntryView", Set.of("3", "2", "10")),
            Map.entry("/admissions/search", Set.of("4", "2", "10")),
            Map.entry("/admissions/admission-update", Set.of("4", "2", "10")),
            Map.entry("/admissions/application-reprint", Set.of("3", "2", "10")),
            Map.entry("/admissions/discharge-admission", Set.of("3", "2", "10")),
            Map.entry("/admissions/print-admission-slip", Set.of("3", "2", "10")),
            Map.entry("/admissions/reprint-verified-application", Set.of("2", "10")),
            Map.entry("/admissions/dsc-list", Set.of("4", "2", "10")),
            Map.entry("/VerifyApplication", Set.of("3", "4")),
            Map.entry("/CallLetterView", Set.of("3", "4")),
            Map.entry("/AdmissionPhase", Set.of("3", "4", "2", "10")),
            Map.entry("/AddTrade", Set.of("4", "2", "10"))
    );

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler)
            throws IOException {
        String path = request.getRequestURI().substring(request.getContextPath().length());
        Set<String> allowedRoles = rolesFor(path);
        if (allowedRoles == null) return true;

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "An official login is required");
            return false;
        }

        Object roleValue = session.getAttribute("roleId");
        String role = roleValue == null ? "" : String.valueOf(roleValue).trim();
        if (!allowedRoles.contains(role)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN,
                    "Your official role does not permit this page or operation");
            return false;
        }

        if (requiresCsrf(request.getMethod()) && !BackendGatewayController.sameOrigin(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Cross-origin writes are not allowed");
            return false;
        }
        return true;
    }

    static Set<String> rolesFor(String path) {
        if (path == null) return null;
        for (Map.Entry<String, Set<String>> rule : ROLE_RULES.entrySet()) {
            String prefix = rule.getKey();
            if (path.equals(prefix) || path.startsWith(prefix + "/")) {
                return rule.getValue();
            }
        }
        return null;
    }

    static boolean requiresCsrf(String method) {
        return method != null && Set.of("POST", "PUT", "PATCH", "DELETE")
                .contains(method.toUpperCase());
    }
}
