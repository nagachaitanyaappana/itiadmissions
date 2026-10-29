package com.server.backend.service.Admission;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSource;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.student_trade_selection_dto;
import com.server.backend.DTO.student_trade_selection_request_dto;
import com.server.backend.service.ITI.TradeSelectionService;

/**
 * Candidate-side write path into {@code student_trade_sel}.
 *
 * <p>Direct port of the insert in {@code applicationForm.open_Application_InterfaceAction}
 * ({@code src/java/applicationForm/open_Application_InterfaceAction.java:321}), the action behind
 * {@code web/open_Application_Interface.jsp} and its {@code locDeptTable}. Without it the table
 * stays empty, so nothing can ever be promoted into {@code trade_sel} by the district/ITI
 * verifier ({@code Re_Verification_Action:572}, {@code verification_interfaceAction:586}) and
 * merit generation finds no candidate.
 *
 * <p>Column semantics taken from the legacy statement and confirmed against the archived phase
 * snapshot ({@code public.trade_sel2025phase1}, 22,060 rows):
 * <ul>
 *   <li>{@code dist_code} — the district of the chosen ITI;</li>
 *   <li>{@code temp_code} — legacy passes the district code again (the archive has zero rows
 *       where {@code temp_code <> dist_code});</li>
 *   <li>{@code iti_code} — the chosen ITI, so the row is the choice;</li>
 *   <li>{@code phase} — {@code hstore(<phase>, 'true')};</li>
 *   <li>{@code year} — the year on the active {@code admissions.admission_phase} row;</li>
 *   <li>{@code trno} — audit trace number (prod takes it from {@code trno_seq}, whose last_value
 *       sits just above the archived {@code trno} values);</li>
 *   <li>{@code temp} — surrogate that the legacy INSERT omits and lets the column default fill.
 *       This schema lost that default, so the port supplies {@code nextval('temp_seq')} explicitly
 *       (the only sequence whose range matches the archived {@code temp} values). Nothing reads the
 *       column back.</li>
 * </ul>
 *
 * <p>Re-saves are scoped to the active cycle and upsert on the current schema key
 * {@code (regid, dist_code)}. Phase membership for older cycles is retained in the hstore; removal
 * deletes only the active phase key.
 */
@Service
public class student_trade_selection_service {

    /** Legacy caps the selection table at 60 rows ({@code open_Application_Interface.jsp}). */
    public static final int MAX_CHOICES = 60;

    private static final Logger logger =
            LoggerFactory.getLogger(student_trade_selection_service.class);

    /** Codes only in {@code student_trade_sel}; names come from {@code iti} / {@code dist_mst}. */
    private static final String SELECT_SQL = """
            SELECT s.regid,
                   s.dist_code,
                   d.dist_name,
                   s.iti_code,
                   i.iti_name,
                   i.govt,
                   s.temp_code,
                   s.trno,
                   s.year,
                   s.phase::text AS phase_text,
                   s.freezee
               FROM student_trade_sel s
               LEFT JOIN iti i      ON i.iti_code  = s.iti_code
               LEFT JOIN dist_mst d ON d.dist_code = s.dist_code
              WHERE s.regid = :regid
                AND s.year = :year
                AND hstore(s.phase)->:phase = 'true'
               ORDER BY s.temp
              """;

    /**
     * The legacy insert, with {@code temp} made explicit.
     *
     * <p>{@code hstore(ARRAY[..], ARRAY[..])} is used rather than {@code hstore(:phase,'true')}
     * because a JDBC bind parameter has no inferred type inside the two-argument form.
     */
    private static final String INSERT_SQL = """
            INSERT INTO student_trade_sel
                        (regid, dist_code, temp_code, trno, phase, year, iti_code, temp, freezee)
            VALUES      (:regid, :distCode, :distCode, :trno,
                         hstore(ARRAY[:phase], ARRAY['true']), :year, :itiCode,
                         nextval('temp_seq'), :freezee)
            ON CONFLICT (regid, dist_code) DO UPDATE SET
                temp_code = EXCLUDED.temp_code,
                trno = EXCLUDED.trno,
                phase = COALESCE(student_trade_sel.phase, ''::hstore) || EXCLUDED.phase,
                year = EXCLUDED.year,
                iti_code = EXCLUDED.iti_code,
                freezee = EXCLUDED.freezee
            """;

