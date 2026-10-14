package com.server.backend.DTO;

import lombok.Data;

/** One pending admission row on the Shift/Unit Verification screen (rec_status = 'E'). */
@Data
public class ShiftUnitVerifyRowResponse {

    private String admNum;
    private String name;
    private String fname;
    private String dob;
    private String gender;
    private String shift;
    private String unit;

    public ShiftUnitVerifyRowResponse() {
    }

    public ShiftUnitVerifyRowResponse(String admNum, String name, String fname,
                                      String dob, String gender, String shift, String unit) {
        this.admNum = admNum;
        this.name = name;
        this.fname = fname;
        this.dob = dob;
        this.gender = gender;
        this.shift = shift;
        this.unit = unit;
    }
}
