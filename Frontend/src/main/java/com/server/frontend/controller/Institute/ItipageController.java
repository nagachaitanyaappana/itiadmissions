package com.server.frontend.controller.Institute;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

@Controller
public class ItipageController {

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    private final RestTemplate rest = new RestTemplate();

    private static final String ITIS_PATH = "/api/itis";
    private static final String DISTRICTS_PATH = "/api/districts";
    private static final String DESIGNATIONS_PATH = "/api/designations";
    private static final String SHIFT_UNIT_PATH = "/api/shift-unit-permitted";

    @GetMapping("/itiList")
    public String getItiList(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) return "redirect:/?error=session";
        model.addAttribute("itiApiUrl", gatewayBase(request) + ITIS_PATH);
        return "Institute/ItiList";
    }

    @GetMapping("/iti-details")
    public String itiDetails(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) return "redirect:/?error=session";
        model.addAttribute("itiApiUrl", gatewayBase(request) + ITIS_PATH);
        return "Institute/ItiDetails";
    }

    @GetMapping("/iti-create")
    public String itiCreate(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) return "redirect:/?error=session";
        model.addAttribute("itiApiUrl", gatewayBase(request) + ITIS_PATH);
        model.addAttribute("districtApiUrl", gatewayBase(request) + DISTRICTS_PATH);
        model.addAttribute("designationApiUrl", gatewayBase(request) + DESIGNATIONS_PATH);
        model.addAttribute("itiRegistrationApiUrl", gatewayBase(request) + ITIS_PATH);
        return "Institute/ItiCreate";
    }

    @GetMapping("/iti-trade-selection")
    public String itiTradeSelection(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) return "redirect:/?error=session";
        Object roleId = request.getSession().getAttribute("roleId");
        Object insCode = request.getSession().getAttribute("insCode");
        boolean districtScoped = "3".equals(String.valueOf(roleId))
                && insCode != null && !String.valueOf(insCode).isBlank();
        String base = gatewayBase(request);
        String itiApiUrl = districtScoped
                ? base + "/admission/district/" + String.valueOf(insCode).trim() + "/itis"
                : base + ITIS_PATH;
        model.addAttribute("itiApiUrl", itiApiUrl);
        model.addAttribute("backendApiBaseUrl", base);
        model.addAttribute("itiTradesApiUrl", base + "/api/trades");
        return "Institute/ItiTradeSelection";
    }

    /**
     * Server-side trade lookup is retained for this legacy page, but it is no
     * longer an unauthenticated proxy or an arbitrary cross-ITI read.
     */
    @GetMapping("/iti-trade-selection/api/iti/{itiCode}/trades")
    @ResponseBody
    public ResponseEntity<Object> tradesByIti(@PathVariable("itiCode") String itiCode,
                                               HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return ResponseEntity.status(401).build();
        }
        if (!"4".equals(String.valueOf(session.getAttribute("roleId")))
                || session.getAttribute("insCode") == null
                || !itiCode.trim().equalsIgnoreCase(String.valueOf(session.getAttribute("insCode")).trim())) {
            return ResponseEntity.status(403).build();
        }
        try {
            ResponseEntity<Object> resp = rest.getForEntity(
                    backendBaseUrl + "/admission/reservation-entry/trades?itiCode=" + itiCode.trim(),
                    Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.status(502).build();
        }
    }

    @GetMapping("/shift-unit-permitted")
    public String shiftUnitPermitted(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) return "redirect:/?error=session";
        model.addAttribute("backendApiBaseUrl", gatewayBase(request));
        model.addAttribute("shiftUnitApiUrl", gatewayBase(request) + SHIFT_UNIT_PATH);
        return "Institute/ShiftUnitPermitted";
    }

    private static String gatewayBase(HttpServletRequest request) {
        return request.getContextPath() + "/backend";
    }

    private static boolean notLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null || session.getAttribute("sessionUser") == null;
    }
}
