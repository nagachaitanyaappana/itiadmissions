package com.server.backend.DTO;


/**
 * One ITI in a district, as listed by the legacy {@code web/getitibydist.jsp}:
 * {@code select iti_code, iti_name, ncvt_code, govt from iti where dist_code::integer = ?
 * order by govt, iti_name}.
 */
public class eligible_iti_list_dto {

    private String itiCode;
    private String itiName;
    private String ncvtCode;
    /** {@code iti.govt}: 'G' for government, 'P' for private. */
    private String govt;

    public eligible_iti_list_dto() {
    }

    public eligible_iti_list_dto(String itiCode, String itiName, String ncvtCode, String govt) {
        this.itiCode = itiCode;
        this.itiName = itiName;
        this.ncvtCode = ncvtCode;
        this.govt = govt;
    }

    public String getItiCode() {
        return itiCode;
    }

    public void setItiCode(String itiCode) {
        this.itiCode = itiCode;
    }

    public String getItiName() {
        return itiName;
    }

    public void setItiName(String itiName) {
        this.itiName = itiName;
    }

    public String getNcvtCode() {
        return ncvtCode;
    }

    public void setNcvtCode(String ncvtCode) {
        this.ncvtCode = ncvtCode;
    }

    public String getGovt() {
        return govt;
    }

    public void setGovt(String govt) {
        this.govt = govt;
    }
}
