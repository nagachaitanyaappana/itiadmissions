package com.server.backend.DTO;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

/**
 * Payload for the printable call-letter page. Carries the letterhead/fee data
 * ({@code iti_params} codes 15/16/17/18-21, current year/phase, district) once, plus the list of
 * candidate letters. Replicates the header block of the legacy
 * {@code call_letter2.jsp} / {@code call_letter_generate.jsp}.
 */
@Data
public class Call_Letter_Print_DTO {

    private String district;
    private String year;
    private String phase;

    /** iti_params code 15 - state heading, e.g. "ANDHRA PRADESH". */
    private String heading;
    /** iti_params code 16 - short heading, e.g. "A.P". */
    private String headingShort;
    /** iti_params code 17 - directorate/commissioner line. */
    private String dirComm;
    /** dist_mst.statecode for the logged-in district. */
    private String stateCode;

    /** iti_params codes 18-21 - private ITI tuition fees. */
    private String feeUrbanEngg;
    private String feeUrbanNonEngg;
    private String feeRuralEngg;
    private String feeRuralNonEngg;

    private List<Call_Letter_Letter_DTO> letters = new ArrayList<>();
}
