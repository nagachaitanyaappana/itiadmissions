package com.server.backend.DTO;

import java.util.List;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class SeatCorrectionRequest {

    @NotBlank(message = "ITI code is required")
    private String itiCode;

    @NotNull(message = "Trade code is required")
    private Integer tradeCode;

    @Valid
    @NotEmpty(message = "At least one category entry is required")
    private List<SeatCorrectionEntry> entries;
}
