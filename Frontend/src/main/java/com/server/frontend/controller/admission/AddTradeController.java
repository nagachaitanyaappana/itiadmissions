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
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

/** Add Trade (DISTLOGIN - Admissions - Add Trade). Port of the legacy addnew_trade flow. */
@Controller
@RequestMapping("/AddTrade")
public class AddTradeController {

    private final RestTemplate rest = new RestTemplate();

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    public AddTradeController() {
        // Keep 4xx bodies (e.g. "already approved") instead of letting RestTemplate throw and hide them.
        rest.setErrorHandler(response -> false);
    }

    @GetMapping({ "", "/", "/Interface" })
    public String addTrade() {
        return "admission/addTrade";
    }

    @GetMapping("/api/district/{distCode}/itis")
    @ResponseBody
    public ResponseEntity<Object> itis(@PathVariable("distCode") String d) {
        return proxyGet(backendBaseUrl + "/admission/district/" + d.trim() + "/itis");
    }

    @GetMapping("/api/itis/{distCode}")
    @ResponseBody
    public ResponseEntity<Object> names(@PathVariable("distCode") String d) {
        return proxyGet(backendBaseUrl + "/admission/itis/" + d.trim());
    }

    /** Catalogue of addable master trades + the ITI's existing trades + approved flag. */
    @GetMapping("/api/iti/{itiCode}/available-trades")
    @ResponseBody
    public ResponseEntity<Object> availableTrades(@PathVariable("itiCode") String c) {
        return proxyGet(backendBaseUrl + "/admission/add-trade/" + c.trim());
    }

    @GetMapping("/api/trade/{tradeShort}")
    @ResponseBody
    public ResponseEntity<Object> trade(@PathVariable("tradeShort") String t) {
        return proxyGet(backendBaseUrl + "/admission/trade/" + t.trim());
    }

    @GetMapping("/api/trades")
    @ResponseBody
    public ResponseEntity<Object> allTrades() {
        return proxyGet(backendBaseUrl + "/api/trades");
    }

    @PostMapping("/api/iti/{itiCode}/trades")
    @ResponseBody
    public ResponseEntity<Object> add(@PathVariable("itiCode") String c,
            @RequestBody(required = false) Map<String, Object> b) {
        return proxyWrite(HttpMethod.POST, backendBaseUrl + "/admission/add-trade/" + c.trim() + "/trade", b);
    }

    @PutMapping("/api/iti/{itiCode}/approve-all")
    @ResponseBody
    public ResponseEntity<Object> approve(@PathVariable("itiCode") String c) {
        return proxyWrite(HttpMethod.PUT, backendBaseUrl + "/admission/add-trade/" + c.trim() + "/approve-all", null);
    }

    /** Edit Trade page payload for one trade of the ITI. */
    @GetMapping("/api/iti/{itiCode}/trade/{tradeCode}")
    @ResponseBody
    public ResponseEntity<Object> getTrade(@PathVariable("itiCode") String c,
            @PathVariable("tradeCode") String t) {
        return proxyGet(backendBaseUrl + "/admission/add-trade/" + c.trim() + "/trade/" + t.trim());
    }

    /** Save edited strength / availability (+ optional shift/unit toggles). */
    @PutMapping("/api/iti/{itiCode}/trade/{tradeCode}")
    @ResponseBody
    public ResponseEntity<Object> updateTrade(@PathVariable("itiCode") String c,
            @PathVariable("tradeCode") String t,
            @RequestBody(required = false) Map<String, Object> b) {
        return proxyWrite(HttpMethod.PUT,
                backendBaseUrl + "/admission/add-trade/" + c.trim() + "/trade/" + t.trim(), b);
    }

    /** Freeze ({@code freeze=true}) or unfreeze every trade of the ITI. */
    @PostMapping("/api/iti/{itiCode}/freeze-trades")
    @ResponseBody
    public ResponseEntity<Object> freezeTrades(@PathVariable("itiCode") String c,
            @RequestParam(name = "freeze", defaultValue = "true") String freeze) {
        String url = backendBaseUrl + "/admission/add-trade/" + c.trim()
                + "/freeze-trades?freeze=" + ("false".equalsIgnoreCase(freeze) ? "false" : "true");
        return proxyWrite(HttpMethod.POST, url, null);
    }

    private ResponseEntity<Object> proxyGet(String url) {
        try {
            ResponseEntity<Object> r = rest.getForEntity(url, Object.class);
            return ResponseEntity.status(r.getStatusCode()).body(r.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(new Object[0]);
        }
    }

    private ResponseEntity<Object> proxyWrite(HttpMethod method, String url, Object body) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        try {
            ResponseEntity<Object> r = rest.exchange(url, method,
                    new HttpEntity<>(body, headers), Object.class);
            return ResponseEntity.status(r.getStatusCode()).body(r.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false,
                    "message", "Unable to reach Add Trade service"));
        }
    }
}
