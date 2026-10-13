package com.server.backend.DTO;

import lombok.Data;

@Data
public class ExistingTradeDto {

    private Integer tradeCode;
    private String tradeShort;
    private String tradeName;
    private Integer strength;
    private Integer strengthFill;
    private Integer strengthVacant;
    private String availableForYear;
    private Integer tradeFreeze;
    private Integer convApproval;

    public ExistingTradeDto() {
    }

    public ExistingTradeDto(Integer tradeCode, String tradeShort, String tradeName,
                            Integer strength, Integer strengthFill, Integer strengthVacant,
                            String availableForYear, Integer tradeFreeze, Integer convApproval) {
        this.tradeCode = tradeCode;
        this.tradeShort = tradeShort;
        this.tradeName = tradeName;
        this.strength = strength;
        this.strengthFill = strengthFill;
        this.strengthVacant = strengthVacant;
        this.availableForYear = availableForYear;
        this.tradeFreeze = tradeFreeze;
        this.convApproval = convApproval;
    }
}
