package com.server.frontend.controller.admission;

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
 * Seat Correction (DISTLOGIN -&gt; Admissions). Port of the legacy
 * manageseats_interface_already_fill_fromadm.jsp -&gt; manageseats_interface_already_fill_fromadmAction
 * flow: the same reservation breakup, but the already-filled count is shown alongside the
 * admitted number and can be corrected before it is written to iti_seatmatrix.
 */
@Controller
@RequestMapping("/SeatCorrection")
public class SeatCorrectionController {

    private final RestTemplate rest = new RestTemplate();

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    @GetMapping({ "", "/", "/Interface" })
    public String seatCorrection() {
        return "admission/seatCorrection";
    }

    @GetMapping("/api/district/{distCode}/itis")
    @ResponseBody
    public ResponseEntity<Object> itisByDistrict(@PathVariable("distCode") String distCode) {
        return proxyGet(backendBaseUrl + "/admission/district/" + distCode.trim() + "/itis");
    }

    /** Only approved trades — feeds the trade dropdown once correction is open. */
    @GetMapping("/api/iti/{itiCode}/approved-trades")
    @ResponseBody
    public ResponseEntity<Object> approvedTradesByIti(@PathVariable("itiCode") String itiCode) {
        return proxyGet(backendBaseUrl + "/admission/reservation-entry/approved-trades?itiCode="
                + itiCode.trim());
    }

    /** Same gate as Reservation Entry: approved trade + shift units must both exist. */
    @GetMapping("/api/iti/{itiCode}/readiness")
    @ResponseBody
    public ResponseEntity<Object> readiness(@PathVariable("itiCode") String itiCode) {
        return proxyGet(backendBaseUrl + "/admission/reservation-entry/readiness?itiCode="
                + itiCode.trim());
    }

    @GetMapping("/api/seat-correction")
    @ResponseBody
    public ResponseEntity<Object> getSeatCorrection(@RequestParam("itiCode") String itiCode,
            @RequestParam("tradeCode") Integer tradeCode) {
        String url = backendBaseUrl + "/admission/reservation-entry/seat-correction?itiCode="
                + itiCode.trim() + "&tradeCode=" + tradeCode;
        return proxyGet(url);
    }

    @PutMapping("/api/seat-correction")
    @ResponseBody
    public ResponseEntity<Object> saveSeatCorrection(@RequestBody Map<String, Object> body) {
        String url = backendBaseUrl + "/admission/reservation-entry/seat-correction";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            ResponseEntity<Object> resp = rest.exchange(url, HttpMethod.PUT,
                    new HttpEntity<>(body, headers), Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false,
                    "message", "Unable to reach Seat Correction service"));
        }
    }

    private ResponseEntity<Object> proxyGet(String url) {
        try {
            ResponseEntity<Object> resp = rest.getForEntity(url, Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(new Object[0]);
        }
    }
}
