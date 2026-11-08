package com.server.backend.controller.Admission;

import com.server.backend.config.JwtAuthenticationFilter;
import com.server.backend.service.Admission.DistrictVerifyService;
import io.jsonwebtoken.Claims;
import io.swagger.v3.oas.annotations.tags.Tag;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import jakarta.servlet.http.HttpServletRequest;
import java.util.List;
import java.util.Map;

@Tag(name = "District Verification")
@RestController
@RequestMapping("/api/dv")
public class DistrictVerifyController {

    private final DistrictVerifyService service;

    public DistrictVerifyController(DistrictVerifyService service) {
        this.service = service;
    }

    @GetMapping("/window-status")
    public Map<String, Object> windowStatus() {
        return service.windowStatus();
    }

    @GetMapping("/lookup")
    public Map<String, Object> lookup(@RequestParam String regid,
                                      @RequestParam(required = false) String distCode,
                                      @RequestParam(required = false) String itiCode,
                                      HttpServletRequest request) {
        Claims principal = claims(request);
        if (principal != null) {
            String role = role(principal);
            String scope = scope(principal);
            if ("3".equals(role)) return service.lookup(regid, scope);
            if ("4".equals(role)) return service.lookupForIti(regid, scope);
            throw forbidden();
        }
        // Compatibility for the existing Frontend server-side verification
        // controller while its internal calls are migrated to forward JWTs.
        return itiCode == null || itiCode.isBlank()
                ? service.lookup(regid, distCode)
                : service.lookupForIti(regid, itiCode);
    }

    @GetMapping("/list")
    public List<Map<String, Object>> list(@RequestParam(required = false) String distCode,
                                          HttpServletRequest request) {
        Claims principal = claims(request);
        if (principal != null) {
            if (!"3".equals(role(principal))) throw forbidden();
            return service.list(scope(principal));
        }
        return service.list(distCode);
    }

    @PostMapping("/approve")
    public Map<String, Object> approve(@RequestBody Map<String, Object> body,
                                       HttpServletRequest request) {
        Claims principal = claims(request);
        if (principal != null && !"3".equals(role(principal))) throw forbidden();
        String distCode = principal == null ? (String) body.get("distCode") : scope(principal);
        String username = principal == null ? (String) body.get("username") : principal.getSubject();
        return service.approve(
                (String) body.get("regid"),
                distCode,
                username,
                request.getRemoteAddr(),
                (Map<String, String>) body.get("documents"));
    }

    @PostMapping("/approve-iti")
    public Map<String, Object> approveIti(@RequestBody Map<String, Object> body,
                                          HttpServletRequest request) {
        Claims principal = claims(request);
        if (principal != null && !"4".equals(role(principal))) throw forbidden();
        String itiCode = principal == null ? (String) body.get("itiCode") : scope(principal);
        String username = principal == null ? (String) body.get("username") : principal.getSubject();
        return service.approveForIti(
                (String) body.get("regid"),
                itiCode,
                username,
                request.getRemoteAddr(),
                (Map<String, String>) body.get("documents"));
    }

    @PostMapping("/reject")
    public Map<String, Object> reject(@RequestBody Map<String, String> body,
                                      HttpServletRequest request) {
        Claims principal = claims(request);
        if (principal != null && !"3".equals(role(principal))) throw forbidden();
        String distCode = principal == null ? body.get("distCode") : scope(principal);
        String username = principal == null ? body.get("username") : principal.getSubject();
        return service.reject(body.get("regid"), distCode, username,
                body.get("reason"), request.getRemoteAddr());
    }

    @PostMapping("/reject-iti")
    public Map<String, Object> rejectIti(@RequestBody Map<String, String> body,
                                         HttpServletRequest request) {
        Claims principal = claims(request);
        if (principal != null && !"4".equals(role(principal))) throw forbidden();
        String itiCode = principal == null ? body.get("itiCode") : scope(principal);
        String username = principal == null ? body.get("username") : principal.getSubject();
        return service.rejectForIti(body.get("regid"), itiCode, username,
                body.get("reason"), request.getRemoteAddr());
    }

    private static Claims claims(HttpServletRequest request) {
        Object value = request.getAttribute(JwtAuthenticationFilter.CLAIMS_ATTRIBUTE);
        return value instanceof Claims claims ? claims : null;
    }

    private static String role(Claims claims) {
        Object value = claims.get("roleId");
        return value == null ? null : String.valueOf(value);
    }

    private static String scope(Claims claims) {
        Object value = claims.get("insCode");
        String scope = value == null ? null : String.valueOf(value).trim();
        if (scope == null || scope.isBlank()) throw forbidden();
        return scope;
    }

    private static ResponseStatusException forbidden() {
        return new ResponseStatusException(HttpStatus.FORBIDDEN,
                "The authenticated official is not authorized for this district or ITI operation");
    }
}
