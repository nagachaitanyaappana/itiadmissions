package com.server.backend.service.MeritChecklist;
import java.util.List;
import com.server.backend.DTO.MeritListRow;
import com.server.backend.DTO.UserPrincipal;
import com.server.backend.service.AdmissionPhaseWindowService;
import com.server.backend.service.AdmissionPhaseWindowService.Window;
import org.springframework.stereotype.Service;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import com.server.backend.Repository.MeritChecklist.MeritListRepository;
import com.server.backend.entity.RankEntity;
import com.server.backend.entity.RankId;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import java.util.Map;
@Service
public class MeritListService {

    private static final Logger logger = LoggerFactory.getLogger(MeritListService.class);

    private final MeritListRepository meritListRepository;
    private final NamedParameterJdbcTemplate jdbcTemplate;
    private final AdmissionPhaseWindowService phaseWindows;

    public MeritListService(MeritListRepository meritListRepository, NamedParameterJdbcTemplate jdbcTemplate,
                            AdmissionPhaseWindowService phaseWindows) {
        this.meritListRepository = meritListRepository;
        this.jdbcTemplate = jdbcTemplate;
        this.phaseWindows = phaseWindows;

    }

    public List<RankEntity> getAllMeritList() {
        return meritListRepository.findAll();
    }
    
    public RankEntity getMeritListByRegId(String regid) {
        // public.ranks.regid is integer in the reference schema; a non-numeric path
        // segment (e.g. /api/meritlist/phases matching /{regid}) must 404/400 rather
        // than reach Postgres as a varchar comparison.
        Integer id;
        try {
            id = Integer.valueOf(regid.trim());
        } catch (NumberFormatException e) {
            return null;
        }
        return meritListRepository.findByRegid(id);
    }

    public List<RankEntity> getMeritListByDistCode(String dist_code) {
        return meritListRepository.findByDistCode(dist_code);
    }

    public List<RankEntity> getMeritListByPhase(String phase) {
        return meritListRepository.findByPhase(phase);
    }

    public List<RankEntity> getMeritListByItiCode(String iti_code) {
        return meritListRepository.findByItiCode(iti_code);
    }

    public List<RankEntity> getMeritListByAppStatus(String app_status) {
        return meritListRepository.findByAppStatus(app_status);
    }
    public List<RankEntity> getMeritListByAppStatusIsNull() {
        return meritListRepository.findByAppStatusIsNull();
    }

