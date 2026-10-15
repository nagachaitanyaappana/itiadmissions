package com.server.backend.service.Student;

import com.server.backend.DTO.StudentApplicationDto;
import com.server.backend.entity.StudentApplication;
import com.server.backend.Repository.Student.StudentApplicationRepository;
import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;
import java.beans.PropertyDescriptor;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.BeanWrapperImpl;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;
import com.server.backend.entity.CasteMasterPublic;
import com.server.backend.entity.SubCasteMasterPublic;
import com.server.backend.Repository.MeritChecklist.CasteMasterRepository;
import com.server.backend.Repository.Student.SubCasteMasterPublicRepository;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import jakarta.servlet.http.HttpServletRequest;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.Map;

@Service
public class StudentApplicationServiceImpl implements StudentApplicationService {

    private final StudentApplicationRepository repository;
    private final CasteMasterRepository casteMasterRepository;
    private final SubCasteMasterPublicRepository subCasteMasterRepository;
    private final JdbcTemplate jdbcTemplate;

    public StudentApplicationServiceImpl(StudentApplicationRepository repository,
            CasteMasterRepository casteMasterRepository,
            SubCasteMasterPublicRepository subCasteMasterRepository,
            JdbcTemplate jdbcTemplate) {
        this.repository = repository;
        this.casteMasterRepository = casteMasterRepository;
        this.subCasteMasterRepository = subCasteMasterRepository;
        this.jdbcTemplate = jdbcTemplate;
    }

    /**
     * The phase a candidate applies under is the phase currently in force (the single
     * admissions.admission_phase row with current='true'), exactly as the legacy
     * open_Application_InterfaceAction_Student resolved it. It is stored as a scalar code here
     * because DistrictVerifyService.approve wraps it into an hstore when promoting to
     * application.phase. Hard-coding "REGISTRATION" left application.phase keyed on
     * "REGISTRATION" instead of the phase number, so the merit query
     * (hstore(a.phase)->'1' = 'true') never matched a UI-submitted candidate.
     */
    private String resolveCurrentPhase() {
        List<String> phases = jdbcTemplate.queryForList(
                "SELECT phase::text FROM admissions.admission_phase WHERE current = 'true'", String.class);
        return phases.isEmpty() ? null : phases.get(0);
    }

    @Override
    public StudentApplicationDto saveStudent(StudentApplicationDto dto) {

        // Step 1 is validation-only, matching open_Application_Step1Action: the application row is
        // NOT created here. If the hall ticket already has an application and the entered
        // board/year/type match, the existing regid is returned so the page resumes it; if they
        // do not match the duplicate is blocked. A new hall ticket simply returns the entered
        // step-1 values with a null regid so the final submit (register) can insert the row.
        String sscRegNo = dto.getSscRegNo() == null ? null : dto.getSscRegNo().trim();
        if (sscRegNo != null && !sscRegNo.isEmpty()) {
            List<Map<String, Object>> existing = jdbcTemplate.queryForList(
                    "SELECT regid, ssc_board, ssc_year, ssc_type FROM student_application "
                            + "WHERE upper(trim(ssc_regno)) = upper(?)",
                    sscRegNo);
            if (!existing.isEmpty()) {
                Map<String, Object> row = existing.get(0);
                boolean matches = equalsNormalized(dto.getSscBoard(), row.get("ssc_board"))
                        && equalsNormalized(dto.getSscYear(), row.get("ssc_year"))
                        && equalsNormalized(dto.getSscType(), row.get("ssc_type"));
                if (!matches) {
                    throw new IllegalArgumentException(
                            "Details do not match the existing application for this SSC Registration Number.");
                }
                StudentApplicationDto resumed = new StudentApplicationDto();
                resumed.setRegid(toIntegerId(str(row.get("regid"))));
                resumed.setSscRegNo(sscRegNo);
                resumed.setResumed(true);
                return resumed;
            }
        }

        StudentApplicationDto pending = new StudentApplicationDto();
        pending.setSscRegNo(sscRegNo);
        pending.setSscBoard(dto.getSscBoard());
        pending.setSscYear(dto.getSscYear());
        pending.setSscType(dto.getSscType());
        pending.setResumed(false);
        return pending;
    }

