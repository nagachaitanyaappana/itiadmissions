package com.server.backend.controller.Reports;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.server.backend.DTO.ShiftUnitVerifyRowResponse;
import com.server.backend.service.Reports.ShiftUnitVerifyService;

import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;

/**
 * Shift / Unit verification endpoints, ported from {@code shift_unit_verify.jsp}
 * and {@code update_shift_unit.jsp}.
 */
@Tag(name = "Shift Unit Verification")
@RestController
@RequestMapping("/api/reports/shift-unit-verify")
public class ShiftUnitVerifyController {

    private final ShiftUnitVerifyService service;

    public ShiftUnitVerifyController(ShiftUnitVerifyService service) {
        this.service = service;
    }

    @Operation(summary = "ITIs of a district (picker options)")
    @GetMapping("/itis")
    public Map<String, Object> itis(@RequestParam String distCode) {
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("success", true);
        out.put("data", service.getItis(distCode));
        return out;
    }

    @Operation(summary = "Admissions pending shift/unit verification (rec_status='E')")
    @GetMapping
    public Map<String, Object> pending(@RequestParam String distCode,
                                       @RequestParam String itiCode,
                                       @RequestParam(required = false) String year) {
        List<ShiftUnitVerifyRowResponse> rows = service.getPending(distCode, itiCode, year);
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("success", true);
        out.put("count", rows.size());
        out.put("data", rows);
        return out;
    }

    @Operation(summary = "Verify one admission's shift/unit")
    @PostMapping
    public ResponseEntity<Object> verify(@RequestBody Map<String, Object> body) {
        String admNum = text(body.get("admNum"));
        String shift = text(body.get("shift"));
        String unit = text(body.get("unit"));
        try {
            int updated = service.verify(admNum, shift, unit);
            if (updated > 0) {
                return ResponseEntity.ok(Map.of("success", true,
                        "message", "Admission " + admNum + " verified."));
            }
            return ResponseEntity.status(404).body(Map.of(
                    "success", false, "message", "Admission number not found: " + admNum));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false, "message", ex.getMessage()));
        }
    }

    private static String text(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
