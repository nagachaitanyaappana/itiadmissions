package com.server.frontend.controller.admission;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;
import java.util.concurrent.TimeUnit;

import jakarta.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Admission Counseling (DCP seat-allotment) flow.
 *
 * <p>Rebuilds documentation screens 2-4 in the SAME legacy UI as the live
 * site (screenshot 1: gen.jpg banner + pale-green #menu-bar + dark-blue
 * footer):
 *
 * <ol>
 *   <li>GET /AdmissionCounseling/Start - "Start Admission Process - Select
 *       all the following" (Caste, Qualification, Admission Timings, Phase,
 *       Year) - docs screen 2/3 first form
 *       (old startAdmission_ConvvinerLevel.jsp).</li>
 *   <li>GET /AdmissionCounseling/Counseling - "Admission Counseling" rank
 *       entry + candidate info + district ITI/trade seat matrix + "Take
 *       Admission" memo - docs screens 3/4
 *       (old itiAdmissionEntry.do).</li>
 * </ol>
 *
 * <p>Backend (port 5050, per swagger tag "admissions",
 * operationId "getCandidatesByRank"):
 * {@code GET /admission/candidate?rank=&phase=&year=}
 * -&gt; array of CandidateResponseDTO
 * {regid, rank, qual, dist_code, iti_code, phase, year, app_status}.
 * The same-origin /api/counseling/* proxies below forward to it so the
 * JSP/JS never hits CORS issues.
 */
@Controller
@RequestMapping("/AdmissionCounseling")
public class AdmissionCounselingController {

    private final RestTemplate rest = new RestTemplate();

    /** Timeout + small result cache so repeat rank lookups feel instant. */
    private static final long RESOLVE_TIMEOUT_MS = 25000L;

    /**
     * Rank resolution is cached only briefly. The rank -> candidate mapping is not immutable: it
     * changes every time the merit list is regenerated (a rank can start pointing at a different
     * regid, or the candidate's details can change). An entry that never expires therefore keeps
     * serving a superseded candidate for the life of the JVM -- the counseling page showed an old
     * candidate after a fresh merit run because of exactly that. Entries older than this TTL are
     * treated as misses and re-resolved from the backend.
     */
    private static final long RESOLVE_CACHE_TTL_MS = 30000L;

    private static final Map<String, CacheEntry> RESOLVE_CACHE = new ConcurrentHashMap<>();

    /** A cached resolve result plus the instant it stops being served. */
    private record CacheEntry(Object value, long expiresAt) {
    }

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    // ========== PAGES (legacy UI, same chrome as live site) ==========

