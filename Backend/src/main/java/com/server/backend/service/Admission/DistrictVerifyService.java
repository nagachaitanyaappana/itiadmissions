package com.server.backend.service.Admission;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.server.backend.Repository.Student.StudentApplicationRepository;
import com.server.backend.entity.StudentApplication;
import com.server.backend.service.AdmissionPhaseWindowService;
import com.server.backend.service.AdmissionPhaseWindowService.Window;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class DistrictVerifyService {

    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final StudentApplicationRepository studentRepo;
    private final AdmissionPhaseWindowService phaseWindows;

    public DistrictVerifyService(NamedParameterJdbcTemplate jdbcTemplate,
                                 StudentApplicationRepository studentRepo,
                                 AdmissionPhaseWindowService phaseWindows) {
        this.jdbcTemplate = jdbcTemplate;
        this.studentRepo = studentRepo;
        this.phaseWindows = phaseWindows;
    }

    public Map<String, Object> windowStatus() {
        AdmissionPhaseWindowService.Status verification = phaseWindows.status(Window.VERIFICATION);
        AdmissionPhaseWindowService.Status reverification = phaseWindows.status(Window.REVERIFICATION);
        Map<String, Object> result = new LinkedHashMap<>();
        result.put("phase", verification.phase());
        result.put("verificationOpen", verification.open());
        result.put("reverificationOpen", reverification.open());
        result.put("open", verification.open() || reverification.open());
        return result;
    }

    private static String str(Object o) {
        return o == null ? "" : String.valueOf(o).trim();
    }

    /** student_application.regid is integer in the reference schema; a non-numeric
     *  incoming id simply matches nothing (same as the old String id lookup). */
    private static Optional<Integer> parseRegid(String rid) {
        try {
            return Optional.of(Integer.parseInt(rid.trim()));
        } catch (NumberFormatException ex) {
            return Optional.empty();
        }
    }

    /**
     * Lookup a student application by regid and enrich with marks, trade selections,
     * and district scope information.
     */
    public Map<String, Object> lookup(String regid, String distCode) {
        Map<String, Object> res = new LinkedHashMap<>();
        res.put("success", false);

        if (regid == null || regid.isBlank()) {
            res.put("message", "regid is required");
            return res;
        }
        if (distCode == null || distCode.isBlank()) {
            res.put("message", "distCode is required");
            return res;
        }
        String rid = regid.trim();
        String dc = distCode.trim();

        List<Map<String, Object>> apps = jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT * FROM student_application WHERE regid::text = ?",
                rid);
        if (apps.isEmpty()) {
            res.put("message", "No student application found with regid " + rid);
            return res;
        }
        Map<String, Object> app = apps.get(0);
        String appStatus = str(app.get("app_status"));
        if (appStatus.isEmpty()) appStatus = "N";

        // Get only trades for THIS district (district-scoping)
        List<Map<String, Object>> trades = jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT st.regid, st.iti_code, st.dist_code, st.temp, st.temp_code, st.trno, st.year, st.phase::text AS phase_text, st.freezee, " +
                " i.iti_name, d.dist_name " +
                " FROM student_trade_sel st " +
                " LEFT JOIN iti i ON i.iti_code = st.iti_code " +
                " LEFT JOIN dist_mst d ON d.dist_code = st.dist_code " +
                " WHERE st.regid::text = ? AND st.dist_code = ? ORDER BY st.temp", rid, dc);

        if (trades.isEmpty()) {
            res.put("message", "This student has no ITI selected in your district (" + dc + ")");
            return res;
        }

        res.put("success", true);
        res.put("student", app);
        res.put("appStatus", appStatus);
        res.put("trades", trades);
        res.put("allowed", true);
        res.put("distCode", dc);

        int existsApp = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT count(*) FROM application WHERE regid::text = ?",
                Integer.class, rid);
        res.put("alreadyInApplication", existsApp > 0);

        List<Map<String, Object>> marks = jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT * FROM student_cand_marks WHERE regid::text = ?", rid);
        res.put("marks", marks.isEmpty() ? null : marks.get(0));

        int hasPhoto = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT count(*) FROM img_cand_photos WHERE regid::text = ?",
                Integer.class, rid);
        res.put("hasPhoto", hasPhoto > 0);

        String distName = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT dist_name FROM dist_mst WHERE dist_code = ?",
                String.class, dc);
        res.put("distName", distName == null ? "" : distName);

        return res;
    }

    /**
     * Approve a student application: copy to admission tables (application, cand_marks, trade_sel)
     * and set app_status='A' on the staging row.
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> approve(String regid, String distCode, String username, String ip,
                                       Map<String, String> documents) {
        Map<String, Object> res = new LinkedHashMap<>();
        res.put("success", false);

        if (regid == null || regid.isBlank()) {
            res.put("message", "regid is required");
            return res;
        }
        String rid = regid.trim();
        if (distCode == null || distCode.isBlank()) {
            res.put("message", "distCode is required");
            return res;
        }
        String dc = distCode.trim();

        // Verify candidate exists and belongs to the district
        Optional<StudentApplication> opt = parseRegid(rid).flatMap(studentRepo::findById);
        if (opt.isEmpty()) {
            res.put("message", "No student application found with regid " + rid);
            return res;
        }

        List<String> dists = jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT DISTINCT dist_code FROM student_trade_sel WHERE regid::text = ? AND dist_code IS NOT NULL",
                String.class, rid);
        if (dists.isEmpty() || !dists.contains(dc)) {
            res.put("message", "This application has no ITI selected in your district (" + dc + ")");
            return res;
        }

        String currentStatus = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT app_status FROM student_application WHERE regid::text = ?", String.class, rid);
        Window window = isPreviouslyVerified(currentStatus) ? Window.REVERIFICATION : Window.VERIFICATION;
        if (!phaseWindows.isOpen(window)) {
            res.put("code", "DATE_EXPIRED");
            res.put("message", "Date has Expired");
            return res;
        }

        // 1. Update student_application: set app_status='A', verified info
        Map<String, String> docs = documents != null ? documents : new HashMap<>();
        String sscEq = docs.getOrDefault("doc_ssc_eq", "N/A");
        String tc = docs.getOrDefault("doc_tc", "N/A");
        String cc = docs.getOrDefault("doc_cc", "N/A");
        String pc = docs.getOrDefault("doc_pc", "N/A");
        String exsv = docs.getOrDefault("doc_exsv", "N/A");
        String sc = docs.getOrDefault("doc_sc", "N/A");
        String nc = docs.getOrDefault("doc_nc", "N/A");
        String uidv = docs.getOrDefault("doc_uidv", "N/A");
        String ewsv = docs.getOrDefault("doc_ewsv", "N/A");
        String age21 = docs.getOrDefault("doc_age21", "N/A");
        String exp = docs.getOrDefault("doc_exp", "N/A");
        String est = docs.getOrDefault("doc_est", "N/A");

        int upd = jdbcTemplate.getJdbcTemplate().update(
                "UPDATE student_application SET app_status='A', user_id=?, ip=?, verified_date=now(), verified_ip=?, " +
                "ssc_eq_marks=?, tc=?, caste_certificate=?, ph_challenge=?, ex_service=?, " +
                "study_certificate=?, nativity_certificate=?, uidv=?, ewsv=?, age_21=?, experience=?, est=? " +
                "WHERE regid::text = ?",
                dc, ip, ip, sscEq, tc, cc, pc, exsv, sc, nc, uidv, ewsv, age21, exp, est, rid);
        if (upd != 1) {
            throw new IllegalStateException("Failed to update student_application for regid " + rid);
        }

        // 2. Copy to application (DELETE then INSERT)
        jdbcTemplate.getJdbcTemplate().update("DELETE FROM application WHERE regid::text = ?", rid);
        String appInsert = """
            INSERT INTO application (
                regid, name, fname, addr, mname, phno, adarno, gender, caste, ssc_type,
                ssc_passed, inter_passed, inter_marks, local, pincode, ts, ip, uid, phc, exservice,
                dob, trno, ssc_regno, ssc_board, ssc_year, ssc_month, phase, year,
                university_area, data_flag, app_status, user_id, reason, email, pwd_category,
                economic_weaker_section, is_trainee_dual_mode, verified_date, verified_ip,
                ssc_eq_marks, tc, caste_certificate, ph_challenge, ex_service,
                study_certificate, nativity_certificate, uidv, ewsv, age_21, experience, est, sub_caste
            ) SELECT
                regid::integer, name, fname, addr, mname, phno, adarno, gender, caste, ssc_type,
                ssc_passed, inter_passed, inter_marks, local, pincode, ts, ip, uid,
                COALESCE(phc, false), COALESCE(exservice, false),
                dob, trno, ssc_regno, ssc_board, ssc_year, ssc_month,
                hstore(array[COALESCE(phase,'')], array['true']),
                year, university_area, data_flag, app_status, user_id, reason, email, pwd_category,
                economic_weaker_section, is_trainee_dual_mode, verified_date, verified_ip,
                ssc_eq_marks, tc, caste_certificate, ph_challenge, ex_service,
                study_certificate, nativity_certificate, uidv, ewsv, age_21, experience, est, sub_caste
            FROM student_application WHERE regid::character varying = ?
            """;
        jdbcTemplate.getJdbcTemplate().update(appInsert, rid);

        // 3. Copy to cand_marks
        jdbcTemplate.getJdbcTemplate().update("DELETE FROM cand_marks WHERE regid::text = ?", rid);
        String marksInsert = """
            INSERT INTO cand_marks (
                regid, ssc_first_lang_marks, ssc_first_lang_gpa, ssc_first_lang_grade,
                ssc_second_lang_marks, ssc_second_lang_gpa, ssc_second_lang_grade,
                ssc_eng_marks, ssc_eng_gpa, ssc_eng_grade,
                ssc_math_marks, ssc_math_gpa, ssc_math_grade,
                ssc_sci_marks, ssc_sci_gpa, ssc_sci_grade,
                ssc_social_marks, ssc_social_gpa, ssc_social_grade,
                inter_first_sub, inter_first_marks,
                inter_second_sub, inter_second_marks,
                inter_third_sub, inter_third_marks,
                ssc_tot_marks, ssc_tot_gpa, "group", trno, groupname, year
            ) SELECT
                regid, ssc_first_lang_marks, ssc_first_lang_gpa, ssc_first_lang_grade,
                ssc_second_lang_marks, ssc_second_lang_gpa, ssc_second_lang_grade,
                ssc_eng_marks, ssc_eng_gpa, ssc_eng_grade,
                ssc_math_marks, ssc_math_gpa, ssc_math_grade,
                ssc_sci_marks, ssc_sci_gpa, ssc_sci_grade,
                ssc_social_marks, ssc_social_gpa, ssc_social_grade,
                inter_first_sub, inter_first_marks,
                inter_second_sub, inter_second_marks,
                inter_third_sub, inter_third_marks,
                ssc_tot_marks, ssc_tot_gpa, "group", trno, groupname, year
            FROM student_cand_marks WHERE regid::character varying = ?
            """;
        jdbcTemplate.getJdbcTemplate().update(marksInsert, rid);

        // 4. Copy to trade_sel — district-scoped: only the trades for the district this
        // officer is approving (mirrors DistrictVerifyService.list which scopes by
        // regid+dist_code). Each district approves/rejects independently, so multiple
        // districts per regid must be able to coexist in trade_sel.
        jdbcTemplate.getJdbcTemplate().update("DELETE FROM trade_sel WHERE regid::text = ? AND dist_code = ?", rid, distCode);
        String tradeInsert = """
            INSERT INTO trade_sel (regid, iti_code, dist_code, temp, freezee, temp_code, trno, phase, year)
            SELECT regid, iti_code, dist_code, temp, freezee, temp_code, trno, phase, year
            FROM student_trade_sel WHERE regid::character varying = ? AND dist_code = ?
            """;
        jdbcTemplate.getJdbcTemplate().update(tradeInsert, rid, distCode);

        // Count rows copied
        int appCount = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT count(*) FROM application WHERE regid::text = ?", Integer.class, rid);
        int marksCount = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT count(*) FROM cand_marks WHERE regid::text = ?", Integer.class, rid);
        int tradeCount = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT count(*) FROM trade_sel WHERE regid::text = ?", Integer.class, rid);

        res.put("success", true);
        res.put("message", "Application approved successfully");
        res.put("appStatus", "A");
        return res;
    }

    /**
     * Reject a student application: set app_status='R' and remove any promoted copies.
     */
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> reject(String regid, String distCode, String username, String reason, String ip) {
        Map<String, Object> res = new LinkedHashMap<>();
        res.put("success", false);

        if (regid == null || regid.isBlank()) {
            res.put("message", "regid is required");
            return res;
        }
        String rid = regid.trim();
        if (distCode == null || distCode.isBlank()) {
            res.put("message", "distCode is required");
            return res;
        }
        String dc = distCode.trim();
        String rejReason = reason == null ? "" : reason.trim();

        // Verify candidate exists
        Optional<StudentApplication> opt = parseRegid(rid).flatMap(studentRepo::findById);
        if (opt.isEmpty()) {
            res.put("message", "No student application found with regid " + rid);
            return res;
        }

        // District-scoping: verify this student has ITIs in the approver's district
        List<String> dists = jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT DISTINCT dist_code FROM student_trade_sel WHERE regid::text = ? AND dist_code IS NOT NULL",
                String.class, rid);
        if (dists.isEmpty() || !dists.contains(dc)) {
            res.put("message", "This application has no ITI selected in your district (" + dc + ")");
            return res;
        }

        String currentStatus = jdbcTemplate.getJdbcTemplate().queryForObject(
                "SELECT app_status FROM student_application WHERE regid::text = ?", String.class, rid);
        Window window = isPreviouslyVerified(currentStatus) ? Window.REVERIFICATION : Window.VERIFICATION;
        if (!phaseWindows.isOpen(window)) {
            res.put("code", "DATE_EXPIRED");
            res.put("message", "Date has Expired");
            return res;
        }

        // 1. Update student_application
        int upd = jdbcTemplate.getJdbcTemplate().update(
                "UPDATE student_application SET app_status='R', reason=?, user_id=?, ip=?, verified_date=now(), verified_ip=? WHERE regid::text = ?",
                rejReason, dc, ip, ip, rid);
        if (upd != 1) {
            throw new IllegalStateException("Failed to update student_application for regid " + rid);
        }

        // 2. Remove any promoted copies
        jdbcTemplate.getJdbcTemplate().update("DELETE FROM application WHERE regid::text = ?", rid);
        jdbcTemplate.getJdbcTemplate().update("DELETE FROM cand_marks WHERE regid::text = ?", rid);
        jdbcTemplate.getJdbcTemplate().update("DELETE FROM trade_sel WHERE regid::text = ?", rid);

        res.put("success", true);
        res.put("message", "Application rejected successfully");
        res.put("appStatus", "R");
        return res;
    }

    private static boolean isPreviouslyVerified(String appStatus) {
        return "A".equalsIgnoreCase(str(appStatus)) || "R".equalsIgnoreCase(str(appStatus));
    }

    /**
     * Lists applications that selected this district (via student_trade_sel),
     * newest first. Shape matches what distVerificationJs.js renders:
     * regid, name, fname, user_id, verified_date, app_status, ssc_regno, dob.
     */
    public List<Map<String, Object>> list(String distCode) {
        if (distCode == null || distCode.isBlank()) {
            return List.of();
        }
        return jdbcTemplate.getJdbcTemplate().queryForList(
                "SELECT a.regid, a.name, a.fname, a.user_id, a.verified_date, " +
                "       a.app_status, a.ssc_regno, a.dob " +
                "FROM student_application a " +
                "WHERE EXISTS (SELECT 1 FROM student_trade_sel s " +
                "              WHERE s.regid::text = a.regid::text AND s.dist_code = ?) " +
                "ORDER BY a.regid DESC",
                distCode.trim());
    }
}