package com.server.backend.DTO;


/**
 * ITI header shown above the trades list in the Apply page popup — the legacy
 * {@code web/getTrade_info.jsp} fetched these columns
 * ({@code select address,pin_code,website from iti where iti_code = ?}) plus the ITI name from
 * {@code beans.MyUtil.getOptionValue("iti", "iti_code", "iti_name", regid)}.
 */
public class iti_info_dto {

    private String itiCode;
    private String itiName;
    private String ncvtCode;
    private String govt;
    private String address;
    private Integer pinCode;
    private String website;

    public iti_info_dto() {
    }

    public iti_info_dto(String itiCode, String itiName, String ncvtCode, String govt,
                        String address, Integer pinCode, String website) {
        this.itiCode = itiCode;
        this.itiName = itiName;
        this.ncvtCode = ncvtCode;
        this.govt = govt;
        this.address = address;
        this.pinCode = pinCode;
        this.website = website;
    }

    public String getItiCode() { return itiCode; }
    public void setItiCode(String itiCode) { this.itiCode = itiCode; }

    public String getItiName() { return itiName; }
    public void setItiName(String itiName) { this.itiName = itiName; }

    public String getNcvtCode() { return ncvtCode; }
    public void setNcvtCode(String ncvtCode) { this.ncvtCode = ncvtCode; }

    public String getGovt() { return govt; }
    public void setGovt(String govt) { this.govt = govt; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Integer getPinCode() { return pinCode; }
    public void setPinCode(Integer pinCode) { this.pinCode = pinCode; }

    public String getWebsite() { return website; }
    public void setWebsite(String website) { this.website = website; }
}
