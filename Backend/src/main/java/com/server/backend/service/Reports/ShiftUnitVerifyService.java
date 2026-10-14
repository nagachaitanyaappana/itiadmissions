package com.server.backend.service.Reports;

import java.time.Year;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.DTO.ShiftUnitVerifyRowResponse;

/**
 * Shift / Unit verification (port of {@code shift_unit_verify.jsp} +
 * {@code update_shift_unit.jsp}).
 *
 * <p>A district operator picks an ITI in their district and sees every admission
 * still pending verification ({@code admissions.iti_admissions.rec_status = 'E'})
 * for the running admission year. Confirming a row writes the corrected shift /
 * unit and moves the row to verified ({@code rec_status = 'D'}).
 */
@Service
public class ShiftUnitVerifyService {

    private final JdbcTemplate jdbc;

    public ShiftUnitVerifyService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** ITIs of a district, for the picker (ordered by code). */
    public List<Map<String, Object>> getItis(String distCode) {
        return jdbc.queryForList(
                "SELECT iti_code AS \"itiCode\", iti_name AS \"itiName\""
                        + " FROM public.iti WHERE dist_code = ? ORDER BY iti_code",
                distCode);
    }

    /** Admissions awaiting verification for the district + ITI + year. */
    public List<ShiftUnitVerifyRowResponse> getPending(String distCode, String itiCode, String year) {
        String effectiveYear = resolveAdmissionYear(year);
        List<Map<String, Object>> rows = jdbc.queryForList(
                "SELECT adm_num, name, fname, dob, gender, shift, unit"
                        + " FROM admissions.iti_admissions"
                        + " WHERE year_of_admission = ? AND dist_code = ? AND iti_code = ?"
                        + " AND rec_status = 'E' ORDER BY adm_num",
                effectiveYear, distCode, itiCode);
        List<ShiftUnitVerifyRowResponse> out = new ArrayList<>();
        for (Map<String, Object> r : rows) {
            out.add(new ShiftUnitVerifyRowResponse(
                    text(r.get("adm_num")),
                    text(r.get("name")),
                    text(r.get("fname")),
                    text(r.get("dob")),
                    text(r.get("gender")),
                    text(r.get("shift")),
                    text(r.get("unit"))));
        }
        return out;
    }

    /** Writes the corrected shift/unit and marks the admission verified. */
    @Transactional
    public int verify(String admNum, String shift, String unit) {
        if (admNum == null || admNum.isBlank()) {
            throw new IllegalArgumentException("Admission number is required");
        }
        return jdbc.update(
                "UPDATE admissions.iti_admissions SET shift = ?, unit = ?, rec_status = 'D'"
                        + " WHERE adm_num = ?",
                shift, unit, admNum.trim());
    }

    private String resolveAdmissionYear(String year) {
        if (year != null && !year.isBlank()) {
            return year.trim();
        }
        try {
            String v = jdbc.queryForObject(
                    "SELECT value FROM public.iti_params WHERE code='7'", String.class);
            if (v != null && !v.isBlank()) {
                return v.trim();
            }
        } catch (Exception ignored) {
            // fall through
        }
        return String.valueOf(Year.now().getValue());
    }

    private static String text(Object value) {
        return value == null ? null : String.valueOf(value);
    }
}
