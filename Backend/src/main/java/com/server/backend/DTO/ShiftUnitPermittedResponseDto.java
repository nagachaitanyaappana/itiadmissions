package com.server.backend.DTO;

import lombok.Data;

import java.util.List;

@Data
public class ShiftUnitPermittedResponseDto {

    private String itiCode;
    private String tradeCode;
    private Boolean availableYear;
    /** Sanctioned strength from Add Trade (ititrade.strength); read-only on the page. */
    private Integer tradeStrength;
    private List<ShiftUnitEntryDto> entries;
}