package com.server.backend.DTO;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

/**
 * Edit Trade page payload: the selected trade's editable attributes plus the
 * permitted shift/unit rows ({@code shift_unit_permitted}) for that ITI + trade.
 */
@Data
public class EditTradePageResponse {

    private String itiCode;
    private String itiName;

    private Integer tradeCode;
    private String tradeShort;
    private String tradeName;

    private Integer strength;
    private Integer strengthFill;
    private Integer strengthVacant;
    private String availableForYear;
    private Integer tradeFreeze;
    private Integer convApproval;

    private List<EditTradeShiftUnitDto> shiftUnits = new ArrayList<>();
}
