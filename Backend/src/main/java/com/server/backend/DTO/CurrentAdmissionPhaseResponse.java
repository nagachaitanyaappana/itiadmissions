package com.server.backend.DTO;

import lombok.Data;

@Data
public class CurrentAdmissionPhaseResponse {
    private String year;
    private int phase;
    private String applicationToDate;
    private boolean open;

    public CurrentAdmissionPhaseResponse(String year, int phase) {
        this.year = year;
        this.phase = phase;
    }

    public CurrentAdmissionPhaseResponse(String year, int phase, String applicationToDate, boolean open) {
        this.year = year;
        this.phase = phase;
        this.applicationToDate = applicationToDate;
        this.open = open;
    }
}
