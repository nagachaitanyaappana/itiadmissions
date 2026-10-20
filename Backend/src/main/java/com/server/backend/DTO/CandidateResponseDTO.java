package com.server.backend.DTO;

public class CandidateResponseDTO {

    private String regid;
    // public.ranks.rank / phase / year are character varying — must match RankEntity's
    // String fields or BeanUtils.copyProperties silently drops them (nulls in the API).
    private String rank;
    private String qual;
    private String dist_code;
    private String iti_code;
    private String phase;
    private String year;
    private String app_status;

    // Default Constructor
    public CandidateResponseDTO() {
    }

    // Parameterized Constructor
    public CandidateResponseDTO(String regid,
                                String rank,
                                String qual,
                                String dist_code,
                                String iti_code,
                                String phase,
                                String year,
                                String app_status) {

        this.regid = regid;
        this.rank = rank;
        this.qual = qual;
        this.dist_code = dist_code;
        this.iti_code = iti_code;
        this.phase = phase;
        this.year = year;
        this.app_status = app_status;
    }

    public String getRegid() {
        return regid;
    }

    public void setRegid(String regid) {
        this.regid = regid;
    }

    public String getRank() {
        return rank;
    }

    public void setRank(String rank) {
        this.rank = rank;
    }

    public String getQual() {
        return qual;
    }

    public void setQual(String qual) {
        this.qual = qual;
    }

    public String getDist_code() {
        return dist_code;
    }

    public void setDist_code(String dist_code) {
        this.dist_code = dist_code;
    }

    public String getIti_code() {
        return iti_code;
    }

    public void setIti_code(String iti_code) {
        this.iti_code = iti_code;
    }

    public String getPhase() {
        return phase;
    }

    public void setPhase(String phase) {
        this.phase = phase;
    }

    public String getYear() {
        return year;
    }

    public void setYear(String year) {
        this.year = year;
    }

    public String getApp_status() {
        return app_status;
    }

    public void setApp_status(String app_status) {
        this.app_status = app_status;
    }

    @Override
    public String toString() {
        return "CandidateResponseDTO{" +
                "regid='" + regid + '\'' +
                ", rank=" + rank +
                ", qual='" + qual + '\'' +
                ", dist_code='" + dist_code + '\'' +
                ", iti_code='" + iti_code + '\'' +
                ", phase=" + phase +
                ", year=" + year +
                ", app_status='" + app_status + '\'' +
                '}';
    }
}