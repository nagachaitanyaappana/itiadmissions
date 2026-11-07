package com.server.frontend.controller.admission;

import java.util.Map;

import com.server.frontend.controller.BackendGatewayController;
import com.server.frontend.security.BackendApiRequestSupport;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

@Controller
@RequestMapping("/AddTrade")
public class AddTradeController {

    private final RestTemplate rest = new RestTemplate();
    private final BackendApiRequestSupport proxySupport;

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    public AddTradeController(BackendApiRequestSupport proxySupport) {
        this.proxySupport = proxySupport;
        rest.setErrorHandler(response -> false);
    }

    @GetMapping({ "", "/", "/Interface" })
    public String addTrade(HttpServletRequest request) {
        return isRole(request, "4") ? "admission/addTrade" : "redirect:/?error=session";
    }

    @GetMapping("/api/district/{distCode}/itis")
    @ResponseBody
    public ResponseEntity<Object> itis(@PathVariable("distCode") String d, HttpServletRequest request) {
        if (!canReadDistrict(request, d)) return forbidden();
        return proxyGet(backendBaseUrl + "/admission/district/" + code(d) + "/itis?permitted=true", request);
    }

    @GetMapping("/api/itis/{distCode}")
    @ResponseBody
    public ResponseEntity<Object> names(@PathVariable("distCode") String d, HttpServletRequest request) {
        if (!canReadDistrict(request, d)) return forbidden();
        return proxyGet(backendBaseUrl + "/admission/itis/" + code(d), request);
    }

    @GetMapping("/api/iti/{itiCode}/available-trades")
    @ResponseBody
    public ResponseEntity<Object> availableTrades(@PathVariable("itiCode") String c, HttpServletRequest request) {
        if (!canReadIti(request, c)) return forbidden();
        return proxyGet(backendBaseUrl + "/admission/add-trade/" + code(c), request);
    }

    @GetMapping("/api/trade/{tradeShort}")
    @ResponseBody
    public ResponseEntity<Object> trade(@PathVariable("tradeShort") String t, HttpServletRequest request) {
        if (!hasOfficialSession(request)) return unauthorized();
        return proxyGet(backendBaseUrl + "/admission/trade/" + code(t), request);
    }

    @GetMapping("/api/trades")
    @ResponseBody
    public ResponseEntity<Object> allTrades(HttpServletRequest request) {
        if (!hasOfficialSession(request)) return unauthorized();
        return proxyGet(backendBaseUrl + "/api/trades", request);
    }

    @PostMapping("/api/iti/{itiCode}/trades")
    @ResponseBody
    public ResponseEntity<Object> add(@PathVariable("itiCode") String c,
            @RequestBody(required = false) Map<String, Object> b, HttpServletRequest request) {
        if (!sameOriginWrite(request)) return forbidden();
        if (!isOwnIti(request, c)) return forbidden();
        return proxyWrite(HttpMethod.POST, backendBaseUrl + "/admission/add-trade/" + code(c) + "/trade", b, request);
    }

    @PutMapping("/api/iti/{itiCode}/approve-all")
    @ResponseBody
    public ResponseEntity<Object> approve(@PathVariable("itiCode") String c, HttpServletRequest request) {
        if (!sameOriginWrite(request)) return forbidden();
        if (!isOwnIti(request, c)) return forbidden();
        return proxyWrite(HttpMethod.PUT, backendBaseUrl + "/admission/add-trade/" + code(c) + "/approve-all", null, request);
    }

    @GetMapping("/api/iti/{itiCode}/trade/{tradeCode}")
    @ResponseBody
    public ResponseEntity<Object> getTrade(@PathVariable("itiCode") String c,
            @PathVariable("tradeCode") String t, HttpServletRequest request) {
        if (!canReadIti(request, c)) return forbidden();
        return proxyGet(backendBaseUrl + "/admission/add-trade/" + code(c) + "/trade/" + code(t), request);
    }

    @PutMapping("/api/iti/{itiCode}/trade/{tradeCode}")
    @ResponseBody
    public ResponseEntity<Object> updateTrade(@PathVariable("itiCode") String c,
            @PathVariable("tradeCode") String t,
            @RequestBody(required = false) Map<String, Object> b, HttpServletRequest request) {
        if (!sameOriginWrite(request)) return forbidden();
        if (!isOwnIti(request, c)) return forbidden();
        return proxyWrite(HttpMethod.PUT,
                backendBaseUrl + "/admission/add-trade/" + code(c) + "/trade/" + code(t), b, request);
    }