    /**
     * Gate check for the Apply page. Ports {@code applicationForm.Apply_iti} (which matched on
     * regid + dob + hall ticket and blocked already-admitted candidates) together with the
     * last-date guard in {@code web/open_editview_form.jsp} ({@code beans.MyUtil.LastDate()}).
     */
    @Override
    @Transactional(readOnly = true)
    public Map<String, Object> applyGate(Integer regid, String dob, String sscRegNo) {
        Map<String, Object> result = new LinkedHashMap<>();

        // Window guard: legacy reads application_to_date from admissions.admission_phase and treats
        // the window as open until one day after it (Calendar.DAY_OF_MONTH += 1).
        Timestamp toDate = jdbcTemplate.query(
                "SELECT application_to_date FROM admissions.admission_phase LIMIT 1",
                rs -> rs.next() ? rs.getTimestamp("application_to_date") : null);
        if (toDate != null
                && LocalDateTime.now().isAfter(toDate.toLocalDateTime().plusDays(1))) {
            result.put("status", "expired");
            return result;
        }

        if (regid == null || sscRegNo == null || sscRegNo.trim().isEmpty()) {
            result.put("status", "norecords");
            return result;
        }
        java.sql.Date dobDate = parseDob(dob);
        if (dobDate == null) {
            result.put("status", "norecords");
            return result;
        }

        Integer matched = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM student_application WHERE regid = ? AND dob = ? AND ssc_regno = ?",
                Integer.class, String.valueOf(regid), dobDate, sscRegNo.trim());
        if (matched == null || matched == 0) {
            result.put("status", "norecords");
            return result;
        }

