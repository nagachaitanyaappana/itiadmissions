package com.server.backend.service.ITI;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.AbstractMap;
import java.util.Comparator;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.AddTradePageResponse;
import com.server.backend.DTO.AddTradeRequest;
import com.server.backend.DTO.AddableTradeDto;
import com.server.backend.DTO.EditTradePageResponse;
import com.server.backend.DTO.EditTradeShiftUnitDto;
import com.server.backend.DTO.EditTradeUpdateRequest;
import com.server.backend.DTO.ExistingTradeDto;

/**
 * Add Trade (district login). Port of {@code addnew_tradeAction} (catalogue of master
 * trades not yet attached to the ITI) and {@code addnew_trade_interfaceAction} (insert
 * into {@code ititrade}), plus {@code Approve_alltradesAction} (set conv_approval +
 * trade_freeze for the ITI). A district login inserts the row immediately frozen
 * (trade_freeze = 1), exactly like the legacy role 3 branch.
 */
@Service
public class AddTradeService {

    private final NamedParameterJdbcTemplate jdbc;

    public AddTradeService(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public AddTradePageResponse getPage(String itiCode) {
        AddTradePageResponse response = new AddTradePageResponse();
        response.setItiCode(itiCode);

        List<Map<String, Object>> itiRows = jdbc.getJdbcTemplate().queryForList(
                "SELECT iti_name FROM iti WHERE iti_code = ?", itiCode);
        if (!itiRows.isEmpty()) {
            response.setItiName(String.valueOf(itiRows.get(0).get("iti_name")));
        }

        Map<String, Object> config = currentPhaseConfig();
        String year = config.get("year") == null ? null : String.valueOf(config.get("year"));
        int phase = seatMatrixPhase(config);
        response.setYear(year);

        Integer approved = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ? AND conv_approval = 1",
                Integer.class, itiCode);
        response.setApprovedExists(approved != null && approved > 0);

        List<Map<String, Object>> existing = jdbc.getJdbcTemplate().queryForList(
                "SELECT t.trade_code, t.trade_short, m.trade_name, t.strength, t.strength_fill,"
                        + " t.strength_vacant, t.available_for_year, t.trade_freeze, t.conv_approval"
                        + " FROM ititrade t LEFT JOIN ititrade_master m ON m.trade_short = t.trade_short"
                        + " WHERE t.iti_code = ?"
                        + " ORDER BY m.trade_name NULLS LAST, t.trade_code",
                itiCode);
        for (Map<String, Object> row : existing) {
            Integer tradeCode = asInteger(row.get("trade_code"));
            response.getExistingTrades().add(new ExistingTradeDto(
                    tradeCode,
                    row.get("trade_short") == null ? null : String.valueOf(row.get("trade_short")),
                    row.get("trade_name") == null ? null : String.valueOf(row.get("trade_name")),
                    asInteger(row.get("strength")),
                    asInteger(row.get("strength_fill")),
                    asInteger(row.get("strength_vacant")),
                    row.get("available_for_year") == null ? null : String.valueOf(row.get("available_for_year")),
                    asInteger(row.get("trade_freeze")),
                    asInteger(row.get("conv_approval")),
                    buildSeatMatrix(itiCode, tradeCode, year, phase)));
        }

        List<Map<String, Object>> addable = jdbc.getJdbcTemplate().queryForList(
                "SELECT a.trade_code, a.trade_short, a.trade_name FROM ititrade_master a"
                        + " WHERE a.trade_code IS NOT NULL"
                        + " AND a.trade_code NOT IN (SELECT trade_code FROM ititrade WHERE iti_code = ?)"
                        + " GROUP BY a.trade_code, a.trade_short, a.trade_name"
                        + " ORDER BY a.trade_name",
                itiCode);
        for (Map<String, Object> row : addable) {
            response.getAddableTrades().add(new AddableTradeDto(
                    asInteger(row.get("trade_code")),
                    row.get("trade_short") == null ? null : String.valueOf(row.get("trade_short")),
                    row.get("trade_name") == null ? null : String.valueOf(row.get("trade_name"))));
        }

        return response;
    }

