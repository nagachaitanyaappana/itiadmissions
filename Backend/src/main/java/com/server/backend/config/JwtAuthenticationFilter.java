package com.server.backend.config;

import com.server.backend.service.Auth.JwtTokenService;
import com.server.backend.service.Student.StudentObjectAuthorizationService;
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
import java.util.HashMap;
import java.util.Map;
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
    private static final Pattern TRADE_SELECTION = Pattern.compile("^/admission/student-trade-selection/(\\d+)(?:/[A-Za-z0-9_-]+|/dist/[A-Za-z0-9_-]+)?$");

    private final JwtTokenService tokens;
    private final StudentObjectAuthorizationService studentObjects;

    public JwtAuthenticationFilter(JwtTokenService tokens,
                                   StudentObjectAuthorizationService studentObjects) {
        this.tokens = tokens;
        this.studentObjects = studentObjects;
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

    private boolean authorized(Claims claims, HttpServletRequest request, String path) {
        String role = claim(claims, "roleId");
        String insCode = claim(claims, "insCode");
        String method = request.getMethod().toUpperCase();
        if (role == null || role.isBlank()) return false;

        // District and ITI verification have distinct authorities.
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

        if ("/admission/admission-image-upload".equals(path)) {
            return "2".equals(role) || "4".equals(role) || "10".equals(role);
        }

        if (path.startsWith("/admission/add-trade/")) {
            String[] parts = path.split("/");
            return "4".equals(role) && hasScope(insCode)
                    && parts.length > 3 && insCode.equalsIgnoreCase(parts[3]);
        }

        if ("/api/shift-unit-permitted".equals(path)) {
            return "4".equals(role) && hasScope(insCode);
        }

        // Admission-process operations use a principal derived from signed claims.
        if (path.startsWith("/api/admission/")) {
            return ("3".equals(role) || "4".equals(role)) && hasScope(insCode);
        }

        if (path.startsWith("/api/reports/")) {
            if ("2".equals(role) || "10".equals(role)) return true;
            if ("/api/reports/current-admission-phase".equals(path)) return true;

            if ("3".equals(role) && hasScope(insCode) && districtScopedReport(path)) {
                String requestedIti = request.getParameter("itiCode");
                return requestedIti == null || requestedIti.isBlank()
                        || "All".equalsIgnoreCase(requestedIti)
                        || studentObjects.isItiInDistrict(requestedIti, insCode);
            }
            if ("4".equals(role) && hasScope(insCode) && itiScopedReport(path)) {
                return true;
            }
            if ("/api/reports/student-details".equals(path)) {
                String regid = request.getParameter("regid");
                if (regid == null || !regid.matches("\\d+")) return false;
                try {
                    return studentObjects.canRead(Integer.valueOf(regid), claims);
                } catch (NumberFormatException ex) {
                    return false;
                }
            }
            return false;
        }

        if (path.startsWith("/api/student/update/")) {
            return "2".equals(role) || "10".equals(role);
        }

        Matcher studentId = STUDENT_REGID.matcher(path);
        Matcher studentPhoto = STUDENT_PHOTO.matcher(path);
        Matcher studentMarks = STUDENT_MARKS.matcher(path);
        if (("GET".equals(method) && studentId.matches())
                || (("GET".equals(method) || "POST".equals(method)) && studentPhoto.matches())
                || ("GET".equals(method) && studentMarks.matches())) {
            String regid = studentId.matches() ? studentId.group(1)
                    : studentPhoto.matches() ? studentPhoto.group(1) : studentMarks.group(1);
            return canReadRegid(regid, claims);
        }

        if (path.equals("/api/student/all") || path.startsWith("/api/student/delete/")
                || path.startsWith("/api/student/hallticket/")) {
            return "2".equals(role) || "10".equals(role);
        }

        // Merit/checklist endpoints that previously exposed unscoped list, phase,
        // status and mutation operations to every signed-in official.
        if (path.equals("/api/meritlist") || path.startsWith("/api/meritlist/")) {
            return authorizeMeritList(claims, request, path, role, insCode);
        }
        if (path.equals("/api/checklist") || path.startsWith("/api/checklist/")) {
            return authorizeChecklist(claims, request, path, role, insCode);
        }

        // Only the scoped schedule workflow is available to district/ITI officials.
        if (path.equals("/admission-timings") || path.startsWith("/admission-timings/")) {
            return authorizeAdmissionTimings(request, path, role, insCode);
        }

        // Master data is read-only for district/ITI users. All writes and broad
        // ITI-list queries remain reserved for state/nodal roles.
        if (path.equals("/api/designations") || path.startsWith("/api/designations/")) {
            return "GET".equals(method) && ("3".equals(role) || "4".equals(role));
        }
        if (path.equals("/api/trades") || path.startsWith("/api/trades/")) {
            return "GET".equals(method) && ("3".equals(role) || "4".equals(role));
        }
        if (path.equals("/api/itis") || path.startsWith("/api/itis/")) {
            return authorizeItiMaster(request, path, role, insCode);
        }

        if (path.startsWith("/admission/reservation-entry")) {
            if ("2".equals(role) || "10".equals(role)) return true;
            if (!hasScope(insCode)) return false;
            if ("PUT".equals(method)) {
                // The controller validates the ITI from the JSON body against these claims.
                return "3".equals(role) || "4".equals(role);
            }
            if ("GET".equals(method)) {
                String itiCode = request.getParameter("itiCode");
                if (itiCode == null || itiCode.isBlank()) return false;
                if ("4".equals(role)) return insCode.equalsIgnoreCase(itiCode.trim());
                return "3".equals(role) && studentObjects.isItiInDistrict(itiCode, insCode);
            }
            return false;
        }

        if (path.startsWith("/admission/")) {
            return authorizeAdmissionLookup(claims, request, path, role, insCode);
        }

        if (path.startsWith("/api/status")) {
            return ("3".equals(role) || "4".equals(role)) && hasScope(insCode);
        }

        // Default-deny for district/ITI roles. State and nodal administrators retain
        // access to remaining protected modules until those modules receive their own
        // narrower policy; unknown roles never inherit access merely by having a JWT.
        return "2".equals(role) || "10".equals(role);
    }

    private boolean authorizeMeritList(Claims claims, HttpServletRequest request,
            String path, String role, String insCode) {
        String method = request.getMethod().toUpperCase();
        if ("GET".equals(method) && "/api/meritlist/window-status".equals(path)) {
            return "3".equals(role) || "4".equals(role);
        }
        if ("POST".equals(method) && "/api/meritlist/generate".equals(path)) {
            return ("3".equals(role) || "4".equals(role)) && hasScope(insCode);
        }
        Matcher district = Pattern.compile("^/api/meritlist/district/([A-Za-z0-9_-]+)$").matcher(path);
        if ("GET".equals(method) && district.matches()) {
            return "3".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(district.group(1));
        }
        Matcher iti = Pattern.compile("^/api/meritlist/iti/([A-Za-z0-9_-]+)$").matcher(path);
        if ("GET".equals(method) && iti.matches()) {
            return "4".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(iti.group(1));
        }
        Matcher regid = Pattern.compile("^/api/meritlist/(\\d+)$").matcher(path);
        return "GET".equals(method) && regid.matches() && canReadRegid(regid.group(1), claims);
    }

    private boolean authorizeChecklist(Claims claims, HttpServletRequest request,
            String path, String role, String insCode) {
        if (!"GET".equalsIgnoreCase(request.getMethod())) return false;
        Matcher district = Pattern.compile("^/api/checklist/district/([A-Za-z0-9_-]+)$").matcher(path);
        if (district.matches()) {
            return "3".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(district.group(1));
        }
        Matcher iti = Pattern.compile("^/api/checklist/iti/([A-Za-z0-9_-]+)$").matcher(path);
        if (iti.matches()) {
            return "4".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(iti.group(1));
        }
        Matcher regid = Pattern.compile("^/api/checklist/(\\d+)$").matcher(path);
        return regid.matches() && canReadRegid(regid.group(1), claims);
    }

    private boolean authorizeAdmissionTimings(HttpServletRequest request,
            String path, String role, String insCode) {
        if (!hasScope(insCode)) return false;
        if (Set.of("/admission-timings/entry", "/admission-timings/timings",
                "/admission-timings/today", "/admission-timings/view").contains(path)) {
            return "3".equals(role) || "4".equals(role);
        }
        Matcher schedule = Pattern.compile("^/admission-timings/([A-Za-z0-9_-]+)/([^/]+)$").matcher(path);
        if (!schedule.matches() || !Set.of("GET", "PUT", "DELETE")
                .contains(request.getMethod().toUpperCase())) return false;
        String itiCode = schedule.group(1);
        if ("4".equals(role)) return insCode.equalsIgnoreCase(itiCode);
        return "3".equals(role) && studentObjects.isItiInDistrict(itiCode, insCode);
    }

    private boolean authorizeItiMaster(HttpServletRequest request,
            String path, String role, String insCode) {
        if (!"GET".equalsIgnoreCase(request.getMethod()) || !hasScope(insCode)) return false;
        if ("/api/itis/by-district".equals(path)) {
            String district = request.getParameter("distCode");
            return "3".equals(role) && district != null && insCode.equalsIgnoreCase(district.trim());
        }
        Matcher iti = Pattern.compile("^/api/itis/([A-Za-z0-9_-]+)$").matcher(path);
        if (!iti.matches()) return false;
        if ("4".equals(role)) return insCode.equalsIgnoreCase(iti.group(1));
        return "3".equals(role) && studentObjects.isItiInDistrict(iti.group(1), insCode);
    }

    private boolean authorizeAdmissionLookup(Claims claims, HttpServletRequest request,
            String path, String role, String insCode) {
        if (!"GET".equalsIgnoreCase(request.getMethod())) return false;
        if ("/admission/call-letter".equals(path)) {
            String requestedDistrict = request.getParameter("distCode");
            String requestedIti = request.getParameter("itiCode");
            if ("3".equals(role)) {
                return hasScope(insCode) && requestedDistrict != null
                        && insCode.equalsIgnoreCase(requestedDistrict.trim());
            }
            if ("4".equals(role)) {
                return hasScope(insCode) && requestedIti != null
                        && insCode.equalsIgnoreCase(requestedIti.trim());
            }
            return false;
        }
        if ("/admission/call-letter/print".equals(path)) {
            if ("3".equals(role)) {
                String requestedDistrict = request.getParameter("distCode");
                return hasScope(insCode) && requestedDistrict != null
                        && insCode.equalsIgnoreCase(requestedDistrict.trim());
            }
            if ("4".equals(role)) {
                String requestedIti = request.getHeader("X-Iti-Code");
                return hasScope(insCode) && requestedIti != null
                        && insCode.equalsIgnoreCase(requestedIti.trim());
            }
            return false;
        }
        if ("/admission/search".equals(path)) {
            String requestedIti = request.getParameter("itiCode");
            return "4".equals(role) && hasScope(insCode) && requestedIti != null
                    && insCode.equalsIgnoreCase(requestedIti.trim());
        }
        if ("/admission/admission-update".equals(path)) {
            String requestedIti = request.getParameter("itiCode");
            return "4".equals(role) && hasScope(insCode) && requestedIti != null
                    && insCode.equalsIgnoreCase(requestedIti.trim());
        }
        if ("/admission/discharge-admission".equals(path)) {
            String admissionNumber = request.getParameter("admissionNumber");
            String year = request.getParameter("year");
            String district = request.getParameter("distCode");
            return "3".equals(role) && hasScope(insCode) && district != null
                    && insCode.equalsIgnoreCase(district.trim())
                    && studentObjects.canReadAdmissionInDistrict(admissionNumber, year, insCode);
        }
        if ("/admission/application-reprint".equals(path)) {
            String regid = request.getParameter("registrationId");
            if (regid == null || !regid.matches("\\d{1,10}")) return false;
            try {
                Integer id = Integer.valueOf(regid);
                String district = request.getParameter("distCode");
                String itiCode = request.getParameter("itiCode");
                if ("3".equals(role)) {
                    return hasScope(insCode) && district != null
                            && insCode.equalsIgnoreCase(district.trim())
                            && studentObjects.canReadInDistrict(id, insCode);
                }
                if ("4".equals(role)) {
                    return hasScope(insCode) && itiCode != null
                            && insCode.equalsIgnoreCase(itiCode.trim())
                            && studentObjects.canReadInIti(id, insCode);
                }
                return false;
            } catch (NumberFormatException ex) {
                return false;
            }
        }
        Matcher candidate = Pattern.compile("^/admission/candidate/(\\d+)$").matcher(path);
        if (candidate.matches()) return canReadRegid(candidate.group(1), claims);
        Matcher selected = Pattern.compile("^/admission/candidate-selected-trade/(\\d+)$").matcher(path);
        if (selected.matches()) return canReadRegid(selected.group(1), claims);

        Matcher districtItis = Pattern.compile("^/admission/district/([A-Za-z0-9_-]+)/itis$").matcher(path);
        if (districtItis.matches()) {
            return "3".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(districtItis.group(1));
        }
        Matcher districtNames = Pattern.compile("^/admission/itis/([A-Za-z0-9_-]+)$").matcher(path);
        if (districtNames.matches()) {
            return "3".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(districtNames.group(1));
        }
        Matcher itiSeats = Pattern.compile("^/admission/iti/([A-Za-z0-9_-]+)/seat-details$").matcher(path);
        if (itiSeats.matches()) {
            return "4".equals(role) && hasScope(insCode)
                    && insCode.equalsIgnoreCase(itiSeats.group(1));
        }
        if ("/admission/dsc-list".equals(path)) {
            String requestedIti = request.getParameter("itiCode");
            return "4".equals(role) && hasScope(insCode) && requestedIti != null
                    && insCode.equalsIgnoreCase(requestedIti.trim());
        }
        if ("/admission/schedule-entry".equals(path)) {
            return ("3".equals(role) || "4".equals(role)) && hasScope(insCode);
        }
        if ("/admission/trade".equals(path) || path.matches("^/admission/trade/[A-Za-z0-9_-]+/details$")) {
            return true; // public trade reference data
        }
        return false;
    }

    private boolean canReadRegid(String rawRegid, Claims claims) {
        try {
            return rawRegid != null && rawRegid.matches("\\d+")
                    && studentObjects.canRead(Integer.valueOf(rawRegid), claims);
        } catch (NumberFormatException ex) {
            return false;
        }
    }

    private static boolean districtScopedReport(String path) {
        return Set.of(
                "/api/reports/iti-wise-status",
                "/api/reports/applicant-report-by-phase",
                "/api/reports/dsc-full",
                "/api/reports/dsc-options",
                "/api/reports/caste-wise-admissions",
                "/api/reports/applicant-count-district-wise",
                "/api/reports/applicant-mobile-address",
                "/api/reports/api-dashboard",
                "/api/reports/verified-application-count",
                "/api/reports/trade-wise-report",
                "/api/reports/applicant-report-state-wise",
                "/api/reports/district-schedule",
                "/api/reports/permitted-shift-unit",
                "/api/reports/iti-admissions",
                "/api/reports/strength-filled-seats",
                "/api/reports/trade-vacant-positions",
                "/api/reports/trade-display/itis").contains(path);
    }

    private static boolean itiScopedReport(String path) {
        return Set.of(
                "/api/reports/iti-wise-status",
                "/api/reports/applicant-report-by-phase",
                "/api/reports/dsc-full",
                "/api/reports/dsc-options",
                "/api/reports/permitted-shift-unit").contains(path);
    }

    private static HttpServletRequest withTrustedIdentityHeaders(HttpServletRequest request, Claims claims) {
        String role = claim(claims, "roleId");
        String insCode = claim(claims, "insCode");
        String itiCode = "4".equals(role) ? insCode : null;
        String distCode = "3".equals(role) ? insCode : null;

        return new HttpServletRequestWrapper(request) {
            @Override
            public String getHeader(String name) {
                if (name == null) return null;
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

            @Override
            public String getParameter(String name) {
                if ("3".equals(role) && isDistrictParameter(name)) return insCode;
                if ("4".equals(role) && isItiParameter(name)) return insCode;
                return super.getParameter(name);
            }

            @Override
            public String[] getParameterValues(String name) {
                String scoped = getParameter(name);
                if (scoped != null && !scoped.equals(super.getParameter(name))) {
                    return new String[] { scoped };
                }
                return super.getParameterValues(name);
            }

            @Override
            public Map<String, String[]> getParameterMap() {
                Map<String, String[]> parameters = new HashMap<>(super.getParameterMap());
                if ("3".equals(role)) {
                    for (String name : new String[] { "distCode", "dist_code", "districtCode", "dist" }) {
                        parameters.put(name, new String[] { insCode });
                    }
                } else if ("4".equals(role)) {
                    for (String name : new String[] { "itiCode", "iti_code" }) {
                        parameters.put(name, new String[] { insCode });
                    }
                }
                return Collections.unmodifiableMap(parameters);
            }
        };
    }

    private static boolean isDistrictParameter(String name) {
        return "distCode".equals(name) || "dist_code".equals(name)
                || "districtCode".equals(name) || "dist".equals(name);
    }

    private static boolean isItiParameter(String name) {
        return "itiCode".equals(name) || "iti_code".equals(name);
    }

    private static boolean hasScope(String value) {
        return value != null && !value.isBlank();
    }

    private static String claim(Claims claims, String name) {
        Object value = claims.get(name);
        return value == null ? null : String.valueOf(value);
    }
}
