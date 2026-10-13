package com.server.backend.DTO;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class AddTradeRequest {

    @NotNull(message = "Trade code is required")
    private Integer tradeCode;

    @NotNull(message = "Strength is required")
    @Min(value = 0, message = "Strength cannot be negative")
    private Integer strength;

    /** Mirrors the legacy freezed/available flag: 1 = available for the year, 0 = not. */
    private Integer available = 1;
}