    @Transactional
    public AddTradePageResponse addTrade(String itiCode, AddTradeRequest request) {
        if (getPage(itiCode).isApprovedExists()) {
            throw new IllegalStateException("Trades for this ITI are already approved; "
                    + "no further trades can be added");
        }

        Integer tradeCode = request.getTradeCode();
        if (tradeCode == null) {
            throw new IllegalArgumentException("Trade code is required");
        }

        List<Map<String, Object>> master = jdbc.getJdbcTemplate().queryForList(
                "SELECT trade_short FROM ititrade_master WHERE trade_code = ? LIMIT 1", tradeCode);
        if (master.isEmpty()) {
            throw new IllegalArgumentException("Unknown trade code " + tradeCode);
        }
        String tradeShort = master.get(0).get("trade_short") == null ? null
                : String.valueOf(master.get(0).get("trade_short"));

        Integer exists = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ? AND trade_code = ?",
                Integer.class, itiCode, tradeCode);
        if (exists != null && exists > 0) {
            throw new IllegalStateException("Trade " + tradeCode + " is already added for ITI " + itiCode);
        }

        int strength = request.getStrength() == null ? 0 : request.getStrength();
        int available = request.getAvailable() == null ? 1 : request.getAvailable();

        jdbc.update("INSERT INTO ititrade"
                        + " (iti_code, trade_code, trade_short, strength, strength_fill, strength_vacant,"
                        + " available_for_year, trade_freeze, conv_approval)"
                        + " VALUES (:itiCode, :tradeCode, :tradeShort, :strength, 0, :strength,"
                        + " :available, 0, 0)",
                new MapSqlParameterSource()
                        .addValue("itiCode", itiCode)
                        .addValue("tradeCode", tradeCode)
                        .addValue("tradeShort", tradeShort)
                        .addValue("strength", strength)
                        .addValue("available", String.valueOf(available)));

