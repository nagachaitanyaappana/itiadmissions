package com.server.backend.DTO;

import lombok.Data;

/**
 * One printable call letter (one candidate). Mirrors the per-candidate values the legacy
 * {@code call_letter2.jsp} / {@code call_letter_generate.jsp} printed: merit rank, register
 * number, candidate/parent names, address and the reporting date/time resolved from
 * {@code admission_timings}.
 */
@Data
public class Call_Letter_Letter_DTO {

    private String rank;
    private String regid;
    private String name;
    private String fname;
    private String address;
    private String caste;
    private String gender;
    private String calDate;
    private String calTime;
    private String itiCode;
    private String qual;
    private String phase;
    private String year;
}
