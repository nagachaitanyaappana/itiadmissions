
package com.server.backend.DTO;

import java.time.LocalDate;

public class Print_Admission_slip_DTO {

    private String name;
    private String fatherName;
    private LocalDate dob;
    private String registrationNumber;
    private String caste;
    private String reservationCategory;
    private LocalDate dateOfAdmission;
    private String itiCode;
    private String tradeCode;
    private String admissionNumber;

    private String rank;
    private String itiName;
    private String tradeName;
    private String districtName;
    private Integer phase;
    private String year;
    private String feeUrbanEngg;
    private String feeUrbanNonEngg;
    private String feeRuralEngg;
    private String feeRuralNonEngg;

    public Print_Admission_slip_DTO() {
    }

    public Print_Admission_slip_DTO(
            String name,
            String fatherName,
            LocalDate dob,
            String registrationNumber,
            String caste,
            String reservationCategory,
            LocalDate dateOfAdmission,
            String itiCode,
            String tradeCode,
            String admissionNumber) {
        this.name = name;
        this.fatherName = fatherName;
        this.dob = dob;
        this.registrationNumber = registrationNumber;
        this.caste = caste;
        this.reservationCategory = reservationCategory;
        this.dateOfAdmission = dateOfAdmission;
        this.itiCode = itiCode;
        this.tradeCode = tradeCode;
        this.admissionNumber = admissionNumber;
    }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getFatherName() { return fatherName; }
    public void setFatherName(String fatherName) { this.fatherName = fatherName; }

    public LocalDate getDob() { return dob; }
    public void setDob(LocalDate dob) { this.dob = dob; }

    public String getRegistrationNumber() { return registrationNumber; }
    public void setRegistrationNumber(String registrationNumber) {
        this.registrationNumber = registrationNumber;
    }

    public String getCaste() { return caste; }
    public void setCaste(String caste) { this.caste = caste; }

    public String getReservationCategory() { return reservationCategory; }
    public void setReservationCategory(String reservationCategory) {
        this.reservationCategory = reservationCategory;
    }

    public LocalDate getDateOfAdmission() { return dateOfAdmission; }
    public void setDateOfAdmission(LocalDate dateOfAdmission) {
        this.dateOfAdmission = dateOfAdmission;
    }

    public String getItiCode() { return itiCode; }
    public void setItiCode(String itiCode) { this.itiCode = itiCode; }

    public String getTradeCode() { return tradeCode; }
    public void setTradeCode(String tradeCode) { this.tradeCode = tradeCode; }

    public String getAdmissionNumber() { return admissionNumber; }
    public void setAdmissionNumber(String admissionNumber) {
        this.admissionNumber = admissionNumber;
    }

    public String getRank() { return rank; }
    public void setRank(String rank) { this.rank = rank; }

    public String getItiName() { return itiName; }
    public void setItiName(String itiName) { this.itiName = itiName; }

    public String getTradeName() { return tradeName; }
    public void setTradeName(String tradeName) { this.tradeName = tradeName; }

    public String getDistrictName() { return districtName; }
    public void setDistrictName(String districtName) { this.districtName = districtName; }

    public Integer getPhase() { return phase; }
    public void setPhase(Integer phase) { this.phase = phase; }

    public String getYear() { return year; }
    public void setYear(String year) { this.year = year; }

    public String getFeeUrbanEngg() { return feeUrbanEngg; }
    public void setFeeUrbanEngg(String feeUrbanEngg) { this.feeUrbanEngg = feeUrbanEngg; }

    public String getFeeUrbanNonEngg() { return feeUrbanNonEngg; }
    public void setFeeUrbanNonEngg(String feeUrbanNonEngg) { this.feeUrbanNonEngg = feeUrbanNonEngg; }

    public String getFeeRuralEngg() { return feeRuralEngg; }
    public void setFeeRuralEngg(String feeRuralEngg) { this.feeRuralEngg = feeRuralEngg; }

    public String getFeeRuralNonEngg() { return feeRuralNonEngg; }
    public void setFeeRuralNonEngg(String feeRuralNonEngg) { this.feeRuralNonEngg = feeRuralNonEngg; }
}