        return getPage(itiCode);
    }

    @Transactional
    public int approveAll(String itiCode) {
        Integer existing = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ?", Integer.class, itiCode);
        if (existing == null || existing == 0) {
            throw new IllegalStateException("No trades found for ITI " + itiCode);
        }
        return jdbc.update(
                "UPDATE ititrade SET conv_approval = 1, trade_freeze = 1 WHERE iti_code = :itiCode",
                new MapSqlParameterSource("itiCode", itiCode));
    }

    /**
     * Edit Trade page: the selected trade's strength / availability plus the permitted
     * shift/unit rows. Port of {@code Master.Trade.EditTrade} (role 3/4 branch).
     */
    public EditTradePageResponse getTradeForEdit(String itiCode, Integer tradeCode) {
        if (tradeCode == null) {
            throw new IllegalArgumentException("Trade code is required");
        }
        EditTradePageResponse response = new EditTradePageResponse();
        response.setItiCode(itiCode);
        response.setTradeCode(tradeCode);

        List<Map<String, Object>> itiRows = jdbc.getJdbcTemplate().queryForList(
                "SELECT iti_name FROM iti WHERE iti_code = ?", itiCode);
        if (!itiRows.isEmpty()) {
            response.setItiName(String.valueOf(itiRows.get(0).get("iti_name")));
        }

        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT t.trade_short, m.trade_name, t.strength, t.strength_fill, t.strength_vacant,"
                        + " t.available_for_year, t.trade_freeze, t.conv_approval"
                        + " FROM ititrade t LEFT JOIN ititrade_master m ON m.trade_short = t.trade_short"
                        + " WHERE t.iti_code = ? AND t.trade_code = ?",
                itiCode, tradeCode);
        if (rows.isEmpty()) {
            throw new IllegalArgumentException(
                    "Trade " + tradeCode + " is not attached to ITI " + itiCode);
        }
        Map<String, Object> row = rows.get(0);
        response.setTradeShort(row.get("trade_short") == null ? null : String.valueOf(row.get("trade_short")));
        response.setTradeName(row.get("trade_name") == null ? null : String.valueOf(row.get("trade_name")));
        response.setStrength(asInteger(row.get("strength")));
        response.setStrengthFill(asInteger(row.get("strength_fill")));
        response.setStrengthVacant(asInteger(row.get("strength_vacant")));
        response.setAvailableForYear(row.get("available_for_year") == null ? null
                : String.valueOf(row.get("available_for_year")));
        response.setTradeFreeze(asInteger(row.get("trade_freeze")));
        response.setConvApproval(asInteger(row.get("conv_approval")));

        List<Map<String, Object>> units = jdbc.getJdbcTemplate().queryForList(
                "SELECT shift_allowed, unit_allowed, strength, available_year"
                        + " FROM shift_unit_permitted WHERE iti_code = ? AND trade_code = ?"
                        + " ORDER BY shift_allowed, unit_allowed",
                itiCode, String.valueOf(tradeCode));
        for (Map<String, Object> unit : units) {
            response.getShiftUnits().add(new EditTradeShiftUnitDto(
                    unit.get("shift_allowed") == null ? null : String.valueOf(unit.get("shift_allowed")),
                    unit.get("unit_allowed") == null ? null : String.valueOf(unit.get("unit_allowed")),
                    asInteger(unit.get("strength")),
                    asBoolean(unit.get("available_year"))));
        }
        return response;
    }

    /**
     * Persist Edit Trade: update the trade's strength / availability, then apply any
     * shift/unit availability toggles on {@code shift_unit_permitted}. Port of
     * {@code Master.Trade.EditTrade_InterfaceAction}.
     */
    @Transactional
    public EditTradePageResponse updateTrade(String itiCode, Integer tradeCode,
                                             EditTradeUpdateRequest request) {
        if (tradeCode == null) {
            throw new IllegalArgumentException("Trade code is required");
        }
        Integer exists = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ? AND trade_code = ?",
                Integer.class, itiCode, tradeCode);
        if (exists == null || exists == 0) {
            throw new IllegalArgumentException(
                    "Trade " + tradeCode + " is not attached to ITI " + itiCode);
        }

        int strength = request.getStrength() == null ? 0 : request.getStrength();
        String available = request.getAvailable() == null ? "1" : String.valueOf(request.getAvailable());
        jdbc.update("UPDATE ititrade SET strength = :strength, available_for_year = :available"
                        + " WHERE iti_code = :itiCode AND trade_code = :tradeCode",
                new MapSqlParameterSource()
                        .addValue("strength", strength)
                        .addValue("available", available)
                        .addValue("itiCode", itiCode)
                        .addValue("tradeCode", tradeCode));

        if (request.getShiftUnits() != null) {
            for (EditTradeUpdateRequest.ShiftUnitUpdate unit : request.getShiftUnits()) {
                if (unit.getShiftAllowed() == null || unit.getUnitAllowed() == null) {
                    continue;
                }
                jdbc.update("UPDATE shift_unit_permitted SET available_year = :available"
                                + " WHERE iti_code = :itiCode AND trade_code = :tradeCode"
                                + " AND shift_allowed = :shift AND unit_allowed = :unit",
                        new MapSqlParameterSource()
                                .addValue("available", Boolean.TRUE.equals(unit.getAvailable()))
                                .addValue("itiCode", itiCode)
                                .addValue("tradeCode", String.valueOf(tradeCode))
                                .addValue("shift", unit.getShiftAllowed())
                                .addValue("unit", unit.getUnitAllowed()));
            }
        }
        return getTradeForEdit(itiCode, tradeCode);
    }

    /**
     * Freeze / unfreeze every trade of an ITI ({@code ititrade.trade_freeze}).
     * Port of {@code Master.Trade.freeze_alltradesAction} (and its unfreeze counterpart).
     */
    @Transactional
    public int setTradeFreeze(String itiCode, boolean freeze) {
        return jdbc.update(
                "UPDATE ititrade SET trade_freeze = :freeze WHERE iti_code = :itiCode",
                new MapSqlParameterSource()
                        .addValue("freeze", freeze ? 1 : 0)
                        .addValue("itiCode", itiCode));
    }

    private Map<String, Object> currentPhaseConfig() {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT year, phase, seatmatrix_phase FROM admissions.admission_phase WHERE current = 'true'");
        if (rows.isEmpty()) {
            throw new IllegalStateException(
                    "No current admission phase found in admissions.admission_phase");
        }
        return rows.get(0);
    }

    private static int seatMatrixPhase(Map<String, Object> config) {
        Object seatMatrixPhase = config.get("seatmatrix_phase");
        if (seatMatrixPhase != null && asInteger(seatMatrixPhase) != null && asInteger(seatMatrixPhase) > 0) {
            return asInteger(seatMatrixPhase);
        }
        return asInteger(config.get("phase"));
    }

    /**
     * Legacy "Seat Matrix" cell: the ITI+trade's per-category sanctioned strength from
     * {@code iti_seatmatrix.strength} (hstore), rendered as {@code "OC-9 PH-13 EWS-9"}.
     */
    /**
     * Legacy "Seat Matrix" cell: the ITI+trade's per-category sanctioned strength from
     * {@code iti_seatmatrix.strength} (hstore), rendered as {@code "OC-9 PH-13 EWS-9"}.
     */
    /**
     * Legacy "Seat Matrix" cell: the ITI+trade's per-category sanctioned strength from
     * {@code iti_seatmatrix.strength} (hstore), rendered as {@code "OC-9 PH-13 EWS-9"}.
     */
    /**
     * Legacy "Seat Matrix" cell: the ITI+trade's per-category sanctioned strength from
     * {@code iti_seatmatrix.strength} (hstore), rendered as {@code "OC-9 PH-13 EWS-9"}.
     */
    /**
     * Legacy "Seat Matrix" cell: the ITI+trade's per-category sanctioned strength from
     * {@code iti_seatmatrix.strength} (hstore), rendered as {@code "OC-9 PH-13 EWS-9"}.
     */
    /**
     * Legacy "Seat Matrix" cell: the ITI+trade's per-category sanctioned strength from
     * {@code iti_seatmatrix.strength} (hstore), rendered as {@code "OC-9 PH-13 EWS-9"}.
     */
    private String buildSeatMatrix(String itiCode, Integer tradeCode, String year, int phase) {
        if (tradeCode == null || year == null) {
            return "";
        }
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT c.category_name, sval AS strength "
                        + "FROM (SELECT skeys(strength) AS category_code, svals(strength) AS sval "
                        + "FROM iti_seatmatrix "
                        + "WHERE iti_code = ? AND trade_code = ? AND year = ? AND phase = ?) s "
                        + "JOIN (SELECT DISTINCT category_code, category_name, category_order "
                        + "FROM category_mast WHERE category_code IS NOT NULL) c "
                        + "ON c.category_code = s.category_code "
                        + "ORDER BY c.category_order NULLS LAST, c.category_name",
                itiCode, tradeCode, year, phase);
        StringBuilder builder = new StringBuilder();
        for (Map<String, Object> row : rows) {
            Integer value = asInteger(row.get("strength"));
            builder.append(row.get("category_name")).append('-')
                    .append(value == null ? 0 : value).append(' ');
        }
        return builder.toString().trim();
    }
    private static Integer asInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.intValue();
        }
        String text = String.valueOf(value).trim();
        return text.isEmpty() ? null : Integer.valueOf(text);
    }

    private static Boolean asBoolean(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Boolean bool) {
            return bool;
        }
        return Boolean.parseBoolean(String.valueOf(value).trim());
    }
}
