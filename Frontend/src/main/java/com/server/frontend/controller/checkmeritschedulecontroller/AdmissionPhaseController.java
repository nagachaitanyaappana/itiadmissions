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
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
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

    /**
     * Legacy {@code imageRetrival.jsp?id={regid}} mirror: streams the candidate's stored
     * photograph as an image. Delegates to the backend's base64 photo endpoint.
     */
    @GetMapping("/photo/{regid}")
    public ResponseEntity<byte[]> photo(@PathVariable("regid") String regid) {
        try {
            Map<String, Object> resp = rest.exchange(
                    backendBase + "/api/student/photo/" + regid, HttpMethod.GET,
                    new HttpEntity<>(new HttpHeaders()), Map.class).getBody();
            Object b64 = resp == null ? null : resp.get("photo");
            if (b64 == null || !(b64 instanceof String s) || s.isBlank()) {
                // Legacy imageRetrival.jsp emits an empty image/jpg body when no photo
                // is stored (browser shows the broken-image icon, HTTP 200, no console error).
                return ResponseEntity.ok()
                        .contentType(MediaType.IMAGE_JPEG)
                        .body(new byte[0]);
            }
            byte[] bytes = java.util.Base64.getDecoder().decode(s);
            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_JPEG)
                    .body(bytes);
        } catch (Exception e) {
            return ResponseEntity.notFound().build();
        }
    }

    @PostMapping("/itiAdmissionEntry")
    public String start(HttpServletRequest request, Model model,
                        @RequestParam("caste_perform") String caste,
                        @RequestParam("qual_perform") String qual,
                        @RequestParam(value = "adm_perform", required = false, defaultValue = "") String time) {
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
                           @RequestParam(value = "adm_perform", required = false, defaultValue = "") String time) {
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
        if (success) {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) resp.get("data");
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> layout = (List<Map<String, Object>>) resp.get("layout");
            @SuppressWarnings("unchecked")
            List<Map<String, Object>> seatMatrix = (List<Map<String, Object>>) resp.get("seat_matrix");
            sessionPut(request, "adm_regid", data.get("regid"));
            sessionPut(request, "adm_merit_number", data.get("rank"));
            model.addAttribute("student", data);
            model.addAttribute("layout", layout);
            model.addAttribute("seat_matrix", seatMatrix);
            model.addAttribute("casteOptions", fetchCasteOptions());
            model.addAttribute("itiBoards", fetchList("/api/admission/iti-boards", request));
            // Legacy putOptions("admissions.ssc_examboard_mst",...) has no public endpoint yet;
            // reproduce the standard board list. TODO: source from backend when exposed.
            model.addAttribute("sscBoards", List.of(
                    Map.of("board_code", "1", "board_name", "SSC"),
                    Map.of("board_code", "2", "board_name", "ICSE"),
                    Map.of("board_code", "3", "board_name", "CBSE"),
                    Map.of("board_code", "4", "board_name", "Other")));
            model.addAttribute("sscYears", sscYears());
            return "checkmeritschedule/DistrictAdmissionProcessOptimise";
        }
        Object err = resp == null ? "Server error" : resp.get("message");
        model.addAttribute("errorMsg", err == null ? "No candidate found for this rank." : err);
        model.addAttribute("currentDate", currentDate);
        model.addAttribute("merit_from", meritFrom);
        model.addAttribute("merit_to", meritTo);
        model.addAttribute("caste_perform", caste);
        model.addAttribute("qual_perform", qual);
        model.addAttribute("adm_perform", time);
        return "checkmeritschedule/DistrictAdmissionEntry";
    }

    /** Final step (mirror of legacy {@code districtAdmission.do}): records the admission. */
    @PostMapping("/take-admission")
    public String takeAdmission(HttpServletRequest request, Model model,
                                @RequestParam("regid") String regid,
                                @RequestParam(value = "trade_code", required = false) String tradeCode,
                                @RequestParam(value = "selectedRadio", required = false) String selectedRadio,
                                @RequestParam(value = "idmarks1", required = false) String idmarks1,
                                @RequestParam(value = "idmarks2", required = false) String idmarks2,
                                @RequestParam(value = "ssc_regno", required = false) String sscRegno,
                                @RequestParam(value = "ssc_board", required = false) String sscBoard,
                                @RequestParam(value = "ssc_year", required = false) String sscYear,
                                @RequestParam(value = "ssc_month", required = false) String sscMonth,
                                @RequestParam(value = "type_admission", required = false) String typeAdmission,
                                @RequestParam(value = "caste_name", required = false) String casteName) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        // trade_code is legacy "itiName+itiCode+tradeCode+check"; selectedRadio is "shift|unit|strength".
        String itiCode = "";
        String trade = "";
        String check = "";
        if (tradeCode != null) {
            String[] t = tradeCode.split("\\+");
            if (t.length >= 4) {
                itiCode = t[1];
                trade = t[2];
                check = t[3];
            }
        }
        String shift = "";
        String unit = "";
        String strength = "";
        if (selectedRadio != null) {
            String[] s = selectedRadio.split("\\|");
            if (s.length >= 3) {
                shift = s[0];
                unit = s[1];
                strength = s[2];
            }
        }
        Map<String, Object> body = new java.util.LinkedHashMap<>();
        body.put("regid", regid);
        body.put("iti_code", itiCode);
        body.put("trade_code", trade);
        body.put("check", check);
        body.put("selectedRadio", selectedRadio);
        body.put("shift", shift);
        body.put("unit", unit);
        body.put("strength", strength);
        body.put("idmarks1", idmarks1);
        body.put("idmarks2", idmarks2);
        body.put("ssc_regno", sscRegno);
        body.put("ssc_board", sscBoard);
        body.put("ssc_year", sscYear);
        body.put("ssc_month", sscMonth);
        body.put("type_admission", typeAdmission);
        body.put("caste_name", casteName);
        @SuppressWarnings("unchecked")
        Map<String, Object> resp = rest.postForObject(
                backendBase + "/api/admission/take-admission", new HttpEntity<>(body, headers(request)),
                Map.class);

        boolean success = resp != null && Boolean.TRUE.equals(resp.get("success"));
        if (success) {
            @SuppressWarnings("unchecked")
            Map<String, Object> data = (Map<String, Object>) resp.get("data");
            Object admNum = data == null ? resp.get("adm_num") : data.get("adm_num");
            model.addAttribute("adm_num", admNum);
            sessionPut(request, "adm_num", admNum);
            return "checkmeritschedule/Phase1AdmSuccess";
        }
        Object err = resp == null ? "Server error" : resp.get("message");
        model.addAttribute("errorMsg", err == null ? "Admission could not be completed." : err);
        return "checkmeritschedule/DistrictAdmissionEntry";
    }

    /** AJAX fragment: permitted shift/unit rows for an ITI+trade (mirror of getShiftUnit.jsp). */
    @GetMapping("/shift-unit")
    @org.springframework.web.bind.annotation.ResponseBody
    public String shiftUnit(@RequestParam("itiCode") String itiCode,
                            @RequestParam("tradeCode") String tradeCode,
                            HttpServletRequest request,
                            jakarta.servlet.http.HttpServletResponse response) {
        response.setContentType("text/html;charset=UTF-8");
        @SuppressWarnings("unchecked")
        Map<String, Object> resp = rest.exchange(
                backendBase + "/api/admission/shift-unit?itiCode=" + itiCode + "&tradeCode=" + tradeCode,
                HttpMethod.GET, new HttpEntity<>(headers(request)), Map.class).getBody();
        @SuppressWarnings("unchecked")
        List<Map<String, Object>> options = resp == null ? null : (List<Map<String, Object>>) resp.get("shifts");
        StringBuilder sb = new StringBuilder();
        if (options == null || options.isEmpty()) {
            sb.append("<tr><td colspan=\"3\">No data found</td></tr>");
        } else {
            for (Map<String, Object> o : options) {
                String value = o.get("shift_allowed") + "|" + o.get("unit_allowed") + "|" + o.get("strength");
                sb.append("<tr>")
                        .append("<td><input type=\"radio\" name=\"selectedRadio\" value=\"").append(value).append("\"></td>")
                        .append("<td style=\"text-align: center;\">").append(o.get("shift_allowed")).append("</td>")
                        .append("<td style=\"text-align: center;\">").append(o.get("unit_allowed")).append("</td>")
                        .append("<td style=\"text-align: center;\">").append(o.get("strength")).append("</td>")
                        .append("<td style=\"text-align: center;\">").append(o.get("strength_vacant")).append("</td>")
                        .append("</tr>");
            }
        }
        return sb.toString();
    }

    // ---------------- helpers ----------------

    private void sessionPut(HttpServletRequest request, String key, Object value) {
        if (value != null) {
            request.getSession(true).setAttribute(key, value);
        }
    }

    private List<Integer> sscYears() {
        int end = java.time.LocalDate.now().getYear();
        List<Integer> years = new java.util.ArrayList<>();
        for (int y = end; y >= end - 15; y--) {
            years.add(y);
        }
        return years;
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> fetchList(String path, HttpServletRequest request) {
        try {
            Map<String, Object> resp = rest.exchange(
                    backendBase + path, HttpMethod.GET,
                    new HttpEntity<>(headers(request)), Map.class).getBody();
            Object data = resp == null ? null : resp.get("data");
            return data == null ? List.of() : (List<Map<String, Object>>) data;
        } catch (Exception e) {
            return List.of();
        }
    }

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
