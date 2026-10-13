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
import java.util.ArrayList;
import java.util.LinkedHashMap;

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

        StudentApplication entity = new StudentApplication();

        // Copy request fields
        BeanUtils.copyProperties(dto, entity);

        // Default values
entity.setEntryDate(LocalDateTime.now());

entity.setAppStatus("N");     // 1 character only
entity.setDataFlag("A");      // 1 character only
entity.setPwdCategory("N");   // 1 character only

entity.setPhase(resolveCurrentPhase());
entity.setSscPassed(true);

        StudentApplication saved = repository.save(entity);

        return toDto(saved);
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

        if ("class".equals(propertyName) || "regid".equals(propertyName)) {
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

    StudentApplication updated = repository.save(entity);

    return toDto(updated);
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