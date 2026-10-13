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

    // The ITI list/detail/create pages read the ITI master, whose endpoint is
    // /api/itis. (This used to point at /api/reports, which has no bare route
    // and returned 404, so every ITI dropdown/table failed to load.)
    private static final String ITIS_PATH = "/api/itis";
    private static final String DISTRICTS_PATH = "/api/districts";
    private static final String DESIGNATIONS_PATH = "/api/designations";
    private static final String SHIFT_UNIT_PATH = "/api/shift-unit-permitted";

    @GetMapping("/itiList")
    public String getItiList(Model model) {
        model.addAttribute("itiApiUrl", backendBaseUrl + ITIS_PATH);
        return "Institute/ItiList";
    }

    @GetMapping("/iti-details")
    public String itiDetails(Model model) {
        model.addAttribute("itiApiUrl", backendBaseUrl + ITIS_PATH);
        return "Institute/ItiDetails";
    }

    @GetMapping("/iti-create")
    public String itiCreate(Model model) {
        model.addAttribute("itiApiUrl", backendBaseUrl + ITIS_PATH);
        model.addAttribute("districtApiUrl", backendBaseUrl + DISTRICTS_PATH);
        model.addAttribute("designationApiUrl", backendBaseUrl + DESIGNATIONS_PATH);
        // Form submission target (POST /api/itis); previously unset, so the
        // create form posted to "" (the page itself) and always failed.
        model.addAttribute("itiRegistrationApiUrl", backendBaseUrl + ITIS_PATH);
        return "Institute/ItiCreate";
    }

    @GetMapping("/iti-trade-selection")
    public String itiTradeSelection(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        // District users must only see their own district's ITIs; state/other
        // roles keep the full list.
        Object roleId = request.getSession().getAttribute("roleId");
        Object insCode = request.getSession().getAttribute("insCode");
        boolean districtScoped = "3".equals(String.valueOf(roleId))
                && insCode != null && !String.valueOf(insCode).isBlank();
        String itiApiUrl = districtScoped
                ? backendBaseUrl + "/admission/district/" + String.valueOf(insCode).trim() + "/itis"
                : backendBaseUrl + ITIS_PATH;
        model.addAttribute("itiApiUrl", itiApiUrl);
        model.addAttribute("backendApiBaseUrl", backendBaseUrl);
        // The JSP loads the trade master list from here; without this attribute
        // it rendered const itiTradesApiUrl = "" and fetched the page itself.
        model.addAttribute("itiTradesApiUrl", backendBaseUrl + "/api/trades");
        return "Institute/ItiTradeSelection";
    }

    /**
     * Same-origin proxy for the per-ITI trade list used by the shift-unit entry
     * page (the JSP cannot call the backend directly without CORS). Delegates to
     * the backend Reservation Entry trade lookup, which returns the ITI's own
     * trades with their sanctioned strength.
     */
    @GetMapping("/iti-trade-selection/api/iti/{itiCode}/trades")
    @ResponseBody
    public ResponseEntity<Object> tradesByIti(@PathVariable("itiCode") String itiCode) {
        try {
            ResponseEntity<Object> resp = rest.getForEntity(
                    backendBaseUrl + "/admission/reservation-entry/trades?itiCode=" + itiCode.trim(),
                    Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(new Object[0]);
        }
    }

    @GetMapping("/shift-unit-permitted")
    public String shiftUnitPermitted(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        model.addAttribute("backendApiBaseUrl", backendBaseUrl);
        // GET ?itiCode&tradeCode to read, PUT to save; previously unset, so the
        // page fetched "" (itself) for both operations.
        model.addAttribute("shiftUnitApiUrl", backendBaseUrl + SHIFT_UNIT_PATH);
        return "Institute/ShiftUnitPermitted";
    }

    /** True when the request has no authenticated session; callers redirect to the login page. */
    private static boolean notLoggedIn(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        return session == null || session.getAttribute("sessionUser") == null;
    }
}