        Integer admitted = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM admissions.iti_admissions WHERE regid = ?",
                Integer.class, String.valueOf(regid));
        if (admitted != null && admitted > 0) {
            result.put("status", "admitted");
            return result;
        }

        result.put("status", "ok");
        result.put("record", getStudentById(regid));
        return result;
    }

    /** Accepts the {@code <input type="date">} value (yyyy-MM-dd) or the legacy dd-MM-yyyy. */
    private static java.sql.Date parseDob(String dob) {
        if (dob == null || dob.trim().isEmpty()) {
            return null;
        }
        String value = dob.trim();
        try {
            if (value.length() >= 10 && value.charAt(2) == '-') {
                String[] parts = value.substring(0, 10).split("-");
                return java.sql.Date.valueOf(parts[2] + "-" + parts[1] + "-" + parts[0]);
            }
            return java.sql.Date.valueOf(value.substring(0, 10));
        } catch (RuntimeException ex) {
            return null;
        }
    }

    /** Null-safe, trim- and case-insensitive comparison of a submitted vs. stored value. */
    private static boolean equalsNormalized(Object a, Object b) {        String sa = a == null ? null : a.toString().trim();
        String sb = b == null ? null : b.toString().trim();
        if (sa == null || sb == null) {
            return sa == null && sb == null;
        }
        return sa.equalsIgnoreCase(sb);
    }

    private static String str(Object o) {
        return o == null ? null : o.toString();
    }

    /** regid is stored as character varying; the JSON API exposes it as a number. */
    private static Integer toIntegerId(String regid) {
        if (regid == null || regid.isBlank()) {
            return null;
        }
        try {
            return Integer.valueOf(regid.trim());
        } catch (NumberFormatException ex) {
            return null;
        }
    }

    private static StudentApplicationDto toDto(StudentApplication entity) {
        StudentApplicationDto dto = new StudentApplicationDto();
        BeanUtils.copyProperties(entity, dto);
        dto.setRegid(toIntegerId(entity.getRegid()));
        return dto;
    }

    /**
     * Single-transaction registration mirroring open_Application_InterfaceAction_Student:
     * student_application + student_cand_marks + img_cand_photos are written atomically (the
     * legacy action set autoCommit(false) and committed once at the end). A non-null
     * {@code dto.regid} selects the legacy "update" branch (UPDATE student_application ...,
     * app_status='A'); otherwise a new application is inserted.
     */
    @Override
    @Transactional(rollbackFor = Exception.class)
    public StudentApplicationDto register(StudentApplicationDto dto, byte[] photo, String photoContentType) {
        boolean isUpdate = dto.getRegid() != null;

        // Reference to the submitting client, equivalent to the legacy logTrace + request.getRemoteAddr().
        String ip = null;
        String referer = null;
        String sessionId = "";
        String userId = "";
        ServletRequestAttributes attrs = (ServletRequestAttributes) RequestContextHolder.getRequestAttributes();
        if (attrs != null) {
            HttpServletRequest req = attrs.getRequest();
            ip = req.getRemoteAddr();
            referer = req.getHeader("referer");
            sessionId = req.getSession().getId();
            Object uname = req.getSession().getAttribute("userName");
            userId = uname == null ? "" : String.valueOf(uname);
        }

        // Duplicate checks (legacy open_Application_InterfaceAction_Student lines 48-67). The
        // second set (lines 153-159) is redundant; a single check per column is sufficient.
        assertUnique("phno", dto.getPhno(), dto.getRegid(),
                "Given Phone is already available for another candidate.");
        assertUnique("email", filterBad(dto.getEmail()), dto.getRegid(),
                "Given Email is already available for another candidate.");
        assertUnique("adarno", filterBad(dto.getAdarno()), dto.getRegid(),
                "Given Aadhaar Number is already available for another candidate.");

        // trno audit row (legacy generic.logTrace -> public.logtr); returns the trace number.
        Integer trno = jdbcTemplate.queryForObject(
                "INSERT INTO public.logtr (ip, userid, referal, tablename, transaction_type, sessionid, ts) "
                        + "VALUES (?, ?, ?, 'application & cand_marks', ?, ?, ?) RETURNING trno",
                Integer.class,
                ip == null ? "" : ip, userId, referer == null ? "" : referer,
                isUpdate ? "Update" : "Insert", sessionId, new Timestamp(System.currentTimeMillis()).toString());

        String year = firstOrNull(jdbcTemplate.queryForList(
                "SELECT value FROM public.iti_params WHERE code = CAST(? AS integer)", String.class, "7"));
        String phase = null;
        if (year != null) {
            phase = firstOrNull(jdbcTemplate.queryForList(
                    "SELECT phase::text FROM admissions.admission_phase WHERE year = ? AND current = 'true'",
                    String.class, year));
        }
        if (phase == null) {
            phase = resolveCurrentPhase();
        }

        StudentApplication entity = isUpdate
                ? repository.findById(String.valueOf(dto.getRegid()))
                        .orElseThrow(() -> new RuntimeException("Student Not Found"))
                : new StudentApplication();

        entity.setName(filterBad(dto.getName()));
        entity.setFname(filterBad(dto.getFname()));
        entity.setAddr(filterBad(dto.getAddr()));
        entity.setMname(filterBad(dto.getMname()));
        entity.setPincode(dto.getPincode() == null ? 0 : dto.getPincode());
        entity.setPhno(dto.getPhno() == null ? 0L : dto.getPhno());
        entity.setAdarno(filterBad(dto.getAdarno()));
        entity.setDob(dto.getDob());
        entity.setGender(filterBad(dto.getGender()));
        entity.setCaste(filterBad(dto.getCaste()));
        entity.setPhc(Boolean.TRUE.equals(dto.getPhc()));
        entity.setExservice(Boolean.TRUE.equals(dto.getExservice()));
        entity.setSscPassed(Boolean.TRUE.equals(dto.getSscPassed()));
        entity.setInterPassed(Boolean.TRUE.equals(dto.getInterPassed()));
        entity.setInterMarks(Boolean.TRUE.equals(dto.getInterPassed())
                ? (dto.getInterMarks() == null ? 0 : dto.getInterMarks()) : 0);
        entity.setLocal(filterBad(dto.getLocal()));
        entity.setTrno(trno == null ? null : trno.longValue());
        entity.setSscRegNo(filterBad(dto.getSscRegNo()));
        entity.setSscBoard(filterBad(dto.getSscBoard()));
        entity.setSscYear(filterBad(dto.getSscYear()));
        entity.setSscMonth(filterBad(dto.getSscMonth()));

        if (isUpdate) {
            // Legacy update branch sets only these columns plus app_status='A'.
            entity.setAppStatus("A");
        } else {
            entity.setSscType(filterBad(dto.getSscType()));
            entity.setEmail(filterBad(dto.getEmail()));
            entity.setPwdCategory(filterBad(dto.getPwdCategory()));
            entity.setEconomicWeakerSection(Boolean.TRUE.equals(dto.getEconomicWeakerSection()));
            entity.setSubCaste(filterBad(dto.getSubCaste()));
            entity.setYear(year);
            entity.setPhase(phase);
            entity.setEntryDate(LocalDateTime.now());
            entity.setIp(ip);
            entity.setAppStatus("N");
            entity.setDataFlag("A");
        }

        StudentApplication saved = repository.save(entity);
        Integer regid = toIntegerId(saved.getRegid());

        writeCandMarks(regid, dto, trno, isUpdate);
        writePhoto(regid, photo, photoContentType);

        StudentApplicationDto result = toDto(saved);
        result.setResumed(isUpdate);
        return result;
    }

    /** student_cand_marks insert/update, matching open_Application_InterfaceAction_Student lines 319-434. */
    private void writeCandMarks(Integer regid, StudentApplicationDto dto, Integer trno, boolean isUpdate) {
        com.server.backend.DTO.StudentCandMarksDto m = dto.getMarks();
        boolean sscg = "sscg".equalsIgnoreCase(filterBad(dto.getSscType()));
        boolean firstLangBlank = m == null || m.getSscFirstLangMarks() == null;

        Integer first = intOr0(m, MField.FIRST);
        Integer second = intOr0(m, MField.SECOND);
        Integer eng = intOr0(m, MField.ENG);
        Integer math = intOr0(m, MField.MATH);
        Integer sci = intOr0(m, MField.SCI);
        Integer social = intOr0(m, MField.SOCIAL);
        Integer tot = m == null ? 0 : (m.getSscTotMarks() == null ? 0 : m.getSscTotMarks());
        if (sscg || firstLangBlank) {
            first = 0; second = 0; eng = 0; math = 0; sci = 0; social = 0; tot = 0;
        }

        String firstGpa = m == null ? null : m.getSscFirstLangGpa();
        String secondGpa = m == null ? null : m.getSscSecondLangGpa();
        String engGpa = m == null ? null : m.getSscEngGpa();
        String mathGpa = m == null ? null : m.getSscMathGpa();
        String sciGpa = m == null ? null : m.getSscSciGpa();
        String socialGpa = m == null ? null : m.getSscSocialGpa();
        String totGpa = m == null ? null : m.getSscTotGpa();
        String firstGrade = m == null ? null : m.getSscFirstLangGrade();
        String secondGrade = m == null ? null : m.getSscSecondLangGrade();
        String engGrade = m == null ? null : m.getSscEngGrade();
        String mathGrade = m == null ? null : m.getSscMathGrade();
        String sciGrade = m == null ? null : m.getSscSciGrade();
        String socialGrade = m == null ? null : m.getSscSocialGrade();
        String groupName = m == null ? null : m.getGroupName();
        String interFirstSub = m == null ? null : m.getInterFirstSub();
        Integer interFirstMarks = m == null ? null : m.getInterFirstMarks();
        String interSecondSub = m == null ? null : m.getInterSecondSub();
        Integer interSecondMarks = m == null ? null : m.getInterSecondMarks();
        String interThirdSub = m == null ? null : m.getInterThirdSub();
        Integer interThirdMarks = m == null ? null : m.getInterThirdMarks();

        if (isUpdate) {
            jdbcTemplate.update(
                    "UPDATE public.student_cand_marks SET ssc_first_lang_marks=?, ssc_first_lang_gpa=?, "
                            + "ssc_first_lang_grade=?, ssc_second_lang_marks=?, ssc_second_lang_gpa=?, "
                            + "ssc_second_lang_grade=?, ssc_eng_marks=?, ssc_eng_gpa=?, ssc_eng_grade=?, "
                            + "ssc_math_marks=?, ssc_math_gpa=?, ssc_math_grade=?, ssc_sci_marks=?, "
                            + "ssc_sci_gpa=?, ssc_sci_grade=?, ssc_social_marks=?, ssc_social_gpa=?, "
                            + "ssc_social_grade=?, inter_first_sub=?, inter_first_marks=?, inter_second_sub=?, "
                            + "inter_second_marks=?, inter_third_sub=?, inter_third_marks=?, ssc_tot_marks=?, "
                            + "ssc_tot_gpa=?, groupname=?, trno=? WHERE regid=?",
                    first, firstGpa, firstGrade, second, secondGpa, secondGrade, eng, engGpa, engGrade,
                    math, mathGpa, mathGrade, sci, sciGpa, sciGrade, social, socialGpa, socialGrade,
                    interFirstSub, interFirstMarks, interSecondSub, interSecondMarks, interThirdSub,
                    interThirdMarks, tot, totGpa, groupName, trno, String.valueOf(regid));
        } else {
            jdbcTemplate.update(
                    "INSERT INTO public.student_cand_marks (regid, ssc_first_lang_marks, ssc_first_lang_gpa, "
                            + "ssc_first_lang_grade, ssc_second_lang_marks, ssc_second_lang_gpa, "
                            + "ssc_second_lang_grade, ssc_eng_marks, ssc_eng_gpa, ssc_eng_grade, "
                            + "ssc_math_marks, ssc_math_gpa, ssc_math_grade, ssc_sci_marks, ssc_sci_gpa, "
                            + "ssc_sci_grade, ssc_social_marks, ssc_social_gpa, ssc_social_grade, "
                            + "inter_first_sub, inter_first_marks, inter_second_sub, inter_second_marks, "
                            + "inter_third_sub, inter_third_marks, ssc_tot_marks, ssc_tot_gpa, groupname, "
                            + "trno, entry_date) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                    String.valueOf(regid), first, firstGpa, firstGrade, second, secondGpa, secondGrade,
                    eng, engGpa, engGrade, math, mathGpa, mathGrade, sci, sciGpa, sciGrade, social,
                    socialGpa, socialGrade, interFirstSub, interFirstMarks, interSecondSub,
                    interSecondMarks, interThirdSub, interThirdMarks, tot, totGpa, groupName, trno,
                    Timestamp.valueOf(LocalDateTime.now()));
        }
    }

    private enum MField { FIRST, SECOND, ENG, MATH, SCI, SOCIAL }

    private static Integer intOr0(com.server.backend.DTO.StudentCandMarksDto m, MField field) {
        if (m == null) {
            return 0;
        }
        Integer value = switch (field) {
            case FIRST -> m.getSscFirstLangMarks();
            case SECOND -> m.getSscSecondLangMarks();
            case ENG -> m.getSscEngMarks();
            case MATH -> m.getSscMathMarks();
            case SCI -> m.getSscSciMarks();
            case SOCIAL -> m.getSscSocialMarks();
        };
        return value == null ? 0 : value;
    }

    /** img_cand_photos insert/replace, matching open_Application_InterfaceAction_Student lines 328-353. */
    private void writePhoto(Integer regid, byte[] photo, String contentType) {
        if (regid == null || photo == null || photo.length == 0) {
            return;
        }
        boolean isPng = "image/png".equalsIgnoreCase(contentType);
        boolean isJpeg = "image/jpeg".equalsIgnoreCase(contentType);
        if (!isPng && !isJpeg) {
            throw new IllegalArgumentException("Photograph must be a PNG or JPEG image");
        }
        Integer existing = jdbcTemplate.queryForObject(
                "SELECT count(*) FROM public.img_cand_photos WHERE regid = ?", Integer.class, regid);
        if (existing != null && existing > 0) {
            jdbcTemplate.update("UPDATE public.img_cand_photos SET pic = ? WHERE regid = ?", photo, regid);
        } else {
            jdbcTemplate.update("INSERT INTO public.img_cand_photos (regid, pic) VALUES (?, ?)", regid, photo);
        }
    }

    private static String firstOrNull(List<String> values) {
        return (values == null || values.isEmpty()) ? null : values.get(0);
    }

    /** Port of beans.MyUtil.filterBad (strips SQL keywords and quote/operator characters). */
    private static String filterBad(String str) {
        if (str == null) {
            return "";
        }
        String s = str;
        for (String token : new String[] { "delete ", "select ", "update ", "drop ", "alter ", "insert ",
                "truncate ", "revoke ", "union ", "create ", "grant ", "script", "'", "\"", ">", "<",
                "&", "%", "limit", ";", "*", "=", "(", ")" }) {
            s = s.replace(token, "");
        }
        return s;
    }


    /**
     * Fields owned by the server. A student-submitted update must never be able to set these:
     * appStatus / phase / verified* drive verification and phase-wise reporting, so accepting
     * them from the client would let a candidate self-verify.
     */
    private static final Set<String> SERVER_OWNED_FIELDS = Set.of(
            "appStatus", "phase", "dataFlag",
            "verifiedDate", "verifiedIp", "userId",
            "trno", "entryDate");

    @Override