    private static final RowMapper<student_trade_selection_dto> ROW_MAPPER =
            (rs, rowNum) -> new student_trade_selection_dto(
                    rs.getInt("regid"),
                    rs.getString("dist_code"),
                    rs.getString("dist_name"),
                    rs.getString("iti_code"),
                    rs.getString("iti_name"),
                    rs.getString("govt"),
                    rs.getString("temp_code"),
                    rs.getObject("trno", Long.class),
                    rs.getString("year"),
                    rs.getString("phase_text"),
                    rs.getObject("freezee", Integer.class));

    private final NamedParameterJdbcTemplate jdbcTemplate;

    /**
     * Reused so this half of the flow resolves year and phase exactly like the {@code trade_sel}
     * half — otherwise the candidate's row would be tagged with a phase the verifier never reads.
     */
    private final TradeSelectionService tradeSelectionService;

    public student_trade_selection_service(NamedParameterJdbcTemplate jdbcTemplate,
            TradeSelectionService tradeSelectionService) {
        this.jdbcTemplate = jdbcTemplate;
        this.tradeSelectionService = tradeSelectionService;
    }

    /** Lists the candidate's saved choices with the district/ITI names the page displays. */
    @Transactional(readOnly = true)
    public List<student_trade_selection_dto> getSelections(Integer regid) {
        requireRegid(regid);
        String year = tradeSelectionService.resolveYear();
        String phase = tradeSelectionService.resolvePhase(year);
        return jdbcTemplate.query(SELECT_SQL,
                new MapSqlParameterSource("regid", regid)
                        .addValue("year", year)
                        .addValue("phase", phase), ROW_MAPPER);
    }

    /**
     * Saves the posted choices using the active admission year and phase.
     *
     * <p>Order of operations (all in one transaction): validate the candidate and every ITI,
     * validate the candidate and every ITI, then upsert the current-cycle rows.
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> saveSelections(Integer regId,
            student_trade_selection_request_dto request) {

        if (request == null) {
            throw new IllegalArgumentException("Request body is required");
        }

        Integer regid = request.getRegid() == null ? regId : request.getRegid();
        requireRegid(regid);
        if (regId != null && request.getRegid() != null && !regId.equals(request.getRegid())) {
            throw new IllegalArgumentException("regid in the body (" + request.getRegid()
                    + ") does not match the path (" + regId + ")");
        }

        List<student_trade_selection_request_dto.Choice> choices = request.getChoices();
        if (choices == null || choices.isEmpty()) {
            throw new IllegalArgumentException("Select at least one option");
        }
        if (choices.size() > MAX_CHOICES) {
            throw new IllegalArgumentException("A maximum of " + MAX_CHOICES
                    + " selections can be made (received " + choices.size() + ")");
        }

        requireCandidateExists(regid);

        String year = tradeSelectionService.resolveYear();
        String phase = tradeSelectionService.resolvePhase(year);
        if (request.getYear() != null && !request.getYear().isBlank()
                && !year.equals(request.getYear().trim())) {
            logger.warn("Ignoring submitted year {} for trade selection; current cycle is {} phase {}",
                    request.getYear(), year, phase);
        }
        if (request.getPhase() != null && !request.getPhase().isBlank()
                && !phase.equals(request.getPhase().trim())) {
            logger.warn("Ignoring submitted phase {} for trade selection; current cycle is {} phase {}",
                    request.getPhase(), year, phase);
        }

        // Phase 1 is district-only (legacy student_trade_sel2025phase1 rows carry iti_code='' with
        // dist_code set); phase 2+ selects district + ITI.
        boolean districtOnly = "1".equals(phase);
        List<Row> rows = districtOnly
                ? resolveDistrictChoices(choices)
                : resolveItiChoices(choices);

        insertRows(regid, year, phase, rows, request.getFreezee());

        // Keep the staged application on the same current-cycle stamp as the choices.
        // If the candidate had app_status 'A' from an earlier phase, reset to 'P' (Pending)
        // so that the current phase application is pending verification.
        jdbcTemplate.update(
                "UPDATE student_application SET entry_date = now(), year = :year, phase = :phase, "
                        + "app_status = CASE WHEN app_status = 'A' THEN 'P' ELSE COALESCE(app_status, 'N') END "
                        + "WHERE regid = :regid",
                new MapSqlParameterSource("regid", regid)
                        .addValue("year", year)
                        .addValue("phase", phase));

        logger.info("Saved {} {}selection(s) for regid {} (year {}, phase {}, {} already present)",
                rows.size(), districtOnly ? "district " : "ITI ", regid, year, phase, request.getChoices().size() - rows.size());

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("regid", regid);
        result.put("year", year);
        result.put("phase", phase);
        result.put("districtOnly", districtOnly);
        result.put("saved", rows.size());
        result.put("codes", rows.stream()
                .map(row -> districtOnly ? row.distCode() : row.itiCode()).toList());
        return result;
    }

    /** A single {@code student_trade_sel} row: district-only rows carry an empty ITI code. */
    private record Row(String distCode, String itiCode) {
    }

