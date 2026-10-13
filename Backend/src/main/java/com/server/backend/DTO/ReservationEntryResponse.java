package com.server.backend.DTO;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class ReservationEntryResponse {

    private boolean success;
    private String message;

    private String itiCode;
    private String itiName;
    private Integer tradeCode;
    private String tradeShort;
    private String tradeName;

    private String year;
    private Integer phase;

    private Integer totalStrength;
    private Integer totalStrengthFill;
    private Integer totalStrengthVacant;

    private Integer enteredStrength;
    private Integer enteredStrengthVacant;

    private List<ReservationCategoryDto> categories = new ArrayList<>();
}
