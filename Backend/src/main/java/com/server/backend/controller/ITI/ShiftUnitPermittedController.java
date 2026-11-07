package com.server.backend.controller.ITI;

import com.server.backend.config.JwtAuthenticationFilter;
import com.server.backend.DTO.ShiftUnitPermittedRequestDto;
import com.server.backend.DTO.ShiftUnitPermittedResponseDto;
import com.server.backend.service.ITI.DGTPermittedShiftsUnits;
import io.jsonwebtoken.Claims;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@Tag(name = "ITI")
@RestController
@RequestMapping("/api/shift-unit-permitted")
public class ShiftUnitPermittedController {

    private final DGTPermittedShiftsUnits service;

    public ShiftUnitPermittedController(DGTPermittedShiftsUnits service) {
        this.service = service;
    }

    @PutMapping
    public ResponseEntity<ShiftUnitPermittedResponseDto> save(
            @Valid @RequestBody ShiftUnitPermittedRequestDto dto,
            HttpServletRequest request) {
        requireItiScope(request, dto.getItiCode());
        return ResponseEntity.ok(service.save(dto));
    }

    @GetMapping
    public ResponseEntity<ShiftUnitPermittedResponseDto> getByItiAndTrade(
            @RequestParam String itiCode,
            @RequestParam String tradeCode,
            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return ResponseEntity.ok(service.getByItiAndTrade(itiCode, tradeCode));
    }

    @DeleteMapping
    public ResponseEntity<String> delete(
            @RequestParam String itiCode,
            @RequestParam String tradeCode,
            @RequestParam Integer shiftAllowed,
            @RequestParam Integer unitAllowed,
            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        service.delete(itiCode, tradeCode, shiftAllowed, unitAllowed);
        return ResponseEntity.ok("Record deleted successfully");
    }

    private static void requireItiScope(HttpServletRequest request, String itiCode) {
        Object value = request.getAttribute(JwtAuthenticationFilter.CLAIMS_ATTRIBUTE);
        if (!(value instanceof Claims claims)) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "A verified official session is required");
        }
        String role = String.valueOf(claims.get("roleId"));
        String scope = claims.get("insCode") == null ? "" : String.valueOf(claims.get("insCode"));
        if ("2".equals(role) || "10".equals(role)) return;
        if (!"4".equals(role) || itiCode == null || !itiCode.trim().equalsIgnoreCase(scope.trim())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "An ITI official may only manage shift/unit permissions for their own ITI");
        }
    }
}