    /** The candidate must exist: {@code student_application} is what the student flow writes. */
    private void requireCandidateExists(Integer regid) {
        List<Integer> found = jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT regid FROM student_application WHERE regid = ?", Integer.class,
                regid);
        if (found.isEmpty()) {
            throw new IllegalArgumentException("No registration found for Registration Id " + regid
                    + ". Please register and apply first.");
        }
    }

    /**
     * Phase-1 path: the candidate picks districts only. Each district becomes one
     * {@code student_trade_sel} row with an empty {@code iti_code}, matching the legacy
     * {@code student_trade_sel2025phase1} rows.
     */
    private List<Row> resolveDistrictChoices(
            List<student_trade_selection_request_dto.Choice> choices) {

        Set<String> districtCodes = new LinkedHashSet<>();
        for (student_trade_selection_request_dto.Choice choice : choices) {
            if (choice == null || choice.getDistCode() == null || choice.getDistCode().isBlank()) {
                throw new IllegalArgumentException("Every row must have a district selected");
            }
            String distCode = choice.getDistCode().trim();
            if (!districtCodes.add(distCode)) {
                throw new IllegalArgumentException("District " + distCode + " is selected more than once");
            }
        }

        Set<String> knownDistricts = new LinkedHashSet<>(jdbcTemplate.getJdbcTemplate()
                .queryForList("SELECT dist_code FROM dist_mst", String.class));

        List<Row> rows = new ArrayList<>(districtCodes.size());
        for (String distCode : districtCodes) {
            if (!knownDistricts.contains(distCode)) {
                throw new IllegalArgumentException("Unknown district code " + distCode);
            }
            rows.add(new Row(distCode, ""));
        }
        return rows;
    }

    /**
     * Phase-2+ path: each choice is a district + ITI. The district is resolved from {@code iti}.
     */
    private List<Row> resolveItiChoices(
            List<student_trade_selection_request_dto.Choice> choices) {

        Set<String> itiCodes = collectItiCodes(choices);
        Map<String, String> districtByIti = resolveDistricts(choices);

        List<Row> rows = new ArrayList<>(itiCodes.size());
        Set<String> selectedDistricts = new LinkedHashSet<>();
        for (String itiCode : itiCodes) {
            String district = districtByIti.get(itiCode);
            if (!selectedDistricts.add(district)) {
                throw new IllegalArgumentException(
                        "Only one ITI can be selected per district in the current application.");
            }
            rows.add(new Row(district, itiCode));
        }
        return rows;
    }

    /**
     * Trims the codes and rejects blanks and duplicates — the legacy PK {@code (iti_code, regid)}
     * kept a candidate from picking the same ITI twice; since the dropped PK no longer does, the
     * rule is enforced here in code.
     */
    private static Set<String> collectItiCodes(
            List<student_trade_selection_request_dto.Choice> choices) {

        Set<String> itiCodes = new LinkedHashSet<>();
        for (student_trade_selection_request_dto.Choice choice : choices) {
            if (choice == null || choice.getItiCode() == null || choice.getItiCode().isBlank()) {
                throw new IllegalArgumentException("Every row must have an ITI selected");
            }
            String itiCode = choice.getItiCode().trim();
            if (!itiCodes.add(itiCode)) {
                throw new IllegalArgumentException("ITI " + itiCode + " is selected more than once");
            }
        }
        return itiCodes;
    }

    /**
     * Resolves each chosen ITI's district from {@code iti} — authoritative over the posted code, so
     * a stale or hand-crafted {@code distCode} can never create a row whose district disagrees with
     * the ITI's real district.
     *
     * @return {@code itiCode -> dist_code}, in the order the candidate posted them
     */
    private Map<String, String> resolveDistricts(
            List<student_trade_selection_request_dto.Choice> choices) {

        Set<String> itiCodes = new LinkedHashSet<>();
        for (student_trade_selection_request_dto.Choice choice : choices) {
            itiCodes.add(choice.getItiCode().trim());
        }

        Map<String, String> districtByIti = new LinkedHashMap<>();
        for (Map<String, Object> row : jdbcTemplate.queryForList(
                "SELECT iti_code, dist_code FROM iti WHERE iti_code IN (:codes)",
                new MapSqlParameterSource("codes", itiCodes))) {
            districtByIti.put(String.valueOf(row.get("iti_code")),
                    row.get("dist_code") == null ? null : String.valueOf(row.get("dist_code")));
        }

        Map<String, String> resolved = new LinkedHashMap<>();
        for (student_trade_selection_request_dto.Choice choice : choices) {
            String itiCode = choice.getItiCode().trim();
            String actual = districtByIti.get(itiCode);
            if (actual == null) {
                throw new IllegalArgumentException("Unknown ITI code " + itiCode);
            }
            String posted = choice.getDistCode() == null ? null : choice.getDistCode().trim();
            if (posted != null && !posted.isEmpty() && !posted.equals(actual)) {
                throw new IllegalArgumentException("ITI " + itiCode + " belongs to district "
                        + actual + ", not " + posted);
            }
            resolved.put(itiCode, actual);
        }
        return resolved;
    }

    /**
     * Writes one row per selection. {@code temp_code} repeats the district and {@code temp} takes
     * the next {@code temp_seq} value, matching how the archived rows were produced.
     */
    private void insertRows(Integer regid, String year, String phase,
            List<Row> rows, Integer freezee) {

        Long trno = jdbcTemplate.getJdbcTemplate()
                .queryForObject("SELECT nextval('trno_seq')", Long.class);

        List<SqlParameterSource> batch = new ArrayList<>(rows.size());
        for (Row row : rows) {
            batch.add(new MapSqlParameterSource("regid", regid)
                    .addValue("distCode", row.distCode())
                    .addValue("trno", trno)
                    .addValue("phase", phase)
                    .addValue("year", year)
                    .addValue("itiCode", row.itiCode())
                    .addValue("freezee", freezee));
        }
        jdbcTemplate.batchUpdate(INSERT_SQL, batch.toArray(new SqlParameterSource[0]));
    }

    /** Removes a single choice — the legacy per-row Delete link. */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> removeSelection(Integer regid, String itiCode) {
        requireRegid(regid);
        if (itiCode == null || itiCode.isBlank()) {
            throw new IllegalArgumentException("itiCode is required");
        }

        int rows = jdbcTemplate.update(
                "UPDATE student_trade_sel SET phase = delete(phase, array[:phase]) "
                        + "WHERE regid = :regid AND iti_code = :itiCode AND year = :year "
                        + "AND hstore(phase)->:phase = 'true'",
                currentCycleParams(regid).addValue("itiCode", itiCode.trim()));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("regid", regid);
        result.put("itiCode", itiCode.trim());
        result.put("rowsAffected", rows);
        return result;
    }

    /** Removes all rows for a candidate+district (phase 1 / legacy deletedist.jsp). */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> removeSelectionByDist(Integer regid, String distCode) {
        requireRegid(regid);
        if (distCode == null || distCode.isBlank()) {
            throw new IllegalArgumentException("distCode is required");
        }
        int rows = jdbcTemplate.update(
                "UPDATE student_trade_sel SET phase = delete(phase, array[:phase]) "
                        + "WHERE regid = :regid AND dist_code = :distCode AND year = :year "
                        + "AND hstore(phase)->:phase = 'true'",
                currentCycleParams(regid).addValue("distCode", distCode.trim()));
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("regid", regid);
        result.put("distCode", distCode.trim());
        result.put("rowsAffected", rows);
        return result;
    }

    /** Clears every choice for the candidate. */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> clearSelections(Integer regid) {
        requireRegid(regid);

        int rows = jdbcTemplate.update(
                "UPDATE student_trade_sel SET phase = delete(phase, array[:phase]) "
                        + "WHERE regid = :regid AND year = :year AND hstore(phase)->:phase = 'true'",
                currentCycleParams(regid));

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("success", true);
        result.put("regid", regid);
        result.put("rowsAffected", rows);
        return result;
    }

    private MapSqlParameterSource currentCycleParams(Integer regid) {
        String year = tradeSelectionService.resolveYear();
        String phase = tradeSelectionService.resolvePhase(year);
        return new MapSqlParameterSource("regid", regid)
                .addValue("year", year)
                .addValue("phase", phase);
    }

    private static void requireRegid(Integer regid) {
        if (regid == null || regid <= 0) {
            throw new IllegalArgumentException("A valid Registration Id is required");
        }
    }
}
