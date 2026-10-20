package com.server.frontend.controller.seniors;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;

/**
 * Public informational pages ported from the seniors' UnifiedApp UI.
 *
 * <p>These pages (ITI list, courses, seats open, ATC/ITI phone directory and the
 * About/Course/STRIVE pages) are read-only views. The seniors' app served them
 * out of {@code StudentController} using raw SQL against PostgreSQL; this port
 * reuses the Backend REST API instead, so ITI/trade data has a single source of
 * truth.
 *
 * <p>Route names are kept identical to the seniors' app ({@code /ItiList},
 * {@code /Course}, ...) so the copied JSPs and their links keep working
 * unchanged. None of these routes collide with the existing application: the
 * seniors' 11 colliding routes are all already owned by
 * {@code HomeController}/{@code LoginController} and are deliberately NOT
 * re-declared here.
 */
@Controller
public class SeniorsPublicController {

    private final RestTemplate rest = new RestTemplate();

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

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

    // -------------------------- Data endpoints --------------------------
    // The seniors' pages POST to these endpoints; the copied JSPs keep the
    // same paths so no JSP rework is needed.

    /**
     * ITI directory. The seniors' page sent {@code {"type": "govt"|"private"}}
     * and expected a flat list of ITI rows.
     */
    @PostMapping("/api/iti-details")
    @ResponseBody
    public List<Map<String, Object>> getItiDetails(@RequestBody(required = false) Map<String, String> body) {
        String type = body != null ? body.get("type") : null;
        Map<String, String> districtNames = districtNameByCode();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> row : queryList("/api/itis")) {
            if (!matchesType(row, type)) {
                continue;
            }
            Map<String, Object> m = new LinkedHashMap<>(row);
            // The seniors' JS reads these camelCase keys.
            m.put("itiCode", firstNonNull(row.get("iti_code"), row.get("itiCode")));
            m.put("ncvtCode", firstNonNull(row.get("ncvt_code"), row.get("ncvtCode")));
            m.put("itiName", firstNonNull(row.get("iti_name"), row.get("itiName")));
            m.put("principalName", firstNonNull(row.get("principalname"), row.get("principalName")));
            m.put("mobile", firstNonNull(row.get("mobile"), row.get("contactNumber")));
            m.put("email", row.get("email"));
            m.put("itiType", govPrivate(row));
            m.put("district", districtNames.get(String.valueOf(row.get("distCode"))));
            out.add(m);
        }
        return out;
    }

    /** ATC / ITI phone directory. */
    @PostMapping("/api/atc-iti-phones")
    @ResponseBody
    public List<Map<String, Object>> getAtcItiPhones() {
        Map<String, String> districtNames = districtNameByCode();
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> row : queryList("/api/itis")) {
            Map<String, Object> m = new LinkedHashMap<>(row);
            m.put("itiCode", firstNonNull(row.get("iti_code"), row.get("itiCode")));
            m.put("ncvtCode", firstNonNull(row.get("ncvt_code"), row.get("ncvtCode")));
            m.put("itiName", firstNonNull(row.get("iti_name"), row.get("itiName")));
            m.put("contactNumber", firstNonNull(row.get("mobile"), row.get("contactNumber")));
            m.put("itiEmailId", row.get("email"));
            m.put("itiType", govPrivate(row));
            m.put("district", districtNames.get(String.valueOf(row.get("distCode"))));
            out.add(m);
        }
        return out;
    }

    /** Trade / course catalogue. */
    @PostMapping("/api/courses")
    @ResponseBody
    public List<Map<String, Object>> getCourses() {
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> row : queryList("/api/trades")) {
            Map<String, Object> m = new LinkedHashMap<>(row);
            m.put("tradeCode", firstNonNull(row.get("tradeCode"), row.get("trade_code")));
            m.put("tradeName", firstNonNull(row.get("tradeName"), row.get("trade_name")));
            m.put("durationVal", firstNonNull(row.get("durationYrs"), row.get("durationVal")));
            m.put("tradeType", tradeType(row));
            m.put("entryQualification", firstNonNull(row.get("minQual"), row.get("entryQualification")));
            m.put("duration", humanDuration(m.get("durationVal")));
            m.put("minimumAge", "14 Years");
            out.add(m);
        }
        return out;
    }

    /**
     * Seat matrix summary (open seats).
     *
     * <p>Backed by the Backend's {@code GET /api/reports/iti-trade-seats}, which
     * ports the seniors' raw {@code iti_seatmatrix} query. The Backend wraps
     * results in {@code {success, count, data}}, so the rows are unwrapped and
     * renamed back into the camelCase keys the seniors' JS expects.
     */
    @PostMapping("/api/seats-open")
    @ResponseBody
    public List<Map<String, Object>> getSeatsOpen() {
        List<Map<String, Object>> out = new ArrayList<>();
        for (Map<String, Object> row : queryData("/api/reports/iti-trade-seats")) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("itiType", seatItiType(row));
            m.put("district", firstNonNull(row.get("distName"), row.get("district")));
            m.put("itiCode", firstNonNull(row.get("itiCode"), row.get("iti_code")));
            m.put("ncvtCode", firstNonNull(row.get("ncvtCode"), row.get("ncvt_code")));
            m.put("itiName", firstNonNull(row.get("itiName"), row.get("iti_name")));
            m.put("tradeCode", firstNonNull(row.get("tradeCode"), row.get("trade_code")));
            m.put("trade", firstNonNull(row.get("tradeName"), row.get("trade")));
            m.put("totalSeatsOpened", firstNonNull(row.get("totalSeatsOpened"), row.get("total_seats_opened")));
            m.put("totalReported", firstNonNull(row.get("totalReported"), row.get("total_reported")));
            m.put("totalVacant", firstNonNull(row.get("totalVacant"), row.get("total_vacant")));
            out.add(m);
        }
        return out;
    }

    // -------------------------- helpers --------------------------

    /**
     * Fetches a Backend list endpoint, transparently unwrapping the
     * {@code {success, count, data}} envelope that the report controllers use.
     * Endpoints returning a bare JSON array are supported as well.
     */
    private List<Map<String, Object>> queryData(String path) {
        try {
            ResponseEntity<Object> response = rest.getForEntity(backendBaseUrl + path, Object.class);
            Object body = response.getBody();
            List<Map<String, Object>> rows = new ArrayList<>();
            if (body instanceof List) {
                for (Object item : (List<?>) body) {
                    if (item instanceof Map) {
                        @SuppressWarnings("unchecked")
                        Map<String, Object> m = (Map<String, Object>) item;
                        rows.add(m);
                    }
                }
                return rows;
            }
            if (body instanceof Map) {
                @SuppressWarnings("unchecked")
                Map<String, Object> m = (Map<String, Object>) body;
                Object data = m.get("data");
                if (data instanceof List) {
                    for (Object item : (List<?>) data) {
                        if (item instanceof Map) {
                            @SuppressWarnings("unchecked")
                            Map<String, Object> row = (Map<String, Object>) item;
                            rows.add(row);
                        }
                    }
                }
            }
            return rows;
        } catch (Exception e) {
            // A missing/failed backend must not 500 the public page; render empty.
            return List.of();
        }
    }

    /**
     * The seniors' page labelled Govt ITIs as "Government ATC" and the rest as
     * "Private". Keep that wording so the copied table renders identically.
     */
    private String seatItiType(Map<String, Object> row) {
        Object govt = firstNonNull(row.get("govt"), row.get("itiType"));
        if (govt == null) {
            return "Private";
        }
        return "G".equalsIgnoreCase(String.valueOf(govt)) ? "Government ATC" : "Private";
    }

    private List<Map<String, Object>> queryList(String path) {
        try {
            ResponseEntity<List> response = rest.getForEntity(backendBaseUrl + path, List.class);
            List<?> body = response.getBody();
            if (body == null) {
                return List.of();
            }
            List<Map<String, Object>> out = new ArrayList<>();
            for (Object item : body) {
                if (item instanceof Map) {
                    @SuppressWarnings("unchecked")
                    Map<String, Object> m = (Map<String, Object>) item;
                    out.add(m);
                }
            }
            return out;
        } catch (Exception e) {
            // A missing/failed backend must not 500 the public page; render empty.
            return List.of();
        }
    }

    /**
     * Maps district code to district name, using the Backend district master.
     * The ITI entity only carries {@code distCode}, but the seniors' pages
     * display the district name.
     */
    private Map<String, String> districtNameByCode() {
        Map<String, String> names = new LinkedHashMap<>();
        for (Map<String, Object> row : queryList("/api/districts")) {
            Object code = firstNonNull(row.get("code"), row.get("dist_code"), row.get("distCode"));
            Object name = firstNonNull(row.get("name"), row.get("dist_name"), row.get("distName"));
            if (code != null && name != null) {
                names.put(String.valueOf(code).trim(), String.valueOf(name));
            }
        }
        return names;
    }

    private boolean matchesType(Map<String, Object> row, String type) {
        if (type == null || type.isBlank() || "all".equalsIgnoreCase(type)) {
            return true;
        }
        String govt = String.valueOf(row.getOrDefault("govt", row.get("itiType")));
        boolean isGovt = "G".equalsIgnoreCase(govt) || "Govt".equalsIgnoreCase(govt)
                || "Government".equalsIgnoreCase(govt);
        return "govt".equalsIgnoreCase(type) ? isGovt : !isGovt;
    }

    private String govPrivate(Map<String, Object> row) {
        Object govt = row.get("govt");
        if (govt != null) {
            return "G".equalsIgnoreCase(String.valueOf(govt)) ? "Govt" : "Private";
        }
        Object type = row.get("itiType");
        return type == null ? "" : String.valueOf(type);
    }

    private String tradeType(Map<String, Object> row) {
        Object eng = firstNonNull(row.get("eng_Nonengg"), row.get("eng_nonengg"), row.get("tradeType"));
        if (eng == null) {
            return "";
        }
        return "E".equalsIgnoreCase(String.valueOf(eng)) ? "Engineering" : "Non-Engineering";
    }

    private String humanDuration(Object raw) {
        if (raw == null) {
            return "N/A";
        }
        try {
            int months = Integer.parseInt(String.valueOf(raw));
            return switch (months) {
                case 12 -> "1 Year";
                case 24 -> "2 Years";
                case 6 -> "6 Months";
                default -> months + " Months";
            };
        } catch (NumberFormatException e) {
            return String.valueOf(raw);
        }
    }

    private Object firstNonNull(Object... values) {
        for (Object v : values) {
            if (v != null) {
                return v;
            }
        }
        return null;
    }
}
