package com.server.backend.DTO;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Payload posted by {@code /AdmissionPhase} when the operator submits a merit rank on the
 * "Admission Counseling" screen, mirroring the legacy {@code DistrictAdmissionEntry.jsp} form
 * that posts to {@code districtAdmissionProcessOptimise.do} with the entered rank plus the
 * hidden caste/qualification/call-time carried from the start step.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record ProcessOptimizeRequest(
        String rank,
        @JsonAlias({"caste_perform", "caste"}) String castePerform,
        @JsonAlias({"qual_perform", "qual", "minqul"}) String qualPerform,
        @JsonAlias({"adm_perform", "cal_time", "time"}) String admPerform
) {
}
