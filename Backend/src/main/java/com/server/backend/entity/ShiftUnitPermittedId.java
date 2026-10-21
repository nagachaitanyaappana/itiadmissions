package com.server.backend.entity;

import java.io.Serializable;
import lombok.Data;

@Data
public class ShiftUnitPermittedId implements Serializable {
    private Integer itiCode;
    private Integer tradeCode;
    private String shiftAllowed;
    private String unitAllowed;

    public ShiftUnitPermittedId() {
    }

    public ShiftUnitPermittedId(Integer itiCode, Integer tradeCode, String shiftAllowed,
            String unitAllowed) {
        this.itiCode = itiCode;
        this.tradeCode = tradeCode;
        this.shiftAllowed = shiftAllowed;
        this.unitAllowed = unitAllowed;
    }
}