
package com.server.backend.Repository.Admission;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.server.backend.entity.Iti;

public interface eligible_iti_list_repository extends JpaRepository<Iti, String> {

    @Query(value = """
        SELECT
            iti_code,
            iti_name,
            ncvt_code,
            govt
        FROM iti
        WHERE dist_code::integer = CAST(:distCode AS integer)
        ORDER BY govt, iti_name
        """, nativeQuery = true)
    List<Object[]> getEligibleItis(@Param("distCode") String distCode);
}