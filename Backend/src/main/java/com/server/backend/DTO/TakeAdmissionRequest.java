package com.server.backend.DTO;

import com.fasterxml.jackson.annotation.JsonAlias;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/**
 * Payload posted by {@code /AdmissionPhase} when the operator confirms an admission
 * ({@code processAdmission()} in the page).
 *
 * <p>The page sends legacy snake_case keys, so each component carries a {@link JsonAlias}
 * for the name that actually arrives on the wire. {@code check} is the seat-matrix cascade
 * bucket code (1..8) that the legacy {@code DistrictAdmissionProcessOptimiseAction} computes
 * and the radio carries as {@code iti_name+iti_code+trade_code+check}; it decides
 * {@code res_category} in {@code DistrictAdmissionAction}. {@code selectedRadio} is the
 * {@code shift|unit|strength} choice from the shift/unit table.
 */
@JsonIgnoreProperties(ignoreUnknown = true)
public record TakeAdmissionRequest(
        String regid,
        @JsonAlias({"trade_code", "tradecode"}) String tradeCode,
        @JsonAlias({"iti_code", "iticode"}) String itiCode,
        String idmarks1,
        String idmarks2,
        @JsonAlias({"ssc_regno", "sscregno"}) String sscRegno,
        @JsonAlias({"ssc_board", "sscboard"}) String sscBoard,
        @JsonAlias({"ssc_year", "sscyear"}) String sscYear,
        @JsonAlias({"ssc_month", "sscmonth"}) String sscMonth,
        @JsonAlias({"type_admission", "typeadmission"}) String typeAdmission,
        @JsonAlias({"shift", "shift_allowed"}) String shift,
        @JsonAlias({"unit", "unit_allowed"}) String unit,
        @JsonAlias({"strength", "strength_allowed"}) String strength,
        @JsonAlias({"check", "bucket_check"}) String check,
        @JsonAlias({"selectedRadio", "selected_radio"}) String selectedRadio,
        @JsonAlias({"caste_name", "castename"}) String casteName
) {
}
