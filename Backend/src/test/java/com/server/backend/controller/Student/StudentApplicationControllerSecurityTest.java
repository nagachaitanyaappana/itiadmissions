package com.server.backend.controller.Student;

import com.server.backend.DTO.StudentApplicationDto;
import com.server.backend.service.Student.StudentApplicationService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verifyNoInteractions;

class StudentApplicationControllerSecurityTest {

    private final StudentApplicationService service = mock(StudentApplicationService.class);
    private StudentApplicationController controller;

    @BeforeEach
    void setUp() {
        controller = new StudentApplicationController(service);
    }

    @Test
    void publicSaveCannotTargetAnExistingRegistration() {
        StudentApplicationDto dto = new StudentApplicationDto();
        dto.setRegid(12345);

        var response = controller.saveStudent(dto);

        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verifyNoInteractions(service);
    }

    @Test
    void publicRegisterCannotTargetAnExistingRegistration() throws Exception {
        StudentApplicationDto dto = new StudentApplicationDto();
        dto.setRegid(12345);

        var response = controller.register(dto, null, null);

        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verifyNoInteractions(service);
    }

    @Test
    void candidateCannotUpdateARegistrationOtherThanTheVerifiedPathId() {
        StudentApplicationDto dto = new StudentApplicationDto();

        var response = controller.updateStudent(12345, dto, "54321");

        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        verifyNoInteractions(service);
    }

    @Test
    void candidateCannotChangeTheSscIdentityDuringAnEdit() {
        StudentApplicationDto dto = new StudentApplicationDto();
        dto.setSscRegNo("ATTACKER-HALL-TICKET");

        var response = controller.updateStudent(12345, dto, "12345");

        assertEquals(HttpStatus.BAD_REQUEST, response.getStatusCode());
        verifyNoInteractions(service);
    }
}
