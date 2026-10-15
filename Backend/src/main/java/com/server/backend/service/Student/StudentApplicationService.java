package com.server.backend.service.Student;

import com.server.backend.DTO.StudentApplicationDto;
import java.util.List;
import java.util.Map;
import com.server.backend.entity.CasteMasterPublic;
import com.server.backend.entity.SubCasteMasterPublic;
public interface StudentApplicationService {

    StudentApplicationDto saveStudent(StudentApplicationDto dto);

    /**
     * Gate check for the Apply page, ported from {@code applicationForm.Apply_iti} plus the
     * last-date guard in {@code web/open_editview_form.jsp}. Returns a map whose {@code status} is
     * one of {@code expired} (application window closed), {@code norecords} (no application matches
     * regid+dob+hall ticket), {@code admitted} (already has an admission) or {@code ok} (with the
     * matching {@code record}).
     */
    Map<String, Object> applyGate(Integer regid, String dob, String sscRegNo);

    /**
     * Single-transaction registration mirroring
     * open_Application_InterfaceAction_Student: writes student_application, student_cand_marks and
     * img_cand_photos atomically and returns the minted (or resumed) regid. When {@code dto.regid}
     * is set the existing application is updated (legacy "update" branch, app_status='A'),
     * otherwise a new application is inserted (legacy "insert ... returning regid").
     */
    StudentApplicationDto register(StudentApplicationDto dto, byte[] photo, String photoContentType);

    StudentApplicationDto updateStudent(Integer regid, StudentApplicationDto dto);

    StudentApplicationDto getStudentById(Integer regid);

    StudentApplicationDto getStudentByHallTicket(String sscRegNo);

    List<StudentApplicationDto> getAllStudents();

    void deleteStudent(Integer regid);
    List<CasteMasterPublic> getAllCastes();

    List<SubCasteMasterPublic> getSubCastesByCaste(String casteCode);
}
