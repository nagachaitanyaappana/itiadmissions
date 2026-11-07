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

    private static String claim(Claims claims, String name) {
        Object value = claims.get(name);
        return value == null ? null : String.valueOf(value);
    }
}
