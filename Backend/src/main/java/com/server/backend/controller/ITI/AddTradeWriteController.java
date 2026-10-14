package com.server.backend.controller.ITI;

import java.util.Map;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.server.backend.DTO.AddTradePageResponse;
import com.server.backend.DTO.AddTradeRequest;
import com.server.backend.DTO.EditTradePageResponse;
import com.server.backend.DTO.EditTradeUpdateRequest;
import com.server.backend.service.ITI.AddTradeService;

import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;

@Tag(name = "Add Trade")
@RestController
@RequestMapping("/admission/add-trade")
public class AddTradeWriteController {

    private final AddTradeService service;

    public AddTradeWriteController(AddTradeService service) {
        this.service = service;
    }

    @GetMapping("/{itiCode}")
    public AddTradePageResponse getPage(@PathVariable String itiCode) {
        return service.getPage(itiCode);
    }

    @PostMapping("/{itiCode}/trade")
    public ResponseEntity<Object> addTrade(@PathVariable String itiCode,
            @Valid @RequestBody AddTradeRequest request) {
        try {
            return ResponseEntity.ok(service.addTrade(itiCode, request));
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", ex.getMessage()));
        }
    }

    @PutMapping("/{itiCode}/approve-all")
    public ResponseEntity<Map<String, Object>> approveAll(@PathVariable String itiCode) {
        try {
            int updated = service.approveAll(itiCode);
            return ResponseEntity.ok(Map.of(
                    "success", true,
                    "updated", updated,
                    "message", "Approved " + updated + " trade(s) for ITI " + itiCode));
        } catch (IllegalStateException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", ex.getMessage()));
        }
    }

    /** Edit Trade page: selected trade's editable attributes + permitted shift/unit rows. */
    @GetMapping("/{itiCode}/trade/{tradeCode}")
    public ResponseEntity<Object> getTrade(@PathVariable String itiCode,
                                           @PathVariable Integer tradeCode) {
        try {
            return ResponseEntity.ok(service.getTradeForEdit(itiCode, tradeCode));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", ex.getMessage()));
        }
    }

    /** Save edited strength / availability (+ any shift/unit availability toggles). */
    @PutMapping("/{itiCode}/trade/{tradeCode}")
    public ResponseEntity<Object> updateTrade(@PathVariable String itiCode,
                                              @PathVariable Integer tradeCode,
                                              @RequestBody EditTradeUpdateRequest request) {
        try {
            return ResponseEntity.ok(service.updateTrade(itiCode, tradeCode, request));
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.badRequest().body(Map.of(
                    "success", false,
                    "message", ex.getMessage()));
        }
    }

    /** Freeze ({@code freeze=true}) or unfreeze every trade of the ITI. */
    @PostMapping("/{itiCode}/freeze-trades")
    public Map<String, Object> freezeTrades(@PathVariable String itiCode,
                                            @RequestParam(name = "freeze", defaultValue = "true") boolean freeze) {
        int updated = service.setTradeFreeze(itiCode, freeze);
        return Map.of("success", true, "updated", updated,
                "message", updated + " trade(s) " + (freeze ? "frozen" : "unfrozen") + " for ITI " + itiCode);
    }
}
