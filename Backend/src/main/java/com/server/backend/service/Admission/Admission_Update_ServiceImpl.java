package com.server.backend.service.Admission;

import org.springframework.stereotype.Service;

import com.server.backend.DTO.Admission_Update_DTO;
import com.server.backend.Repository.Admission.Admission_Update_Repository;
import com.server.backend.entity.iti_admissions;

@Service
public class Admission_Update_ServiceImpl
        implements Admission_Update_Service {

    private final Admission_Update_Repository repository;

    public Admission_Update_ServiceImpl(
            Admission_Update_Repository repository) {
        this.repository = repository;
    }

    @Override
    public Admission_Update_DTO getAdmission(String admissionNumber, String itiCode) {

        String requestedIti = itiCode == null ? "" : itiCode.trim();
        if (requestedIti.isEmpty()) {
            throw new IllegalArgumentException("Admission number not found");
        }
        iti_admissions admission = repository
                .findByAdmissionNumber(admissionNumber)
                .filter(row -> requestedIti.equalsIgnoreCase(row.getIti_code()))
                .orElseThrow(() -> new IllegalArgumentException(
                        "Admission number not found"));

        return new Admission_Update_DTO(
                admission.getAdm_num(),
                admission.getRegid(),
                admission.getName(),
                admission.getFname(),
                admission.getMname(),
                admission.getIti_code(),
                String.valueOf(admission.getTrade_code()),
                admission.getCaste(),
                admission.getRes_category(),
                admission.getYear_of_admission(),
                admission.getDist_code(),
                admission.getDob(),
                admission.getDate_of_admission(),
                admission.getPhase()
        );
    }

}
