package com.server.backend.controller.MeritChecklist;

import java.util.Map;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.server.backend.DTO.CouncilMeritsRequest;
import com.server.backend.DTO.ProcessOptimizeRequest;
import com.server.backend.DTO.RankLookupRequest;
import com.server.backend.DTO.TakeAdmissionRequest;
import com.server.backend.DTO.UserPrincipal;
import com.server.backend.service.MeritChecklist.AdmissionProcessService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * The endpoints {@code /AdmissionPhase} ("Admission Phase 1" in the navbar) builds and calls.
 *
 * <p>Before this controller existed the page called three paths that returned 404 and three that
 * landed on {@code POST /admission-timings} — the "create a schedule row" route — which answered 400
 * for every payload the page sent. The page hid all of it behind {@code console.error}, which is why
 * it still rendered as a 200 page with an empty grid.
 *
 * <p>Caller identity arrives as headers, the convention already used by {@code MeritListController}
 * and {@code AdmissionTimingController}: the JSP layer and this backend are separate applications, so
 * this side never sees the login session.
 */
@Tag(name = "Admission Process", description = "Admission Phase 1: boards, seat matrix, rank lookup, admission entry")
@RestController
@RequestMapping("/api/admission")
public class AdmissionProcessController {

    private final AdmissionProcessService admissionProcessService;

    public AdmissionProcessController(AdmissionProcessService admissionProcessService) {
        this.admissionProcessService = admissionProcessService;
    }

