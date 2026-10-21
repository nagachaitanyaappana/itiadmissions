package com.server.backend.Repository.Admission;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.server.backend.entity.application;

/**
 * Reads for the printable call-letter page. All queries are native because they project plain
 * columns (rank/regid/name/...) that have no single JPA entity.
 *
 * <p>Candidates come from {@code ranks} joined to {@code student_application} (the store the rest
 * of the admission flow writes), reproducing the legacy
 * {@code select ... from application a, trade_sel b, ranks c} query but keyed on the district, as
 * the legacy call-letter generator did ({@code c.dist_code = ins_code}).
 */
public interface Call_Letter_Print_Repository extends JpaRepository<application, Integer> {

    /**
     * Candidates ranked inside a merit range for one district, ordered by rank. {@code rank} is
     * varchar in the reference schema, so it is cast for the numeric comparison/order.
     * Columns: rank, regid, name, fname, addr, caste, gender, phc, exservice.
     */
    @Query(value = "SELECT r.rank, r.regid, s.name, s.fname, s.addr, s.caste, s.gender, s.phc, s.exservice "
            + "FROM public.ranks r "
            + "JOIN public.student_application s ON s.regid = r.regid "
            + "WHERE r.dist_code = :distCode "
            + "AND r.rank ~ '^[0-9]+$' "
            + "AND CAST(r.rank AS integer) BETWEEN :fromRank AND :toRank "
            + "ORDER BY CAST(r.rank AS integer)", nativeQuery = true)
    List<Object[]> findCandidatesByRankRange(
            @Param("distCode") String distCode,
            @Param("fromRank") int fromRank,
            @Param("toRank") int toRank);

    /**
     * One candidate by register number, scoped to the district (the legacy single call letter
     * looked the candidate up by regid). Columns: rank, regid, name, fname, addr, caste, gender,
     * phc, exservice.
     */
    @Query(value = "SELECT r.rank, r.regid, s.name, s.fname, s.addr, s.caste, s.gender, s.phc, s.exservice "
            + "FROM public.ranks r "
            + "JOIN public.student_application s ON s.regid = r.regid "
            + "WHERE r.regid = :regid AND r.dist_code = :distCode AND r.rank ~ '^[0-9]+$' "
            + "ORDER BY CAST(r.rank AS integer) LIMIT 1", nativeQuery = true)
    List<Object[]> findCandidateByRegid(
            @Param("regid") String regid,
            @Param("distCode") String distCode);

    /**
     * Reporting slots for a district. Columns: merit_from, merit_to, cal_date (dd-mm-yyyy),
     * cal_time (HH12:MI AM). Resolved in Java per rank to avoid a query per candidate.
     */
    @Query(value = "SELECT merit_from, merit_to, to_char(cal_date, 'DD-MM-YYYY'), "
            + "to_char(cal_time, 'HH12:MI AM') "
            + "FROM public.admission_timings WHERE dist_code = :distCode ORDER BY merit_from", nativeQuery = true)
    List<Object[]> findTimings(@Param("distCode") String distCode);

    /** A single {@code iti_params} value by code (15/16/17/18-21). */
    @Query(value = "SELECT value FROM public.iti_params WHERE code = :code LIMIT 1", nativeQuery = true)
    String findParam(@Param("code") String code);

    /** District display name + state code. Columns: dist_name, statecode. */
    @Query(value = "SELECT dist_name, statecode FROM public.dist_mst WHERE dist_code = :distCode LIMIT 1", nativeQuery = true)
    List<Object[]> findDistrict(@Param("distCode") String distCode);

    /** The single row flagged {@code current} in admissions.admission_phase. Columns: year, phase. */
    @Query(value = "SELECT year, phase FROM admissions.admission_phase WHERE current = true LIMIT 1", nativeQuery = true)
    List<Object[]> findCurrentYearPhase();
}
