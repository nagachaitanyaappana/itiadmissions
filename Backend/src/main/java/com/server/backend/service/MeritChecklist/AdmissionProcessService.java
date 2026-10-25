package com.server.backend.service.MeritChecklist;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.regex.Pattern;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.TransactionDefinition;
import org.springframework.transaction.support.TransactionSynchronization;
import org.springframework.transaction.support.TransactionSynchronizationManager;
import org.springframework.transaction.support.TransactionTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.CouncilMeritsRequest;
import com.server.backend.DTO.ProcessOptimizeRequest;
import com.server.backend.DTO.TakeAdmissionRequest;
import com.server.backend.DTO.UserPrincipal;
import com.server.backend.service.AdmissionPhaseWindowService;
import com.server.backend.service.AdmissionPhaseWindowService.Window;

/**
 * Backend for the Admission Phase 1 page ({@code /AdmissionPhase}).
 *
 * <p>This is a faithful port of the legacy Struct-Struts flow:
 * <pre>
 *   startAdmission_ConvvinerLevel.jsp  -> itiAdmissionEntry.do   (ItiAdmissionEntryAction)
 *   DistrictAdmissionEntry.jsp         -> districtAdmissionProcessOptimise.do
 *                                        (DistrictAdmissionProcessOptimiseAction - the seat-matrix cascade)
 *   DistrictAdmissionProcessOptimise.jsp -> districtAdmission.do (DistrictAdmissionAction - the write)
 * </pre>
 *
 * <p>Published domain configuration:
 * <ul>
 *   <li>The running year, phase, and seat-matrix phase come from the row flagged current in
 *       {@code admissions.admission_phase}; caller-supplied values are not used for writes.</li>
 *   <li>The seat matrix stores category buckets in hstore columns ({@code strength},
 *       {@code strength_fill}, {@code strength_vacant}) keyed by caste code (OC, OC-W, PH,
 *       PH-W, EX-S, EX-SW, IM/IMC, and the reservation caste codes).</li>
 * </ul>
 */
@Service
public class AdmissionProcessService {

    private static final Logger logger = LoggerFactory.getLogger(AdmissionProcessService.class);

    private static final String NUMERIC = "^[0-9]+$";
    private static final String STATE_CODE = "28";

    /** Legacy {@code res_category} codes derived from the cascade {@code check} value. */
    private static final String OC = "OC";
    private static final String OC_W = "OC-W";
    private static final String PH = "PH";
    private static final String PH_W = "PH-W";
    private static final String EX_S = "EX-S";
    private static final String EX_SW = "EX-SW";
    private static final String IM = "IM";
    private static final Pattern HSTORE_INTEGER_ENTRY = Pattern.compile(
            "(?:^|,)\\s*(?:\"((?:\\\\.|[^\"])*)\"|([^=,\\s]+))\\s*=>\\s*(?:\"((?:\\\\.|[^\"])*)\"|([^,\\s]+))\\s*(?=,|$)");

    private final NamedParameterJdbcTemplate jdbc;
    private final TransactionTemplate photoTransaction;
    private final AdmissionPhaseWindowService phaseWindows;

    public AdmissionProcessService(
            NamedParameterJdbcTemplate jdbc,
            PlatformTransactionManager transactionManager,
            AdmissionPhaseWindowService phaseWindows) {
        this.jdbc = jdbc;
        this.phaseWindows = phaseWindows;
        this.photoTransaction = new TransactionTemplate(transactionManager);
        this.photoTransaction.setPropagationBehavior(TransactionDefinition.PROPAGATION_REQUIRES_NEW);
    }

    public Map<String, Object> admissionWindowStatus() {
        AdmissionPhaseWindowService.Status window = phaseWindows.status(Window.ADMISSIONS);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("phase", window.phase());
        AdmissionPhaseWindowService.Cycle cycle = phaseWindows.currentCycle();
        result.put("year", cycle == null ? null : cycle.year());
        result.put("open", window.open());
        result.put("starts_at", window.start());
        result.put("ends_at", window.end());
        return result;
    }

    private boolean isPhaseOneAdmissionOpen() {
        AdmissionPhaseWindowService.Status window = phaseWindows.status(Window.ADMISSIONS);
        return "1".equals(window.phase()) && window.open();
    }

    private boolean isAdmissionWindowOpen() {
        return phaseWindows.status(Window.ADMISSIONS).open();
    }

    // ------------------------------------------------------------------ phase config

    /**
     * The running year, phase, and seat-matrix phase from the active admission configuration.
     */
    private Map<String, Object> currentPhaseConfig() {
        AdmissionPhaseWindowService.Cycle cycle = phaseWindows.currentCycle();
        if (cycle == null || blank(cycle.year()) || blank(cycle.phase())) {
            throw new IllegalStateException(
                    "No current admission year and phase found in admissions.admission_phase");
        }
        Map<String, Object> config = new HashMap<>();
        config.put("year", cycle.year().trim());
        config.put("phase", cycle.phase().trim());
        config.put("seatmatrix_phase", blank(cycle.seatMatrixPhase())
                ? number(cycle.phase(), 1) : number(cycle.seatMatrixPhase(), 1));
        return config;
    }

    private String currentYear(Map<String, Object> config) {
        return text(config.get("year"));
    }

    private int currentPhase(Map<String, Object> config) {
        return number(config.get("phase"), 1);
    }

    private int currentSeatMatrixPhase(Map<String, Object> config) {
        return number(config.get("seatmatrix_phase"), currentPhase(config));
    }

    // ------------------------------------------------------------------ boards

