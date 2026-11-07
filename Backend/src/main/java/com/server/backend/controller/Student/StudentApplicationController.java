package com.server.backend.controller.Student;

import com.server.backend.DTO.StudentApplicationDto;
import com.server.backend.DTO.StudentCandMarksDto;
import io.swagger.v3.oas.annotations.tags.Tag;
import com.server.backend.service.Student.StudentApplicationService;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import com.server.backend.entity.CasteMasterPublic;
import com.server.backend.entity.SubCasteMasterPublic;
@Tag(name = "Student")
@RestController
@RequestMapping("/api/student")
public class StudentApplicationController {

    private final StudentApplicationService service;

    public StudentApplicationController(StudentApplicationService service) {
        this.service = service;
    }

    // Save Student
    @PostMapping("/save")
    public ResponseEntity<StudentApplicationDto> saveStudent(
            @RequestBody StudentApplicationDto dto) {

        // Public registration may create a new record only. Existing records
        // must use the verified candidate session or an authenticated official.
        if (dto.getRegid() != null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        StudentApplicationDto saved = service.saveStudent(dto);

        // 200 when the hall ticket already had an application and the details matched (the
        // page resumes the existing regid); 201 only when a new application was created.
        if (Boolean.TRUE.equals(saved.getResumed())) {
            return ResponseEntity.ok(saved);
        }
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
    }

    // Single-transaction registration (application + marks + photo), mirroring
    // open_Application_InterfaceAction_Student. Sent as multipart: "application" (JSON),
    // optional "marks" (JSON) and optional "photo" (file).
    @PostMapping(value = "/register", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<StudentApplicationDto> register(
            @RequestPart("application") StudentApplicationDto dto,
            @RequestPart(value = "marks", required = false) StudentCandMarksDto marks,
            @RequestPart(value = "photo", required = false) MultipartFile photo) throws Exception {

        // The public registration route creates new candidates only. Editing
        // an existing registration is handled by the candidate-session-protected
        // PUT /api/student/update/{regid} endpoint.
        if (dto.getRegid() != null) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        dto.setMarks(marks);
        byte[] bytes = (photo != null && !photo.isEmpty()) ? photo.getBytes() : null;
        String contentType = photo == null ? null : photo.getContentType();

        return ResponseEntity.ok(service.register(dto, bytes, contentType));
    }
    // Gate check for the Apply page: verifies regid+dob+hall ticket, the application window, and
    // whether the candidate is already admitted (legacy applicationForm.Apply_iti + LastDate()).
    @GetMapping("/apply-gate")
    public ResponseEntity<java.util.Map<String, Object>> applyGate(
            @RequestParam Integer regid,
            @RequestParam(required = false) String dob,
            @RequestParam(name = "ssc_regno", required = false) String sscRegNo) {

        return ResponseEntity.ok(service.applyGate(regid, dob, sscRegNo));
    }

    /**
     * Verify a candidate's identity before returning any personal application
     * data. The Frontend gateway binds the successful regid to the HTTP session,
     * after which only that candidate's record/photo/marks can be read or edited.
     */
    @GetMapping("/verify-identity")
    public ResponseEntity<StudentApplicationDto> verifyIdentity(
            @RequestParam Integer regid,
            @RequestParam String dob,
            @RequestParam(name = "ssc_regno") String sscRegNo) {
        if (regid == null || regid <= 0 || dob == null || dob.isBlank()
                || sscRegNo == null || sscRegNo.isBlank()) {
            return ResponseEntity.notFound().build();
        }
        try {
            StudentApplicationDto student = service.getStudentById(regid);
            String storedDob = student.getDob() == null ? "" : String.valueOf(student.getDob());
            if (storedDob.length() > 10) storedDob = storedDob.substring(0, 10);
            if (!storedDob.equals(dob.trim())
                    || student.getSscRegNo() == null
                    || !student.getSscRegNo().trim().equalsIgnoreCase(sscRegNo.trim())) {
                return ResponseEntity.notFound().build();
            }
            return ResponseEntity.ok(student);
        } catch (RuntimeException ex) {
            return ResponseEntity.notFound().build();
        }
    }

    // Get Student By RegId
    @GetMapping("/{regid}")
    public ResponseEntity<StudentApplicationDto> getStudentById(
            @PathVariable Integer regid) {

        return ResponseEntity.ok(service.getStudentById(regid));
    }

    // Get Student By Hall Ticket
    @GetMapping("/hallticket/{sscRegNo}")
    public ResponseEntity<StudentApplicationDto> getStudentByHallTicket(
            @PathVariable String sscRegNo) {

        return ResponseEntity.ok(service.getStudentByHallTicket(sscRegNo));
    }

    // Get All Students
    @GetMapping("/all")
    public ResponseEntity<List<StudentApplicationDto>> getAllStudents() {

        return ResponseEntity.ok(service.getAllStudents());
    }

    // Update Student
    @PutMapping("/update/{regid}")
    public ResponseEntity<StudentApplicationDto> updateStudent(
            @PathVariable Integer regid,
            @RequestBody StudentApplicationDto dto) {

        return ResponseEntity.ok(service.updateStudent(regid, dto));
    }

    // Delete Student
    @DeleteMapping("/delete/{regid}")
    public ResponseEntity<String> deleteStudent(
            @PathVariable Integer regid) {

        service.deleteStudent(regid);
        return ResponseEntity.ok("Student Deleted Successfully");
    }
    // Get All Castes
@GetMapping("/castes")
public ResponseEntity<List<CasteMasterPublic>> getAllCastes() {

    return ResponseEntity.ok(service.getAllCastes());

}

    // Get Sub-Castes for a caste code (reference derived from real applications; names are
    // filled in as the true master becomes available)
    @GetMapping("/subcastes/{casteCode}")
    public ResponseEntity<List<SubCasteMasterPublic>> getSubCastes(@PathVariable String casteCode) {
        return ResponseEntity.ok(service.getSubCastesByCaste(casteCode));
    }
}