    public Map<String, Object> meritListWindowStatus() {
        AdmissionPhaseWindowService.Status window = phaseWindows.status(Window.MERIT_LIST);
        Map<String, Object> result = new java.util.LinkedHashMap<>();
        result.put("phase", window.phase());
        result.put("open", window.open());
        result.put("starts_at", window.start());
        result.put("ends_at", window.end());
        return result;
    }
    public RankEntity saveMeritList(RankEntity meritList) {
        return meritListRepository.save(meritList);
    }
    public RankEntity updateMeritList(RankEntity meritList) {
        return meritListRepository.save(meritList);
    }
    public void deleteMeritList(RankId id) {
        meritListRepository.deleteById(id);
    }


    
    @Transactional(rollbackFor = Exception.class)
    public Map<String, Object> generateMeritList(String Category,String qual, String status, UserPrincipal user) {
        // 1. Resolve the year + phase actually in force.
        //    iti_params code '7' is advisory only. It currently reads 2026 while
        //    admissions.admission_phase holds its only current row under 2025, so trusting it
        //    made every request throw "No current phase found for year 2026".
        //    admission_phase is the authority, because the date-window checks below depend on it.
        String paramYearQuery = "SELECT value FROM iti_params WHERE code = '7'";
        List<String> paramYears = jdbcTemplate.getJdbcTemplate().queryForList(paramYearQuery, String.class);
        String paramYear = paramYears.isEmpty() ? null : paramYears.get(0);

        String phaseQuery = "SELECT year, phase " +
                "FROM admissions.admission_phase " +
                "WHERE current = 'true' ORDER BY year DESC LIMIT 1";
        List<Map<String, Object>> phases =
                jdbcTemplate.queryForList(phaseQuery, new MapSqlParameterSource());
        if (phases.isEmpty()) {
            throw new IllegalStateException("No current admission phase found in admissions.admission_phase");
        }

        Map<String, Object> phaseInfo = phases.get(0);
        String year = String.valueOf(phaseInfo.get("year"));
        String phase = String.valueOf(phaseInfo.get("phase"));
        if (paramYear != null && !paramYear.equals(year)) {
            logger.warn("iti_params code '7' year {} does not match the current admission_phase year {}; using admission_phase",
                    paramYear, year);
        }
        if (!phaseWindows.isOpen(Window.MERIT_LIST)) {
            throw new IllegalStateException("Merit-list date has expired or is not configured.");
        }

        // 2. The caller's own role sets the scope: role 3 = whole district, role 4 = one ITI.
        //    Phases 2-5 used to force every caller to role 4, so a district login generated a
        //    single ITI's list instead of the district's.
        String roleId = user.roleid();
        boolean useDistCode = "3".equals(roleId);
        String targetCode = useDistCode ? user.distCode() : user.itiCode();
        if (targetCode == null || targetCode.isBlank()) {
            throw new IllegalArgumentException("No " + (useDistCode ? "district" : "ITI")
                    + " code is available for this login; cannot scope the merit list.");
        }
        String codeColumn = useDistCode ? "dist_code" : "iti_code";

        // 3. 'qual' used to be ignored and every generated row was written as 'all'.
        String qualCode = (qual == null || qual.isBlank()) ? "all" : qual.trim();

        // trno audit row (legacy generic.logTrace -> public.logtr), matching
        // Rank_Generation_Process.jsp line 53 (logTrace(userName, "ranks", "insert", request)).
        String ip = null;
        String referer = null;
        String sessionId = "";
        String userId = "";
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs != null) {
            jakarta.servlet.http.HttpServletRequest req = attrs.getRequest();
            ip = req.getRemoteAddr();
            referer = req.getHeader("referer");
            sessionId = req.getSession().getId();
            Object uname = req.getSession().getAttribute("userName");
            userId = uname == null ? "" : String.valueOf(uname);
        }
        Integer trno = jdbcTemplate.getJdbcTemplate().queryForObject(
                "INSERT INTO public.logtr (ip, userid, referal, tablename, transaction_type, sessionid, ts) "
                        + "VALUES (?, ?, ?, 'ranks', 'insert', ?, ?) RETURNING trno",
                Integer.class,
                ip == null ? "" : ip, userId, referer == null ? "" : referer,
                sessionId, new java.sql.Timestamp(System.currentTimeMillis()).toString());

        String dbTablename;
        String heading;
        String insertColumns;
        String selectValues;

        if ("checklist".equals(status)) {
            dbTablename = "checklist";
            heading = "System Generated CheckList";

            String deleteQuery = String.format(
                    "DELETE FROM checklist c WHERE c.phase = :phase AND c.%s = :targetCode",
                    codeColumn);
            jdbcTemplate.update(deleteQuery, new MapSqlParameterSource("targetCode", targetCode)
                    .addValue("phase", phase));

            insertColumns = "dist_code, regid, rank, iti_code, qual, temp_pk, phase, trno, app_status";
            selectValues = ":distCode, regid, generated_rank::text, :itiCode, :qual, :targetCode, :phase, :trno, app_status";
            
        } else if ("finalmeritlist".equals(status)) {
            // Check if checklist exists
            String checkQuery = String.format(
                    "SELECT EXISTS(SELECT 1 FROM checklist WHERE phase = :phase "
                            + "AND %s = :targetCode LIMIT 1)", codeColumn);
            MapSqlParameterSource checklistParams = new MapSqlParameterSource()
                    .addValue("phase", phase)
                    .addValue("targetCode", targetCode);
            Boolean checklistExists = jdbcTemplate.queryForObject(checkQuery, checklistParams, Boolean.class);
            if (checklistExists == null || !checklistExists) {
                throw new IllegalStateException("Checklist must be generated first for this ITI/District and Phase.");
            }

            // A final merit list is unique within its scope and active year/phase.
            String rankCheckQuery = String.format("SELECT EXISTS(SELECT 1 FROM ranks WHERE phase = :phase AND year = :year AND %s = :targetCode LIMIT 1)", codeColumn);
            MapSqlParameterSource rankParams = new MapSqlParameterSource()
                    .addValue("phase", phase)
                    .addValue("targetCode", targetCode)
                    .addValue("year", year);
            Boolean alreadyGenerated = jdbcTemplate.queryForObject(rankCheckQuery, rankParams, Boolean.class);
            if (alreadyGenerated != null && alreadyGenerated) {
                throw new IllegalStateException(
                    "Final merit list has already been generated for this " +
                    (useDistCode ? "district" : "ITI") + " and phase " + phase
                            + " year " + year + "; it cannot be regenerated.");
            }

            dbTablename = "ranks";
            heading = "FINAL MERIT LIST";

            String deleteQuery = String.format(
                    "DELETE FROM ranks WHERE phase = :phase AND year = :year AND %s = :targetCode",
                    codeColumn);
            jdbcTemplate.update(deleteQuery, rankParams);

            insertColumns = "dist_code, regid, rank, iti_code, qual, temp_pk, phase, year, trno, app_status";
            selectValues = ":distCode, regid, generated_rank::text, :itiCode, :qual, :targetCode, :phase, :year, :trno, app_status";
            
        } else {
            throw new IllegalArgumentException("Invalid status value provided: " + status);
        }