    public Map<String, Object> getItiBoards() {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT board_code, board_name FROM admissions.iti_board "
                        + "WHERE status = 'y' ORDER BY board_code");
        List<Map<String, Object>> data = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("board_code", text(row.get("board_code")));
            item.put("board_name", text(row.get("board_name")));
            data.add(item);
        }
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", data);
        return response;
    }

    // ------------------------------------------------------------------ entry (council merits)

    /**
     * Port of {@code ItiAdmissionEntryAction}: validates rank generation, checks the seat matrix
     * is generated (no ITI with {@code trade_freeze=10}), and resolves the merit window
     * ({@code merit_from}/{@code merit_to}) from {@code admission_timings} for the district/ITI
     * and today's date. Mirrors {@code getCouncilMerits} + {@code checkForRankGeneration} +
     * {@code getItiDetails1}.
     */
    public Map<String, Object> councilMerits(CouncilMeritsRequest request, UserPrincipal user) {
        if (!isPhaseOneAdmissionOpen()) {
            return status("ADMISSION_EXPIRED", "Admission Date is Expired");
        }
        // 1. Rank generation check: select count(regid) from ranks must be > 0.
        Integer rankCount = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(regid) FROM public.ranks", Integer.class);
        if (rankCount == null || rankCount == 0) {
            return status("RANK_NOT_GENERATED", "Rank generation is not completed yet.");
        }

        // 2. Seat-matrix generation check: any ITI with trade_freeze=10 blocks admission.
        String scope = scopeLike(user);
        Integer pending = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(DISTINCT a.iti_code) FROM public.ititrade a JOIN public.iti b "
                        + "ON a.iti_code = b.iti_code WHERE a.trade_freeze = 10 AND a.iti_code LIKE ?",
                Integer.class, scope);
        if (pending != null && pending > 0) {
            return status("SEATMATRIX_NOT_GENERATED",
                    "Seat matrix is not generated for some ITIs; complete trade approval first.");
        }

        // 3. Merit window from admission_timings for the scope, today and the selected
        //    caste/qualification. Legacy startAdmissionAction builds
        //    " and caste='<caste>' and minqul='<qual>' and cal_time='<time>'" before looking the
        //    row up, so honour those filters (cal_time only when the operator supplied one).
        Map<String, Object> config = currentPhaseConfig();
        String today = java.time.LocalDate.now().toString();
        String column = "3".equals(user.roleid()) ? "dist_code" : "iti_code";
        String value = "3".equals(user.roleid()) ? user.distCode() : user.itiCode();
        StringBuilder sql = new StringBuilder(
                "SELECT merit_from, merit_to, cal_time FROM public.admission_timings "
                        + "WHERE " + column + " = :value AND cal_date = CAST(:calDate AS date) "
                        + "AND caste = :caste AND minqul = :qual");
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("value", value)
                .addValue("calDate", today)
                .addValue("caste", blank(request.castePerform()) ? "all" : request.castePerform().trim())
                .addValue("qual", blank(request.qualPerform()) ? "all" : request.qualPerform().trim());
        if (!blank(request.admPerform())) {
            sql.append(" AND cal_time = CAST(:calTime AS time)");
            params.addValue("calTime", request.admPerform().trim());
        }
        List<Map<String, Object>> rows = jdbc.queryForList(sql.toString(), params);
        if (rows.isEmpty()) {
            return status("NO_COUNCIL", "No counselling window is configured for today.");
        }
        Map<String, Object> row = rows.get(0);
        Map<String, Object> data = new LinkedHashMap<>();
        data.put("merit_from", number(row.get("merit_from"), 0));
        data.put("merit_to", number(row.get("merit_to"), 0));
        data.put("cal_time", text(row.get("cal_time")));
        data.put("current_date", today);
        data.put("year", currentYear(config));
        data.put("phase", currentPhase(config));
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", data);
        return response;
    }

    /**
     * Today's admission timings ({@code cal_time}) for the logged-in district/ITI, mirroring the
     * legacy {@code putOptions("admission_timings","cal_time",...)} used by
     * {@code startAdmission_ConvvinerLevel.jsp} to fill the "Admission Timings" dropdown.
     */
    public Map<String, Object> todayTimings(UserPrincipal user) {
        String today = java.time.LocalDate.now().toString();
        String column = "3".equals(user.roleid()) ? "dist_code" : "iti_code";
        String value = "3".equals(user.roleid()) ? user.distCode() : user.itiCode();
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT DISTINCT cal_time FROM public.admission_timings "
                        + "WHERE " + column + " = :value AND cal_date = CAST(:calDate AS date) "
                        + "ORDER BY cal_time",
                new MapSqlParameterSource()
                        .addValue("value", value)
                        .addValue("calDate", today));
        List<String> times = new java.util.ArrayList<>();
        for (Map<String, Object> row : rows) {
            times.add(text(row.get("cal_time")));
        }
        Map<String, Object> response = new java.util.LinkedHashMap<>();
        response.put("success", true);
        response.put("data", times);
        return response;
    }

    private String scopeLike(UserPrincipal user) {
        if ("3".equals(user.roleid()) && !blank(user.distCode())) {
            return user.distCode() + "%";
        }
        if (!blank(user.itiCode())) {
            return user.itiCode() + "%";
        }
        return "%";
    }

    private static Map<String, Object> status(String code, String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("code", code);
        response.put("message", message);
        return response;
    }

    // ------------------------------------------------------------------ process optimize (cascade)

    /**
     * Port of {@code DistrictAdmissionProcessOptimiseAction}: resolves the candidate from the
     * merit rank, loads the application profile, applies the general-pool override, then computes
     * a per-(ITI, trade) {@code check} code by vacancy precedence across the applicable seat-matrix
     * buckets. The check code is what the radio carries back and what decides {@code res_category}.
     *
     * <p>The legacy implementation is a 16-branch cascade (OC/reservation × male/female × phc ×
     * exservice) that merges several seat-matrix queries and computes the check per row. This port
     * reproduces the same vacancy precedence in one pass over the seat-matrix hstore buckets.
     */
    public Map<String, Object> processOptimize(ProcessOptimizeRequest request, UserPrincipal user) {
        if (!isPhaseOneAdmissionOpen()) {
            return status("ADMISSION_EXPIRED", "Admission Date is Expired");
        }
        if (request == null || blank(request.rank()) || !request.rank().trim().matches(NUMERIC)) {
            throw new IllegalArgumentException("A numeric merit rank is required");
        }
        String rank = request.rank().trim();
        String distCode = resolveDistCode(user);
        Map<String, Object> config = currentPhaseConfig();
        String year = currentYear(config);
        int phase = currentPhase(config);
        int seatMatrixPhase = currentSeatMatrixPhase(config);
        String candidateTable = resolveCandidateTable(year);

        // Resolve the registration from ranks first so an existing admission is detected
        // even if its application row no longer matches the current caste filter.
        List<Map<String, Object>> rankedCandidates = jdbc.queryForList(
                "SELECT DISTINCT r.regid, r.rank FROM public.ranks r "
                        + "WHERE r.dist_code = :distCode AND r.rank::text = :rank "
                        + "AND r.phase = :phase AND r.qual = :qual",
                new MapSqlParameterSource()
                        .addValue("distCode", distCode)
                        .addValue("rank", rank)
                        .addValue("phase", String.valueOf(phase))
                        .addValue("qual", blank(request.qualPerform()) ? "all" : request.qualPerform().trim()));
        if (rankedCandidates.isEmpty()) {
            return status("RANK_NOT_FOUND", "No candidate holds rank " + rank + " in district " + distCode);
        }
        for (Map<String, Object> rankedCandidate : rankedCandidates) {
            String rankedRegid = text(rankedCandidate.get("regid"));
            Map<String, Object> admission = findAdmission(rankedRegid, year, String.valueOf(phase));
            if (admission != null) {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("code", "ALREADY_ADMITTED");
                response.put("admission_details", admission);
                return response;
            }
        }

        // Preserve the legacy caste filter when resolving a candidate who is not admitted.
        StringBuilder regSql = new StringBuilder(
                "SELECT a.regid, b.caste FROM public.ranks a JOIN public." + candidateTable + " b "
                        + "ON a.regid::integer = b.regid WHERE a.dist_code = :distCode "
                        + "AND a.rank::text = :rank AND a.phase = :phase AND a.qual = :qual");
        MapSqlParameterSource regParams = new MapSqlParameterSource()
                .addValue("distCode", distCode)
                .addValue("rank", rank)
                .addValue("phase", String.valueOf(phase))
                .addValue("qual", blank(request.qualPerform()) ? "all" : request.qualPerform().trim());
        String casteFilter = request.castePerform() == null ? "" : request.castePerform().trim();
        if (!casteFilter.isEmpty() && !"all".equalsIgnoreCase(casteFilter)) {
            regSql.append(" AND b.caste = :caste");
            regParams.addValue("caste", casteFilter);
        }
        regSql.append(" LIMIT 1");
        List<Map<String, Object>> regRows = jdbc.queryForList(regSql.toString(), regParams);
        if (regRows.isEmpty()) {
            return status("RANK_NOT_FOUND", "No candidate holds rank " + rank + " in district " + distCode);
        }
        String regid = text(regRows.get(0).get("regid"));

        // Application profile (getApplicationDetails).
        List<Map<String, Object>> candidates = jdbc.queryForList(
                "SELECT regid, name, fname, caste, gender, dob, phc, exservice, ssc_regno, ssc_year, ssc_month, "
                        + "email, economic_weaker_section, ewsv, pwd_category "
                        + "FROM public." + candidateTable + " WHERE regid = CAST(:regid AS integer) LIMIT 1",
                new MapSqlParameterSource("regid", regid));
        if (candidates.isEmpty()) {
            return status("APP_NOT_FOUND", "No application record for registration " + regid);
        }
        Map<String, Object> candidate = candidates.get(0);

        // Candidate profile + general-pool override (DistrictAdmissionProcessOptimiseAction lines 105-144).
        String casteCode = text(candidate.get("caste"));
        boolean female = isFemale(candidate.get("gender"));
        boolean phc = isYes(candidate.get("phc"));
        boolean exService = isYes(candidate.get("exservice"));
        Map<String, Object> pool = generalPool(distCode, year);
        if (pool != null) {
            String poolCaste = text(pool.get("caste"));
            if (IM.equalsIgnoreCase(poolCaste)) {
                casteCode = IM;
            } else {
                casteCode = poolCaste;
                female = true;
            }
            phc = true;
            exService = true;
        }
        if (female && casteCode != null && !casteCode.contains("-")) {
            // Women reservation bucket: the -W variant of the caste (done in the cascade too).
        }

        // The candidate's own reservation bucket (category code from category_mast by caste name).
        String reservationBucket = reservationBucket(casteCode);
        boolean isOc = OC.equalsIgnoreCase(casteCode);

        // Compute the check code per (iti, trade) by vacancy precedence.
        List<Map<String, Object>> rows = seatMatrixRowsForDistrict(distCode, year, seatMatrixPhase);
        List<Map<String, Object>> data = new ArrayList<>();
        String prevIti = null;
        for (Map<String, Object> row : rows) {
            String itiCode = text(row.get("iti_code"));
            int check = computeCheck(row, isOc, female, phc, exService, reservationBucket);
            int checkName = (prevIti != null && prevIti.equals(itiCode)) ? 1 : 0;
            prevIti = itiCode;

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("iti_name", text(row.get("iti_name")));
            item.put("iti_code", itiCode);
            item.put("trade_code", text(row.get("trade_code")));
            item.put("trade_short", text(row.get("trade_short")));
            item.put("trade_name", text(row.get("trade_name")));
            item.put("total_strength", number(row.get("total_strength"), 0));
            item.put("check", check);
            item.put("check_name", checkName);
            // Expose the buckets the JSP renders per category (OC / reservation / PH / EX-S + women).
            item.put("general_strength", hstoreInt(row, "strength", OC));
            item.put("general_fill", hstoreInt(row, "strength_fill", OC));
            item.put("general_vacant", hstoreInt(row, "strength_vacant", OC));
            item.put("general_w_strength", hstoreInt(row, "strength", OC_W));
            item.put("general_w_fill", hstoreInt(row, "strength_fill", OC_W));
            item.put("general_w_vacant", hstoreInt(row, "strength_vacant", OC_W));
            item.put("reservation_strength", hstoreInt(row, "strength", reservationBucket));
            item.put("reservation_fill", hstoreInt(row, "strength_fill", reservationBucket));
            item.put("reservation_vacant", hstoreInt(row, "strength_vacant", reservationBucket));
            item.put("reservation_w_strength", hstoreInt(row, "strength", womenBucket(reservationBucket)));
            item.put("reservation_w_fill", hstoreInt(row, "strength_fill", womenBucket(reservationBucket)));
            item.put("reservation_w_vacant", hstoreInt(row, "strength_vacant", womenBucket(reservationBucket)));
            item.put("phc_strength", hstoreInt(row, "strength", PH));
            item.put("phc_fill", hstoreInt(row, "strength_fill", PH));
            item.put("phc_vacant", hstoreInt(row, "strength_vacant", PH));
            item.put("phc_w_strength", hstoreInt(row, "strength", PH_W));
            item.put("phc_w_fill", hstoreInt(row, "strength_fill", PH_W));
            item.put("phc_w_vacant", hstoreInt(row, "strength_vacant", PH_W));
            item.put("exservice_strength", hstoreInt(row, "strength", EX_S));
            item.put("exservice_fill", hstoreInt(row, "strength_fill", EX_S));
            item.put("exservice_vacant", hstoreInt(row, "strength_vacant", EX_S));
            item.put("exservice_w_strength", hstoreInt(row, "strength", EX_SW));
            item.put("exservice_w_fill", hstoreInt(row, "strength_fill", EX_SW));
            item.put("exservice_w_vacant", hstoreInt(row, "strength_vacant", EX_SW));
            data.add(item);
        }

        if (data.isEmpty()) {
            return status("NO_SEATS", "No seat-matrix rows are available for district " + distCode);
        }

        Map<String, Object> student = new LinkedHashMap<>();
        student.put("regid", regid);
        student.put("rank", number(rank, 0));
        student.put("name", text(candidate.get("name")));
        student.put("fname", text(candidate.get("fname")));
        student.put("caste", text(candidate.get("caste")));
        student.put("gender", text(candidate.get("gender")));
        student.put("dob", candidate.get("dob"));
        student.put("phc", isYes(candidate.get("phc")) ? "Yes" : "No");
        student.put("exservice", isYes(candidate.get("exservice")) ? "Yes" : "No");
        student.put("year_of_admission", year + "-" + academicYearSuffix(year));
        student.put("current_date", java.time.LocalDate.now().toString());
        student.put("ssc_regno", text(candidate.get("ssc_regno")));
        student.put("ssc_year", text(candidate.get("ssc_year")));
        student.put("ssc_month", text(candidate.get("ssc_month")));
        student.put("ssc_month_option", normalizeSscMonth(candidate.get("ssc_month")));
        student.put("email_id", text(candidate.get("email")));
        student.put("ews", isYes(candidate.get("economic_weaker_section")) ? "Yes" : "No");
        student.put("pwd_category", isYes(candidate.get("pwd_category")) ? "Yes" : "No");

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", student);
        // Column layout the legacy DistrictAdmissionProcessOptimise.jsp renders for this candidate
        // (each of the 16 cascade branches shows a different set of buckets).
        response.put("layout", columnLayout(isOc, female, phc, exService));
        response.put("seat_matrix", data);
        response.put("shift_units", shiftUnitMatrix(data));
        return response;
    }

    /**
     * The seat-matrix columns the legacy page shows for a candidate, mirroring the 16 cascade
     * branches: General always; General-W for women; Reservation (+ -W) only for reservation
     * castes; PH (+ -W) and EX-S (+ -W) only when the candidate is flagged.
     */
    private static List<Map<String, Object>> columnLayout(boolean isOc, boolean female, boolean phc,
            boolean exService) {
        List<Map<String, Object>> columns = new ArrayList<>();
        columns.add(column("General", 1, "general_strength", "general_fill", "general_vacant"));
        if (female) {
            columns.add(column("General-W", 2, "general_w_strength", "general_w_fill", "general_w_vacant"));
        }
        if (!isOc) {
            columns.add(column("Reservation", 3, "reservation_strength", "reservation_fill", "reservation_vacant"));
            if (female) {
                columns.add(column("Reservation-W", 4, "reservation_w_strength", "reservation_w_fill",
                        "reservation_w_vacant"));
            }
        }
        if (phc) {
            columns.add(column("PH", 5, "phc_strength", "phc_fill", "phc_vacant"));
            if (female) {
                columns.add(column("PH-W", 6, "phc_w_strength", "phc_w_fill", "phc_w_vacant"));
            }
        }
        if (exService) {
            columns.add(column("EX-S", 7, "exservice_strength", "exservice_fill", "exservice_vacant"));
            if (female) {
                columns.add(column("EX-SW", 8, "exservice_w_strength", "exservice_w_fill", "exservice_w_vacant"));
            }
        }
        return columns;
    }

    private static Map<String, Object> column(String label, int checkCode, String strength, String fill,
            String vacant) {
        Map<String, Object> column = new LinkedHashMap<>();
        column.put("label", label);
        column.put("check_code", checkCode);
        column.put("strength", strength);
        column.put("fill", fill);
        column.put("vacant", vacant);
        return column;
    }

    /** Shift/unit options per (iti, trade) pair, keyed {@code "iti|trade"}. */
    private List<Map<String, Object>> shiftUnitMatrix(List<Map<String, Object>> trades) {
        List<Map<String, Object>> result = new ArrayList<>();
        for (Map<String, Object> trade : trades) {
            String itiCode = text(trade.get("iti_code"));
            String tradeCode = text(trade.get("trade_code"));
            List<Map<String, Object>> options = jdbc.queryForList(
                    "SELECT shift_allowed, unit_allowed, strength, strength_vacant "
                            + "FROM public.shift_unit_permitted "
                            + "WHERE iti_code = :itiCode AND trade_code = :tradeCode "
                            + "  AND available_year = true "
                            + "  AND strength_vacant > 0 "
                            + "ORDER BY shift_allowed, unit_allowed",
                    new MapSqlParameterSource("itiCode", itiCode).addValue("tradeCode", tradeCode));
            Map<String, Object> entry = new LinkedHashMap<>();
            entry.put("iti_code", itiCode);
            entry.put("trade_code", tradeCode);
            entry.put("options", options);
            result.add(entry);
        }
        return result;
    }

    /**
     * Vacancy-precedence check code for a seat-matrix row, reproducing the legacy 16-branch
     * cascade. Codes: 1=OC, 2=OC-W, 3=reservation, 4=reservation-W, 5=PH, 6=PH-W, 7=EX-S, 8=EX-SW.
     */
    private int computeCheck(Map<String, Object> row, boolean isOc, boolean female, boolean phc,
            boolean exService, String reservationBucket) {
        int ocVacant = hstoreInt(row, "strength_vacant", OC);
        int ocwVacant = hstoreInt(row, "strength_vacant", OC_W);
        int resVacant = hstoreInt(row, "strength_vacant", reservationBucket);
        int reswVacant = hstoreInt(row, "strength_vacant", womenBucket(reservationBucket));
        int phVacant = hstoreInt(row, "strength_vacant", PH);
        int phwVacant = hstoreInt(row, "strength_vacant", PH_W);
        int exVacant = hstoreInt(row, "strength_vacant", EX_S);
        int exwVacant = hstoreInt(row, "strength_vacant", EX_SW);

        // 1. OC general seat always has precedence when vacant.
        if (ocVacant > 0) {
            return 1;
        }
        if (isOc) {
            // OC candidate: only OC / OC-W (+ PH / EX-S if flagged).
            if (female) {
                if (ocwVacant > 0) {
                    return 2;
                }
                if (phc && phVacant > 0) {
                    return 5;
                }
                if (phc && phwVacant > 0) {
                    return 6;
                }
                if (exService && exVacant > 0) {
                    return 7;
                }
                if (exService && exwVacant > 0) {
                    return 8;
                }
            } else {
                if (phc && phVacant > 0) {
                    return 5;
                }
                if (exService && exVacant > 0) {
                    return 7;
                }
            }
            return 0;
        }
        // Reservation candidate.
        if (female) {
            if (ocwVacant > 0) {
                return 2;
            }
            if (resVacant > 0) {
                return 3;
            }
            if (reswVacant > 0) {
                return 4;
            }
            if (phc && phVacant > 0) {
                return 5;
            }
            if (phc && phwVacant > 0) {
                return 6;
            }
            if (exService && exVacant > 0) {
                return 7;
            }
            if (exService && exwVacant > 0) {
                return 8;
            }
        } else {
            if (resVacant > 0) {
                return 3;
            }
            if (phc && phVacant > 0) {
                return 5;
            }
            if (exService && exVacant > 0) {
                return 7;
            }
        }
        return 0;
    }

    /**
     * The seat-matrix rows for the district: one per sanctioned (ITI, trade) available this year,
     * joining the hstore buckets. Mirrors the legacy council-district queries
     * ({@code available_for_year='1'} and {@code strength>0}).
     */
    private List<Map<String, Object>> seatMatrixRowsForDistrict(
            String distCode, String year, int seatMatrixPhase) {
        return jdbc.queryForList(
                "SELECT d.iti_name, b.iti_code, a.trade_code, b.trade_short, "
                        + "       COALESCE(c.trade_name, b.trade_short) AS trade_name, "
                        + "       b.strength AS total_strength, "
                        + "       a.strength, a.strength_fill, a.strength_vacant "
                        + "FROM public.iti_seatmatrix a "
                        + "JOIN public.ititrade b ON a.trade_code = b.trade_code AND b.iti_code = a.iti_code "
                        + "LEFT JOIN public.ititrade_master c ON b.trade_short = c.trade_short "
                        + "JOIN public.iti d ON b.iti_code = d.iti_code "
                        + "WHERE d.dist_code = :distCode AND b.available_for_year = '1' "
                        + "  AND b.strength > 0 AND a.phase = :seatMatrixPhase AND a.year = :year "
                        + "ORDER BY b.iti_code, b.trade_code",
                new MapSqlParameterSource()
                        .addValue("distCode", distCode)
                        .addValue("seatMatrixPhase", seatMatrixPhase)
                        .addValue("year", year));
    }

    /** The candidate's reservation bucket code (category_mast lookup of the caste code). */
    private String reservationBucket(String casteCode) {
        if (blank(casteCode)) {
            return null;
        }
        String code = casteCode.trim();
        // Legacy getCategoryCode() looks category_mast up by category_name.
        List<String> byName = jdbc.queryForList(
                "SELECT category_code FROM public.category_mast WHERE category_name = :name LIMIT 1",
                new MapSqlParameterSource("name", code), String.class);
        if (!byName.isEmpty()) {
            return byName.get(0);
        }
        // Fall back to the caste code itself (OC is handled separately).
        return code;
    }

    /**
     * The women variant of a category bucket, matching the legacy construction
     * ({@code caste_code.contains("-") ? caste + "W" : caste + "-W"}): {@code BC-A -> BC-AW},
     * {@code SC -> SC-W}, {@code OC -> OC-W}.
     */
    private static String womenBucket(String bucket) {
        if (blank(bucket)) {
            return bucket;
        }
        return bucket.contains("-") ? bucket + "W" : bucket + "-W";
    }

    /** The general-pool override row for the district and year, or null. */
    private Map<String, Object> generalPool(String distCode, String year) {
        // The general-pool schema is optional. Probe with to_regclass first so a missing table
        // does not abort the surrounding transaction (PostgreSQL poisons the tx on a failed query).
        try {
            String present = jdbc.getJdbcTemplate().queryForObject(
                    "SELECT to_regclass('generalpool.open_general_pool')::text", String.class);
            if (present == null) {
                return null;
            }
        } catch (Exception ex) {
            logger.debug("general pool unavailable: {}", ex.getMessage());
            return null;
        }
        try {
            List<Map<String, Object>> rows = jdbc.queryForList(
                    "SELECT year, permission, caste FROM generalpool.open_general_pool "
                            + "WHERE dist_code = :distCode LIMIT 1",
                    new MapSqlParameterSource("distCode", distCode));
            if (rows.isEmpty()) {
                return null;
            }
            Map<String, Object> row = rows.get(0);
            if (!year.trim().equals(text(row.get("year")))) {
                return null;
            }
            String permission = text(row.get("permission"));
            if ("T".equalsIgnoreCase(permission) || "true".equalsIgnoreCase(permission)) {
                return row;
            }
            return null;
        } catch (Exception ex) {
            logger.debug("general pool unavailable: {}", ex.getMessage());
            return null;
        }
    }

    /**
     * District-level general-pool activation, ported from legacy {@code open_pool_dist_level.jsp}:
     * the year comes from {@code iti_params code 7} and the phase from the current
     * {@code admissions.admission_phase} row, the district from the caller's {@code ins_code}.
     * An existing row is updated in place; otherwise a new row is inserted with
     * {@code permission = true} — the flag {@link #generalPool} later reads.
     */
    public Map<String, Object> updateDistrictGeneralPool(String distCode, String caste) {
        requireNonNull(distCode, "district code");
        requireNonNull(caste, "caste");
        requireTable();

        Map<String, Object> config = currentPhaseConfig();
        String year = currentYear(config);
        String phase = text(config.get("phase"));
        logger.info("open general pool: dist_code={} caste={} year={} phase={}", distCode, caste, year,
                phase);

        int updated = jdbc.update(
                "UPDATE generalpool.open_general_pool SET caste = :caste, gender = 'male', year = :year, "
                        + "phase = :phase, permission = true WHERE dist_code = :distCode",
                new MapSqlParameterSource()
                        .addValue("distCode", distCode).addValue("caste", caste)
                        .addValue("year", year).addValue("phase", phase));
        if (updated == 0) {
            jdbc.update(
                    "INSERT INTO generalpool.open_general_pool "
                            + "(dist_code, caste, gender, year, phase, permission) "
                            + "VALUES (:distCode, :caste, 'male', :year, :phase, true)",
                    new MapSqlParameterSource()
                            .addValue("distCode", distCode).addValue("caste", caste)
                            .addValue("year", year).addValue("phase", phase));
        }

        Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("success", true);
        result.put("message", "General Pool is Opened for the caste" + caste);
        result.put("rowsAffected", updated == 0 ? 1 : updated);
        result.put("year", year);
        result.put("phase", phase);
        return result;
    }

    /**
     * ITI-level general-pool activation, ported from legacy {@code open_pool_iti_level.jsp}. The
     * legacy page wrote to a {@code generalpool} table our schema does not carry; the port keeps the
     * same row shape in {@code generalpool.open_general_pool} keyed by {@code iti_code} (with the
     * district derived from the first two digits, as legacy did) so both levels live in one table.
     */
    public Map<String, Object> updateItiGeneralPool(String itiCode, String caste) {
        requireNonNull(itiCode, "ITI code");
        requireNonNull(caste, "caste");
        requireTable();

        Map<String, Object> config = currentPhaseConfig();
        String year = currentYear(config);
        String phase = text(config.get("phase"));
        String distCode = itiCode.length() >= 2 ? itiCode.substring(0, 2) : itiCode;
        long trno = jdbc.getJdbcTemplate().queryForObject("SELECT nextval('trno_seq')", Long.class);
        logger.info("open general pool (ITI): iti_code={} caste={} year={} phase={} trno={}", itiCode,
                caste, year, phase, trno);

        int updated = jdbc.update(
                "UPDATE generalpool.open_general_pool SET caste = :caste, gender = 'male', year = :year, "
                        + "phase = :phase, permission = true, trno = :trno WHERE iti_code = :itiCode",
                new MapSqlParameterSource()
                        .addValue("itiCode", itiCode).addValue("caste", caste)
                        .addValue("year", year).addValue("phase", phase).addValue("trno", trno));
        if (updated == 0) {
            jdbc.update(
                    "INSERT INTO generalpool.open_general_pool "
                            + "(dist_code, caste, gender, year, phase, permission, trno, iti_code) "
                            + "VALUES (:distCode, :caste, 'male', :year, :phase, true, :trno, :itiCode)",
                    new MapSqlParameterSource()
                            .addValue("distCode", distCode).addValue("caste", caste)
                            .addValue("year", year).addValue("phase", phase)
                            .addValue("trno", trno).addValue("itiCode", itiCode));
        }

        Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("success", true);
        result.put("message", "General Pool is Opened for the caste" + caste);
        result.put("rowsAffected", updated == 0 ? 1 : updated);
        result.put("year", year);
        result.put("phase", phase);
        return result;
    }

    /** The general-pool table is optional in some schema snapshots; fail with a readable error. */
    private void requireTable() {
        try {
            String present = jdbc.getJdbcTemplate().queryForObject(
                    "SELECT to_regclass('generalpool.open_general_pool')::text", String.class);
            if (present == null) {
                throw new IllegalStateException(
                        "general pool table not available in this database");
            }
        } catch (IllegalStateException ex) {
            throw ex;
        } catch (Exception ex) {
            throw new IllegalStateException("general pool table not available: " + ex.getMessage());
        }
    }

    private static void requireNonNull(String value, String name) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(name + " is required");
        }
    }

    // ------------------------------------------------------------------ seat matrix (raw grid)

    private static final String SEAT_MATRIX_SQL = """
            SELECT sm.iti_code,
                   i.iti_name,
                   sm.trade_code,
                   COALESCE(m.trade_name, m.trade_short, sm.trade_code::text) AS trade_name,
                   COALESCE(tot.total, 0) AS strength_total,
                   COALESCE(sm.strength -> 'OC', '0')::int + COALESCE(sm.strength -> 'OC-W', '0')::int AS gen_t,
                   COALESCE(sm.strength_fill -> 'OC', '0')::int + COALESCE(sm.strength_fill -> 'OC-W', '0')::int AS gen_f,
                   COALESCE(sm.strength_vacant -> 'OC', '0')::int + COALESCE(sm.strength_vacant -> 'OC-W', '0')::int AS gen_v,
                   COALESCE(sm.strength -> 'IM', sm.strength -> 'IMC', '0')::int AS im_t,
                   COALESCE(sm.strength_fill -> 'IM', sm.strength_fill -> 'IMC', '0')::int AS im_f,
                   COALESCE(sm.strength_vacant -> 'IM', sm.strength_vacant -> 'IMC', '0')::int AS im_v,
                   COALESCE(sm.strength -> 'PH', '0')::int + COALESCE(sm.strength -> 'PH-W', '0')::int AS ph_t,
                   COALESCE(sm.strength_fill -> 'PH', '0')::int + COALESCE(sm.strength_fill -> 'PH-W', '0')::int AS ph_f,
                   COALESCE(sm.strength_vacant -> 'PH', '0')::int + COALESCE(sm.strength_vacant -> 'PH-W', '0')::int AS ph_v,
                   COALESCE(sm.strength -> 'EX-S', '0')::int + COALESCE(sm.strength -> 'EX-SW', '0')::int AS exs_t,
                   COALESCE(sm.strength_fill -> 'EX-S', '0')::int + COALESCE(sm.strength_fill -> 'EX-SW', '0')::int AS exs_f,
                   COALESCE(sm.strength_vacant -> 'EX-S', '0')::int + COALESCE(sm.strength_vacant -> 'EX-SW', '0')::int AS exs_v
            FROM public.iti_seatmatrix sm
            JOIN public.iti i ON i.iti_code = sm.iti_code
            LEFT JOIN public.ititrade_master m ON m.trade_code = sm.trade_code
            LEFT JOIN LATERAL (
                SELECT SUM(v::int) AS total FROM (SELECT svals(sm.strength) AS v) AS bucket
            ) tot ON TRUE
            WHERE sm.year = :year
              AND sm.phase = :seatmatrixPhase
              AND (CAST(:itiCode AS text) IS NULL OR sm.iti_code = CAST(:itiCode AS text))
              AND (CAST(:distCode AS text) IS NULL OR i.dist_code = CAST(:distCode AS text))
            ORDER BY i.iti_name, trade_name
            """;

    public Map<String, Object> getSeatMatrix(UserPrincipal user) {
        Map<String, Object> config = currentPhaseConfig();
        String year = currentYear(config);
        int seatMatrixPhase = currentSeatMatrixPhase(config);

        String itiCode = blank(user.itiCode()) ? null : user.itiCode().trim();
        String distCode = blank(user.distCode()) ? null : user.distCode().trim();
        if (itiCode == null && distCode == null) {
            throw new IllegalArgumentException(
                    "No ITI or district code is available for this login; cannot scope the seat matrix");
        }

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("year", year)
                .addValue("seatmatrixPhase", seatMatrixPhase)
                .addValue("itiCode", itiCode)
                .addValue("distCode", distCode);

        List<Map<String, Object>> rows = jdbc.queryForList(SEAT_MATRIX_SQL, params);
        List<Map<String, Object>> data = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("iti_code", text(row.get("iti_code")));
            item.put("iti_name", text(row.get("iti_name")));
            item.put("trade_code", row.get("trade_code"));
            item.put("trade_name", text(row.get("trade_name")));
            item.put("strength_total", number(row.get("strength_total"), 0));
            Map<String, Object> categories = new LinkedHashMap<>();
            categories.put("General", tfv(row, "gen_t", "gen_f", "gen_v"));
            categories.put("IM", tfv(row, "im_t", "im_f", "im_v"));
            categories.put("PH", tfv(row, "ph_t", "ph_f", "ph_v"));
            categories.put("EXS", tfv(row, "exs_t", "exs_f", "exs_v"));
            item.put("categories", categories);
            data.add(item);
        }

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("year", year);
        response.put("phase", seatMatrixPhase);
        response.put("data", data);
        return response;
    }

    // ------------------------------------------------------------------ rank lookup (profile)

    public Map<String, Object> lookupRank(String rank, UserPrincipal user) {
        if (!isAdmissionWindowOpen()) {
            return status("ADMISSION_EXPIRED", "Admission Date is Expired");
        }
        if (blank(rank) || !rank.trim().matches(NUMERIC)) {
            throw new IllegalArgumentException("A numeric merit rank is required");
        }
        String wantedRank = rank.trim();

        Map<String, Object> config = currentPhaseConfig();
        String year = currentYear(config);
        int phase = currentPhase(config);
        int seatMatrixPhase = currentSeatMatrixPhase(config);
        if (phase > 1 && !"4".equals(user.roleid())) {
            return status("ITI_LOGIN_REQUIRED", "Phase " + phase
                    + " admissions must be processed by the ITI login.");
        }

        String itiCode = blank(user.itiCode()) ? null : user.itiCode().trim();
        String distCode = blank(user.distCode()) ? null : user.distCode().trim();
        if (distCode == null) {
            distCode = districtOf(itiCode);
        }
        if (distCode == null) {
            throw new IllegalArgumentException(
                    "No district code is available for this login; cannot resolve the rank");
        }

        String itiPredicate = phase > 1 ? " AND r.iti_code = :itiCode" : "";
        List<Map<String, Object>> rankRows = jdbc.queryForList(
                "SELECT DISTINCT r.regid AS regid, r.rank AS rank FROM public.ranks r "
                        + "WHERE r.rank::text = :rank AND r.dist_code = :distCode "
                        + " AND r.phase = :phase AND r.year = :year"
                        + itiPredicate + " LIMIT 1",
                new MapSqlParameterSource()
                        .addValue("rank", wantedRank)
                        .addValue("distCode", distCode)
                        .addValue("phase", String.valueOf(phase))
                        .addValue("year", year)
                        .addValue("itiCode", itiCode));
        if (rankRows.isEmpty()) {
            return notFound("No candidate holds rank " + wantedRank + " in district " + distCode
                    + " for year " + year + " phase " + phase);
        }

        String regid = text(rankRows.get(0).get("regid"));
        String candidateTable = resolveCandidateTable(year);
        List<Map<String, Object>> candidates = jdbc.queryForList(
                "SELECT regid, name, fname, mname, caste, gender, dob, phc, exservice, ssc_regno, "
                        + "ssc_board, ssc_year, ssc_month, "
                        + "email, economic_weaker_section, ewsv, pwd_category "
                        + "FROM public." + candidateTable + " WHERE regid = CAST(:regid AS integer) LIMIT 1",
                new MapSqlParameterSource("regid", regid));
        if (candidates.isEmpty()) {
            return notFound("Rank " + wantedRank + " is held by registration " + regid
                    + ", which has no application row in " + candidateTable);
        }
        Map<String, Object> candidate = candidates.get(0);
        Map<String, Object> admission = findAdmission(regid, year, String.valueOf(phase));

        Map<String, Object> student = new LinkedHashMap<>();
        student.put("regid", regid);
        student.put("rank", number(rankRows.get(0).get("rank"), 0));
        student.put("name", text(candidate.get("name")));
        student.put("fname", text(candidate.get("fname")));
        student.put("mname", text(candidate.get("mname")));
        student.put("caste", text(candidate.get("caste")));
        student.put("gender", text(candidate.get("gender")));
        student.put("dob", candidate.get("dob"));
        student.put("phc", isYes(candidate.get("phc")) ? "Yes" : "No");
        student.put("exservice", isYes(candidate.get("exservice")) ? "Yes" : "No");
        student.put("year_of_admission", year + "-" + academicYearSuffix(year));
        student.put("ssc_regno", text(candidate.get("ssc_regno")));
        student.put("ssc_board", text(candidate.get("ssc_board")));
        student.put("ssc_year", text(candidate.get("ssc_year")));
        student.put("ssc_month", text(candidate.get("ssc_month")));
        student.put("ssc_month_option", normalizeSscMonth(candidate.get("ssc_month")));
        student.put("email_id", text(candidate.get("email")));
        student.put("ews", isYes(candidate.get("economic_weaker_section")) ? "Yes" : "No");
        student.put("pwd_category", isYes(candidate.get("pwd_category")) ? "Yes" : "No");
        student.put("photo_base64", photoBase64(regid));
        student.put("is_admitted", admission != null);
        student.put("admission_details", admission);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("data", student);
        return response;
    }

    private static Map<String, Object> notFound(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("message", message);
        return response;
    }

    private String resolveCandidateTable(String year) {
        String suffixed = "application" + year;
        return tableExists(suffixed) ? suffixed : "application";
    }

    private boolean tableExists(String table) {
        if (!table.matches("[A-Za-z0-9_]+")) {
            throw new IllegalArgumentException("Unsafe table name: " + table);
        }
        Integer count = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public' AND table_name = ?",
                Integer.class, table);
        return count != null && count > 0;
    }

    private static String academicYearSuffix(String year) {
        int value;
        try {
            value = Integer.parseInt(year);
        } catch (NumberFormatException ex) {
            return year;
        }
        return String.format("%02d", (value + 1) % 100);
    }

    private Map<String, Object> findAdmission(String regid, String year, String phase) {
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT ia.adm_num, ia.iti_code, ia.trade_code, ia.date_of_admission, "
                        + "       i.iti_name, COALESCE(m.trade_name, m.trade_short) AS trade_name "
                        + "FROM admissions.iti_admissions ia "
                        + "LEFT JOIN public.iti i ON i.iti_code = ia.iti_code "
                        + "LEFT JOIN public.ititrade_master m ON m.trade_code = ia.trade_code "
                        + "WHERE ia.regid = :regid AND ia.phase::text = :phase "
                        + "AND ia.year_of_admission = :year "
                        + "ORDER BY ia.date_of_admission DESC NULLS LAST LIMIT 1",
                new MapSqlParameterSource("regid", regid)
                        .addValue("phase", phase)
                        .addValue("year", year));
        if (rows.isEmpty()) {
            return null;
        }
        Map<String, Object> row = rows.get(0);
        Map<String, Object> details = new LinkedHashMap<>();
        details.put("adm_num", text(row.get("adm_num")));
        details.put("iti_code", text(row.get("iti_code")));
        details.put("iti_name", text(row.get("iti_name")));
        details.put("trade_code", row.get("trade_code"));
        details.put("trade_name", text(row.get("trade_name")));
        details.put("date_of_admission", row.get("date_of_admission"));
        return details;
    }

    private String photoBase64(String regid) {
        List<String> photos = jdbc.queryForList(
                "SELECT translate(encode(pic, 'base64'), E'\\n', '') FROM public.img_cand_photos "
                        + "WHERE regid = CAST(:regid AS integer) LIMIT 1",
                new MapSqlParameterSource("regid", regid), String.class);
        if (photos.isEmpty() || photos.get(0) == null) {
            return null;
        }
        return photos.get(0).replace("\n", "").replace("\r", "");
    }

    // ------------------------------------------------------------------ take admission (write)

    private static final String DEFAULT_MODE_OF_ADMISSION = "Convenor of the Sellection comitte";

    private static final String INSERT_ADMISSION_SQL = """
            INSERT INTO admissions.iti_admissions
                (adm_num, regid, name, fname, addr, mname, phno, adarno, gender, caste,
                 ssc_passed, inter_passed, inter_marks, local, pincode, dob, phc, exservice,
                 iti_code, trade_code, res_category, year_of_admission, trno, dist_code, mode_adm,
                 fromd_training, tod_training, idmarks1, idmarks2, ssc_regno, ssc_board, ssc_year,
                 ssc_month, date_of_admission, type_admission, phase, htno, sem_nonsem,
                 dgettrade_code, email_id, pwd_category, sub_caste, shift, unit)
            SELECT :admNum,
                   c.regid::text,
                   c.name, c.fname, c.addr, c.mname, c.phno, c.adarno, c.gender, c.caste,
                   c.ssc_passed, c.inter_passed, c.inter_marks, c.local, c.pincode, c.dob,
                   c.phc, c.exservice,
                   :itiCode, :tradeCode, :resCategory, :year, :trno, :distCode, :modeAdmission,
                   :fromdTraining, :todTraining, :idmarks1, :idmarks2,
                   COALESCE(NULLIF(:sscRegno, ''), c.ssc_regno),
                   COALESCE(NULLIF(:sscBoard, ''), c.ssc_board),
                   COALESCE(NULLIF(:sscYear,  ''), c.ssc_year),
                   COALESCE(NULLIF(:sscMonth, ''), c.ssc_month),
                   CURRENT_DATE, :typeAdmission, :phase, :htno, :semNonsem,
                   :dgetTradeCode, c.email, c.pwd_category, c.sub_caste,
                   :shift, :unit
            FROM public.%s c
            WHERE c.regid = CAST(:regid AS integer)
            ORDER BY c.regid
            LIMIT 1
            """;

    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> takeAdmission(TakeAdmissionRequest request, UserPrincipal user) {
        if (!isAdmissionWindowOpen()) {
            return status("ADMISSION_EXPIRED", "Admission Date is Expired");
        }
        if (request == null) {
            throw new IllegalArgumentException("Request body is required");
        }
        String regid = text(request.regid());
        String itiCode = text(request.itiCode());
        String tradeCodeText = text(request.tradeCode());
        if (blank(regid)) {
            throw new IllegalArgumentException("regid is required");
        }
        if (blank(itiCode)) {
            throw new IllegalArgumentException("iti_code is required");
        }
        if (blank(tradeCodeText) || !tradeCodeText.matches(NUMERIC)) {
            throw new IllegalArgumentException("A numeric trade_code is required");
        }
        int tradeCode = Integer.parseInt(tradeCodeText);

        // Parse selectedRadio "shift|unit|strength" (legacy DistrictAdmissionAction lines 48-54).
        String shift = emptyToNull(request.shift());
        String unit = emptyToNull(request.unit());
        if (blank(shift) && !blank(request.selectedRadio())) {
            String[] parts = request.selectedRadio().split("\\|");
            if (parts.length >= 2) {
                shift = parts[0].trim();
                unit = parts[1].trim();
            }
        }

        // Scope guard.
        if (!blank(user.itiCode()) && !user.itiCode().equals(itiCode)) {
            throw new IllegalArgumentException("ITI " + user.itiCode()
                    + " cannot admit a candidate into ITI " + itiCode);
        }
        String distCode = districtOf(itiCode);
        if (distCode == null) {
            throw new IllegalArgumentException("Unknown ITI code: " + itiCode);
        }
        if (!blank(user.distCode()) && !user.distCode().equals(distCode)) {
            throw new IllegalArgumentException("District " + user.distCode()
                    + " cannot admit a candidate into district " + distCode);
        }

        Map<String, Object> config = currentPhaseConfig();
        String year = currentYear(config);
        int phase = currentPhase(config);
        int seatMatrixPhase = currentSeatMatrixPhase(config);
        if (phase > 1 && !"4".equals(user.roleid())) {
            return status("ITI_LOGIN_REQUIRED", "Phase " + phase
                    + " admissions must be processed by the ITI login.");
        }

        String typeAdmission = emptyToNull(request.typeAdmission());
        if (typeAdmission == null) {
            throw new IllegalArgumentException(
                    "type_admission (Type of Admission) is required to record an admission");
        }

        Map<String, Object> existing = findAdmission(regid, year, String.valueOf(phase));
        if (existing != null) {
            String itiName = existing.get("iti_name") != null ? existing.get("iti_name").toString() : "";
            String admNum = existing.get("adm_num") != null ? existing.get("adm_num").toString() : "";
            return failure("Candidate " + regid + " is already admitted at ITI " + itiName
                    + " (admission number " + admNum + ")");
        }

        String candidateRankScope = phase == 1
                ? "dist_code = :distCode" : "iti_code = :itiCode";
        MapSqlParameterSource rankScopeParams = new MapSqlParameterSource()
                .addValue("regid", regid)
                .addValue("phase", String.valueOf(phase))
                .addValue("year", year)
                .addValue("distCode", distCode)
                .addValue("itiCode", itiCode);
        Boolean rankedForCurrentCycle = jdbc.queryForObject(
                "SELECT EXISTS (SELECT 1 FROM public.ranks WHERE regid::text = :regid "
                        + "AND phase = :phase AND year = :year AND " + candidateRankScope + ")",
                rankScopeParams, Boolean.class);
        if (!Boolean.TRUE.equals(rankedForCurrentCycle)) {
            throw new IllegalArgumentException("Candidate " + regid
                    + " is not ranked for this ITI in the current admission phase and year.");
        }

        List<Map<String, Object>> trades = jdbc.queryForList(
                "SELECT m.trade_short, COALESCE(m.trade_name, m.trade_short) AS trade_name "
                        + "FROM public.ititrade_master m WHERE m.trade_code = :tradeCode",
                new MapSqlParameterSource("tradeCode", tradeCode));
        if (trades.isEmpty()) {
            throw new IllegalArgumentException("Unknown trade code: " + tradeCode);
        }
        String tradeShort = text(trades.get(0).get("trade_short"));
        String tradeName = text(trades.get(0).get("trade_name"));
        if (blank(tradeShort)) {
            throw new IllegalArgumentException("Trade " + tradeCode
                    + " has no short code; cannot build an admission number");
        }

        Integer sanctioned = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM public.ititrade WHERE iti_code = ? AND trade_code = ?",
                Integer.class, itiCode, tradeCode);
        if (sanctioned == null || sanctioned == 0) {
            throw new IllegalArgumentException("Trade " + tradeName + " is not sanctioned for ITI " + itiCode);
        }

        String candidateTable = resolveCandidateTable(year);
        List<Map<String, Object>> candidateRows = jdbc.queryForList(
                "SELECT regid, name, caste, phc, exservice, gender FROM public." + candidateTable
                        + " WHERE regid = CAST(:regid AS integer) LIMIT 1",
                new MapSqlParameterSource("regid", regid));
        if (candidateRows.isEmpty()) {
            throw new IllegalArgumentException("No application record for registration " + regid
                    + " in " + candidateTable);
        }
        Map<String, Object> candidate = candidateRows.get(0);

        // General-pool override + res_category from the cascade check code
        // (DistrictAdmissionAction lines 90-183 + 305).
        String casteName = emptyToNull(request.casteName());
        if (blank(casteName)) {
            casteName = text(candidate.get("caste"));
        }
        String resCategory = resolveResCategory(request.check(), candidate, distCode, year, casteName,
                itiCode, tradeCode, config);

        // Vacancy gate (checkForVacencies): strength_vacant->resCategory must be > 0.
        int vacant = checkVacancies(itiCode, tradeCode, resCategory, config);
        if (vacant <= 0) {
            return failure("No vacancies available for category " + resCategory + " at ITI "
                    + itiCode + " trade " + tradeName);
        }

        String admNum = nextAdmissionNumber(itiCode, tradeCode, tradeShort, year);

        // Training dates (fromd/tod) and DGT metadata.
        String yy = year.length() >= 2 ? year.substring(year.length() - 2) : year;
        java.time.LocalDate fromdTraining;
        java.time.LocalDate todTraining;
        try {
            fromdTraining = java.time.LocalDate.of(2000 + Integer.parseInt(yy), 8, 1);
            Integer durationMonths = jdbc.getJdbcTemplate().queryForObject(
                    "SELECT durationyrs FROM public.ititrade_master WHERE trade_code = ?",
                    Integer.class, tradeCode);
            todTraining = (durationMonths == null)
                    ? fromdTraining
                    : fromdTraining.plusMonths(durationMonths).minusDays(1);
        } catch (NumberFormatException ex) {
            fromdTraining = null;
            todTraining = null;
        }

        Map<String, Object> dget = dgetTradeMeta(tradeCode);
        String dgetTradeCode = text(dget.get("dget_tradecode"));
        String noOfSem = text(dget.get("noofsem"));
        String htno = buildHtno(distCode, dgetTradeCode, noOfSem, year);
        String semNonsem = "N".equalsIgnoreCase(typeAdmission) ? "SEM" : "NONSEM";
        Long trno = jdbc.getJdbcTemplate().queryForObject("SELECT nextval('trno_seq')", Long.class);

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("admNum", admNum)
                .addValue("regid", regid)
                .addValue("itiCode", itiCode)
                .addValue("distCode", distCode)
                .addValue("tradeCode", tradeCode)
                .addValue("year", year)
                .addValue("phase", phase)
                .addValue("typeAdmission", typeAdmission)
                .addValue("idmarks1", emptyToNull(request.idmarks1()))
                .addValue("idmarks2", emptyToNull(request.idmarks2()))
                .addValue("sscRegno", emptyToNull(request.sscRegno()))
                .addValue("sscBoard", emptyToNull(request.sscBoard()))
                .addValue("sscYear", emptyToNull(request.sscYear()))
                .addValue("sscMonth", emptyToNull(request.sscMonth()))
                .addValue("modeAdmission", DEFAULT_MODE_OF_ADMISSION)
                .addValue("fromdTraining", fromdTraining)
                .addValue("todTraining", todTraining)
                .addValue("resCategory", resCategory)
                .addValue("trno", trno)
                .addValue("htno", htno)
                .addValue("semNonsem", semNonsem)
                .addValue("dgetTradeCode", dgetTradeCode)
                .addValue("shift", shift)
                .addValue("unit", unit);

        int inserted = jdbc.update(String.format(INSERT_ADMISSION_SQL, candidateTable), params);
        if (inserted != 1) {
            throw new IllegalStateException("Expected to admit exactly one candidate but wrote " + inserted);
        }

        // Keep the admission and both capacity counters atomic; never report success if a
        // matching seat-matrix row was not updated.
        if (!fillSeat(itiCode, tradeCode, resCategory, seatMatrixPhase, year)) {
            throw new IllegalStateException("Admission could not update the seat matrix for ITI "
                    + itiCode + " and trade " + tradeCode + " (category " + resCategory + ")");
        }

        // Shift/unit decrement (sqlShiftUnitPermit, available_year=true).
        if (!consumeShiftUnit(itiCode, String.valueOf(tradeCode), shift, unit)) {
            throw new IllegalStateException("Admission could not update vacant seats for ITI "
                    + itiCode + ", trade " + tradeCode + ", shift " + shift + ", unit " + unit);
        }

        // Copy the candidate photo into exams.img_cand_photos_exams (legacy lines 475-488).
        copyPhotoAfterAdmissionCommits(admNum, regid, year);

        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("adm_num", admNum);
        response.put("htno", htno);
        response.put("regid", regid);
        response.put("iti_code", itiCode);
        response.put("trade_code", tradeCode);
        response.put("trade_name", tradeName);
        response.put("res_category", resCategory);
        response.put("year", year);
        response.put("phase", phase);
        response.put("date_of_admission", java.time.LocalDate.now().toString());
        response.put("shift", shift);
        response.put("unit", unit);
        return response;
    }

    /**
     * Resolves {@code res_category} from the cascade {@code check} code, applying the general-pool
     * override first (legacy DistrictAdmissionAction lines 90-183). Codes: 1=OC, 2=OC-W,
     * 3=caste, 4=caste-W, 5=PH, 6=PH-W, 7=EX-S, 8=EX-SW.
     */
    private String resolveResCategory(String check, Map<String, Object> candidate, String distCode,
            String year, String casteName, String itiCode, int tradeCode, Map<String, Object> config) {
        // General-pool override: when the district is in the general pool for this year and the
        // permission is granted, use the pool caste if it still has vacancies, otherwise its
        // women variant (legacy DistrictAdmissionAction lines 117-141).
        Map<String, Object> pool = generalPool(distCode, year);
        if (pool != null) {
            String cast = text(pool.get("caste"));
            if (!blank(cast)) {
                int poolVacant = checkVacancies(itiCode, tradeCode, cast, config);
                if (poolVacant > 0) {
                    return cast;
                }
                return womenBucket(cast);
            }
        }
        String c = text(check);
        if (blank(c)) {
            // No check provided: fall back to the candidate's own bucket (PH > EX-S > caste).
            if (isYes(candidate.get("phc"))) {
                return PH;
            }
            if (isYes(candidate.get("exservice"))) {
                return EX_S;
            }
            return blank(casteName) ? OC : casteName;
        }
        switch (c) {
            case "1": return OC;
            case "2": return OC_W;
            case "3": return blank(casteName) ? OC : casteName;
            case "4": return womenBucket(blank(casteName) ? OC : casteName);
            case "5": return PH;
            case "6": return PH_W;
            case "7": return EX_S;
            case "8": return EX_SW;
            default: return blank(casteName) ? OC : casteName;
        }
    }

    /** {@code checkForVacencies}: {@code strength_vacant->category} on the seat-matrix row. */
    private int checkVacancies(String itiCode, int tradeCode, String category, Map<String, Object> config) {
        String year = currentYear(config);
        int phase = currentSeatMatrixPhase(config);
        List<Integer> values = jdbc.queryForList(
                "SELECT COALESCE(strength_vacant -> :category, '0')::int FROM public.iti_seatmatrix "
                        + "WHERE iti_code = :itiCode AND trade_code = :tradeCode "
                        + "  AND phase = :phase AND year = :year",
                new MapSqlParameterSource()
                        .addValue("category", category)
                        .addValue("itiCode", itiCode)
                        .addValue("tradeCode", tradeCode)
                        .addValue("phase", phase)
                        .addValue("year", year),
                Integer.class);
        return values.isEmpty() ? 0 : values.get(0);
    }

    private static Map<String, Object> failure(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);
        response.put("error", message);
        return response;
    }

    private static String emptyToNull(String value) {
        return blank(value) ? null : value.trim();
    }

    /**
     * {@code <iti_code><trade_short><yy>} plus the next serial. Legacy {@code getAdm_numCount}
     * returns {@code max(substring(adm_num,9,3))} for the ITI/trade/year (length<12), then the
     * action increments and zero-pads to 3 digits. The archive is unioned so the serial continues
     * the historical series when the live table is empty.
     */
    private String nextAdmissionNumber(String itiCode, int tradeCode, String tradeShort, String year) {
        String yy = year.length() >= 2 ? year.substring(year.length() - 2) : year;
        String prefix = itiCode + tradeShort + yy;
        Integer highest = jdbc.getJdbcTemplate().queryForObject(
                "SELECT MAX(serial) FROM ("
                        + "  SELECT SUBSTRING(adm_num FROM 9 FOR 3)::int AS serial "
                        + "  FROM admissions.iti_admissions "
                        + "  WHERE iti_code = ? AND trade_code = ? AND year_of_admission = ? "
                        + "    AND LENGTH(adm_num) < 12 AND SUBSTRING(adm_num FROM 9 FOR 3) ~ '^[0-9]+$' "
                        + "  UNION ALL "
                        + "  SELECT SUBSTRING(adm_num FROM 9 FOR 3)::int AS serial "
                        + "  FROM admissions.iti_admissions_archive "
                        + "  WHERE iti_code = ? AND trade_code = ? AND year_of_admission = ? "
                        + "    AND LENGTH(adm_num) < 12 AND SUBSTRING(adm_num FROM 9 FOR 3) ~ '^[0-9]+$' "
                        + ") c",
                Integer.class,
                itiCode, tradeCode, year,
                itiCode, tradeCode, year);
        int next = (highest == null ? 0 : highest) + 1;
        return prefix + String.format("%03d", next);
    }

    /**
     * Increments the filled bucket and decrements the vacant one for {@code res_category}. Matches
     * legacy {@code SqlUpdate}: no year/phase filter (the seat-matrix row the page rendered is the
     * only row for that ITI/trade in the running year). Uses {@code exist()} so a bucket the hstore
     * does not carry is left untouched rather than guessed at.
     */
    private boolean fillSeat(String itiCode, int tradeCode, String category, int seatMatrixPhase, String year) {
        if (category == null) {
            return false;
        }
        int updated = jdbc.update(
                "UPDATE public.iti_seatmatrix SET "
                        + "strength_fill = strength_fill || hstore(CAST(:category AS text), "
                        + "            ((COALESCE(strength_fill -> :category, '0')::int) + 1)::text), "
                        + "strength_vacant = strength_vacant || hstore(CAST(:category AS text), "
                        + "            ((COALESCE(strength_vacant -> :category, '0')::int) - 1)::text) "
                        + "WHERE iti_code = :itiCode AND trade_code = :tradeCode "
                        + "  AND phase = :seatMatrixPhase AND year = :year "
                        + "  AND COALESCE(strength_vacant -> :category, '0')::int > 0 "
                        + "  AND exist(strength_fill, CAST(:category AS text))",
                new MapSqlParameterSource()
                        .addValue("category", category)
                        .addValue("itiCode", itiCode)
                        .addValue("tradeCode", tradeCode)
                        .addValue("seatMatrixPhase", seatMatrixPhase)
                        .addValue("year", year));
        return updated == 1;
    }

    /** {@code sqlShiftUnitPermit}: decrement {@code strength_vacant} for the chosen shift/unit. */
    private boolean consumeShiftUnit(String itiCode, String tradeCode, String shift, String unit) {
        if (blank(shift) || blank(unit)) {
            return false;
        }
        int updated = jdbc.update(
                "UPDATE public.shift_unit_permitted SET strength_vacant = COALESCE(strength_vacant, 0) - 1 "
                        + "WHERE iti_code = :itiCode AND trade_code = :tradeCode "
                        + "  AND shift_allowed = :shift AND unit_allowed = :unit AND available_year = true "
                        + "  AND strength_vacant > 0",
                new MapSqlParameterSource()
                        .addValue("itiCode", itiCode)
                        .addValue("tradeCode", tradeCode)
                        .addValue("shift", shift)
                        .addValue("unit", unit));
        return updated == 1;
    }

    /**
     * Copies the candidate's photograph into {@code exams.img_cand_photos_exams}, keyed by
     * {@code adm_num} and academic year (legacy DistrictAdmissionAction lines 475-488). No-ops
     * when the exams schema or the source photo is unavailable.
     */
    private void copyPhotoAfterAdmissionCommits(String admNum, String regid, String year) {
        TransactionSynchronizationManager.registerSynchronization(new TransactionSynchronization() {
            @Override
            public void afterCommit() {
                try {
                    photoTransaction.executeWithoutResult(status -> copyPhotoToExams(admNum, regid, year));
                } catch (RuntimeException ex) {
                    logger.warn("Admission {} was saved, but copying its photo to exams failed", admNum, ex);
                }
            }
        });
    }

    private void copyPhotoToExams(String admNum, String regid, String year) {
        String present = jdbc.getJdbcTemplate().queryForObject(
                "SELECT to_regclass('exams.img_cand_photos_exams')::text", String.class);
        if (present == null) {
            return;
        }
        jdbc.update(
                "INSERT INTO exams.img_cand_photos_exams (adm_num, image, year_of_admission) "
                        + "SELECT :admNum, pic, :year FROM public.img_cand_photos "
                        + "WHERE regid = CAST(:regid AS integer)",
                new MapSqlParameterSource()
                        .addValue("admNum", admNum)
                        .addValue("year", year)
                        .addValue("regid", regid));
    }

    /** Shift/unit options the admission page may offer for an ITI/trade ({@code getShiftUnit.jsp}). */
    public List<Map<String, Object>> getShiftUnits(String itiCode, String tradeCode) {
        return jdbc.queryForList(
                "SELECT shift_allowed, unit_allowed, strength, strength_vacant "
                        + "FROM public.shift_unit_permitted "
                        + "WHERE iti_code = :itiCode AND trade_code = :tradeCode "
                        + "  AND available_year = true "
                        + "  AND strength_vacant > 0 "
                        + "ORDER BY shift_allowed, unit_allowed",
                new MapSqlParameterSource("itiCode", itiCode).addValue("tradeCode", tradeCode));
    }

    private Map<String, Object> dgetTradeMeta(int tradeCode) {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT dget_tradecode, noofsem FROM public.dget_trademaster WHERE trade_code = ?",
                String.valueOf(tradeCode));
        return rows.isEmpty() ? new HashMap<>() : rows.get(0);
    }

    /** {@code state(2)+dget_tradecode(3)+noofsem(1)+yy(2)+dist(2)+serial(4)}, live+archive union. */
    private String buildHtno(String distCode, String dgetTradeCode, String noOfSem, String year) {
        if (blank(dgetTradeCode) || blank(noOfSem) || blank(distCode) || blank(year)) {
            return null;
        }
        String yy = year.length() >= 2 ? year.substring(year.length() - 2) : year;
        String prefix = STATE_CODE + dgetTradeCode + noOfSem + yy + distCode;
        Integer highest = jdbc.getJdbcTemplate().queryForObject(
                "SELECT MAX(serial) FROM ("
                        + "  SELECT SUBSTRING(htno FROM 11 FOR 4)::int AS serial "
                        + "  FROM admissions.iti_admissions "
                        + "  WHERE dist_code = ? AND sem_nonsem = 'SEM' AND dgettrade_code = ? "
                        + "    AND year_of_admission = ? AND SUBSTRING(htno FROM 11 FOR 4) ~ '^[0-9]+$' "
                        + "  UNION ALL "
                        + "  SELECT SUBSTRING(htno FROM 11 FOR 4)::int AS serial "
                        + "  FROM admissions.iti_admissions_archive "
                        + "  WHERE dist_code = ? AND sem_nonsem = 'SEM' AND dgettrade_code = ? "
                        + "    AND year_of_admission = ? AND SUBSTRING(htno FROM 11 FOR 4) ~ '^[0-9]+$' "
                        + ") c",
                Integer.class,
                distCode, dgetTradeCode, year,
                distCode, dgetTradeCode, year);
        int next = (highest == null ? 0 : highest) + 1;
        return prefix + String.format("%04d", next);
    }

    // ------------------------------------------------------------------ helpers

    /** Reads an integer out of an hstore column loaded as a {@code Map} or a {@code String}. */
    private static int hstoreInt(Map<String, Object> row, String column, String key) {
        Object value = row.get(column);
        if (value == null) {
            return 0;
        }
        if (value instanceof Map<?, ?> map) {
            Object bucket = map.get(key);
            return bucket == null ? 0 : parseIntSafe(bucket.toString());
        }
        // PostgreSQL's hstore text format quotes keys and values, e.g. "OC"=>"2".
        var matcher = HSTORE_INTEGER_ENTRY.matcher(value.toString());
        while (matcher.find()) {
            String entryKey = matcher.group(1) != null ? matcher.group(1) : matcher.group(2);
            if (key.equals(unescapeHstore(entryKey))) {
                String entryValue = matcher.group(3) != null ? matcher.group(3) : matcher.group(4);
                return parseIntSafe(unescapeHstore(entryValue));
            }
        }
        return 0;
    }

    private static String unescapeHstore(String value) {
        return value.replace("\\\"", "\"").replace("\\\\", "\\");
    }

    private static String normalizeSscMonth(Object value) {
        String month = text(value);
        if (blank(month)) {
            return "";
        }
        String normalized = month.trim().toUpperCase(Locale.ROOT);
        if (normalized.equals("03") || normalized.equals("3") || normalized.contains("MAR")) {
            return "03";
        }
        if (normalized.equals("04") || normalized.equals("4") || normalized.equals("10")
                || normalized.contains("SUPPLY") || normalized.contains("SUPPLEMENT")
                || normalized.contains("SUPPL") || normalized.contains("JUN")) {
            return "04";
        }
        return "";
    }

    private static int parseIntSafe(String value) {
        try {
            return Integer.parseInt(value.trim());
        } catch (Exception ex) {
            return 0;
        }
    }

    private static String text(Object value) {
        return value == null ? null : String.valueOf(value).trim();
    }

    private static boolean blank(String value) {
        return value == null || value.isBlank();
    }

    private static boolean isFemale(Object gender) {
        String value = text(gender);
        return value != null && value.equalsIgnoreCase("female");
    }

    private static boolean isYes(Object value) {
        if (value instanceof Boolean flag) {
            return flag;
        }
        String text = text(value);
        return "yes".equalsIgnoreCase(text) || "y".equalsIgnoreCase(text)
                || "t".equalsIgnoreCase(text) || "true".equalsIgnoreCase(text)
                || "1".equals(text);
    }

    private static int number(Object value, int fallback) {
        if (value == null) {
            return fallback;
        }
        if (value instanceof Number n) {
            return n.intValue();
        }
        try {
            return Integer.parseInt(String.valueOf(value).trim());
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    private static Map<String, Object> tfv(Map<String, Object> row, String totalKey,
            String filledKey, String vacantKey) {
        Map<String, Object> cell = new LinkedHashMap<>();
        cell.put("T", number(row.get(totalKey), 0));
        cell.put("F", number(row.get(filledKey), 0));
        cell.put("V", number(row.get(vacantKey), 0));
        return cell;
    }

    private String resolveDistCode(UserPrincipal user) {
        if (user == null) {
            throw new IllegalArgumentException("A logged-in user is required to scope admission trades");
        }
        String loginDistCode = blank(user.distCode()) ? null : user.distCode().trim();
        String loginItiCode = blank(user.itiCode()) ? null : user.itiCode().trim();
        String itiDistCode = loginItiCode == null ? null : districtOf(loginItiCode);

        if (loginDistCode != null && itiDistCode != null && !loginDistCode.equals(itiDistCode)) {
            throw new IllegalArgumentException(
                    "The logged-in ITI does not belong to the supplied district");
        }
        String resolvedDistCode = loginDistCode != null ? loginDistCode : itiDistCode;
        if (blank(resolvedDistCode)) {
            throw new IllegalArgumentException(
                    "Unable to resolve the logged-in user's district for admission trades");
        }
        return resolvedDistCode;
    }

    private String districtOf(String itiCode) {
        if (blank(itiCode)) {
            return null;
        }
        List<String> districts = jdbc.queryForList(
                "SELECT dist_code FROM public.iti WHERE iti_code = :itiCode",
                new MapSqlParameterSource("itiCode", itiCode), String.class);
        return districts.isEmpty() ? null : districts.get(0);
    }
}
