package com.server.backend.DTO;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

/** Body of {@code PUT /admission/add-trade/{itiCode}/trade/{tradeCode}}. */
@Data
public class EditTradeUpdateRequest {

    private Integer strength;
    private Integer available;

    /** Optional shift/unit availability toggles for {@code shift_unit_permitted}. */
    private List<ShiftUnitUpdate> shiftUnits = new ArrayList<>();

    @Data
    public static class ShiftUnitUpdate {
        private String shiftAllowed;
        private String unitAllowed;
        private Boolean available;
    }
}