        // The ssc_*_gpa columns are varchar and hold '', 'NaN' and zero-padded values (e.g. '05').
        // A bare ::real aborts the whole ranking on '' (reproduced on live data) and lets 'NaN'
        // silently poison the ordering. Strip every non-numeric character first, then let
        // unparseable values fall through to NULLS LAST.
        String safeGpa = "nullif(regexp_replace(%s, '[^0-9.]', '', 'g'), '')::real";

        // Build Optimized SQL Query with safe parameters and dynamic schema interpolation
        String yearFilter = "checklist".equals(status) ? "" : " AND year = :year";
        String sql = String.format(
            "WITH existing_check AS (\n" +
            "    SELECT EXISTS (SELECT 1 FROM %s WHERE phase = :phase AND %s = :targetCode%s) as already_exists\n" +
            "),\n" +
            "rank_generation AS (\n" +
            "    SELECT \n" +
            "        regid, \n" +
            "        app_status, \n" +
            "        ROW_NUMBER() OVER (\n" +
            "            ORDER BY \n" +
            "                ssc_passed DESC, \n" +
            String.format(safeGpa, "ssc_tot_gpa") + " DESC NULLS LAST, \n" +
            String.format(safeGpa, "ssc_math_gpa") + " DESC NULLS LAST, \n" +
            String.format(safeGpa, "ssc_sci_gpa") + " DESC NULLS LAST, \n" +
            String.format(safeGpa, "ssc_social_gpa") + " DESC NULLS LAST, \n" +
            String.format(safeGpa, "ssc_eng_gpa") + " DESC NULLS LAST, \n" +
            String.format(safeGpa, "ssc_first_lang_gpa") + " DESC NULLS LAST, \n" +
            String.format(safeGpa, "ssc_second_lang_gpa") + " DESC NULLS LAST, \n" +
            "                dob ASC, \n" +
            "                name ASC\n" +
            "        ) as generated_rank\n" +
            "    FROM (\n" +
            "        SELECT a.name, a.regid, a.dob, a.ssc_passed, a.app_status, b.ssc_tot_gpa, b.ssc_math_gpa, b.ssc_sci_gpa, b.ssc_social_gpa, b.ssc_eng_gpa, b.ssc_first_lang_gpa, b.ssc_second_lang_gpa\n" +
            "        FROM application a\n" +
            // cand_marks is the promoted marks table (one row per regid), matching the legacy
            // merit source. student_cand_marks is the per-phase staging table that is only
            // promoted to cand_marks at verification, so ranking off it would miss/duplicate.
            // Legacy Rank_Generation_Process.jsp inner-joins application to cand_marks (a, b).
            "        JOIN (SELECT DISTINCT * FROM cand_marks) b ON a.regid::character varying = b.regid\n" +
            "        WHERE hstore(a.phase)->:phase = 'true'\n" +
            "        AND a.year = :year\n" +
            "        AND a.app_status = 'A'\n" +
            "        AND EXISTS (\n" +
            "            SELECT 1 FROM trade_sel t \n" +
            "            WHERE t.regid = a.regid::character varying \n" +
            "            AND t.%s = :targetCode \n" +
            "            AND t.year = :year \n" +
            "            AND hstore(t.phase)->:phase = 'true'\n" +
            "        )\n" +
            "    ) sub\n" +
            "),\n" +
            "inserted AS (\n" +
            "    INSERT INTO %s (%s)\n" +
            "    SELECT %s\n" +
            "    FROM rank_generation\n" +
            "    WHERE (SELECT NOT already_exists FROM existing_check)\n" +
            "    RETURNING rank, regid\n" +
            "),\n" +
            "final_set AS (\n" +
            "    SELECT rank::text, regid FROM inserted\n" +
            "    UNION ALL\n" +
            "    SELECT rank::text, regid FROM %s \n" +
            "    WHERE phase = :phase AND %s = :targetCode\n" +
            "    %s\n" +
            "    AND (SELECT already_exists FROM existing_check)\n" +
            ")\n" +
            "SELECT \n" +
            "    r.rank::text as rank, r.regid::text as regid, \n" +
            "    COALESCE(b.name, '') as name, \n" +
            "    COALESCE(b.fname, '') as fname, \n" +
            "    COALESCE(b.mname, '') as mname, \n" +
            "    COALESCE(b.gender, '') as gender, \n" +
            "    COALESCE(b.caste, '') as caste, \n" +
            "    to_char(b.dob, 'DD-MM-YYYY') as dob, \n" +
            "    CASE WHEN b.ssc_passed = 't' THEN 'Pass' ELSE 'Fail' END as ssc_passed,\n" +
            "    CASE WHEN b.phc = 't' THEN 'Yes' ELSE 'No' END as phc,\n" +
            "    CASE WHEN b.exservice = 't' THEN 'Yes' ELSE 'No' END as exservice,\n" +
            "    COALESCE(cm.ssc_tot_gpa, '') as ssc_tot_gpa\n" +
            "FROM final_set r\n" +
            "JOIN application b ON r.regid::text = b.regid::text\n" +
            "LEFT JOIN (SELECT DISTINCT regid, ssc_tot_gpa FROM cand_marks) cm ON cm.regid = r.regid::text\n" +
            "ORDER BY r.rank::integer;",
            dbTablename, codeColumn, yearFilter, codeColumn, dbTablename, insertColumns, selectValues,
            dbTablename, codeColumn, yearFilter
        );

