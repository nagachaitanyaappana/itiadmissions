package com.server.frontend.controller.seniors;

import com.server.frontend.service.FrontendRestClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
public class SeniorsPublicController {

    private final FrontendRestClient restClient;

    @Autowired
    public SeniorsPublicController(FrontendRestClient restClient) {
        this.restClient = restClient;
    }

    // -------------------------- Page routes --------------------------

    @GetMapping("/AboutUs")
    public String aboutUs() {
        return "seniors/public/AboutUs";
    }

    @GetMapping("/AboutStrive")
    public String aboutStrive() {
        return "seniors/public/AboutStrive";
    }

    @GetMapping("/AtcItiPhone")
    public String atcItiPhone() {
        return "seniors/public/AtcItiPhone";
    }

    @GetMapping("/Course")
    public String course() {
        return "seniors/public/Course";
    }

    @GetMapping("/ItiList")
    public String itiList() {
        return "seniors/public/ItiList";
    }

    @GetMapping("/GovtItiList")
    public String govtItiList() {
        return "seniors/public/ItiList";
    }

    @GetMapping("/PrivateItiList")
    public String privateItiList() {
        return "seniors/public/ItiList";
    }

    @GetMapping("/SeatsOpen")
    public String seatsOpen() {
        return "seniors/public/SeatsOpen";
    }
    @PostMapping("/api/iti-details")
    @ResponseBody
    public List<Map<String, Object>> getItiDetails(@RequestBody(required = false) Map<String, String> body) {
        String type = body != null ? body.get("type") : null;
        Map<String, String> districtNames = districtNameByCode();
        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Map<String, Object> row : restClient.queryList("/api/itis")) {
            if (!matchesType(row, type)) {
                continue;
            }
            Map<String, Object> transformed = new java.util.LinkedHashMap<>(row);
            String itiCode = firstNonNull(transformed.get("iti_code"), transformed.get("itiCode"));
            String ncvtCode = firstNonNull(transformed.get("ncvt_code"), transformed.get("ncvtCode"));
            String itiName = firstNonNull(transformed.get("iti_name"), transformed.get("itiName"));
            String mobile = firstNonNull(transformed.get("mobile"), transformed.get("contactNumber"));
            String email = (String) transformed.get("email");
            String distCode = (String) transformed.get("distCode");
            String district = districtNames.get(distCode);
            transformed.put("itiCode", itiCode);
            transformed.put("ncvtCode", ncvtCode);
            transformed.put("itiName", itiName);
            transformed.put("contactNumber", mobile);
            transformed.put("email", email);
            transformed.put("district", district);
            out.add(transformed);
        }
        return out;
    }

    @PostMapping("/api/atc-iti-phones")
    @ResponseBody
    public List<Map<String, Object>> getAtcItiPhones() {
        Map<String, String> districtNames = districtNameByCode();
        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Map<String, Object> row : restClient.queryList("/api/itis")) {
            Map<String, Object> m = new java.util.LinkedHashMap<>(row);
            m.put("itiCode", firstNonNull(m.get("iti_code"), m.get("itiCode")));
            m.put("ncvtCode", firstNonNull(m.get("ncvt_code"), m.get("ncvtCode")));
            m.put("itiName", firstNonNull(m.get("iti_name"), m.get("itiName")));
            m.put("contactNumber", firstNonNull(m.get("mobile"), m.get("contactNumber")));
            m.put("itiEmailId", m.get("email"));
            m.put("itiType", govPrivate(m));
            m.put("district", districtNames.get(String.valueOf(m.get("distCode"))));
            out.add(m);
        }
        return out;
    }

    @PostMapping("/api/courses")
    @ResponseBody
    public List<Map<String, Object>> getCourses() {
        List<Map<String, Object>> out = new java.util.ArrayList<>();
        for (Map<String, Object> row : restClient.queryList("/api/trades")) {
            Map<String, Object> m = new java.util.LinkedHashMap<>(row);
            m.put("tradeCode", firstNonNull(m.get("tradeCode"), m.get("trade_code")));
            m.put("tradeName", firstNonNull(m.get("tradeName"), m.get("trade_name")));
            m.put("durationVal", firstNonNull(m.get("durationYrs"), m.get("durationVal")));
            m.put("tradeType", tradeType(m));
            m.put("entryQualification", firstNonNull(m.get("minQual"), m.get("entryQualification")));
            m.put("duration", humanDuration(m.get("durationVal")));
            m.put("minimumAge", "14 Years");
            out.add(m);
        }
        return out;
    }

    private String firstNonNull(Object... values) {
        for (Object v : values) {
            if (v != null && !(v instanceof String && ((String) v).isEmpty())) {
                return String.valueOf(v);
            }
        }
        return null;
    }

    private boolean matchesType(Map<String, Object> row, String type) {
        if (type == null || type.isBlank() || "all".equalsIgnoreCase(type)) {
            return true;
        }
        Object govt = row.get("govt");
        if (govt == null) {
            return "private".equalsIgnoreCase(type);
        }
        return "govt".equalsIgnoreCase(String.valueOf(govt)) ? "govt".equalsIgnoreCase(type) : "private".equalsIgnoreCase(type);
    }

    private String seatItiType(Map<String, Object> row) {
        Object govt = firstNonNull(row.get("govt"), row.get("itiType"));
        if (govt == null) {
            return "Private";
        }
        return "G".equalsIgnoreCase(String.valueOf(govt)) ? "Government ATC" : "Private";
    }

    private String tradeType(Map<String, Object> m) {
        Object t = m.get("eng_Nonengg");
        if (t == null) {
            return "Theory";
        }
        return "E".equalsIgnoreCase(String.valueOf(t)) ? "Engineering" : "Non-Engineering";
    }

    private String humanDuration(Object dur) {
        if (dur == null) return "";
        return String.valueOf(dur) + " Months";
    }

    private Map<String, String> districtNameByCode() {
        Map<String, String> map = new java.util.HashMap<>();
        map.put("1", "District A");
        map.put("2", "District B");
        map.put("3", "District C");
        map.put("4", "District D");
        map.put("5", "District E");
        return map;
    }

    private String govPrivate(Map<String, Object> m) {
        Object govt = m.get("govt");
        if (govt == null) {
            return "Private";
        }
        return "G".equalsIgnoreCase(String.valueOf(govt)) ? "Government" : "Private";
    }
}