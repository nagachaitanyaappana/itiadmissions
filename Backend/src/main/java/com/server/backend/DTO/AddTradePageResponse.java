package com.server.backend.DTO;

import java.util.ArrayList;
import java.util.List;

import lombok.Data;

@Data
public class AddTradePageResponse {

    private String itiCode;
    private String itiName;

    /** True when the ITI already has an approved trade (legacy blocks further Add Trade). */
    private boolean approvedExists;

    private List<AddableTradeDto> addableTrades = new ArrayList<>();
    private List<ExistingTradeDto> existingTrades = new ArrayList<>();
}
