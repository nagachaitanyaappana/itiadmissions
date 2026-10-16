package com.server.backend.DTO;

import lombok.Data;

@Data
public class ReservationCategoryDto {

    private String categoryCode;
    private String categoryName;
    private Integer strength;
    private Integer strengthFill;
    private Integer strengthVacant;

    /** Actual admitted count (admissions.iti_admissions, by res_category); Seat Correction only. */
    private Integer admitted;

    public ReservationCategoryDto() {
    }

    public ReservationCategoryDto(String categoryCode, String categoryName,
                                  Integer strength, Integer strengthFill,
                                  Integer strengthVacant) {
        this.categoryCode = categoryCode;
        this.categoryName = categoryName;
        this.strength = strength;
        this.strengthFill = strengthFill;
        this.strengthVacant = strengthVacant;
    }
}
