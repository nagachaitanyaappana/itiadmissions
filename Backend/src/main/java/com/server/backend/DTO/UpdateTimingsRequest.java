package com.server.backend.DTO;
import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.validation.constraints.NotNull;
@JsonIgnoreProperties(ignoreUnknown = true)
public record UpdateTimingsRequest(
    String minqul,
    String reservation,
    // meritFrom is derived server-side as max(merit_to)+1 (legacy admission.jsp/admissionAction) and
    // is accepted only as a fallback, so it is not required here.
    Integer meritFrom,
    @NotNull(message="meritTo is Required")
    Integer meritTo,
    @JsonAlias({"date", "calDate", "cal_date", "caldate"}) String calDate,
    @JsonAlias({"time", "calTime", "cal_time", "caltime"}) String calTime
) {}
