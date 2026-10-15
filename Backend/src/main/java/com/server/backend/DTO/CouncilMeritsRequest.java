package com.server.backend.DTO;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Payload posted by {@code /AdmissionPhase} on the "Start Admission" step, mirroring the legacy
 * {@code startAdmission_ConvvinerLevel.jsp} form ({@code caste_perform}, {@code qual_perform},
 * {@code adm_perform}) that posts to {@code itiAdmissionEntry.do}.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record CouncilMeritsRequest(
        @JsonAlias({"caste_perform", "caste"}) String castePerform,
        @JsonAlias({"qual_perform", "qual", "minqul"}) String qualPerform,
        @JsonAlias({"adm_perform", "cal_time", "time"}) String admPerform
) {
}
