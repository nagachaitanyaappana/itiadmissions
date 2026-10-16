package com.server.backend.DTO;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

/**
 * One category row of the Seat Correction screen. Unlike Reservation Entry, the
 * already-filled count is supplied by the operator (the legacy
 * {@code manageseats_interface_already_fill_fromadm.jsp} page makes "Already Fill"
 * editable so it can be corrected against the actual admitted numbers).
 */
@Data
public class SeatCorrectionEntry {

    @NotBlank(message = "Category code is required")
    private String categoryCode;

    @NotNull(message = "Strength is required")
    @Min(value = 0, message = "Strength cannot be negative")
    private Integer strength;

    @NotNull(message = "Already fill is required")
    @Min(value = 0, message = "Already fill cannot be negative")
    private Integer strengthFill;
}
