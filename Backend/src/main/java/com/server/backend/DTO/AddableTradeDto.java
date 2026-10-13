package com.server.backend.DTO;

import lombok.Data;

@Data
public class AddableTradeDto {

    private Integer tradeCode;
    private String tradeShort;
    private String tradeName;

    public AddableTradeDto() {
    }

    public AddableTradeDto(Integer tradeCode, String tradeShort, String tradeName) {
        this.tradeCode = tradeCode;
        this.tradeShort = tradeShort;
        this.tradeName = tradeName;
    }
}
