package com.server.backend.service.Student;

import io.jsonwebtoken.Claims;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

/**
 * Object-level checks for official access to candidate records. District and
 * ITI officials may only read a candidate who has a trade selection in their
 * own district/ITI; state administrators and nodal officials retain the
 * application-wide access their role requires.
 */
@Service
public class StudentObjectAuthorizationService {

    private static final Logger log = LoggerFactory.getLogger(StudentObjectAuthorizationService.class);
    private final JdbcTemplate jdbc;

    public StudentObjectAuthorizationService(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public boolean canRead(Integer regid, Claims claims) {
        if (regid == null || claims == null) return false;
        String role = claim(claims, "roleId");
        if ("2".equals(role) || "10".equals(role)) return true;

        String scope = claim(claims, "insCode");
        if (scope == null || scope.isBlank()) return false;

        String sql;
        if ("3".equals(role)) {
            sql = "SELECT EXISTS (SELECT 1 FROM public.student_trade_sel "
                    + "WHERE CAST(regid AS text) = ? AND dist_code = ?)";
        } else if ("4".equals(role)) {
            sql = "SELECT EXISTS (SELECT 1 FROM public.student_trade_sel "
                    + "WHERE CAST(regid AS text) = ? AND iti_code = ?)";
        } else {
            return false;
        }

        try {
            return Boolean.TRUE.equals(jdbc.queryForObject(sql, Boolean.class,
                    String.valueOf(regid), scope.trim()));
        } catch (org.springframework.dao.DataAccessException ex) {
            // Fail closed when the ownership record cannot be verified.
            log.warn("Candidate object authorization could not be verified");
            return false;
        }
    }

    public boolean canReadInDistrict(Integer regid, String distCode) {
        if (regid == null || distCode == null || distCode.isBlank()) return false;
        try {
            return Boolean.TRUE.equals(jdbc.queryForObject(
                    "SELECT EXISTS (SELECT 1 FROM public.student_trade_sel "
                            + "WHERE CAST(regid AS text) = ? AND CAST(dist_code AS text) = ?)",
                    Boolean.class, String.valueOf(regid), distCode.trim()));
        } catch (org.springframework.dao.DataAccessException ex) {
            log.warn("Candidate district authorization could not be verified");
            return false;
        }
    }

    public boolean canReadInIti(Integer regid, String itiCode) {
        if (regid == null || itiCode == null || itiCode.isBlank()) return false;
        try {
            return Boolean.TRUE.equals(jdbc.queryForObject(
                    "SELECT EXISTS (SELECT 1 FROM public.student_trade_sel "
                            + "WHERE CAST(regid AS text) = ? AND CAST(iti_code AS text) = ?)",
                    Boolean.class, String.valueOf(regid), itiCode.trim()));
        } catch (org.springframework.dao.DataAccessException ex) {
            log.warn("Candidate ITI authorization could not be verified");
            return false;
        }
    }

    public boolean canReadAdmissionInDistrict(String admissionNumber, String year, String distCode) {
        if (admissionNumber == null || admissionNumber.isBlank()
                || year == null || year.isBlank() || distCode == null || distCode.isBlank()) return false;
        try {
            return Boolean.TRUE.equals(jdbc.queryForObject(
                    "SELECT EXISTS (SELECT 1 FROM admissions.iti_admissions "
                            + "WHERE TRIM(BOTH FROM adm_num) = TRIM(BOTH FROM ?) "
                            + "AND TRIM(BOTH FROM CAST(year_of_admission AS TEXT)) = TRIM(BOTH FROM ?) "
                            + "AND CAST(dist_code AS text) = ?)",
                    Boolean.class, admissionNumber.trim(), year.trim(), distCode.trim()));
        } catch (org.springframework.dao.DataAccessException ex) {
            log.warn("Admission district authorization could not be verified");
            return false;
        }
    }

    public boolean isItiInDistrict(String itiCode, String distCode) {
        if (distCode == null || distCode.isBlank()) return false;
        String actualDistrict = districtForIti(itiCode);
        return actualDistrict != null && actualDistrict.equals(distCode.trim());
    }

    /**
     * Resolve an ITI's authoritative district code. Ambiguous, missing or failed
     * mappings return null so an ITI can never inherit multiple district scopes.
     */
    public String districtForIti(String itiCode) {
        if (itiCode == null || itiCode.isBlank()) return null;
        try {
            java.util.List<String> districts = jdbc.queryForList(
                    "SELECT DISTINCT CAST(dist_code AS text) FROM public.iti "
                            + "WHERE CAST(iti_code AS text) = ? AND dist_code IS NOT NULL",
                    String.class, itiCode.trim());
            if (districts.size() != 1 || districts.get(0) == null || districts.get(0).isBlank()) {
                return null;
            }
            return districts.get(0).trim();
        } catch (org.springframework.dao.DataAccessException ex) {
            log.warn("ITI district scope could not be resolved");
            return null;
        }
    }

    private static String claim(Claims claims, String name) {
        Object value = claims.get(name);
        return value == null ? null : String.valueOf(value);
    }
}
