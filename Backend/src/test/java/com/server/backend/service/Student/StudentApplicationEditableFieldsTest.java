package com.server.backend.service.Student;

import com.server.backend.DTO.StudentApplicationDto;
import com.server.backend.entity.StudentApplication;
import org.junit.jupiter.api.Test;
import org.springframework.beans.BeanWrapper;
import org.springframework.beans.BeanWrapperImpl;

import static org.junit.jupiter.api.Assertions.*;

class StudentApplicationEditableFieldsTest {

    @Test
    void copiesOnlyFieldsExposedByCandidateEditForm() {
        StudentApplicationDto dto = new StudentApplicationDto();
        dto.setName("UPDATED NAME");
        dto.setSscMonth("04");
        dto.setSscPassed(Boolean.TRUE);
        dto.setSscRegNo("ATTACKER-HALL-TICKET");
        dto.setSscBoard("ATTACKER-BOARD");
        dto.setSscYear("2099");
        dto.setSscType("sscm");
        dto.setInterPassed(Boolean.TRUE);
        dto.setInterMarks(999);
        dto.setAppStatus("VERIFIED");
        dto.setPhase("999");
        dto.setDataFlag("A");
        dto.setVerifiedIp("127.0.0.1");
        dto.setUserId("attacker");
        dto.setUid("attacker-uid");
        dto.setIsTraineeDualMode(Boolean.TRUE);

        StudentApplication entity = new StudentApplication();
        entity.setName("ORIGINAL NAME");
        entity.setSscMonth("03");
        entity.setSscPassed(Boolean.FALSE);
        entity.setSscRegNo("ORIGINAL-HALL-TICKET");
        entity.setSscBoard("ORIGINAL-BOARD");
        entity.setSscYear("2025");
        entity.setSscType("gpa");
        entity.setInterPassed(Boolean.FALSE);
        entity.setInterMarks(450);
        entity.setAppStatus("PENDING");
        entity.setPhase("1");
        entity.setDataFlag("P");
        entity.setVerifiedIp("10.0.0.1");
        entity.setUserId("official");
        entity.setUid("original-uid");
        entity.setIsTraineeDualMode(Boolean.FALSE);

        BeanWrapper source = new BeanWrapperImpl(dto);
        BeanWrapper target = new BeanWrapperImpl(entity);
        StudentApplicationServiceImpl.copyEditableCandidateFields(source, target);

        assertEquals("UPDATED NAME", entity.getName());
        assertEquals("04", entity.getSscMonth());
        assertEquals(Boolean.TRUE, entity.getSscPassed());

        assertEquals("ORIGINAL-HALL-TICKET", entity.getSscRegNo());
        assertEquals("ORIGINAL-BOARD", entity.getSscBoard());
        assertEquals("2025", entity.getSscYear());
        assertEquals("gpa", entity.getSscType());
        assertEquals(Boolean.FALSE, entity.getInterPassed());
        assertEquals(450, entity.getInterMarks());
        assertEquals("PENDING", entity.getAppStatus());
        assertEquals("1", entity.getPhase());
        assertEquals("P", entity.getDataFlag());
        assertEquals("10.0.0.1", entity.getVerifiedIp());
        assertEquals("official", entity.getUserId());
        assertEquals("original-uid", entity.getUid());
        assertEquals(Boolean.FALSE, entity.getIsTraineeDualMode());
    }
}
