package com.server.backend.service.ITI;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.AddTradePageResponse;
import com.server.backend.DTO.AddTradeRequest;
import com.server.backend.DTO.AddableTradeDto;
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
            response.getExistingTrades().add(new ExistingTradeDto(
                    asInteger(row.get("trade_code")),
                    row.get("trade_short") == null ? null : String.valueOf(row.get("trade_short")),
                    row.get("trade_name") == null ? null : String.valueOf(row.get("trade_name")),
                    asInteger(row.get("strength")),
                    asInteger(row.get("strength_fill")),
                    asInteger(row.get("strength_vacant")),
                    row.get("available_for_year") == null ? null : String.valueOf(row.get("available_for_year")),
                    asInteger(row.get("trade_freeze")),
                    asInteger(row.get("conv_approval"))));
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
                        + " :available, 1, 0)",
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
}
