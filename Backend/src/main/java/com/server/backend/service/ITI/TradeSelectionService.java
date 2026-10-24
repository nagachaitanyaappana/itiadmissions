package com.server.backend.service.ITI;

import java.util.List;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.TradeSelectionRequestDto;
import com.server.backend.service.AdmissionPhaseWindowService;

/**
 * Records a candidate's chosen ITI/trade in {@code trade_sel}.
 *
 * <p>Direct port of the legacy Struts action {@code Master.Trade.Tradesel_entry_Action}
 * ({@code src/java/Master/Trade/Tradesel_entry_Action.java:72}). This write path was **never
 * ported** to Spring Boot, which is why {@code trade_sel} is empty and merit generation returns
 * "No records found": the candidate query is
 * {@code regid in (select regid from trade_sel where ...)}, so no selections means no candidates.
 *
 * <p>Reproduced deliberately from the legacy action:
 * <ul>
 *   <li>the hstore phase key is appended with {@code phase || hstore(...)} rather than overwritten,
 *       so earlier phase membership survives;</li>
 *   <li>{@code application.year} / {@code application.phase} are updated in the same step from the
 *       active {@code admissions.admission_phase} row — that
 *       update is the only writer of {@code application.phase} in the merit path, and the
 *       generator's {@code hstore(a.phase)->:phase='true'} predicate depends on it.</li>
 * </ul>
 */
@Service
public class TradeSelectionService {

    private static final Logger logger = LoggerFactory.getLogger(TradeSelectionService.class);

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final AdmissionPhaseWindowService phaseWindows;

    public TradeSelectionService(NamedParameterJdbcTemplate jdbcTemplate,
            AdmissionPhaseWindowService phaseWindows) {
        this.jdbcTemplate = jdbcTemplate;
        this.phaseWindows = phaseWindows;
    }

    /** Resolves the running admission year from the single active phase configuration. */
    public String resolveYear() {
        AdmissionPhaseWindowService.Cycle cycle = requireCurrentCycle();
        return cycle.year();
    }

    private AdmissionPhaseWindowService.Cycle requireCurrentCycle() {
        AdmissionPhaseWindowService.Cycle cycle = phaseWindows.currentCycle();
        if (cycle == null || cycle.year() == null || cycle.year().isBlank()
                || cycle.phase() == null || cycle.phase().isBlank()) {
            throw new IllegalStateException(
                    "No current admission year and phase found in admissions.admission_phase");
        }
        return cycle;
    }

    /**
     * Resolves the current phase.
     *
     * <p>The submitted year is never authoritative. Both year and phase come from the active
     * {@code admissions.admission_phase} row.
     */
    public String resolvePhase(String paramYear) {
        AdmissionPhaseWindowService.Cycle cycle = requireCurrentCycle();
        if (paramYear != null && !paramYear.isBlank()
                && !paramYear.trim().equals(cycle.year())) {
            logger.warn("Ignoring submitted admission year {}; using current admission_phase year {}",
                    paramYear, cycle.year());
        }
        return cycle.phase();
    }