    /** Docs screen 2/3 - Start Admission Process form. */
    @GetMapping("/Start")
    public String start(HttpServletRequest request, org.springframework.ui.Model model) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        addCurrentPhase(model);
        if ("1".equals(model.getAttribute("currentPhase"))) {
            return "redirect:/AdmissionPhase";
        }
        if (!"4".equals(sessionValue(request, "roleId"))) {
            model.addAttribute("phase2RoleMessage",
                    "Phase 2 and later admissions are processed by the ITI login for that ITI.");
            return "admission/phase2RoleRequired";
        }
        return "admission/counselingStart";
    }

    /**
     * Docs screens 3/4 - Rank entry, candidate + ITI matrix, Take Admission memo.
     *
     * <p>Gated like the legacy {@code StartAdmissionProcess}: with no counselling schedule for the
     * district today the process is blocked and the operator sees {@code CouncilDates_notFound}.
     */
    @GetMapping("/Counseling")
    public String counseling(HttpServletRequest request, org.springframework.ui.Model model) {
        if (notLoggedIn(request)) {
            return "redirect:/?error=session";
        }
        addCurrentPhase(model);
        if ("1".equals(model.getAttribute("currentPhase"))) {
            return "redirect:/AdmissionPhase";
        }
        if (!"4".equals(sessionValue(request, "roleId"))) {
            model.addAttribute("phase2RoleMessage",
                    "Phase 2 and later admissions are processed by the ITI login for that ITI.");
            return "admission/phase2RoleRequired";
        }
        if (!hasCouncilToday(request)) {
            return "admission/councilDatesNotFound";
        }
        return "admission/counselingRank";
    }

    /** Publishes the active year and phase (from admissions.admission_phase) to the page defaults. */
    private void addCurrentPhase(org.springframework.ui.Model model) {
        ResponseEntity<Map<String, Object>> resp = rest.exchange(
                backendBaseUrl + "/api/admission/window-status",
                org.springframework.http.HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {
                });
        Map<String, Object> body = resp.getBody();
        Object phase = body == null ? null : body.get("phase");
        Object year = body == null ? null : body.get("year");
        if (phase == null || year == null || String.valueOf(phase).isBlank()
                || String.valueOf(year).isBlank()) {
            throw new IllegalStateException(
                    "Current admission phase and year are not configured.");
        }
        model.addAttribute("currentPhase", String.valueOf(phase));
        model.addAttribute("currentYear", String.valueOf(year));
        model.addAttribute("admissionWindowOpen", Boolean.TRUE.equals(body.get("open")));
    }

    /** True when the caller's district/ITI has a counselling session scheduled for today. */
    private boolean hasCouncilToday(HttpServletRequest request) {
        try {
            ResponseEntity<Map<String, Object>> resp = rest.exchange(
                    backendBaseUrl + "/admission-timings/today",
                    org.springframework.http.HttpMethod.GET,
                    new HttpEntity<>(scopeHeaders(request)),
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });
            Map<String, Object> body = resp.getBody();
            return body == null || !Boolean.FALSE.equals(body.get("hasScheduleToday"));
        } catch (Exception e) {
            // If the check itself cannot run, do not hard-block the page.
            return true;
        }
    }

    // ========== SAME-ORIGIN PROXIES (JS calls these, not the backend directly) ==========

    /**
     * Proxy for the user's backend API:
     * {@code GET /admission/candidate?rank=1&phase=1&year=2025}.
     * Returns the raw backend array (or empty array when the backend 500s /
     * has no row for that rank/phase/year) so the UI can render the
     * "no record" state instead of breaking.
     */
    @GetMapping("/api/candidate")
    @ResponseBody
    public ResponseEntity<Object> candidate(@RequestParam("rank") String rank,
                                            @RequestParam("phase") String phase,
                                            @RequestParam("year") String year) {
        String url = UriComponentsBuilder.fromUriString(backendBaseUrl + "/admission/candidate")
                .queryParam("rank", rank)
                .queryParam("phase", phase)
                .queryParam("year", year)
                .toUriString();
        try {
            ResponseEntity<Object> resp = rest.getForEntity(url,
                    Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            // Backend currently 500s for unknown rank/phase/year combos;
            // surface an empty list so the page shows "no candidate found".
            return ResponseEntity.ok(new Object[0]);
        }
    }

    /** Proxy: GET /admission/itis/{distCode} - ITI names in the district. */
    @GetMapping({"/api/itis", "/api/itis/{distCode}"})
    @ResponseBody
    public ResponseEntity<Object> itis(
            @RequestParam(value = "distCode", required = false) String distCodeParam,
            @org.springframework.web.bind.annotation.PathVariable(value = "distCode", required = false) String distCodePath) {
        String distCode = distCodePath != null ? distCodePath : distCodeParam;
        if (distCode == null || distCode.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "distCode is required"));
        }
        String url = backendBaseUrl + "/admission/itis/" + distCode;
        try {
            ResponseEntity<Object> resp = rest.getForEntity(url, Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(new Object[0]);
        }
    }

    /** Proxy: GET /admission/master-data - {itiNames[], tradeNames[]}. */
    @GetMapping("/api/master-data")
    @ResponseBody
    public ResponseEntity<Object> masterData() {
        try {
            ResponseEntity<Object> resp = rest.getForEntity(
                    backendBaseUrl + "/admission/master-data", Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("itiNames", new Object[0], "tradeNames", new Object[0]));
        }
    }

    /** Proxy: GET /api/reports/student-details?regid= - full student record (fallback rank lookup). */
    @GetMapping("/api/student-details")
    @ResponseBody
    public ResponseEntity<Object> studentDetails(@RequestParam("regid") String regid) {
        String url = UriComponentsBuilder.fromUriString(backendBaseUrl + "/api/reports/student-details")
                .queryParam("regid", regid)
                .toUriString();
        try {
            ResponseEntity<Object> resp = rest.getForEntity(url, Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("registration", null));
        }
    }

    /** Proxy: GET /api/reports/students-not-admitted?year=&phase= - rank->regid fallback list. */
    @GetMapping("/api/students-not-admitted")
    @ResponseBody
    public ResponseEntity<Object> studentsNotAdmitted(@RequestParam("year") String year,
                                                      @RequestParam(value = "phase", required = false) String phase) {
        UriComponentsBuilder b = UriComponentsBuilder
                .fromUriString(backendBaseUrl + "/api/reports/students-not-admitted")
                .queryParam("year", year);
        if (phase != null && !phase.isBlank()) b.queryParam("phase", phase);
        try {
            ResponseEntity<Object> resp = rest.getForEntity(b.toUriString(), Object.class);
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("data", new Object[0], "success", false));
        }
    }

    /** Resolve a counseling candidate from a Rank number (primary + fallback chain). */
    @GetMapping("/api/candidate-resolve")
    @ResponseBody
    public ResponseEntity<Object> candidateResolve(@RequestParam("rank") String rank,
                                                   @RequestParam("phase") String phase,
                                                   @RequestParam("year") String year,
                                                   HttpServletRequest request) {
        if (!"4".equals(sessionValue(request, "roleId"))) {
            return ResponseEntity.status(403).body(Map.of(
                    "source", "scope",
                    "message", "Phase 2 and later admissions require an ITI login."));
        }
        Map<String, Object> cycle = currentCycle();
        phase = String.valueOf(cycle.get("phase"));
        year = String.valueOf(cycle.get("year"));
        if ("1".equals(phase)) {
            return ResponseEntity.status(409).body(Map.of(
                    "source", "phase",
                    "candidate", null,
                    "message", "Use the Phase 1 admission workflow for the current cycle."));
        }
        if (!Boolean.TRUE.equals(cycle.get("open"))) {
            return ResponseEntity.status(410).body(Map.of(
                    "source", "window",
                    "candidate", null,
                    "message", "Admission Date is Expired"));
        }
        String ins = sessionValue(request, "insCode");
        String key = sessionValue(request, "roleId") + "|" + ins + "|" + rank + "|" + phase + "|" + year;
        Object cached = cacheGet(key);
        if (cached != null) return ResponseEntity.ok(cached);

        // 1) primary path: the verified rank-lookup, scoped to the caller's district/ITI. The old
        // primary (GET /admission/candidate) returned a row with every field null -- its entity/DTO
        // copy dropped all non-matching properties (regid Integer->String, distCode vs dist_code,
        // rank String->Integer) -- so the page always rendered an empty candidate.
        Map<String, Object> resolved = resolveFromRankLookup(rank, phase, year, request);
        if (resolved != null) {
            cachePut(key, resolved);
            return ResponseEntity.ok(resolved);
        }
        // 2) fallback scan below (parallel student-details merit match, bounded)
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("source", "none");
        out.put("rank", rank);
        out.put("phase", phase);
        out.put("year", year);
        out.put("candidate", null);
        return ResponseEntity.ok(out);
    }

    /** Returns a still-fresh cached resolve, or null (evicting the entry) once its TTL elapsed. */
    private static Object cacheGet(String key) {
        CacheEntry entry = RESOLVE_CACHE.get(key);
        if (entry == null) {
            return null;
        }
        if (System.currentTimeMillis() >= entry.expiresAt()) {
            RESOLVE_CACHE.remove(key);
            return null;
        }
        return entry.value();
    }

    /** Stores a resolve result that stays valid for {@link #RESOLVE_CACHE_TTL_MS}. */
    private static void cachePut(String key, Object value) {
        RESOLVE_CACHE.put(key, new CacheEntry(value, System.currentTimeMillis() + RESOLVE_CACHE_TTL_MS));
    }

    /**
     * Calls {@code POST /api/admission/rank-lookup}, forwarding the login scope as headers, and maps
     * the returned student record onto the field names the counseling JSP reads
     * (name / fatherName / caste / gender / dist_code / iti_code / ...). Returns null on any failure
     * so the caller can fall back.
     */
    private Map<String, Object> resolveFromRankLookup(String rank, String phase, String year,
                                                      HttpServletRequest request) {
        try {
            HttpHeaders headers = scopeHeaders(request);
            headers.setContentType(MediaType.APPLICATION_JSON);
            ResponseEntity<Map<String, Object>> resp = rest.exchange(
                    backendBaseUrl + "/api/admission/rank-lookup",
                    org.springframework.http.HttpMethod.POST,
                    new HttpEntity<>(Map.of("rank", rank), headers),
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });
            Map<String, Object> body = resp.getBody();
            if (body == null || !Boolean.TRUE.equals(body.get("success"))) {
                return null;
            }
            Map<String, Object> data = asMap(body.get("data"));
            if (data == null) {
                return null;
            }
            boolean districtLogin = "3".equals(sessionValue(request, "roleId"));
            String distCode = districtLogin ? sessionValue(request, "insCode") : null;

            Map<String, Object> cand = new LinkedHashMap<>();
            cand.put("regid", data.get("regid"));
            cand.put("rank", data.get("rank"));
            cand.put("name", data.get("name"));
            cand.put("fatherName", data.get("fname"));
            cand.put("caste", data.get("caste"));
            cand.put("gender", data.get("gender"));
            cand.put("qual", "");
            cand.put("dist_code", distCode);
            cand.put("distName", distCode);
            cand.put("iti_code", sessionValue(request, "insCode"));
            cand.put("phase", phase);
            cand.put("year", year);
            cand.put("app_status", Boolean.TRUE.equals(data.get("is_admitted")) ? "A" : "N");
            cand.put("dob", data.get("dob"));
            cand.put("phc", data.get("phc"));
            cand.put("exservice", data.get("exservice"));
            cand.put("ssc_regno", data.get("ssc_regno"));
            cand.put("ssc_year", data.get("ssc_year"));
            cand.put("is_admitted", data.get("is_admitted"));
            cand.put("admission_details", data.get("admission_details"));
            cand.put("photo_base64", data.get("photo_base64"));

            Map<String, Object> out = new LinkedHashMap<>();
            out.put("source", "rank-lookup");
            out.put("rank", rank);
            out.put("phase", phase);
            out.put("year", year);
            out.put("candidate", cand);
            return out;
        } catch (Exception ignored) {
            return null;
        }
    }

    /** Login-scope headers from the servlet session, matching the page's own apiHeaders(). */
    private HttpHeaders scopeHeaders(HttpServletRequest request) {
        HttpHeaders headers = new HttpHeaders();
        String role = sessionValue(request, "roleId");
        String ins = sessionValue(request, "insCode");
        if (role != null) headers.set("X-Role-Id", role);
        if (ins != null) {
            headers.set("X-Ins-Code", ins);
            if ("3".equals(role)) {
                headers.set("X-Dist-Code", ins);
            } else {
                headers.set("X-Iti-Code", ins);
            }
        }
        return headers;
    }

    private static String sessionValue(HttpServletRequest request, String name) {
        if (request == null) return null;
        var session = request.getSession(false);
        if (session == null) return null;
        Object value = session.getAttribute(name);
        return value == null ? null : String.valueOf(value);
    }

    private Map<String, Object> currentCycle() {
        ResponseEntity<Map<String, Object>> resp = rest.exchange(
                backendBaseUrl + "/api/admission/window-status",
                org.springframework.http.HttpMethod.GET,
                null,
                new ParameterizedTypeReference<Map<String, Object>>() {
                });
        Map<String, Object> body = resp.getBody();
        if (body == null || body.get("phase") == null || body.get("year") == null) {
            throw new IllegalStateException(
                    "Current admission phase and year are not configured.");
        }
        return body;
    }

    private static boolean notLoggedIn(HttpServletRequest request) {
        var session = request.getSession(false);
        return session == null || session.getAttribute("sessionUser") == null;
    }

    /** Paged fallback: parallel meritList[].rank+phase match. Bounded by timeout. */
    private Map<String, Object> fallbackByMerit(String rank, String phase, String year) {
        ExecutorService pool = Executors.newFixedThreadPool(10);
        long deadline = System.currentTimeMillis() + RESOLVE_TIMEOUT_MS;
        try {
            int size = 200;
            for (int page = 0; page < 5; page++) {
                String listUrl = UriComponentsBuilder
                        .fromUriString(backendBaseUrl + "/api/reports/students-not-admitted")
                        .queryParam("year", year).queryParam("phase", phase)
                        .queryParam("page", page).queryParam("size", size).toUriString();
                Map<String, Object> listResp = rest.exchange(listUrl,
                        org.springframework.http.HttpMethod.GET, null,
                        new ParameterizedTypeReference<Map<String, Object>>() {
                        }).getBody();
                if (listResp == null) break;
                List<Object> rows = toList(listResp.get("data"));
                if (rows.isEmpty()) break;
                Map<String, Object> hit = scanPageParallel(pool, rows, rank, phase, year, deadline);
                if (hit != null) return hit;
                Number count = (Number) listResp.get("count");
                if (count != null && (page + 1) * size >= count.intValue()) break;
                if (System.currentTimeMillis() > deadline) break;
            }
        } catch (Exception ignored) {
        } finally {
            pool.shutdownNow();
        }
        return null;
    }

    /** Scan one page of not-admitted rows in parallel for a merit match. */
    private Map<String, Object> scanPageParallel(ExecutorService pool, List<Object> rows,
                                                 String rank, String phase, String year,
                                                 long deadline) {
        List<Future<Map<String, Object>>> futures = new ArrayList<>();
        for (Object r : rows) {
            Map<String, Object> row0 = asMap(r);
            if (row0 == null) continue;
            Object regid = row0.get("regid");
            if (regid == null) continue;
            String rid = String.valueOf(regid);
            Callable<Map<String, Object>> task = () -> {
                Map<String, Object> sd = fetchDetails(rid);
                if (sd == null) return null;
                return matchMerit(sd, row0, rank, phase, year);
            };
            futures.add(pool.submit(task));
        }
        for (Future<Map<String, Object>> f : futures) {
            long left = deadline - System.currentTimeMillis();
            if (left <= 0) break;
            try {
                Map<String, Object> hit = f.get(Math.min(left, 4000L), TimeUnit.MILLISECONDS);
                if (hit != null) {
                    for (Future<Map<String, Object>> o : futures) o.cancel(true);
                    return hit;
                }
            } catch (Exception ignored) {
            }
        }
        return null;
    }

    /** Fetch one student-details record by regid (null on error). */
    private Map<String, Object> fetchDetails(String regid) {
        try {
            String sdUrl = UriComponentsBuilder
                    .fromUriString(backendBaseUrl + "/api/reports/student-details")
                    .queryParam("regid", regid).toUriString();
            ResponseEntity<Map<String, Object>> resp = rest.exchange(sdUrl,
                    org.springframework.http.HttpMethod.GET, null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });
            return resp.getBody();
        } catch (Exception ignored) {
            return null;
        }
    }

    /** Build unified candidate when a merit entry matches rank+phase. */
    private Map<String, Object> matchMerit(Map<String, Object> sd, Map<String, Object> row0,
                                           String rank, String phase, String year) {
        for (Object m : toList(sd.get("meritList"))) {
            Map<String, Object> mm = asMap(m);
            if (mm == null) continue;
            boolean ok = String.valueOf(mm.get("rank")).equals(String.valueOf(rank))
                    && String.valueOf(mm.get("phase")).equals(String.valueOf(phase));
            if (!ok) continue;
            return buildCandidate(sd, row0, mm, rank, phase, year);
        }
        return null;
    }

    /** Assemble the unified candidate payload from registration + merit + list row. */
    private Map<String, Object> buildCandidate(Map<String, Object> sd, Map<String, Object> row0,
                                              Map<String, Object> mm,
                                              String rank, String phase, String year) {
        Map<String, Object> reg = asMapOrEmpty(sd.get("registration"));
        Map<String, Object> cand = new LinkedHashMap<>();
        cand.put("regid", reg.getOrDefault("registrationId", row0.getOrDefault("regid", "")));
        cand.put("rank", rank);
        cand.put("phase", phase);
        cand.put("year", year);
        cand.put("name", reg.getOrDefault("name", row0.getOrDefault("name", "")));
        cand.put("fatherName", reg.getOrDefault("fatherName", row0.getOrDefault("fname", "")));
        cand.put("dist_code", mm.getOrDefault("distName", ""));
        cand.put("distName", mm.getOrDefault("distName", ""));
        cand.put("iti_code", mm.getOrDefault("itiName", ""));
        cand.put("qual", mm.getOrDefault("qualification", "all"));
        cand.put("app_status", row0.getOrDefault("appStatus", "A"));
        cand.put("gender", reg.getOrDefault("gender", row0.getOrDefault("gender", "")));
        cand.put("caste", reg.getOrDefault("caste", row0.getOrDefault("caste", "")));
        cand.put("phoneNo", reg.getOrDefault("phoneNo", row0.getOrDefault("phno", "")));
        Map<String, Object> out = new LinkedHashMap<>();
        out.put("source", "student-details");
        out.put("rank", rank);
        out.put("phase", phase);
        out.put("year", year);
        out.put("candidate", cand);
        return out;
    }

    private static List<Object> toList(Object body) {
        if (body instanceof List<?> list) {
            return new ArrayList<>(list);
        }
        if (body instanceof Map<?, ?> map) {
            Object d = map.get("data");
            if (d instanceof List<?> dataList) {
                return new ArrayList<>(dataList);
            }
        }
        return new ArrayList<>();
    }

    /** Type-safe view of a decoded JSON object without unchecked casts. */
    private static Map<String, Object> asMap(Object value) {
        if (!(value instanceof Map<?, ?> map)) {
            return null;
        }
        Map<String, Object> out = new LinkedHashMap<>();
        for (Map.Entry<?, ?> e : map.entrySet()) {
            out.put(String.valueOf(e.getKey()), e.getValue());
        }
        return out;
    }

    private static Map<String, Object> asMapOrEmpty(Object value) {
        Map<String, Object> m = asMap(value);
        return m != null ? m : Map.of();
    }

    /**
     * Proxy the real seat matrix: {@code POST /api/admission/iti-seat-matrix}.
     * Returns {@code {success, year, phase, data:[{iti_code,iti_name,trade_code,trade_name,
     * strength_total,categories:{General:{T,F,V},IM,PH,EXS}}]}} for the caller's scope
     * (district login = every ITI in the district).
     */
    @PostMapping("/api/seat-matrix")
    @ResponseBody
    public ResponseEntity<Object> seatMatrix(HttpServletRequest request) {
        try {
            HttpHeaders headers = scopeHeaders(request);
            ResponseEntity<Object> resp = rest.exchange(
                    backendBaseUrl + "/api/admission/iti-seat-matrix",
                    org.springframework.http.HttpMethod.POST,
                    new HttpEntity<>(headers),
                    new ParameterizedTypeReference<Object>() {
                    });
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (org.springframework.web.client.HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode().value())
                    .body(e.getResponseBodyAs(Map.class));
        } catch (Exception e) {
            return ResponseEntity.status(502)
                    .body(Map.of("success", false, "error", "Unable to load the seat matrix."));
        }
    }

    /** Proxy the type-of-admission (board) list: {@code GET /api/admission/iti-boards}. */
    @GetMapping("/api/iti-boards")
    @ResponseBody
    public ResponseEntity<Object> itiBoards(HttpServletRequest request) {
        try {
            HttpEntity<Void> entity = new HttpEntity<>(scopeHeaders(request));
            ResponseEntity<Object> resp = rest.exchange(
                    backendBaseUrl + "/api/admission/iti-boards",
                    org.springframework.http.HttpMethod.GET, entity,
                    new ParameterizedTypeReference<Object>() {
                    });
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "data", new Object[0]));
        }
    }

    /**
     * Proxy the real admission write: {@code POST /api/admission/take-admission}.
     * The body is forwarded as-is (the page builds the legacy snake_case keys).
     */
    @PostMapping("/api/take-admission")
    @ResponseBody
    public ResponseEntity<Object> takeAdmission(@RequestBody Map<String, Object> body,
                                                HttpServletRequest request) {
        try {
            HttpHeaders headers = scopeHeaders(request);
            headers.setContentType(MediaType.APPLICATION_JSON);
            ResponseEntity<Object> resp = rest.exchange(
                    backendBaseUrl + "/api/admission/take-admission",
                    org.springframework.http.HttpMethod.POST,
                    new HttpEntity<>(body, headers),
                    new ParameterizedTypeReference<Object>() {
                    });
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (org.springframework.web.client.HttpStatusCodeException e) {
            return ResponseEntity.status(e.getStatusCode().value())
                    .body(e.getResponseBodyAs(Map.class));
        } catch (Exception e) {
            return ResponseEntity.status(502)
                    .body(Map.of("success", false, "error", "Unable to record the admission."));
        }
    }

    /** Proxy the permitted shift/unit options: {@code GET /api/admission/shift-unit}. */
    @GetMapping("/api/shift-unit")
    @ResponseBody
    public ResponseEntity<Object> shiftUnit(@RequestParam("itiCode") String itiCode,
                                            @RequestParam("tradeCode") String tradeCode,
                                            HttpServletRequest request) {
        String url = UriComponentsBuilder.fromUriString(backendBaseUrl + "/api/admission/shift-unit")
                .queryParam("itiCode", itiCode)
                .queryParam("tradeCode", tradeCode)
                .toUriString();
        try {
            HttpEntity<Void> entity = new HttpEntity<>(scopeHeaders(request));
            ResponseEntity<Object> resp = rest.exchange(url,
                    org.springframework.http.HttpMethod.GET, entity,
                    new ParameterizedTypeReference<Object>() {
                    });
            return ResponseEntity.status(resp.getStatusCode()).body(resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("success", false, "shifts", new Object[0]));
        }
    }

    /** Proxy open-seats. */
    @GetMapping("/api/open-seats")
    @ResponseBody
    public ResponseEntity<Object> openSeats(@RequestParam("year") String year) {
        String url = UriComponentsBuilder.fromUriString(backendBaseUrl + "/api/reports/open-seats")
                .queryParam("year", year)
                .toUriString();
        try {
            ResponseEntity<Map<String, Object>> resp = rest.exchange(url,
                    org.springframework.http.HttpMethod.GET, null,
                    new ParameterizedTypeReference<Map<String, Object>>() {
                    });
            return ResponseEntity.ok((Object) resp.getBody());
        } catch (Exception e) {
            return ResponseEntity.ok(Map.of("data", new Object[0], "success", false));
        }
    }
}
