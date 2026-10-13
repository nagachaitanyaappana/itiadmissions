package com.server.backend.DTO;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class ReservationCategoryEntry {

    @NotBlank(message = "Category code is required")
    private String categoryCode;

    @NotNull(message = "Strength is required")
    @Min(value = 0, message = "Strength cannot be negative")
    private Integer strength;
}