    /**
     * Records (or re-records) a trade selection and moves the candidate into the current phase.
     *
     * @param scopeItiCode ITI code for the selection; must be non-blank
     * @param scopeDistCode district code, stored for traceability; the merit query filters on
     *                      {@code iti_code} for role 4 and {@code dist_code} for role 3
     * @param freezee 1 to freeze the preference immediately, null/0 to leave it unset
     * @return a small map describing what was written
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> saveSelection(TradeSelectionRequestDto dto, String scopeItiCode,
            String scopeDistCode, Integer freezee) {

        if (dto == null || dto.getRegid() == null) {
            throw new IllegalArgumentException("regid is required");
        }
        if (scopeItiCode == null || scopeItiCode.isBlank()) {
            throw new IllegalArgumentException("itiCode is required to record a trade selection");
        }

        AdmissionPhaseWindowService.Cycle cycle = requireCurrentCycle();
        String year = cycle.year();
        String phase = cycle.phase();
        String regid = String.valueOf(dto.getRegid());
        String itiCode = scopeItiCode.trim();
        // trade_sel.dist_code is part of the primary key (regid, dist_code, iti_code) and is
        // NOT NULL, and it lets a district-scoped merit run (role 3) find the same rows. When
        // the caller does not supply it, resolve it from the ITI so the row stays valid.
        String distCode = (scopeDistCode == null || scopeDistCode.isBlank())
                ? null : scopeDistCode.trim();
        if (distCode == null) {
            List<String> resolved = jdbcTemplate.getJdbcTemplate().queryForList(
                    "SELECT dist_code FROM iti WHERE iti_code = ?", String.class, itiCode);
            if (!resolved.isEmpty() && resolved.get(0) != null && !resolved.get(0).isBlank()) {
                distCode = resolved.get(0).trim();
            }
        }
        if (distCode == null) {
            throw new IllegalArgumentException(
                    "Could not resolve a district for ITI " + itiCode);
        }
        Integer freeze = (freezee == null) ? 0 : freezee;

        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("regid", regid)
                .addValue("itiCode", itiCode)
                .addValue("distCode", distCode)
                .addValue("freezee", freeze)
                .addValue("phase", phase)
                .addValue("year", year);

        // Primary key is (regid, dist_code) in the reference schema (a candidate holds one ITI
        // per district), so this is an upsert on that key. An existing row keeps
        // its history: the phase key is appended, matching legacy "update ... phase || hstore(...)".
        // `temp` is NOT NULL with no column default on this schema and the legacy inserts never
        // supplied it either (they relied on a production-side default that is absent here), so
        // it is taken explicitly from the existing public.trade_sel_temp_seq.
        String upsert = """
                INSERT INTO trade_sel(regid, iti_code, dist_code, freezee, temp_code, temp, phase, year)
                VALUES (:regid, :itiCode, :distCode, :freezee, :itiCode,
                        nextval('public.trade_sel_temp_seq'),
                        hstore(array[:phase], array['true']), :year)
                ON CONFLICT (regid, dist_code) DO UPDATE SET
                    freezee  = EXCLUDED.freezee,
                    year     = EXCLUDED.year,
                    phase    = COALESCE(trade_sel.phase, ''::hstore) || EXCLUDED.phase
                """;
        jdbcTemplate.update(upsert, params);

        // The only writer of application.phase in the merit path. The COALESCE-to-'' guard
        // matters: a NULL phase cannot be concatenated with ||.
        String applicationUpdate = """
                UPDATE application
                   SET year = :year,
                       phase = COALESCE(phase, ''::hstore) || hstore(array[:phase], array['true'])
                 WHERE regid = :regid
                """;
        int updated = jdbcTemplate.update(applicationUpdate,
                new MapSqlParameterSource("regid", dto.getRegid())
                        .addValue("year", year)
                        .addValue("phase", phase));

        if (updated == 0) {
            logger.warn("Trade selection saved for regid {} but no application row matched", regid);
        }

        return Map.of(
                "success", true,
                "regid", regid,
                "itiCode", itiCode,
                "distCode", distCode == null ? "" : distCode,
                "phase", phase,
                "year", year,
                "freezee", freeze,
                "applicationUpdated", updated);
    }

    /**
     * Removes a candidate's phase membership from {@code trade_sel} — the legacy delete branch
     * ({@code UPDATE trade_sel SET phase = delete(phase, array[?]) WHERE regid=? AND iti_code=?}).
     * The row itself is kept so the selection can be re-confirmed without a fresh insert.
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> removeSelection(Integer regid, String itiCode) {
        if (regid == null) {
            throw new IllegalArgumentException("regid is required");
        }
        if (itiCode == null || itiCode.isBlank()) {
            throw new IllegalArgumentException("itiCode is required");
        }
        String year = resolveYear();
        String phase = resolvePhase(year);

        int rows = jdbcTemplate.update(
                "UPDATE trade_sel SET phase = delete(phase, array[:phase]) "
                        + "WHERE regid = :regid AND iti_code = :itiCode",
                new MapSqlParameterSource("regid", String.valueOf(regid))
                        .addValue("itiCode", itiCode.trim())
                        .addValue("phase", phase));

        return Map.of(
                "success", true,
                "regid", String.valueOf(regid),
                "itiCode", itiCode.trim(),
                "phase", phase,
                "rowsAffected", rows);
    }

    /** Lists a candidate's current selections, for the trade-selection page. */
    public List<Map<String, Object>> getSelections(Integer regid) {
        if (regid == null) {
            throw new IllegalArgumentException("regid is required");
        }
        return jdbcTemplate.queryForList(
                "SELECT regid, iti_code, dist_code, freezee, temp_code, year, phase "
                        + "FROM trade_sel WHERE regid = :regid ORDER BY iti_code",
                new MapSqlParameterSource("regid", String.valueOf(regid)));
    }
}