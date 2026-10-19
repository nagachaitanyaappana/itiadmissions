package com.server.backend.service.Admission;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.LinkedHashSet;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.ReservationCategoryDto;
import com.server.backend.DTO.ReservationCategoryEntry;
import com.server.backend.DTO.ReservationEntryRequest;
import com.server.backend.DTO.ReservationEntryResponse;
import com.server.backend.DTO.ReservationTradeDto;
import com.server.backend.DTO.SeatCorrectionEntry;
import com.server.backend.DTO.SeatCorrectionRequest;

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
        return queryTrades(itiCode, false);
    }

    /**
     * Only the trades that have been approved (Add Trade -&gt; Approve All) for the ITI. Reservation
     * Entry must not offer unapproved trades.
     */
    public List<ReservationTradeDto> getApprovedTradesForIti(String itiCode) {
        return queryTrades(itiCode, true);
    }

    private List<ReservationTradeDto> queryTrades(String itiCode, boolean approvedOnly) {
        String sql = "SELECT t.trade_code, t.trade_short, m.trade_name, m.durationyrs, t.strength,"
                + " t.strength_fill, t.strength_vacant"
                + " FROM ititrade t LEFT JOIN ititrade_master m ON m.trade_short = t.trade_short"
                + " WHERE t.iti_code = ?"
                + (approvedOnly ? " AND t.conv_approval = 1" : "")
                + " ORDER BY m.trade_name NULLS LAST, t.trade_code";
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(sql, itiCode);
        List<ReservationTradeDto> trades = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            ReservationTradeDto dto = new ReservationTradeDto(
                    asInteger(row.get("trade_code")),
                    row.get("trade_short") == null ? null : String.valueOf(row.get("trade_short")),
                    row.get("trade_name") == null ? null : String.valueOf(row.get("trade_name")),
                    asInteger(row.get("strength")),
                    asInteger(row.get("strength_fill")),
                    asInteger(row.get("strength_vacant")));
            dto.setDurationYrs(asInteger(row.get("durationyrs")));
            trades.add(dto);
        }
        return trades;
    }

    /**
     * Whether Reservation Entry may be opened for this ITI. It requires both an approved trade
     * ({@code ititrade.conv_approval = 1}, produced by Add Trade -&gt; Approve All) and a shift-unit
     * row ({@code shift_unit_permitted.available_year = true}, produced by DGT Permitted Shifts
     * Units).
     */
    public Map<String, Object> getReadiness(String itiCode) {
        Integer approvedTrades = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ? AND conv_approval = 1",
                Integer.class, itiCode);
        Integer shiftUnits = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM shift_unit_permitted WHERE iti_code = ? AND available_year = true",
                Integer.class, itiCode);

        int approved = approvedTrades == null ? 0 : approvedTrades;
        int shifts = shiftUnits == null ? 0 : shiftUnits;
        boolean tradesApproved = approved > 0;
        boolean shiftUnitDone = shifts > 0;
        boolean ready = tradesApproved && shiftUnitDone;

        String message;
        if (ready) {
            message = "Reservation Entry is open for ITI " + itiCode;
        } else if (!tradesApproved && !shiftUnitDone) {
            message = "Complete DGT Permitted Shifts Units, then Add Trade and click Approve All, for ITI "
                    + itiCode + " before entering reservations.";
        } else if (!tradesApproved) {
            message = "No approved trade for ITI " + itiCode
                    + ". Go to Add Trade and click Approve All first.";
        } else {
            message = "No shift units permitted for ITI " + itiCode
                    + ". Complete DGT Permitted Shifts Units first.";
        }

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("itiCode", itiCode);
        result.put("approvedTrades", approved);
        result.put("shiftUnits", shifts);
        result.put("tradesApproved", tradesApproved);
        result.put("shiftUnitDone", shiftUnitDone);
        result.put("ready", ready);
        result.put("message", message);
        return result;
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

        // Reservation Entry is gated: the ITI must have an approved trade and shift units, and the
        // trade being edited must itself be approved (ititrade.conv_approval = 1).
        Map<String, Object> readiness = getReadiness(request.getItiCode());
        if (!Boolean.TRUE.equals(readiness.get("ready"))) {
            response.setSuccess(false);
            response.setMessage(String.valueOf(readiness.get("message")));
            return response;
        }
        Integer tradeApproved = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ? AND trade_code = ? AND conv_approval = 1",
                Integer.class, request.getItiCode(), request.getTradeCode());
        if (tradeApproved == null || tradeApproved == 0) {
            response.setSuccess(false);
            response.setMessage("Trade " + request.getTradeCode() + " is not approved for ITI "
                    + request.getItiCode() + ". Approve the trade (Add Trade) before entering reservations.");
            return response;
        }

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

    /**
     * Seat Correction screen (legacy {@code manageseats_interface_already_fill_fromadm.jsp}).
     * Same category/strength data as {@link #getReservation}, plus the actual admitted count
     * read from {@code admissions.iti_admissions} for the category's {@code res_category}.
     */
    public ReservationEntryResponse getSeatCorrection(String itiCode, Integer tradeCode) {
        Map<String, Object> config = currentPhaseConfig();
        String year = String.valueOf(config.get("year"));
        int phase = seatMatrixPhase(config);

        ReservationEntryResponse response = baseResponse(itiCode, tradeCode, year, phase);

        Map<String, Integer> strength = new LinkedHashMap<>();
        Map<String, Integer> fill = new LinkedHashMap<>();
        loadMatrix(itiCode, tradeCode, year, phase, strength, fill);
        Map<String, Integer> admitted = admittedCounts(itiCode, tradeCode, year);

        for (String[] category : categoryList()) {
            String code = category[0];
            ReservationCategoryDto dto = new ReservationCategoryDto(code, category[1],
                    strength.getOrDefault(code, 0),
                    fill.getOrDefault(code, 0),
                    Math.max(strength.getOrDefault(code, 0) - fill.getOrDefault(code, 0), 0));
            dto.setAdmitted(admitted.getOrDefault(code, 0));
            response.getCategories().add(dto);
        }

        response.setEnteredStrength(sumEntries(response.getCategories()));
        response.setEnteredStrengthVacant(sumVacant(response.getCategories()));
        response.setSuccess(true);
        response.setMessage("Seat correction loaded");
        return response;
    }

    /**
     * Persist Seat Correction: like {@link #saveReservation} but the already-filled count is
     * taken from the request (the operator corrects it against the admitted numbers), exactly
     * like the legacy {@code manageseats_interface_already_fill_fromadmAction}. Vacant is
     * recomputed as {@code strength - fill} (the legacy page's own vacant field is ignored).
     */
    @Transactional
    public ReservationEntryResponse saveSeatCorrection(SeatCorrectionRequest request) {
        Map<String, Object> config = currentPhaseConfig();
        String year = String.valueOf(config.get("year"));
        int phase = seatMatrixPhase(config);

        ReservationEntryResponse response = baseResponse(
                request.getItiCode(), request.getTradeCode(), year, phase);

        Map<String, Object> readiness = getReadiness(request.getItiCode());
        if (!Boolean.TRUE.equals(readiness.get("ready"))) {
            response.setSuccess(false);
            response.setMessage(String.valueOf(readiness.get("message")));
            return response;
        }
        Integer tradeApproved = jdbc.getJdbcTemplate().queryForObject(
                "SELECT COUNT(*) FROM ititrade WHERE iti_code = ? AND trade_code = ? AND conv_approval = 1",
                Integer.class, request.getItiCode(), request.getTradeCode());
        if (tradeApproved == null || tradeApproved == 0) {
            response.setSuccess(false);
            response.setMessage("Trade " + request.getTradeCode() + " is not approved for ITI "
                    + request.getItiCode() + ". Approve the trade (Add Trade) before correcting seats.");
            return response;
        }
        if (response.getTotalStrength() == null) {
            response.setSuccess(false);
            response.setMessage("No sanctioned strength (ititrade) found for ITI "
                    + request.getItiCode() + " trade " + request.getTradeCode());
            return response;
        }

        Map<String, Integer> requestedStrength = new LinkedHashMap<>();
        Map<String, Integer> requestedFill = new LinkedHashMap<>();
        for (SeatCorrectionEntry entry : request.getEntries()) {
            requestedStrength.put(entry.getCategoryCode(),
                    entry.getStrength() == null ? 0 : entry.getStrength());
            requestedFill.put(entry.getCategoryCode(),
                    entry.getStrengthFill() == null ? 0 : entry.getStrengthFill());
        }

        Map<String, Integer> strength = new LinkedHashMap<>();
        Map<String, Integer> fill = new LinkedHashMap<>();
        Map<String, Integer> vacant = new LinkedHashMap<>();

        int totalStrength = 0;
        int totalVacant = 0;
        for (String[] category : categoryList()) {
            String code = category[0];
            int st = requestedStrength.getOrDefault(code, 0);
            int fl = requestedFill.getOrDefault(code, 0);
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

        Map<String, Integer> admitted = admittedCounts(
                request.getItiCode(), request.getTradeCode(), year);
        for (String[] category : categoryList()) {
            String code = category[0];
            ReservationCategoryDto dto = new ReservationCategoryDto(code, category[1],
                    strength.get(code), fill.get(code), vacant.get(code));
            dto.setAdmitted(admitted.getOrDefault(code, 0));
            response.getCategories().add(dto);
        }
        response.setEnteredStrength(totalStrength);
        response.setEnteredStrengthVacant(totalVacant);
        response.setSuccess(true);
        response.setMessage("Seat correction saved for " + request.getItiCode()
                + " trade " + request.getTradeCode());
        return response;
    }

    /** Actual admitted counts per {@code res_category} from {@code admissions.iti_admissions}. */
    private Map<String, Integer> admittedCounts(String itiCode, Integer tradeCode, String year) {
        Map<String, Integer> counts = new LinkedHashMap<>();
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT res_category, COUNT(*) AS admitted FROM admissions.iti_admissions"
                        + " WHERE iti_code = ? AND trade_code = ? AND year_of_admission = ?"
                        + " GROUP BY res_category",
                itiCode, tradeCode, year);
        for (Map<String, Object> row : rows) {
            String code = row.get("res_category") == null ? null : String.valueOf(row.get("res_category"));
            if (code != null) {
                counts.put(code, asInteger(row.get("admitted")));
            }
        }
        return counts;
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
            response.setTotalStrength(getIntegerFromValue(row.get("strength")));
            response.setTotalStrengthFill(getIntegerFromValue(row.get("strength_fill")));
            response.setTotalStrengthVacant(getIntegerFromValue(row.get("strength_vacant")));
        }
        return response;
    }


    private void loadMatrix(String itiCode, Integer tradeCode, String year, int phase,
                            Map<String, Integer> strength, Map<String, Integer> fill) {
        List<Map<String, Object>> rows = jdbc.getJdbcTemplate().queryForList(
                "SELECT strength, strength_fill"
                        + " FROM iti_seatmatrix"
                        + " WHERE iti_code = ? AND trade_code = ? AND year = ? AND phase = ?",
                itiCode, tradeCode, year, phase);
        for (Map<String, Object> row : rows) {
            String strengthHstore = row.get("strength") == null ? null
                    : String.valueOf(row.get("strength"));
            String fillHstore = row.get("strength_fill") == null ? null
                    : String.valueOf(row.get("strength_fill"));
            Map<String, String> strengthMap = parseHstoreToMap(strengthHstore);
            Map<String, String> fillMap = parseHstoreToMap(fillHstore);
            // We need to combine the keys from both maps; assume they have the same keys.
            // We'll iterate over the union of keys.
            Set<String> keys = new LinkedHashSet<>(strengthMap.keySet());
            keys.addAll(fillMap.keySet());
            for (String code : keys) {
                String sVal = strengthMap.get(code);
                String fVal = fillMap.get(code);
                int sInt = sVal == null ? 0 : parseInt(sVal);
                int fInt = fVal == null ? 0 : parseInt(fVal);
                strength.put(code, sInt);
                fill.put(code, fInt);
            }
        }
    }

    private int parseInt(String value) {
        try {
            return Integer.valueOf(value);
        } catch (NumberFormatException e) {
            return 0;
        }
    }
    private static Map<String, String> parseHstoreToMap(String hstoreString) {
        Map<String, String> map = new LinkedHashMap<>();
        if (hstoreString == null || hstoreString.isEmpty()) {
            return map;
        }
        String text = hstoreString.trim();
        if (text.isEmpty() || "null".equalsIgnoreCase(text)) {
            return map;
        }
        // Expect format: {key1=>value1,key2=>value2,...}
        if (text.startsWith("{") && text.endsWith("}")) {
            String inner = text.substring(1, text.length() - 1);
            if (inner.isEmpty()) {
                return map;
            }
            String[] pairs = inner.split(",");
            for (String pair : pairs) {
                String[] kv = pair.split("=>", 2);
                if (kv.length == 2) {
                    String key = kv[0].trim();
                    String val = kv[1].trim();
                    // Remove surrounding quotes if present
                    if (val.startsWith("\"") && val.endsWith("\"") && val.length() > 1) {
                        val = val.substring(1, val.length() - 1);
                    }
                    map.put(key, val);
                }
            }
        }
        // If not hstore format, treat as a single value? Not expected.
        return map;
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
    private static Integer getIntegerFromValue(Object value) {
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
        // Try to parse as integer directly
        try {
            return Integer.valueOf(text);
        } catch (NumberFormatException e) {
            // If not a plain integer, try to parse as hstore
            if (text.startsWith("{") && text.endsWith("}")) {
                String inner = text.substring(1, text.length() - 1);
                if (inner.isEmpty()) {
                    return null;
                }
                String[] pairs = inner.split(",");
                int sum = 0;
                for (String pair : pairs) {
                    String[] kv = pair.split("=>", 2);
                    if (kv.length == 2) {
                        String valStr = kv[1].trim();
                        // Remove surrounding quotes if present
                        if (valStr.startsWith("\"") && valStr.endsWith("\"") && valStr.length() > 1) {
                            valStr = valStr.substring(1, valStr.length() - 1);
                        }
                        try {
                            sum += Integer.valueOf(valStr);
                        } catch (NumberFormatException ex) {
                            // If a value is not an integer, skip it
                        }
                    }
                }
                return sum;
            }
            // If not hstore and not integer, return null
            return null;
        }
    }
}
