package com.server.backend.controller.MeritChecklist;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.server.backend.DTO.CurrentUser;
import com.server.backend.DTO.CreateEntryRequest;
import com.server.backend.DTO.UpdateTimingsRequest;
import com.server.backend.DTO.ViewScheduleRequest;
import com.server.backend.entity.AdmissionTiming;
import com.server.backend.service.MeritChecklist.AdmissionTimingService;
import com.server.backend.config.JwtAuthenticationFilter;
import com.server.backend.service.Student.StudentObjectAuthorizationService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.server.ResponseStatusException;
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Operation;
import jakarta.validation.Valid;
@Tag(name = "admission-timings", description = "Admission timing schedule management")
@RestController
@RequestMapping("/admission-timings")
public class AdmissionTimingController {
    private final AdmissionTimingService admissionTimingService;
    private final StudentObjectAuthorizationService objectAuthorization;
    public AdmissionTimingController(AdmissionTimingService admissionTimingService,
            StudentObjectAuthorizationService objectAuthorization) {
        this.admissionTimingService = admissionTimingService;
        this.objectAuthorization = objectAuthorization;
    }
   @Operation(summary = "Create a new admission timing schedule entry")
    @PostMapping
public AdmissionTiming createAdmissionTiming(@RequestBody AdmissionTiming admissionTiming,
            HttpServletRequest request) {
    requireAdmin(request);
    return admissionTimingService.createAdmissionTiming(admissionTiming);
    }
   @Operation(summary = "Retrieve all admission timing schedules")
    @GetMapping
    public List<AdmissionTiming> getAllAdmissionTimings(HttpServletRequest request) {
        requireAdmin(request);
        return admissionTimingService.getAllAdmissionTimings();
    }
    @Operation(summary = "Retrieve a specific admission timing schedule by ITI code and phase")
    @GetMapping("/{itiCode}/{phase}")
    public AdmissionTiming getById(@PathVariable String itiCode, @PathVariable String phase,
            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return admissionTimingService.getById(itiCode, phase);
    }
    @Operation(summary = "Delete an admission timing schedule by ITI code and phase")
    @DeleteMapping("/{itiCode}/{phase}")
    public String delete(@PathVariable String itiCode, @PathVariable String phase,
            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        admissionTimingService.delete(itiCode, phase);
        return "Schedule Entry Deleted Successfully";
    }
    @Operation(summary = "Update an admission timing schedule by ITI code and phase")
    @PutMapping("/{itiCode}/{phase}")
    public AdmissionTiming updateAdmissionTiming(@PathVariable String itiCode, @PathVariable String phase,
            @RequestBody AdmissionTiming updatedAdmissionTiming, HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return admissionTimingService.updateAdmissionTiming(itiCode, phase, updatedAdmissionTiming);
    }
    // 2. These three endpoints resolve the caller from request headers, the same convention
    //    MeritListController uses. They previously hardcoded ("ITI001", "24", "12345", "3"),
    //    so every schedule row was attributed to one fixed ITI regardless of who was logged in.
    @Operation(summary = "Create a new schedule entry")
    @PostMapping("/entry")
    public ResponseEntity<Map<String, Object>> createScheduleEntry(
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestBody CreateEntryRequest req,
            HttpServletRequest request) {
        CurrentUser user = currentUser(request);
        Map<String, Object> result = admissionTimingService.createScheduleEntry(req, user);
        return new ResponseEntity<>(result, HttpStatus.CREATED);
    }

