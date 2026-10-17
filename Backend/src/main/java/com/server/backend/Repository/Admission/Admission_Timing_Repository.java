package com.server.backend.Repository.Admission;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.server.backend.entity.AdmissionTiming;
import com.server.backend.entity.AdmissionTimingId;

public interface Admission_Timing_Repository
        extends JpaRepository<AdmissionTiming, AdmissionTimingId> {

    List<AdmissionTiming> findByMinqulAndCasteAndPhaseAndYear(
            String minqul,
            String caste,
            String phase,
            String year);

    /**
     * Filtered lookup for DISTLOGIN Schedule Entry screen.
     * {@code "all"} (any case) acts as a wildcard for qualification/caste so the
     * Screen-1 "All" option returns every row instead of matching the literal
     * string "all" (which never exists in admission_timings and always came back
     * empty). Comparisons are case-insensitive because the UI sends "10th"/"inter"
     * while legacy rows may store "10TH"/"Inter".
     *
     * <p>Built as a constructor projection, not an entity {@code SELECT a}: the
     * district-level rows Hibernate used to materialise as {@code null} (their
     * {@code iti_code} — an {@code @Id} column — is NULL), and
     * {@code Schedule_Entry_ServiceImpl.convertToDTO} NPEd on every result,
     * 500ing GET /admission/schedule-entry and leaving ScheduleEntryView empty.
     */
    @Query("SELECT new com.server.backend.DTO.Schedule_Entry_DTO("
            + "a.itiCode, a.minqul, a.meritFrom, a.meritTo, a.calDate, a.calTime, "
            + "a.distCode, a.caste, a.trno, a.tempPk, a.phase, a.year) "
            + "FROM AdmissionTiming a "
            + "WHERE (:minqul = 'all' OR LOWER(a.minqul) = LOWER(:minqul)) "
            + "AND (:caste = 'all' OR LOWER(a.caste) = LOWER(:caste)) "
            + "AND a.phase = :phase AND a.year = :year")
    List<com.server.backend.DTO.Schedule_Entry_DTO> findFilteredScheduleEntries(
            @Param("minqul") String minqul,
            @Param("caste") String caste,
            @Param("phase") String phase,
            @Param("year") String year);
}