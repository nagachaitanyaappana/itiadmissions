package com.server.backend.DTO;

import lombok.Data;

/** One permitted shift/unit row shown on the Edit Trade screen. */
@Data
public class EditTradeShiftUnitDto {

    private String shiftAllowed;
    private String unitAllowed;
    private Integer strength;
    private Boolean availableYear;

    public EditTradeShiftUnitDto() {
    }

    public EditTradeShiftUnitDto(String shiftAllowed, String unitAllowed,
                                 Integer strength, Boolean availableYear) {
        this.shiftAllowed = shiftAllowed;
        this.unitAllowed = unitAllowed;
        this.strength = strength;
        this.availableYear = availableYear;
    }
}