    @PostMapping("/api/iti/{itiCode}/freeze-trades")
    @ResponseBody
    public ResponseEntity<Object> freezeTrades(@PathVariable("itiCode") String c,
            @RequestParam(name = "freeze", defaultValue = "true") String freeze,
            HttpServletRequest request) {
        if (!sameOriginWrite(request)) return forbidden();
        if (!isOwnIti(request, c)) return forbidden();
        String url = backendBaseUrl + "/admission/add-trade/" + code(c)
                + "/freeze-trades?freeze=" + ("false".equalsIgnoreCase(freeze) ? "false" : "true");
        return proxyWrite(HttpMethod.POST, url, null, request);
    }

    private ResponseEntity<Object> proxyGet(String url, HttpServletRequest request) {
        try {
            ResponseEntity<Object> response = rest.exchange(url, HttpMethod.GET, proxySupport.entity(request), Object.class);
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (Exception ex) {
            return ResponseEntity.status(502).body(Map.of("success", false, "message", "Add Trade service unavailable"));
        }
    }

    private ResponseEntity<Object> proxyWrite(HttpMethod method, String url, Object body, HttpServletRequest request) {
        try {
            ResponseEntity<Object> response = rest.exchange(url, method,
                    proxySupport.entity(request, body), Object.class);
            return ResponseEntity.status(response.getStatusCode()).body(response.getBody());
        } catch (Exception ex) {
            return ResponseEntity.status(502).body(Map.of("success", false, "message", "Add Trade service unavailable"));
        }
    }

    private static boolean hasOfficialSession(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) return false;
        String role = String.valueOf(session.getAttribute("roleId"));
        return "2".equals(role) || "3".equals(role) || "4".equals(role) || "10".equals(role);
    }

    private static boolean isRole(HttpServletRequest request, String role) {
        HttpSession session = request.getSession(false);
        return session != null && session.getAttribute("sessionUser") != null
                && role.equals(String.valueOf(session.getAttribute("roleId")));
    }

    private static boolean canReadDistrict(HttpServletRequest request, String districtCode) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) return false;
        String role = String.valueOf(session.getAttribute("roleId"));
        if ("2".equals(role) || "10".equals(role)) return validCode(districtCode);
        return "3".equals(role) && districtCode != null
                && districtCode.trim().equalsIgnoreCase(String.valueOf(session.getAttribute("insCode")).trim())
                && validCode(districtCode);
    }

    private static boolean canReadIti(HttpServletRequest request, String itiCode) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) return false;
        String role = String.valueOf(session.getAttribute("roleId"));
        if ("2".equals(role) || "10".equals(role)) return validCode(itiCode);
        return "4".equals(role) && itiCode != null
                && itiCode.trim().equalsIgnoreCase(String.valueOf(session.getAttribute("insCode")).trim())
                && validCode(itiCode);
    }

    private static boolean isOwnIti(HttpServletRequest request, String itiCode) {
        return isRole(request, "4") && itiCode != null
                && itiCode.trim().equalsIgnoreCase(String.valueOf(request.getSession(false).getAttribute("insCode")).trim())
                && validCode(itiCode);
    }

    private static boolean sameOriginWrite(HttpServletRequest request) {
        return hasOfficialSession(request) && BackendGatewayController.sameOrigin(request);
    }

    private static boolean validCode(String value) {
        return value != null && value.matches("[A-Za-z0-9_-]{1,20}");
    }

    private static String code(String value) {
        if (!validCode(value)) throw new org.springframework.web.server.ResponseStatusException(
                org.springframework.http.HttpStatus.BAD_REQUEST, "Invalid code");
        return value.trim();
    }

    private static ResponseEntity<Object> unauthorized() {
        return ResponseEntity.status(401).body(Map.of("success", false, "message", "Authentication required"));
    }

    private static ResponseEntity<Object> forbidden() {
        return ResponseEntity.status(403).body(Map.of("success", false, "message", "Operation is outside your authorized scope"));
    }
}
