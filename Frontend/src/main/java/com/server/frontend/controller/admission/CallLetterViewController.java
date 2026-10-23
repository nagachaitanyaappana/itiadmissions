package com.server.frontend.controller.admission;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Call Letter (DISTLOGIN -&gt; Admissions -&gt; Call Letter) two-screen flow.
 * Same legacy UI as the Schedule Entry / Counseling pages (gen.jpg banner,
 * pale-green menu-bar, dark-blue footer).
 * Page: GET /CallLetterView -&gt; admission/callLetterView.jsp (Screen 1
 * From Rank + To Rank + Caste form + Screen 2 results table).
 *
 * <p>Real backend (port 5050, Call_Letter_Controller):
 * {@code GET /admission/call-letter?rank=&caste=} -&gt; array of
 * Call_Letter_DTO {rank, caste, regid, itiCode, qualification, tempPk, phase,
 * trno, year, name}. The backend serves ONE rank per call, so a From..To range
 * is honoured by calling it once per rank here (server-side aggregation) and
 * returning the combined array. No backend change, no mock data, no new API.
 */
@Controller
@RequestMapping("/CallLetterView")
public class CallLetterViewController {

    private final RestTemplate rest = new RestTemplate();

    /** Safety cap so a huge range cannot hammer the backend. */
    private static final int MAX_RANGE = 100;

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    /** Screen 1 - From Rank + To Rank + Caste selection form. */
    @GetMapping({ "", "/", "/Interface" })
    public String callLetterView(HttpServletRequest request) {
        var session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return "redirect:/?error=session";
        }
        Object role = session.getAttribute("roleId");
        if (role == null || (!"3".equals(String.valueOf(role)) && !"4".equals(String.valueOf(role)))) {
            return "redirect:/?error=session";
        }
        return "admission/callLetterView";
    }

    /**
     * Same-origin proxy so the JSP/JS never hits CORS issues.
     * Validates fromRank/toRank/caste, fans out to the real single-rank backend
     * endpoint once per rank, merges every returned record into one array.
     * Empty merged array means "no records" (backend reachable, nothing for that
     * range/caste). HTTP 5xx with {error} means the backend call itself failed.
     */
    @GetMapping("/api/call-letter")
    @ResponseBody
    public ResponseEntity<Object> callLetter(@RequestParam("fromRank") String fromRank,
            @RequestParam("toRank") String toRank,
            @RequestParam("caste") String caste) {
        int from;
        int to;
        try {
            from = Integer.parseInt(fromRank == null ? "" : fromRank.trim());
            to = Integer.parseInt(toRank == null ? "" : toRank.trim());
        } catch (NumberFormatException nfe) {
            return ResponseEntity.badRequest().body(Map.of("error", "From Rank and To Rank must be numeric."));
        }
        if (from <= 0 || to <= 0) {
            return ResponseEntity.badRequest().body(Map.of("error", "From Rank and To Rank must be positive numbers."));
        }
        if (from > to) {
            return ResponseEntity.badRequest().body(Map.of("error", "From Rank must not be greater than To Rank."));
        }
        if (to - from + 1 > MAX_RANGE) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Rank range too large. Please select at most " + MAX_RANGE + " ranks."));
        }
        String casteValue = caste == null ? "" : caste.trim();
        if (casteValue.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Caste is required."));
        }

        List<Object> merged = new ArrayList<>();
        int okCalls = 0;
        int failCalls = 0;
        for (int rank = from; rank <= to; rank++) {
            String url = UriComponentsBuilder.fromUriString(backendBaseUrl + "/admission/call-letter")
                    .queryParam("rank", rank)
                    .queryParam("caste", casteValue)
                    .toUriString();
            try {
                ResponseEntity<Object> resp = rest.exchange(url, HttpMethod.GET, null,
                        new ParameterizedTypeReference<Object>() {
                        });
                okCalls++;
                merged.addAll(toList(resp.getBody()));
            } catch (Exception e) {
                failCalls++;
            }
        }
        if (okCalls == 0 && failCalls > 0) {
            Map<String, Object> err = new LinkedHashMap<>();
            err.put("error", "Backend unavailable. Please try again later.");
            return ResponseEntity.status(502).body(err);
        }
        return ResponseEntity.ok(merged);
    }

    /**
     * Same-origin proxy for the printable call letter.
     * Single mode: {@code regid}. Bulk mode: {@code fromRank}/{@code toRank}/{@code caste}.
     * District/ITI scope is derived from the authenticated session, never from request input.
     */
    @GetMapping("/api/call-letter/print")
    @ResponseBody
    public ResponseEntity<Object> callLetterPrint(
            @RequestParam(value = "regid", required = false) String regid,
            @RequestParam(value = "fromRank", required = false) String fromRank,
            @RequestParam(value = "toRank", required = false) String toRank,
            @RequestParam(value = "caste", required = false) String caste,
            HttpServletRequest request) {
        var session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return ResponseEntity.status(401).body(Map.of("error", "Login is required."));
        }
        String role = String.valueOf(session.getAttribute("roleId"));
        String insCode = String.valueOf(session.getAttribute("insCode"));
        if (!"3".equals(role) && !"4".equals(role)) {
            return ResponseEntity.status(403).body(Map.of("error", "District or ITI login is required."));
        }
        String dist = "3".equals(role) ? insCode : "";
        if ("3".equals(role) && dist.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "District is not configured for this login."));
        }
        if ("4".equals(role) && (insCode.isBlank() || insCode.equals("null"))) {
            return ResponseEntity.badRequest().body(Map.of("error", "ITI is not configured for this login."));
        }
        String reg = regid == null ? "" : regid.trim();
        UriComponentsBuilder builder = UriComponentsBuilder
                .fromUriString(backendBaseUrl + "/admission/call-letter/print")
                .queryParam("distCode", dist);
        if (!reg.isEmpty()) {
            if (!reg.matches("\\d+")) {
                return ResponseEntity.badRequest().body(Map.of("error", "Register Number must be numeric."));
            }
            builder.queryParam("regid", reg);
        } else {
            int from;
            int to;
            try {
                from = Integer.parseInt(fromRank == null ? "" : fromRank.trim());
                to = Integer.parseInt(toRank == null ? "" : toRank.trim());
            } catch (NumberFormatException nfe) {
                return ResponseEntity.badRequest().body(Map.of("error", "From Rank and To Rank must be numeric."));
            }
            if (from <= 0 || to <= 0) {
                return ResponseEntity.badRequest().body(Map.of("error", "From Rank and To Rank must be positive numbers."));
            }
            if (from > to) {
                return ResponseEntity.badRequest().body(Map.of("error", "From Rank must not be greater than To Rank."));
            }
            if (to - from > MAX_RANGE) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Ranks difference should be less than " + MAX_RANGE + "."));
            }
            builder.queryParam("fromRank", from).queryParam("toRank", to)
                    .queryParam("caste", caste == null ? "all" : caste.trim());
        }
        try {
            ResponseEntity<Object> resp = rest.exchange(builder.toUriString(), HttpMethod.GET,
                    new HttpEntity<>(scopeHeaders(request)),
                    new ParameterizedTypeReference<Object>() {
                    });
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (HttpStatusCodeException e) {
            int code = e.getStatusCode().value();
            if (code == 400) {
                return ResponseEntity.badRequest().body(e.getResponseBodyAs(Map.class));
            }
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to generate call letter. Please try again."));
        } catch (Exception e) {
            return ResponseEntity.status(502)
                    .body(Map.of("error", "Unable to generate call letter. Please try again."));
        }
    }

    private static List<Object> toList(Object body) {
        if (body instanceof List<?> list) {
            return new ArrayList<>(list);
        }
        if (body instanceof Map<?, ?> map) {
            Object data = map.get("data");
            if (data instanceof List<?> dataList) {
                return new ArrayList<>(dataList);
            }
        }
        return new ArrayList<>();
    }

    private HttpHeaders scopeHeaders(HttpServletRequest request) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        var session = request.getSession(false);
        if (session == null) {
            return headers;
        }
        Object role = session.getAttribute("roleId");
        Object ins = session.getAttribute("insCode");
        if (role != null) {
            headers.set("X-Role-Id", String.valueOf(role));
        }
        if (ins != null) {
            headers.set("X-Ins-Code", String.valueOf(ins));
            if ("3".equals(String.valueOf(role))) {
                headers.set("X-Dist-Code", String.valueOf(ins));
            } else if ("4".equals(String.valueOf(role))) {
                headers.set("X-Iti-Code", String.valueOf(ins));
            }
        }
        return headers;
    }
}
