package com.server.frontend.controller.checkmeritschedulecontroller;

import java.util.List;
import java.util.Map;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.client.RestTemplate;

/**
 * Exact 1:1 port of the legacy Phase-1 admission flow:
 *
 * <p>1. {@code GET /AdmissionPhase} → {@code startAdmission_ConvvinerLevel.jsp} (screen 1).
 * <p>2. {@code POST /AdmissionPhase/itiAdmissionEntry} (mirror of {@code itiAdmissionEntry.do}) →
 * resolves the merit window and forwards to {@code DistrictAdmissionEntry.jsp} (screen 2).
 * <p>3. {@code POST /AdmissionPhase/districtAdmissionProcessOptimise}
 * (mirror of {@code districtAdmissionProcessOptimise.do}) → takes the admission.
 *
 * <p>Caller identity is forwarded to the backend as the {@code X-Role-Id}/{@code X-Ins-Code}
 * headers the backend already expects.
 */
@Controller
@RequestMapping("/AdmissionPhase")
public class AdmissionPhaseController {

    @Value("${backend.api.base-url}")
    private String backendBase;

    private final RestTemplate rest = new RestTemplate();

    @GetMapping
    public String show(HttpServletRequest request, Model model) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        model.addAttribute("phase", fetchPhase());
        model.addAttribute("casteOptions", fetchCasteOptions());
        model.addAttribute("timingOptions", fetchTodayTimings(request));
        return "checkmeritschedule/AdmissionPhase";
    }

    @PostMapping("/itiAdmissionEntry")
    public String start(HttpServletRequest request, Model model,
                        @RequestParam("caste_perform") String caste,
                        @RequestParam("qual_perform") String qual,
                        @RequestParam("adm_perform") String time) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        Map<String, Object> body = Map.of(
                "caste_perform", caste,
                "qual_perform", qual,
                "adm_perform", time);
        @SuppressWarnings("unchecked")
        Map<String, Object> resp = rest.postForObject(
                backendBase + "/api/admission/council-merits", new HttpEntity<>(body, headers(request)),
                Map.class);

        boolean success = resp != null && Boolean.TRUE.equals(resp.get("success"));
        if (!success) {
            Object err = resp == null ? "Server error" : resp.get("message");
            model.addAttribute("errorMsg", err == null ? "No counselling window is configured for today." : err);
            model.addAttribute("phase", fetchPhase());
            model.addAttribute("casteOptions", fetchCasteOptions());
            model.addAttribute("timingOptions", fetchTodayTimings(request));
            return "checkmeritschedule/AdmissionPhase";
        }

        @SuppressWarnings("unchecked")
        Map<String, Object> data = (Map<String, Object>) resp.get("data");
        model.addAttribute("currentDate", data.get("current_date"));
        model.addAttribute("merit_from", data.get("merit_from"));
        model.addAttribute("merit_to", data.get("merit_to"));
        model.addAttribute("caste_perform", caste);
        model.addAttribute("qual_perform", qual);
        model.addAttribute("adm_perform", data.get("cal_time") != null ? data.get("cal_time") : time);
        return "checkmeritschedule/DistrictAdmissionEntry";
    }

    @PostMapping("/districtAdmissionProcessOptimise")
    public String optimize(HttpServletRequest request, Model model,
                           @RequestParam("rank") String rank,
                           @RequestParam("currentDate") String currentDate,
                           @RequestParam("merit_from") String meritFrom,
                           @RequestParam("merit_to") String meritTo,
                           @RequestParam("caste_perform") String caste,
                           @RequestParam("qual_perform") String qual,
                           @RequestParam("adm_perform") String time) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        Map<String, Object> body = Map.of(
                "rank", rank,
                "caste_perform", caste,
                "qual_perform", qual,
                "adm_perform", time);
        @SuppressWarnings("unchecked")
        Map<String, Object> resp = rest.postForObject(
                backendBase + "/api/admission/process-optimize", new HttpEntity<>(body, headers(request)),
                Map.class);

        boolean success = resp != null && Boolean.TRUE.equals(resp.get("success"));
        String code = resp == null ? "ERROR" : String.valueOf(resp.get("code"));
        if (success && ("ADMITTED".equalsIgnoreCase(code) || "ALREADY_ADMITTED".equalsIgnoreCase(code))) {
            model.addAttribute("rank", rank);
            return "checkmeritschedule/Phase1AdmSuccess";
        }
        Object err = resp == null ? "Server error" : resp.get("message");
        model.addAttribute("errorMsg", err == null ? "Admission could not be completed." : err);
        model.addAttribute("currentDate", currentDate);
        model.addAttribute("merit_from", meritFrom);
        model.addAttribute("merit_to", meritTo);
        model.addAttribute("caste_perform", caste);
        model.addAttribute("qual_perform", qual);
        model.addAttribute("adm_perform", time);
        return "checkmeritschedule/DistrictAdmissionEntry";
    }

    // ---------------- helpers ----------------

    private HttpHeaders headers(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        HttpHeaders h = new HttpHeaders();
        h.setContentType(MediaType.APPLICATION_JSON);
        if (s != null) {
            Object role = s.getAttribute("roleId");
            Object ins = s.getAttribute("insCode");
            if (role != null) h.set("X-Role-Id", String.valueOf(role));
            if (ins != null) h.set("X-Ins-Code", String.valueOf(ins));
        }
        return h;
    }

    private String fetchPhase() {
        try {
            @SuppressWarnings("unchecked")
            Map<String, Object> resp = rest.postForObject(backendBase + "/api/status", null, Map.class);
            Object phase = resp == null ? null : resp.get("phase");
            return phase == null ? "1" : String.valueOf(phase);
        } catch (Exception e) {
            return "1";
        }
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, String>> fetchCasteOptions() {
        try {
            Map<String, Object> resp = rest.getForObject(backendBase + "/api/dsc/caste-list", Map.class);
            Object data = resp == null ? null : resp.get("data");
            return data == null ? List.of() : (List<Map<String, String>>) data;
        } catch (Exception e) {
            return List.of();
        }
    }

    @SuppressWarnings("unchecked")
    private List<String> fetchTodayTimings(HttpServletRequest request) {
        try {
            Map<String, Object> resp = rest.exchange(
                    backendBase + "/api/admission/today-timings", HttpMethod.GET,
                    new HttpEntity<>(headers(request)), Map.class).getBody();
            Object data = resp == null ? null : resp.get("data");
            return data == null ? List.of() : (List<String>) data;
        } catch (Exception e) {
            return List.of();
        }
    }

    private static boolean notLoggedIn(HttpServletRequest request) {
        HttpSession s = request.getSession(false);
        return s == null || s.getAttribute("sessionUser") == null;
    }
}
