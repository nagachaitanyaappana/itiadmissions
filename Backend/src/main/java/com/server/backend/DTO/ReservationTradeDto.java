package com.server.backend.DTO;

import lombok.Data;

@Data
public class ReservationTradeDto {

    private Integer tradeCode;
    private String tradeShort;
    private String tradeName;
    private Integer strength;
    private Integer strengthFill;
    private Integer strengthVacant;

    /** Sanctioned course duration in months (ititrade_master.durationyrs); shown by the trade pages. */
    private Integer durationYrs;

    public ReservationTradeDto() {
    }

    public ReservationTradeDto(Integer tradeCode, String tradeShort, String tradeName,
                               Integer strength, Integer strengthFill, Integer strengthVacant) {
        this.tradeCode = tradeCode;
        this.tradeShort = tradeShort;
        this.tradeName = tradeName;
        this.strength = strength;
        this.strengthFill = strengthFill;
        this.strengthVacant = strengthVacant;
    }
}
