package com.server.backend.service.Admission;


import org.springframework.stereotype.Service;

import com.server.backend.DTO.Print_Admission_slip_DTO;
import com.server.backend.entity.iti_admissions;
import com.server.backend.Repository.Admission.Print_Admission_Slip_Repository;

/**
 * Builds the ITI Admission Memo / receipt for one admission number.
 *
 * <p>Ports the legacy {@code admissionmemo.jsp}: the candidate and admission columns come from
 * {@code admissions.iti_admissions}; the merit rank, ITI/trade names, district name and the four
 * tuition fees are resolved from their master tables ({@code ranks}, {@code iti},
 * {@code ititrade_master}, {@code dist_mst}, {@code iti_params} 18-21), exactly as the legacy page
 * did with {@code MyUtil.getOptionValue(...)}.
 */
@Service
public class Print_Admission_Slip_ServiceImpl
        implements Print_Admission_Slip_Service {

    private final Print_Admission_Slip_Repository repository;

    public Print_Admission_Slip_ServiceImpl(
            Print_Admission_Slip_Repository repository) {
        this.repository = repository;
    }

    @Override
    public Print_Admission_slip_DTO getAdmissionSlip(
            String admissionNumber) {

        iti_admissions admission = repository
                .findByAdmissionNumber(admissionNumber)
                .orElseThrow(() -> new IllegalArgumentException(
                        "Admission number not found"));

        Print_Admission_slip_DTO dto = new Print_Admission_slip_DTO(
                admission.getName(),
                admission.getFname(),
                admission.getDob(),
                admission.getRegid(),
                admission.getCaste(),
                admission.getRes_category(),
                admission.getDate_of_admission(),
                admission.getIti_code(),
                admission.getTrade_code() == null
                        ? null
                        : admission.getTrade_code().toString(),
                admission.getAdm_num()
        );

        dto.setPhase(admission.getPhase());
        dto.setYear(admission.getYear_of_admission());

        if (admission.getRegid() != null && admission.getPhase() != null) {
            dto.setRank(repository.findRank(admission.getRegid(),
                    String.valueOf(admission.getPhase())));
        }
        if (admission.getIti_code() != null) {
            dto.setItiName(repository.findItiName(admission.getIti_code()));
        }
        if (admission.getTrade_code() != null) {
            dto.setTradeName(repository.findTradeName(admission.getTrade_code()));
        }
        if (admission.getDist_code() != null) {
            dto.setDistrictName(repository.findDistrictName(admission.getDist_code()));
        }

        dto.setFeeUrbanEngg(repository.findParam("18"));
        dto.setFeeUrbanNonEngg(repository.findParam("19"));
        dto.setFeeRuralEngg(repository.findParam("20"));
        dto.setFeeRuralNonEngg(repository.findParam("21"));

        return dto;
    }
}
