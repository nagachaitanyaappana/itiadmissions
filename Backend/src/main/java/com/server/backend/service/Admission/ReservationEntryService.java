package com.server.backend.service.Admission;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.ReservationCategoryDto;
import com.server.backend.DTO.ReservationCategoryEntry;
import com.server.backend.DTO.ReservationEntryRequest;
import com.server.backend.DTO.ReservationEntryResponse;
import com.server.backend.DTO.ReservationTradeDto;

/**
 * Port of the legacy Reservation Entry screen (manageseats_interface.jsp ->
 * ManageSeats_InterfaceAction). Writes the per-category reservation split into
 * {@code iti_seatmatrix} (delete + insert hstore) and keeps
 * {@code ititrade.strength_fill / strength_vacant} in sync, exactly like the
 * legacy action. The seat matrix is published for the current year and the
 * current admission phase's {@code seatmatrix_phase}.
 */
@Service
public class ReservationEntryService {

    private final NamedParameterJdbcTemplate jdbc;

    public ReservationEntryService(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ReservationTradeDto> getTradesForIti(String itiCode) {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT t.trade_code, t.trade_short, m.trade_name, t.strength,"
                        + " t.strength_fill, t.strength_vacant"
                        + " FROM ititrade t LEFT JOIN ititrade_master m ON m.trade_short = t.trade_short"
                        + " WHERE t.iti_code = ?"
                        + " ORDER BY m.trade_name NULLS LAST, t.trade_code",
                itiCode);
        List<ReservationTradeDto> trades = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            trades.add(new ReservationTradeDto(
                    asInteger(row.get("trade_code")),
                    row.get("trade_short") == null ? null : String.valueOf(row.get("trade_short")),
                    row.get("trade_name") == null ? null : String.valueOf(row.get("trade_name")),
                    asInteger(row.get("strength")),
                    asInteger(row.get("strength_fill")),
                    asInteger(row.get("strength_vacant"))));
        }
        return trades;
    }

    public ReservationEntryResponse getReservation(String itiCode, Integer tradeCode) {
        Map<String, Object> config = currentPhaseConfig();
        String year = String.valueOf(config.get("year"));
        int phase = seatMatrixPhase(config);

        ReservationEntryResponse response = baseResponse(itiCode, tradeCode, year, phase);

        Map<String, Integer> strength = new LinkedHashMap<>();
        Map<String, Integer> fill = new LinkedHashMap<>();
        loadMatrix(itiCode, tradeCode, year, phase, strength, fill);

        for (String[] category : categoryList()) {
            String code = category[0];
            int st = strength.getOrDefault(code, 0);
            int fl = fill.getOrDefault(code, 0);
            response.getCategories().add(
                    new ReservationCategoryDto(code, category[1], st, fl, Math.max(st - fl, 0)));
        }

        response.setEnteredStrength(sumEntries(response.getCategories()));
        response.setEnteredStrengthVacant(sumVacant(response.getCategories()));
        response.setSuccess(true);
        response.setMessage("Reservation breakup loaded");
        return response;
    }

    @Transactional
    public ReservationEntryResponse saveReservation(ReservationEntryRequest request) {
        Map<String, Object> config = currentPhaseConfig();
        String year = String.valueOf(config.get("year"));
        int phase = seatMatrixPhase(config);

        ReservationEntryResponse response = baseResponse(
                request.getItiCode(), request.getTradeCode(), year, phase);

        if (response.getTotalStrength() == null) {
            response.setSuccess(false);
            response.setMessage("No sanctioned strength (ititrade) found for ITI "
                    + request.getItiCode() + " trade " + request.getTradeCode());
            return response;
        }

        Map<String, Integer> requestedStrength = new LinkedHashMap<>();
        for (ReservationCategoryEntry entry : request.getEntries()) {
            requestedStrength.put(entry.getCategoryCode(),
                    entry.getStrength() == null ? 0 : entry.getStrength());
        }

        Map<String, Integer> existingStrength = new LinkedHashMap<>();
        Map<String, Integer> existingFill = new LinkedHashMap<>();
        loadMatrix(request.getItiCode(), request.getTradeCode(), year, phase,
                existingStrength, existingFill);

        Map<String, Integer> strength = new LinkedHashMap<>();
        Map<String, Integer> fill = new LinkedHashMap<>();
        Map<String, Integer> vacant = new LinkedHashMap<>();

        int totalStrength = 0;
        int totalVacant = 0;
        for (String[] category : categoryList()) {
            String code = category[0];
            int st = requestedStrength.getOrDefault(code, 0);
            int fl = existingFill.getOrDefault(code, 0);
            if (fl > st) {
                response.setSuccess(false);
                response.setMessage("Strength (" + st + ") is less than the already filled ("
                        + fl + ") seats for category " + code);
                return response;
            }
            strength.put(code, st);
            fill.put(code, fl);
            vacant.put(code, st - fl);
            totalStrength += st;
            totalVacant += st - fl;
        }

        if (totalStrength > response.getTotalStrength()) {
            response.setSuccess(false);
            response.setMessage("Total reserved strength (" + totalStrength
                    + ") exceeds the sanctioned strength (" + response.getTotalStrength() + ")");
            return response;
        }

        MapSqlParameterSource matrixParams = new MapSqlParameterSource()
                .addValue("itiCode", request.getItiCode())
                .addValue("tradeCode", request.getTradeCode())
                .addValue("strength", toHstore(strength))
                .addValue("strengthFill", toHstore(fill))
                .addValue("strengthVacant", toHstore(vacant))
                .addValue("year", year)
                .addValue("phase", phase);

        jdbc.update("DELETE FROM iti_seatmatrix WHERE iti_code = :itiCode"
                        + " AND trade_code = :tradeCode AND year = :year AND phase = :phase",
                matrixParams);

        jdbc.update("INSERT INTO iti_seatmatrix"
                        + " (iti_code, trade_code, strength, strength_fill, strength_vacant, year, phase)"
                        + " VALUES (:itiCode, :tradeCode, CAST(:strength AS hstore),"
                        + " CAST(:strengthFill AS hstore), CAST(:strengthVacant AS hstore),"
                        + " :year, :phase)",
                matrixParams);

        int itiTradeFill = response.getTotalStrength() - totalVacant;
        jdbc.update("UPDATE ititrade SET strength_vacant = :vacant, strength_fill = :fill"
                        + " WHERE iti_code = :itiCode AND trade_code = :tradeCode",
                new MapSqlParameterSource()
                        .addValue("vacant", totalVacant)
                        .addValue("fill", itiTradeFill)
                        .addValue("itiCode", request.getItiCode())
                        .addValue("tradeCode", request.getTradeCode()));

        response.setTotalStrengthFill(itiTradeFill);
        response.setTotalStrengthVacant(totalVacant);

        for (String[] category : categoryList()) {
            String code = category[0];
            response.getCategories().add(new ReservationCategoryDto(code, category[1],
                    strength.get(code), fill.get(code), vacant.get(code)));
        }
        response.setEnteredStrength(totalStrength);
        response.setEnteredStrengthVacant(totalVacant);
        response.setSuccess(true);
        response.setMessage("Reservation breakup saved for " + request.getItiCode()
                + " trade " + request.getTradeCode());
        return response;
    }

    private ReservationEntryResponse baseResponse(String itiCode, Integer tradeCode,
                                                  String year, int phase) {
        ReservationEntryResponse response = new ReservationEntryResponse();
        response.setItiCode(itiCode);
        response.setTradeCode(tradeCode);
        response.setYear(year);
        response.setPhase(phase);

        List<Map<String, Object>> itiRows = jdbc.getJdbcTemplate().queryForList(
                "SELECT iti_name FROM iti WHERE iti_code = ?", itiCode);
        if (!itiRows.isEmpty()) {
            response.setItiName(String.valueOf(itiRows.get(0).get("iti_name")));
        }

        List<Map<String, Object>> tradeRows = jdbc.getJdbcTemplate().queryForList(
                "SELECT t.strength, t.strength_fill, t.strength_vacant, t.trade_short, m.trade_name"
                        + " FROM ititrade t LEFT JOIN ititrade_master m ON m.trade_short = t.trade_short"
                        + " WHERE t.iti_code = ? AND t.trade_code = ?",
                itiCode, tradeCode);
        if (!tradeRows.isEmpty()) {
            Map<String, Object> row = tradeRows.get(0);
            response.setTradeShort(row.get("trade_short") == null ? null
                    : String.valueOf(row.get("trade_short")));
            response.setTradeName(row.get("trade_name") == null ? null
                    : String.valueOf(row.get("trade_name")));
            response.setTotalStrength(asInteger(row.get("strength")));
            response.setTotalStrengthFill(asInteger(row.get("strength_fill")));
            response.setTotalStrengthVacant(asInteger(row.get("strength_vacant")));
        }
        return response;
    }

    private void loadMatrix(String itiCode, Integer tradeCode, String year, int phase,
                            Map<String, Integer> strength, Map<String, Integer> fill) {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT s.category_code, s.strength, s.strength_fill"
                        + " FROM (SELECT skeys(strength) AS category_code,"
                        + " svals(strength) AS strength, svals(strength_fill) AS strength_fill"
                        + " FROM iti_seatmatrix"
                        + " WHERE iti_code = ? AND trade_code = ? AND year = ? AND phase = ?) s",
                itiCode, tradeCode, year, phase);
        for (Map<String, Object> row : rows) {
            String code = row.get("category_code") == null ? null
                    : String.valueOf(row.get("category_code"));
            if (code == null) {
                continue;
            }
            strength.put(code, asInteger(row.get("strength")));
            fill.put(code, asInteger(row.get("strength_fill")));
        }
    }

    private List<String[]> categoryList() {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT category_code, category_name FROM category_mast"
                        + " WHERE category_code IS NOT NULL"
                        + " GROUP BY category_code, category_name, category_order"
                        + " ORDER BY category_order NULLS LAST, category_name");
        List<String[]> categories = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            categories.add(new String[]{
                    String.valueOf(row.get("category_code")),
                    String.valueOf(row.get("category_name"))});
        }
        return categories;
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

    private int seatMatrixPhase(Map<String, Object> config) {
        Object seatMatrixPhase = config.get("seatmatrix_phase");
        if (seatMatrixPhase != null && asInteger(seatMatrixPhase) > 0) {
            return asInteger(seatMatrixPhase);
        }
        return asInteger(config.get("phase"));
    }

    private int sumEntries(List<ReservationCategoryDto> categories) {
        int total = 0;
        for (ReservationCategoryDto category : categories) {
            total += category.getStrength() == null ? 0 : category.getStrength();
        }
        return total;
    }

    private int sumVacant(List<ReservationCategoryDto> categories) {
        int total = 0;
        for (ReservationCategoryDto category : categories) {
            total += category.getStrengthVacant() == null ? 0 : category.getStrengthVacant();
        }
        return total;
    }

    private static String toHstore(Map<String, Integer> values) {
        StringBuilder builder = new StringBuilder();
        for (Map.Entry<String, Integer> entry : values.entrySet()) {
            if (builder.length() > 0) {
                builder.append(',');
            }
            builder.append('"').append(entry.getKey()).append('"')
                    .append("=>")
                    .append('"').append(entry.getValue()).append('"');
        }
        return builder.toString();
    }

    private static Integer asInteger(Object value) {
        if (value == null) {
            return null;
        }
        if (value instanceof Number number) {
            return number.intValue();
        }
        String text = String.valueOf(value).trim();
        if (text.isEmpty() || "null".equalsIgnoreCase(text)) {
            return null;
        }
        return Integer.valueOf(text);
    }
}
