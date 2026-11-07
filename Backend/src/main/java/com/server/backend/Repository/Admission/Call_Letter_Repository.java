package com.server.backend.Repository.Admission;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.server.backend.entity.StudentApplication;

public interface Call_Letter_Repository
        extends JpaRepository<StudentApplication, String> {

    @Query(value = """
        SELECT
            r.rank AS rank,
            s.caste AS caste,
            r.regid AS regid,
            r.iti_code AS itiCode,
            r.qual AS qualification,
            r.temp_pk AS tempPk,
            r.phase AS phase,
            r.trno AS trno,
            r.year AS year,
            s.name AS name
        FROM public.ranks r
        INNER JOIN public.student_application s
            ON r.regid = s.regid
            AND r.year = s.year
            AND r.phase = s.phase
        WHERE r.rank = :rank
          AND s.caste = :caste
          AND r.phase = :phase
          AND r.year = :year
          AND (:itiCode IS NULL OR CAST(r.iti_code AS text) = :itiCode)
          AND (:distCode IS NULL OR EXISTS (
              SELECT 1 FROM public.iti i
              WHERE CAST(i.iti_code AS text) = CAST(r.iti_code AS text)
                AND CAST(i.dist_code AS text) = :distCode
          ))
        """, nativeQuery = true)
    List<Object[]> findCallLetterData(
            @Param("rank") String rank,
            @Param("caste") String caste,
            @Param("phase") String phase,
            @Param("year") String year,
            @Param("distCode") String distCode,
            @Param("itiCode") String itiCode);
}
