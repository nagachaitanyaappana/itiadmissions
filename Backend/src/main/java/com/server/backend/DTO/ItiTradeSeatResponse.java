package com.server.backend.DTO;

import lombok.AllArgsConstructor;
import lombok.Data;

/**
 * One ITI + trade seat-matrix row for the public "Seats Open" page.
 *
 * <p>The seniors' UnifiedApp computed these numbers with a raw SQL query over
 * {@code public.iti_seatmatrix} (strength / strength_fill / strength_vacant are
 * hstore columns holding per-category counts). This DTO exposes the same
 * figures in the flat shape the seniors' page expected:
 * {@code totalSeatsOpened}, {@code totalReported}, {@code totalVacant}.
 */
@Data
@AllArgsConstructor
public class ItiTradeSeatResponse {

    private String distCode;
    private String distName;
    private String itiCode;
    private String ncvtCode;
    private String itiName;
    private String govt;
    private String tradeCode;
    private String tradeName;
    private int totalSeatsOpened;
    private int totalReported;
    private int totalVacant;
}
