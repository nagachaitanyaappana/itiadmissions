package com.server.backend.controller.Admission;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.server.backend.DTO.ReservationEntryRequest;
import com.server.backend.DTO.ReservationEntryResponse;
import com.server.backend.DTO.ReservationTradeDto;
import com.server.backend.DTO.SeatCorrectionRequest;
import com.server.backend.service.Admission.ReservationEntryService;
import com.server.backend.config.JwtAuthenticationFilter;
import com.server.backend.service.Student.StudentObjectAuthorizationService;
import io.jsonwebtoken.Claims;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.Map;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@Tag(name = "Reservation Entry")
@RestController
@RequestMapping("/admission/reservation-entry")
public class ReservationEntryController {

    private final ReservationEntryService service;
    private final StudentObjectAuthorizationService objectAuthorization;

    public ReservationEntryController(ReservationEntryService service,
            StudentObjectAuthorizationService objectAuthorization) {
        this.service = service;
        this.objectAuthorization = objectAuthorization;
    }

    @GetMapping
    public ReservationEntryResponse getReservation(
            @RequestParam String itiCode,
            @RequestParam Integer tradeCode,
            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return service.getReservation(itiCode, tradeCode);
    }

    @GetMapping("/trades")
    public List<ReservationTradeDto> getTrades(@RequestParam String itiCode, HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return service.getTradesForIti(itiCode);
    }

    /** Only approved trades — what Reservation Entry may edit. */
    @GetMapping("/approved-trades")
    public List<ReservationTradeDto> getApprovedTrades(@RequestParam String itiCode, HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return service.getApprovedTradesForIti(itiCode);
    }

    /** Whether Reservation Entry is open for this ITI (approved trade + shift units present). */
    @GetMapping("/readiness")
    public Map<String, Object> getReadiness(@RequestParam String itiCode, HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return service.getReadiness(itiCode);
    }

    @PutMapping
    public ReservationEntryResponse saveReservation(
            @Valid @RequestBody ReservationEntryRequest requestBody,
            HttpServletRequest request) {
        requireItiScope(request, requestBody.getItiCode());
        return service.saveReservation(requestBody);
    }

    /** Seat Correction: same screen plus the admitted count; "Already Fill" is operator-editable. */
    @GetMapping("/seat-correction")
    public ReservationEntryResponse getSeatCorrection(
            @RequestParam String itiCode,
            @RequestParam Integer tradeCode,
            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return service.getSeatCorrection(itiCode, tradeCode);
    }

    private void requireItiScope(HttpServletRequest request, String itiCode) {
        Object value = request.getAttribute(JwtAuthenticationFilter.CLAIMS_ATTRIBUTE);
        if (!(value instanceof Claims claims) || itiCode == null || itiCode.isBlank()) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "A verified official session is required");
        }
        String role = String.valueOf(claims.get("roleId"));
        String scope = String.valueOf(claims.get("insCode"));
        boolean allowed = ("2".equals(role) || "10".equals(role))
                || ("4".equals(role) && scope.equalsIgnoreCase(itiCode.trim()))
                || ("3".equals(role) && objectAuthorization.isItiInDistrict(itiCode, scope));
        if (!allowed) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "ITI is outside your authorized scope");
        }
    }

    @PutMapping("/seat-correction")
    public ReservationEntryResponse saveSeatCorrection(
            @Valid @RequestBody SeatCorrectionRequest requestBody,
            HttpServletRequest request) {
        requireItiScope(request, requestBody.getItiCode());
        return service.saveSeatCorrection(requestBody);
    }
}
