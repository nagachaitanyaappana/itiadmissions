package com.server.backend.service.Student;

import com.server.backend.DTO.StudentApplicationDto;
import java.util.List;
import com.server.backend.entity.CasteMasterPublic;
import com.server.backend.entity.SubCasteMasterPublic;
public interface StudentApplicationService {

    StudentApplicationDto saveStudent(StudentApplicationDto dto);

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