public StudentApplicationDto updateStudent(Integer regid, StudentApplicationDto dto) {

    StudentApplication entity = repository.findById(String.valueOf(regid))
            .orElseThrow(() -> new RuntimeException("Student Not Found"));

    BeanWrapper src = new BeanWrapperImpl(dto);
    BeanWrapper trg = new BeanWrapperImpl(entity);

    for (PropertyDescriptor pd : src.getPropertyDescriptors()) {

        String propertyName = pd.getName();

        if ("class".equals(propertyName) || "regid".equals(propertyName)
                || "resumed".equals(propertyName)) {
            continue;
        }

            // Server-owned fields are never accepted from the client: letting an applicant
            // write appStatus/phase/verified* would let a candidate self-verify.
            if (SERVER_OWNED_FIELDS.contains(propertyName)) {
                continue;
            }


        Object value = src.getPropertyValue(propertyName);

        if (value != null) {
            trg.setPropertyValue(propertyName, value);
        }
    }

    // Stamp the phase the candidate is applying under, server-side (never the client's).
    String currentPhase = resolveCurrentPhase();
    if (currentPhase != null) {
        entity.setPhase(currentPhase);
    }

    // Phone / e-mail / Aadhaar must be unique across candidates (legacy
    // open_Application_InterfaceAction_Student). Exclude the candidate's own regid so an edit
    // that leaves these values unchanged is still allowed.
    assertUnique("phno", entity.getPhno(), regid,
            "Given Phone is already available for another candidate.");
    assertUnique("email", entity.getEmail(), regid,
            "Given Email is already available for another candidate.");
    assertUnique("adarno", entity.getAdarno(), regid,
            "Given Aadhaar Number is already available for another candidate.");

    StudentApplication updated = repository.save(entity);

    return toDto(updated);
}

    /**
     * Blocks a save when value already belongs to a different candidate. column is always a
     * fixed literal supplied by this class (never client input). Blank strings are treated as
     * absent so an empty e-mail/Aadhaar is not flagged as a duplicate.
     */
    private void assertUnique(String column, Object value, Integer selfRegid, String message) {
        if (value == null) {
            return;
        }
        if (value instanceof CharSequence cs && cs.toString().trim().isEmpty()) {
            return;
        }
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM student_application WHERE " + column + " = ? AND regid::text <> ?",
                Integer.class, value, String.valueOf(selfRegid));
        if (count != null && count > 0) {
            throw new IllegalArgumentException(message);
        }
    }

    @Override
    public StudentApplicationDto getStudentById(Integer regid) {

        StudentApplication entity = repository.findById(String.valueOf(regid))
                .orElseThrow(() -> new RuntimeException("Student Not Found"));

        return toDto(entity);
    }

    @Override
    public StudentApplicationDto getStudentByHallTicket(String sscRegNo) {

        StudentApplication entity = repository.findBySscRegNo(sscRegNo)
                .orElseThrow(() -> new RuntimeException("Student Not Found"));

        return toDto(entity);
    }

    @Override
    public List<StudentApplicationDto> getAllStudents() {

        return repository.findAll().stream()
                .map(StudentApplicationServiceImpl::toDto)
                .collect(Collectors.toList());
    }

    @Override
    public void deleteStudent(Integer regid) {

        repository.deleteById(String.valueOf(regid));

    }
    @Override
public List<CasteMasterPublic> getAllCastes() {

    // Caste master lives in public.caste_master (CasteMasterPublic), the same table
    // the /api/dsc/caste-list endpoint reads. De-duplicated by code, matching
    // CasteMasterService.getAllCasteMasters().
    LinkedHashMap<String, CasteMasterPublic> byCode = new LinkedHashMap<>();

    for (CasteMasterPublic caste : casteMasterRepository.findAll()) {
        byCode.putIfAbsent(caste.getCasteCode(), caste);
    }

    return new ArrayList<>(byCode.values());
}

    @Override
    public List<SubCasteMasterPublic> getSubCastesByCaste(String casteCode) {
        return subCasteMasterRepository.findByCasteCodeOrderBySubCasteIdAsc(casteCode);
    }
}