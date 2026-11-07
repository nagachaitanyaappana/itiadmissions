package com.server.frontend.controller.admission;

import com.server.frontend.security.BackendApiRequestSupport;
import jakarta.servlet.http.HttpServletRequest;

import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

/**
 * Reservation Entry (DISTLOGIN -&gt; Admissions). Port of the legacy
 * manageseats_interface.jsp -&gt; ManageSeats_InterfaceAction flow: enter the
 * per-category reservation breakup of seats for an ITI + trade, which is
 * written to iti_seatmatrix (current year / seatmatrix phase).
 */
@Controller
@RequestMapping("/ReservationEntry")
public class ReservationEntryController {

    private final RestTemplate rest = new RestTemplate();
    private final BackendApiRequestSupport proxySupport;

    public ReservationEntryController(BackendApiRequestSupport proxySupport) {
        this.proxySupport = proxySupport;
    }

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    @GetMapping({ "", "/", "/Interface" })
    public String reservationEntry() {
        return "admission/reservationEntry";
    }

    @GetMapping("/api/district/{distCode}/itis")
    @ResponseBody
    public ResponseEntity<Object> itisByDistrict(@PathVariable("distCode") String distCode,
            HttpServletRequest request) {
        if ("3".equals(BackendApiRequestSupport.role(request))
                && !BackendApiRequestSupport.scope(request).equalsIgnoreCase(distCode.trim())) {
            return ResponseEntity.status(403).body(Map.of("error", "District scope mismatch"));
        }
        return proxyGet(backendBaseUrl + "/admission/district/" + distCode.trim() + "/itis", request);
    }

    @GetMapping("/api/iti/{itiCode}/trades")
    @ResponseBody
    public ResponseEntity<Object> tradesByIti(@PathVariable("itiCode") String itiCode, HttpServletRequest request) {
        return proxyGet(backendBaseUrl + "/admission/reservation-entry/trades?itiCode=" + itiCode.trim(), request);
    }

    /** Only approved trades — feeds the trade dropdown once reservation entry is open. */
    @GetMapping("/api/iti/{itiCode}/approved-trades")
    @ResponseBody
    public ResponseEntity<Object> approvedTradesByIti(@PathVariable("itiCode") String itiCode, HttpServletRequest request) {
        return proxyGet(backendBaseUrl + "/admission/reservation-entry/approved-trades?itiCode="
                + itiCode.trim(), request);
    }

    /** Gate: approved trade + shift units must both exist before Reservation Entry is usable. */
    @GetMapping("/api/iti/{itiCode}/readiness")
    @ResponseBody
    public ResponseEntity<Object> readiness(@PathVariable("itiCode") String itiCode, HttpServletRequest request) {
        return proxyGet(backendBaseUrl + "/admission/reservation-entry/readiness?itiCode="
                + itiCode.trim(), request);
    }

    @GetMapping("/api/reservation-entry")
    @ResponseBody
    public ResponseEntity<Object> getReservation(@RequestParam("itiCode") String itiCode,
            @RequestParam("tradeCode") Integer tradeCode,
            HttpServletRequest request) {
        String url = backendBaseUrl + "/admission/reservation-entry?itiCode="
                + itiCode.trim() + "&tradeCode=" + tradeCode;
        return proxyGet(url, request);
    }

    @PutMapping("/api/reservation-entry")
    @ResponseBody
    public ResponseEntity<Object> saveReservation(@RequestBody Map<String, Object> body, HttpServletRequest request) {
        String url = backendBaseUrl + "/admission/reservation-entry";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            ResponseEntity<Object> resp = rest.exchange(url, HttpMethod.PUT,
                    proxySupport.entity(request, body), Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false,
                    "message", "Unable to reach Reservation Entry service"));
        }
    }

    private ResponseEntity<Object> proxyGet(String url, HttpServletRequest request) {
        try {
            ResponseEntity<Object> resp = rest.exchange(url, HttpMethod.GET, proxySupport.entity(request), Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(new Object[0]);
        }
    }
}
