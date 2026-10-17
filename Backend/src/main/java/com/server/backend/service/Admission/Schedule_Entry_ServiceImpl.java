package com.server.backend.service.Admission;

import java.util.List;

import org.springframework.stereotype.Service;

import com.server.backend.DTO.Schedule_Entry_DTO;
import com.server.backend.Repository.Admission.Admission_Timing_Repository;

@Service
public class Schedule_Entry_ServiceImpl implements Schedule_Entry_Service {

    private final Admission_Timing_Repository repository;

    public Schedule_Entry_ServiceImpl(
            Admission_Timing_Repository repository) {

        this.repository = repository;
    }

    @Override
    public List<Schedule_Entry_DTO> getScheduleEntries(
            String qualification,
            String caste,
            String phase,
            String year) {

        // "All" from Screen 1 means wildcard. Normalise to lower-case "all" so the
        // JPQL wildcard check matches regardless of the case the UI sends ("All",
        // "ALL", "all"), and trim blanks to avoid silent empty results.
        String minqulFilter = normaliseFilter(qualification);
        String casteFilter = normaliseFilter(caste);

        List<Schedule_Entry_DTO> timings =
                repository.findFilteredScheduleEntries(
                        minqulFilter,
                        casteFilter,
                        phase == null ? null : phase.trim(),
                        year == null ? null : year.trim());

        return timings.stream()
                .filter(java.util.Objects::nonNull)
                .toList();
    }

    private String normaliseFilter(String value) {
        if (value == null) {
            return "all";
        }
        String trimmed = value.trim();
        if (trimmed.isEmpty() || trimmed.equalsIgnoreCase("all")) {
            return "all";
        }
        return trimmed;
    }
}