    @Operation(summary = "Add schedule timings")
    @PutMapping("/timings")
    public ResponseEntity<Map<String, Object>> addScheduleTimings(
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @Valid @RequestBody UpdateTimingsRequest req,
            HttpServletRequest request) {
        CurrentUser user = currentUser(request);
        Map<String, Object> result = admissionTimingService.addScheduleTimings(req, user);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @Operation(summary = "Whether a counselling session is scheduled for today")
    @GetMapping("/today")
    public ResponseEntity<Map<String, Object>> scheduleToday(
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            HttpServletRequest request) {
        CurrentUser user = currentUser(request);
        Map<String, Object> result = admissionTimingService.hasScheduleToday(user);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @Operation(summary = "View schedule timings")
    @PostMapping("/view")
    public ResponseEntity<Map<String, Object>> viewScheduleTimings(
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestBody ViewScheduleRequest req,
            HttpServletRequest request) {
        CurrentUser user = currentUser(request);
        Map<String, Object> result = admissionTimingService.viewScheduleTimings(req, user);
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    // ---------------------------------------------------------------------------
    // Delete-Schedule-Entry page. These are not header-scoped: the page is an admin search across
    // any district/ITI, so the filters arrive in the request. The old page called nonexistent
    // /itiapi/* URLs, which is why every dropdown and the delete button failed.
    // ---------------------------------------------------------------------------

    @Operation(summary = "Districts for the delete-schedule page (optional govt filter)")
    @GetMapping("/districts")
    public List<Map<String, Object>> deleteDistricts(
            @RequestParam(name = "govt", required = false) String govt,
            HttpServletRequest request) {
        requireAdmin(request);
        return admissionTimingService.listDistrictsForDelete(govt);
    }

    @Operation(summary = "ITIs of a district for the delete-schedule page (optional govt filter)")
    @GetMapping("/itis")
    public List<Map<String, Object>> deleteItis(
            @RequestParam(name = "distCode") String distCode,
            @RequestParam(name = "govt", required = false) String govt,
            HttpServletRequest request) {
        requireAdmin(request);
        return admissionTimingService.listItisForDelete(distCode, govt);
    }

    @Operation(summary = "Search schedule entries for the delete-schedule page")
    @PostMapping("/search")
    public ResponseEntity<Map<String, Object>> deleteSearch(@RequestBody Map<String, String> req,
            HttpServletRequest request) {
        requireAdmin(request);
        Map<String, Object> result = admissionTimingService.searchScheduleForDelete(
                req.get("distCode"), req.get("itiCode"), req.get("itiType"));
        return new ResponseEntity<>(result, HttpStatus.OK);
    }

    @Operation(summary = "Delete a schedule entry by its id")
    @PostMapping("/delete-by-id")
    public ResponseEntity<Map<String, Object>> deleteById(@RequestBody Map<String, Object> req,
            HttpServletRequest request) {
        requireAdmin(request);
        Object raw = req.get("sid");
        String sid = raw == null || String.valueOf(raw).isBlank() ? null : String.valueOf(raw).trim();
        if (sid == null) {
            Map<String, Object> bad = new HashMap<>();
            bad.put("success", false);
            bad.put("error", "Missing schedule id");
            return new ResponseEntity<>(bad, HttpStatus.BAD_REQUEST);
        }
        return new ResponseEntity<>(admissionTimingService.deleteScheduleById(sid), HttpStatus.OK);
    }

    /**
     * Builds the calling user from request headers. Fails loudly when no institution code is
     * present, instead of silently writing a schedule against a placeholder ITI.
     *
     * <p>{@code login_users.ins_code} is a single column holding either a district code or an ITI
     * code depending on the role, and the page sends it once as {@code X-Ins-Code} via
     * {@code scopeHeaders()}. The role therefore decides which field it belongs in. The explicit
     * {@code X-Iti-Code} / {@code X-Dist-Code} headers still win when supplied, matching
     * {@code MeritListController.resolveUser}.
     *
     * <p>Previously this passed {@code insCode} through without placing it in either field, so the
     * schedule row was saved with {@code iti_code} and {@code dist_code} both null and Step 2 could
     * never find the placeholder it had just created.
     */
    private CurrentUser currentUser(HttpServletRequest request) {
        Claims claims = verifiedClaims(request);
        String role = String.valueOf(claims.get("roleId"));
        String scope = claims.get("insCode") == null ? "" : String.valueOf(claims.get("insCode")).trim();
        if (scope.isBlank() || (!"3".equals(role) && !"4".equals(role))) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "District or ITI schedule access is required");
        }
        return "3".equals(role)
                ? new CurrentUser(null, scope, scope, role)
                : new CurrentUser(scope, null, scope, role);
    }

    private void requireItiScope(HttpServletRequest request, String itiCode) {
        Claims claims = verifiedClaims(request);
        String role = String.valueOf(claims.get("roleId"));
        String scope = claims.get("insCode") == null ? "" : String.valueOf(claims.get("insCode")).trim();
        boolean allowed = ("2".equals(role) || "10".equals(role))
                || ("4".equals(role) && !scope.isBlank() && scope.equalsIgnoreCase(itiCode))
                || ("3".equals(role) && !scope.isBlank()
                        && objectAuthorization.isItiInDistrict(itiCode, scope));
        if (!allowed) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Schedule is outside your authorized scope");
        }
    }

    private static void requireAdmin(HttpServletRequest request) {
        Claims claims = verifiedClaims(request);
        String role = String.valueOf(claims.get("roleId"));
        if (!"2".equals(role) && !"10".equals(role)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "State or nodal administrator access is required");
        }
    }

    private static Claims verifiedClaims(HttpServletRequest request) {
        Object value = request.getAttribute(JwtAuthenticationFilter.CLAIMS_ATTRIBUTE);
        if (!(value instanceof Claims claims)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "A verified official session is required");
        }
        return claims;
    }

    private static boolean isBlank(String value) {
        return value == null || value.isBlank();
    }

// 3. Add an Exception Handler to catch scheduling/overlap validation errors and send them to the frontend
@ExceptionHandler(ResponseStatusException.class)
public ResponseEntity<Map<String, Object>> handleAuthorizationError(ResponseStatusException ex) {
    Map<String, Object> response = new HashMap<>();
    response.put("success", false);
    response.put("error", ex.getReason());
    return new ResponseEntity<>(response, ex.getStatusCode());
}

@ExceptionHandler({IllegalArgumentException.class, RuntimeException.class})
public ResponseEntity<Map<String, Object>> handleSchedulingErrors(Exception ex) {
    Map<String, Object> response = new HashMap<>();
    response.put("success", false);
    response.put("error", ex.getMessage());
    return new ResponseEntity<>(response, HttpStatus.BAD_REQUEST);
}

}
