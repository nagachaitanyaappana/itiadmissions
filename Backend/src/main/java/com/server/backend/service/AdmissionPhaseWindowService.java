package com.server.backend.service;

import java.sql.Timestamp;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

@Service
public class AdmissionPhaseWindowService {

    public enum Window {
        APPLICATION(null, "application_to_date"),
        MERIT_LIST("meritliststartdate", "meritlisttodate"),
        VERIFICATION("verification_start_date", "verification_end_date"),
        REVERIFICATION("reverificationstartdate", "reverificationenddate"),
        ADMISSIONS("admissions_start_date", "admissions_end_date");

        private final String startColumn;
        private final String endColumn;

        Window(String startColumn, String endColumn) {
            this.startColumn = startColumn;
            this.endColumn = endColumn;
        }
    }

    public record Status(String phase, boolean open, Timestamp start, Timestamp end) {}
    public record Cycle(String year, String phase, String seatMatrixPhase) {}

    private final JdbcTemplate jdbcTemplate;

    public AdmissionPhaseWindowService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Status status(Window window) {
        String startExpression = window.startColumn == null
                ? "NULL::timestamp"
                : window.startColumn;
        String endExpression = window == Window.APPLICATION
                ? "application_to_date + interval '1 second'"
                : window.endColumn;
        String predicate = window == Window.APPLICATION
                ? "application_to_date IS NOT NULL AND now() <= application_to_date + interval '1 second'"
                : window.startColumn + " IS NOT NULL AND " + window.endColumn
                        + " IS NOT NULL AND now() BETWEEN " + window.startColumn
                        + " AND " + window.endColumn;

        return jdbcTemplate.query(
                "SELECT phase::text, " + startExpression + " AS starts_at, "
                        + endExpression + " AS ends_at, COALESCE((" + predicate + "), false) AS open "
                        + "FROM admissions.admission_phase WHERE current = 'true' "
                        + "ORDER BY year DESC, phase DESC LIMIT 1",
                rs -> rs.next()
                        ? new Status(rs.getString("phase"), rs.getBoolean("open"),
                                rs.getTimestamp("starts_at"), rs.getTimestamp("ends_at"))
                        : new Status(null, false, null, null));
    }

    public Cycle currentCycle() {
        return jdbcTemplate.query(
                "SELECT year::text, phase::text, seatmatrix_phase::text "
                        + "FROM admissions.admission_phase WHERE current = 'true' "
                        + "ORDER BY year DESC, phase DESC LIMIT 1",
                rs -> rs.next()
                        ? new Cycle(rs.getString("year"), rs.getString("phase"),
                                rs.getString("seatmatrix_phase"))
                        : null);
    }

    public boolean isOpen(Window window) {
        return status(window).open();
    }
}
