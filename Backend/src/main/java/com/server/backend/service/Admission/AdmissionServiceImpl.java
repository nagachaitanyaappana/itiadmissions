package com.server.backend.service.Admission;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.BeanUtils;
import org.springframework.stereotype.Service;

import com.server.backend.DTO.CandidateResponseDTO;
import com.server.backend.Repository.Admission.RankRepository;
import com.server.backend.entity.RankEntity;
import com.server.backend.service.AdmissionPhaseWindowService;

@Service
public class AdmissionServiceImpl implements AdmissionService {

    private final RankRepository rankRepository;
    private final AdmissionPhaseWindowService phaseWindows;

    public AdmissionServiceImpl(RankRepository rankRepository,
            AdmissionPhaseWindowService phaseWindows) {
        this.rankRepository = rankRepository;
        this.phaseWindows = phaseWindows;
    }

    @Override
    public List<CandidateResponseDTO> getCandidatesByRank(
            String rank,
            String phase,
            String year) {

        AdmissionPhaseWindowService.Cycle cycle = phaseWindows.currentCycle();
        if (cycle == null || cycle.phase() == null || cycle.year() == null) {
            throw new IllegalStateException(
                    "No current admission year and phase found in admissions.admission_phase.");
        }
        List<RankEntity> entities = rankRepository.findByRankAndPhaseAndYear(
                rank, cycle.phase(), cycle.year());

        if (entities.isEmpty()) {
            throw new RuntimeException("Candidate not found");
        }

        List<CandidateResponseDTO> dtos = new ArrayList<>();

        for (RankEntity entity : entities) {
            CandidateResponseDTO dto = new CandidateResponseDTO();
            BeanUtils.copyProperties(entity, dto);
            dtos.add(dto);
        }

        BeanUtils.copyProperties(entities.get(0), dtos.get(0));

        return dtos;
    }
}