        String distCode = user.distCode();
        if ((distCode == null || distCode.isBlank()) && user.itiCode() != null) {
            try {
                distCode = jdbcTemplate.queryForObject(
                        "SELECT dist_code FROM public.iti WHERE iti_code = :itiCode LIMIT 1",
                        new MapSqlParameterSource("itiCode", user.itiCode()),
                        String.class);
            } catch (Exception ignored) {
            }
        }

        MapSqlParameterSource queryParams = new MapSqlParameterSource()
                .addValue("phase", phase)
                .addValue("qual", qualCode)
                .addValue("targetCode", targetCode)
                .addValue("itiCode", user.itiCode())
                .addValue("distCode", distCode)
                .addValue("year", year)
                .addValue("trno", trno);

        List<MeritListRow> results = jdbcTemplate.query(sql, queryParams, (rs, rowNum) -> new MeritListRow(
                rs.getString("rank"),
                rs.getString("regid"),
                rs.getString("name"),
                rs.getString("fname"),
                rs.getString("mname"),
                rs.getString("gender"),
                rs.getString("caste"),
                rs.getString("dob"),
                rs.getString("ssc_passed"),
                rs.getString("phc"),
                rs.getString("exservice"),
                rs.getString("ssc_tot_gpa")
        ));

        if(results.isEmpty())
        {
            throw new IllegalStateException("No records found for the given criteria.");
        }
        return Map.of(
            "heading", heading,
            "data", results
        );
    }
}
