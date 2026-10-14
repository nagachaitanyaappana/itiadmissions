package com.server.backend.Repository.Admission;


import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import com.server.backend.entity.iti_admissions;

public interface Print_Admission_Slip_Repository
        extends JpaRepository<iti_admissions, String> {

    @Query("SELECT a FROM iti_admissions a WHERE a.adm_num = :admNum")
    Optional<iti_admissions> findByAdmissionNumber(
            @Param("admNum") String admNum);

    /** Merit rank held by the candidate for the admission phase (null when not ranked). */
    @Query(value = "SELECT r.rank FROM public.ranks r "
            + "WHERE r.regid = :regid AND r.phase = :phase AND r.rank ~ '^[0-9]+$' "
            + "ORDER BY CAST(r.rank AS integer) LIMIT 1", nativeQuery = true)
    String findRank(@Param("regid") String regid, @Param("phase") String phase);

    /** ITI display name for an ITI code. */
    @Query(value = "SELECT iti_name FROM public.iti WHERE iti_code = :code LIMIT 1", nativeQuery = true)
    String findItiName(@Param("code") String code);

    /** Trade display name for a trade code. */
    @Query(value = "SELECT trade_name FROM public.ititrade_master WHERE trade_code = :code LIMIT 1", nativeQuery = true)
    String findTradeName(@Param("code") Integer code);

    /** District display name for a district code. */
    @Query(value = "SELECT dist_name FROM public.dist_mst WHERE dist_code = :code LIMIT 1", nativeQuery = true)
    String findDistrictName(@Param("code") String code);

    /** A single {@code iti_params} value by code (18-21 are the tuition fees). */
    @Query(value = "SELECT value FROM public.iti_params WHERE code = CAST(:code AS integer) LIMIT 1", nativeQuery = true)
    String findParam(@Param("code") String code);
}