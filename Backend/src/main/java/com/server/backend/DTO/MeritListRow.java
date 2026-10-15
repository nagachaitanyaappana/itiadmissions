package com.server.backend.DTO;
public record MeritListRow(
    String rank,
    String regid,
    String name,
    String fname,
    String mname,
    String gender,
    String caste,
    String dob,
    String ssc_passed,
    String phc,
    String exservice,
    String ssc_tot_gpa
) {}
