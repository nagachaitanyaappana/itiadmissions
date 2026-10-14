package com.server.backend.service.Admission;

import com.server.backend.DTO.Call_Letter_Print_DTO;

/**
 * Builds the data for the printable call letter (single candidate by register number, or a bulk
 * merit-rank range filtered by caste), replicating the legacy
 * {@code call_letterAction} + {@code call_letter2.jsp} / {@code call_letter_generate.jsp}.
 */
public interface Call_Letter_Print_Service {

    Call_Letter_Print_DTO getCallLetterPrint(
            String distCode,
            String regid,
            String fromRank,
            String toRank,
            String caste);
}
