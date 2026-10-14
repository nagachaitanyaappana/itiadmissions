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
import com.server.backend.service.Admission.ReservationEntryService;

import java.util.List;
import java.util.Map;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@Tag(name = "Reservation Entry")
@RestController
@RequestMapping("/admission/reservation-entry")
public class ReservationEntryController {

    private final ReservationEntryService service;

    public ReservationEntryController(ReservationEntryService service) {
        this.service = service;
    }

    @GetMapping
    public ReservationEntryResponse getReservation(
            @RequestParam String itiCode,
            @RequestParam Integer tradeCode) {
        return service.getReservation(itiCode, tradeCode);
    }

    @GetMapping("/trades")
    public List<ReservationTradeDto> getTrades(@RequestParam String itiCode) {
        return service.getTradesForIti(itiCode);
    }

    /** Only approved trades — what Reservation Entry may edit. */
    @GetMapping("/approved-trades")
    public List<ReservationTradeDto> getApprovedTrades(@RequestParam String itiCode) {
        return service.getApprovedTradesForIti(itiCode);
    }

    /** Whether Reservation Entry is open for this ITI (approved trade + shift units present). */
    @GetMapping("/readiness")
    public Map<String, Object> getReadiness(@RequestParam String itiCode) {
        return service.getReadiness(itiCode);
    }

    @PutMapping
    public ReservationEntryResponse saveReservation(
            @Valid @RequestBody ReservationEntryRequest request) {
        return service.saveReservation(request);
    }
}