    @Operation(summary = "Type-of-admission (board) list for the approval dropdown")
    @GetMapping("/iti-boards")
    public ResponseEntity<Map<String, Object>> getItiBoards(
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> {
            resolveUser(roleId, insCode, itiCode, distCode);
            return admissionProcessService.getItiBoards();
        });
    }

    @Operation(summary = "Seat matrix (T/F/V per category) for the logged-in ITI or district")
    @PostMapping("/iti-seat-matrix")
    public ResponseEntity<Map<String, Object>> getSeatMatrix(
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> admissionProcessService.getSeatMatrix(
                resolveUser(roleId, insCode, itiCode, distCode)));
    }

    @Operation(summary = "Resolve a merit rank to the candidate holding it")
    @PostMapping("/rank-lookup")
    public ResponseEntity<Map<String, Object>> lookupRank(
            @RequestBody(required = false) RankLookupRequest request,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> admissionProcessService.lookupRank(
                request == null ? null : request.rank(),
                resolveUser(roleId, insCode, itiCode, distCode)));
    }

    @Operation(summary = "Record an admission for the candidate and fill the seat")
    @PostMapping("/take-admission")
    public ResponseEntity<Map<String, Object>> takeAdmission(
            @RequestBody(required = false) TakeAdmissionRequest request,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> admissionProcessService.takeAdmission(request,
                resolveUser(roleId, insCode, itiCode, distCode)));
    }

    @Operation(summary = "Permitted shift/unit options for an ITI and trade")
    @GetMapping("/shift-unit")
    public ResponseEntity<Map<String, Object>> getShiftUnits(
            @org.springframework.web.bind.annotation.RequestParam(name = "itiCode") String itiCode,
            @org.springframework.web.bind.annotation.RequestParam(name = "tradeCode") String tradeCode,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCodeHeader,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> {
            UserPrincipal user = resolveUser(roleId, insCode, itiCodeHeader, distCode);
            if ("4".equals(user.roleid())) {
                if (!user.itiCode().equalsIgnoreCase(itiCode)) {
                    throw new IllegalArgumentException("An ITI official may only view their own ITI shift/unit options.");
                }
            } else if (!admissionProcessService.isItiInDistrict(itiCode, user.distCode())) {
                throw new IllegalArgumentException("The selected ITI does not belong to your district.");
            }
            Map<String, Object> body = new java.util.LinkedHashMap<>();
            body.put("success", true);
            body.put("shifts", admissionProcessService.getShiftUnits(itiCode, tradeCode));
            return body;
        });
    }

    @Operation(summary = "Today's admission timings (cal_time) for the district/ITI dropdown")
    @GetMapping("/today-timings")
    public ResponseEntity<Map<String, Object>> todayTimings(
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> admissionProcessService.todayTimings(
                resolveUser(roleId, insCode, itiCode, distCode)));
    }

    @Operation(summary = "Current Phase 1 admission date-window status")
    @GetMapping("/window-status")
    public ResponseEntity<Map<String, Object>> admissionWindowStatus() {
        return ResponseEntity.ok(admissionProcessService.admissionWindowStatus());
    }

    @Operation(summary = "Start admission: validate rank generation and resolve the merit window")
    @PostMapping("/council-merits")
    public ResponseEntity<Map<String, Object>> councilMerits(
            @RequestBody(required = false) CouncilMeritsRequest request,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> admissionProcessService.councilMerits(
                request, resolveUser(roleId, insCode, itiCode, distCode)));
    }

    @Operation(summary = "Admission counseling: resolve rank and compute the seat-matrix check cascade")
    @PostMapping("/process-optimize")
    public ResponseEntity<Map<String, Object>> processOptimize(
            @RequestBody(required = false) ProcessOptimizeRequest request,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode,
            @RequestHeader(name = "X-Iti-Code", required = false) String itiCode,
            @RequestHeader(name = "X-Dist-Code", required = false) String distCode) {
        return handle(() -> admissionProcessService.processOptimize(
                request, resolveUser(roleId, insCode, itiCode, distCode)));
    }

    @Operation(summary = "Open general pool for a district (district login only)")
    @PostMapping("/general-pool/district")
    public ResponseEntity<Map<String, Object>> openDistrictGeneralPool(
            @RequestBody Map<String, String> body,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode) {
        return handle(() -> {
            if (!"3".equals(roleId)) {
                throw new IllegalArgumentException(
                        "General pool district activation requires district login");
            }
            if (insCode == null || insCode.isBlank()) {
                throw new IllegalArgumentException("X-Ins-Code (district code) is required");
            }
            return admissionProcessService.updateDistrictGeneralPool(insCode.trim(), body.get("caste"));
        });
    }

    @Operation(summary = "Open general pool for an ITI (ITI login only)")
    @PostMapping("/general-pool/iti")
    public ResponseEntity<Map<String, Object>> openItiGeneralPool(
            @RequestBody Map<String, String> body,
            @RequestHeader(name = "X-Role-Id", required = false) String roleId,
            @RequestHeader(name = "X-Ins-Code", required = false) String insCode) {
        return handle(() -> {
            if (!"4".equals(roleId)) {
                throw new IllegalArgumentException(
                        "General pool ITI activation requires ITI login");
            }
            if (insCode == null || insCode.isBlank()) {
                throw new IllegalArgumentException("X-Ins-Code (ITI code) is required");
            }
            return admissionProcessService.updateItiGeneralPool(insCode.trim(), body.get("caste"));
        });
    }

    /** Keeps every endpoint's error shape identical: {@code {success:false, error:"..."}} at 400. */
    private ResponseEntity<Map<String, Object>> handle(
            java.util.function.Supplier<Map<String, Object>> action) {
        try {
            return ResponseEntity.ok(action.get());
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("success", false, "error", ex.getMessage()));
        } catch (org.springframework.dao.DataIntegrityViolationException ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("success", false, "error", "Admission already processed for this candidate or duplicate record."));
        } catch (Exception ex) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("success", false, "error", ex.getMessage() != null ? ex.getMessage() : "Error processing admission request."));
        }
    }

    /**
     * Builds the caller from the request headers.
     *
     * <p>{@code login_users.ins_code} holds either a district code or an ITI code depending on the
     * role, so the page sends it once as {@code X-Ins-Code} and the role decides which field it
     * belongs to. Explicit {@code X-Iti-Code} / {@code X-Dist-Code} headers still win.
     */
    private UserPrincipal resolveUser(String roleId, String insCode, String itiCode, String distCode) {
        String role = (roleId == null || roleId.isBlank()) ? null : roleId.trim();
        String ins = (insCode == null || insCode.isBlank()) ? null : insCode.trim();

        // Admission Process is scoped to a district official or an ITI official.
        // The JWT filter supplies these headers from signed claims, never from
        // browser-controlled X-Role-Id / X-Ins-Code headers.
        if (!"3".equals(role) && !"4".equals(role)) {
            throw new IllegalArgumentException("Only district and ITI officials may use this admission operation.");
        }
        if (ins == null) {
            throw new IllegalArgumentException("The authenticated account has no district/ITI scope.");
        }
        return "3".equals(role)
                ? new UserPrincipal(role, null, ins)
                : new UserPrincipal(role, ins, null);
    }
}
