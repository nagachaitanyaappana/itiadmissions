package com.server.backend.controller.ITI;

import java.util.Map;

import com.server.backend.config.JwtAuthenticationFilter;
import com.server.backend.DTO.AddTradePageResponse;
import com.server.backend.DTO.AddTradeRequest;
import com.server.backend.DTO.EditTradeUpdateRequest;
import com.server.backend.service.ITI.AddTradeService;
import io.jsonwebtoken.Claims;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@Tag(name = "Add Trade")
@RestController
@RequestMapping("/admission/add-trade")
public class AddTradeWriteController {

    private final AddTradeService service;

    public AddTradeWriteController(AddTradeService service) {
        this.service = service;
    }

    @GetMapping("/{itiCode}")
    public AddTradePageResponse getPage(@PathVariable String itiCode, HttpServletRequest request) {
        requireItiScope(request, itiCode);
        return service.getPage(itiCode);
    }

    @PostMapping("/{itiCode}/trade")
    public ResponseEntity<Object> addTrade(@PathVariable String itiCode,
            @Valid @RequestBody AddTradeRequest body, HttpServletRequest request) {
        requireItiScope(request, itiCode);
        try {
            return ResponseEntity.ok(service.addTrade(itiCode, body));
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", ex.getMessage()));
        }
    }

    @PutMapping("/{itiCode}/approve-all")
    public ResponseEntity<Map<String, Object>> approveAll(@PathVariable String itiCode,
                                                            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        try {
            int updated = service.approveAll(itiCode);
            return ResponseEntity.ok(Map.of("success", true, "updated", updated,
                    "message", "Approved " + updated + " trade(s) for ITI " + itiCode));
        } catch (IllegalStateException ex) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", ex.getMessage()));
        }
    }

    @GetMapping("/{itiCode}/trade/{tradeCode}")
    public ResponseEntity<Object> getTrade(@PathVariable String itiCode,
                                           @PathVariable Integer tradeCode,
                                           HttpServletRequest request) {
        requireItiScope(request, itiCode);
        try {
            return ResponseEntity.ok(service.getTradeForEdit(itiCode, tradeCode));
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", ex.getMessage()));
        }
    }

    @PutMapping("/{itiCode}/trade/{tradeCode}")
    public ResponseEntity<Object> updateTrade(@PathVariable String itiCode,
                                              @PathVariable Integer tradeCode,
                                              @RequestBody EditTradeUpdateRequest body,
                                              HttpServletRequest request) {
        requireItiScope(request, itiCode);
        try {
            return ResponseEntity.ok(service.updateTrade(itiCode, tradeCode, body));
        } catch (IllegalArgumentException | IllegalStateException ex) {
            return ResponseEntity.badRequest().body(Map.of("success", false, "message", ex.getMessage()));
        }
    }

    @PostMapping("/{itiCode}/freeze-trades")
    public Map<String, Object> freezeTrades(@PathVariable String itiCode,
                                            @RequestParam(name = "freeze", defaultValue = "true") boolean freeze,
                                            HttpServletRequest request) {
        requireItiScope(request, itiCode);
        int updated = service.setTradeFreeze(itiCode, freeze);
        return Map.of("success", true, "updated", updated,
                "message", updated + " trade(s) " + (freeze ? "frozen" : "unfrozen") + " for ITI " + itiCode);
    }

    private static void requireItiScope(HttpServletRequest request, String itiCode) {
        Object value = request.getAttribute(JwtAuthenticationFilter.CLAIMS_ATTRIBUTE);
        if (!(value instanceof Claims claims)) return; // trusted Frontend server-side compatibility
        String role = String.valueOf(claims.get("roleId"));
        String scope = claims.get("insCode") == null ? "" : String.valueOf(claims.get("insCode"));
        if (!"4".equals(role) || itiCode == null || !itiCode.trim().equalsIgnoreCase(scope.trim())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN,
                    "An ITI official may only manage the ITI assigned to their account");
        }
    }
}
