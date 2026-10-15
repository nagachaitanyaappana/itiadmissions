package com.server.backend.Repository.MeritChecklist;
import org.springframework.data.jpa.repository.JpaRepository;
import com.server.backend.entity.AdmissionTiming;
import com.server.backend.entity.AdmissionTimingId;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;
public interface AdmissionTimingRepository extends JpaRepository<AdmissionTiming, AdmissionTimingId> {
    

// Add these native queries to find Year/Phase, Max ID, and Entity Names
@Query(value = "SELECT value FROM public.iti_params WHERE code = '7'", nativeQuery = true)
String findCurrentYearVal();

@Query(value = "SELECT phase FROM admissions.admission_phase WHERE year = :year AND current = 'true'", nativeQuery = true)
Optional<String> findCurrentPhaseVal(@Param("year") String year);

/**
 * The single row flagged {@code current} in {@code admissions.admission_phase}. This table — not
 * {@code iti_params} code '7' — is the authority on which year/phase is running: the param
 * currently reads 2026 while the only current phase row is 2025, so resolving the year from the
 * param makes every lookup fail with "No current phase found for year 2026".
 *
 * <p>Kept as two single-column queries on purpose: a native query returning several columns mapped
 * to {@code Optional<Object[]>} comes back as a one-element array, which fails at runtime.
 */
@Query(value = "SELECT year FROM admissions.admission_phase WHERE current = 'true'", nativeQuery = true)
Optional<String> findCurrentPhaseYear();

@Query(value = "SELECT phase FROM admissions.admission_phase WHERE current = 'true'", nativeQuery = true)
Optional<String> findCurrentPhaseAnyYear();


/**
 * Phase and its admission date window for the current row of a given year.
 *
 * <p>Returns {@code List<Object[]>} rather than {@code Optional<Object[]>}: a multi-column native
 * query declared as {@code Optional<Object[]>} comes back wrapped, so {@code row[0]} is another
 * Object[] and casting it to String throws ClassCastException at runtime.
 */
@Query(value = "SELECT phase, admissions_start_date, admissions_end_date FROM admissions.admission_phase WHERE year = :year AND current = 'true'", nativeQuery = true)
List<Object[]> findPhaseDates(@Param("year") String year);

@Query(value = "SELECT COALESCE(MAX(CAST(temp_pk AS integer)), 0) + 1 FROM public.admission_timings", nativeQuery = true)
Integer getNextTempPkVal();

/**
 * Serialises temp_pk allocation between concurrent Step 1 calls.
 *
 * <p>{@link #getNextTempPkVal()} reads MAX(temp_pk)+1 and the caller then INSERTs that value, so two
 * requests arriving together both read the same max and write the same temp_pk. That was observed in
 * testing: district 11 and ITI 1536 were both handed 3283.
 *
 * <p>The advisory lock is transaction-scoped, so it is released automatically at commit or rollback
 * and cannot leak if the request fails. Call it before {@link #getNextTempPkVal()}; both must run in
 * the same transaction, which is why the caller is {@code @Transactional}. The id is an arbitrary
 * constant -- it only has to be unique within this database, and no other code path takes this lock.
 *
 * <p>No schema change: temp_pk has no unique index because legacy rows already reuse values (an
 * ITI's own code appears as its temp_pk), so the collision is prevented here rather than by a
 * constraint.
 */
@Query(value = "SELECT 1 FROM pg_advisory_xact_lock(918273645)", nativeQuery = true)
Integer lockTempPkAllocation();

// ---------------------------------------------------------------------------
// Native reads and writes for the two-step schedule flow.
//
// AdmissionTiming is mapped with @IdClass(AdmissionTimingId.class) over (itiCode, phase), but a
// district schedule has iti_code IS NULL. Hibernate cannot build an identifier from a null id
// component, so every JPQL/derived query that returns the entity yields a literal null element for
// district rows -- which Spring Data hands back as Optional.empty(). That is why district Step 2
// answered "No available placeholder found" even though the placeholder row existed.
//
// These queries project plain columns instead of the entity, so they behave identically for ITI and
// district rows and leave the @IdClass mapping (and the legacy CRUD endpoints that still depend on
// it) untouched.
//
// temp_pk is NOT unique across the table: legacy 2024 rows reuse an ITI's own code as their temp_pk.
// Every statement below therefore carries the year and the scope column, and updateScheduleRow is
// additionally guarded on merit_from = 0 so it can only ever fill in an unclaimed placeholder.
// ---------------------------------------------------------------------------

/**
 * Step 1's INSERT. Native rather than save() because @IdClass(itiCode, phase) gives a district row
 * a null identifier, so save() can only ever reach a district row through merge()'s
 * select-then-fall-back-to-insert path -- it returned 201 by accident, not by design. An explicit
 * INSERT states plainly that this is a brand new placeholder and needs no identity to resolve.
 */
@Modifying
@Query(value = "INSERT INTO public.admission_timings "
    + "(iti_code, dist_code, minqul, merit_from, merit_to, cal_date, cal_time, caste, trno, temp_pk, phase, year) "
    + "VALUES (:itiCode, :distCode, :minqul, 0, 0, :calDate, :calTime, :caste, :trno, :tempPk, :phase, :year)", nativeQuery = true)
int insertScheduleRow(
    @Param("itiCode") String itiCode,
    @Param("distCode") String distCode,
    @Param("minqul") String minqul,
    @Param("calDate") LocalDate calDate,
    @Param("calTime") LocalTime calTime,
    @Param("caste") String caste,
    @Param("trno") Integer trno,
    @Param("tempPk") String tempPk,
    @Param("phase") String phase,
    @Param("year") String year
);

/**
 * The next {@code merit_from} for a scope/category. Legacy {@code admission.jsp} and
 * {@code admissionAction} derive it as
 * {@code SELECT max(merit_to)+1 FROM admission_timings WHERE <scope>=? AND minqul=? AND caste=?
 * AND phase=? AND year=?}, defaulting to 1 when no session exists yet. Placeholder rows carry
 * {@code merit_to = 0}, so they cannot raise the maximum.
 */
@Query(value = "SELECT COALESCE(MAX(merit_to), 0) + 1 FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year AND caste = :caste AND minqul = :minqul", nativeQuery = true)
Integer findNextMeritFrom(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("caste") String caste,
    @Param("minqul") String minqul
);

/**
 * Drops unclaimed Step 1 placeholders for the same scope/category before a new one is written.
 * {@code temp_pk} is now the institution code (legacy behaviour) rather than a unique value, so
 * re-running Step 1 would otherwise leave several {@code merit_from = 0} rows that a later Step 2
 * UPDATE could not tell apart.
 */
@Modifying
@Query(value = "DELETE FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year AND caste = :caste AND minqul = :minqul "
    + "AND merit_from = 0 AND merit_to = 0", nativeQuery = true)
int deleteUnclaimedPlaceholders(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("caste") String caste,
    @Param("minqul") String minqul
);

/** The unclaimed placeholder created by Step 1 for this scope/category, identified by its temp_pk. */
@Query(value = "SELECT temp_pk FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year AND caste = :caste AND minqul = :minqul AND merit_from = 0 "
    + "ORDER BY CAST(temp_pk AS integer) DESC LIMIT 1", nativeQuery = true)
List<String> findPlaceholderTempPk(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("caste") String caste,
    @Param("minqul") String minqul
);

/**
 * Writes Step 2's merit range and date onto the placeholder. Scoped by the same key the placeholder
 * was found with, so the reused legacy temp_pk values can never be overwritten by accident.
 */
@Modifying
@Query(value = "UPDATE public.admission_timings SET merit_from = :meritFrom, merit_to = :meritTo, "
    + "cal_date = :calDate, cal_time = :calTime "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year AND caste = :caste AND minqul = :minqul "
    + "AND merit_from = 0 AND temp_pk = :tempPk", nativeQuery = true)
int updateScheduleRow(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("caste") String caste,
    @Param("minqul") String minqul,
    @Param("tempPk") String tempPk,
    @Param("meritFrom") Integer meritFrom,
    @Param("meritTo") Integer meritTo,
    @Param("calDate") LocalDate calDate,
    @Param("calTime") LocalTime calTime
);

/** The single row Step 2 just wrote, re-read as plain columns so no entity hydration is involved. */
@Query(value = "SELECT temp_pk, cal_date, merit_from, merit_to, cal_time FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year AND temp_pk = :tempPk", nativeQuery = true)
List<Object[]> findRowByTempPk(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("tempPk") String tempPk
);

/**
 * Rows for /view. Native for the same reason as the reads above: a district row cannot be hydrated
 * into the entity, so the previous JPQL version silently dropped every district schedule.
 * Columns: cal_date, merit_from, merit_to, caste, minqul, cal_time.
 */
@Query(value = "SELECT cal_date, merit_from, merit_to, caste, minqul, cal_time FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year "
    + "AND (merit_from <> 0 OR merit_to <> 0) "
    + "AND (:caste = 'all' OR caste = :caste) "
    + "AND (:minqul = 'all' OR minqul = :minqul) "
    + "ORDER BY cal_date, cal_time", nativeQuery = true)
List<Object[]> findFilteredScheduleRows(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("caste") String caste,
    @Param("minqul") String minqul
);

@Query(value = "SELECT dist_name FROM public.dist_mst WHERE dist_code = :distCode", nativeQuery = true)
Optional<String> findDistName(@Param("distCode") String distCode);

@Query(value = "SELECT iti_name FROM public.iti WHERE iti_code = :itiCode", nativeQuery = true)
Optional<String> findItiName(@Param("itiCode") String itiCode);

// Add these to check for Date/Time overlaps
boolean existsByItiCodeAndPhaseAndYearAndCalDateAndCalTimeAndTempPkNot(
    String itiCode, String phase, String year, LocalDate calDate, LocalTime calTime, String tempPk
);

boolean existsByDistCodeAndPhaseAndYearAndCalDateAndCalTimeAndTempPkNot(
    String distCode, String phase, String year, LocalDate calDate, LocalTime calTime, String tempPk
);

// Add these to check for Merit Range overlaps.
// Native for the same @IdClass reason as the reads above: the JPQL versions returned the entity, so
// for a district they came back as a list holding a single null and the overlap was reported against
// a null row (NPE on existing.getMeritTo()) instead of the real conflicting range.
@Query(value = "SELECT merit_from, merit_to FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND phase = :phase AND year = :year AND temp_pk <> :tempPk AND merit_from <> 0 "
    + "AND (:meritFrom <= merit_to AND :meritTo >= merit_from) "
    + "ORDER BY merit_from LIMIT 1", nativeQuery = true)
List<Object[]> findOverlappingMeritRange(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("tempPk") String tempPk,
    @Param("meritFrom") Integer meritFrom,
    @Param("meritTo") Integer meritTo
);

/**
 * Count of today's counselling sessions for the caller's district/ITI. Legacy
 * {@code StartAdmissionProcess} blocks the admission process with {@code CouncilDates_notFound}
 * when {@code admission_timings} has no row for the district with {@code cal_date = today}; this
 * reproduces that gate. Same native projection rule as the reads above (a district row has a null
 * iti_code and cannot be hydrated into the entity).
 */
@Query(value = "SELECT COUNT(*) FROM public.admission_timings "
    + "WHERE ((:useDist = true AND dist_code = :code) OR (:useDist = false AND iti_code = :code)) "
    + "AND cal_date = CURRENT_DATE "
    + "AND (:phase IS NULL OR phase = :phase) AND (:year IS NULL OR year = :year)", nativeQuery = true)
long countSchedulesToday(
    @Param("useDist") boolean useDist,
    @Param("code") String code,
    @Param("phase") String phase,
    @Param("year") String year
);

// ---------------------------------------------------------------------------
// Delete-Schedule-Entry admin reads. These are deliberately NOT scoped to the caller's own
// district: the delete page lets an administrator pick any Government/Private district and ITI, so
// the rows are filtered by what the page sends, not by the session. project plain columns for the
// same @IdClass reason as the reads above -- a district (phase 1) row has a null iti_code.
// ---------------------------------------------------------------------------

/** Districts that have at least one ITI of the given govt; a blank govt returns all districts. */
@Query(value = "SELECT DISTINCT d.dist_code, d.dist_name FROM public.dist_mst d "
    + "JOIN public.iti i ON i.dist_code = d.dist_code "
    + "WHERE (:govt IS NULL OR i.govt = :govt) ORDER BY d.dist_name", nativeQuery = true)
List<Object[]> findDistrictsForDelete(@Param("govt") String govt);

/** ITIs of a district for the given govt; a blank govt returns all of the district's ITIs. */
@Query(value = "SELECT i.iti_code, i.iti_name FROM public.iti i "
    + "WHERE i.dist_code = :distCode AND (:govt IS NULL OR i.govt = :govt) "
    + "ORDER BY i.iti_name", nativeQuery = true)
List<Object[]> findItisForDelete(@Param("distCode") String distCode, @Param("govt") String govt);

/**
 * Schedule rows for the running phase/year, filtered by whatever the page selected. Any of
 * district/ITI/govt may be null and is then ignored. The LEFT JOINs keep phase 1 (district-level,
 * iti_code NULL) rows visible while still allowing an ITI/govt filter in later phases.
 */
@Query(value = "SELECT a.sid, a.dist_code, c.dist_name, a.iti_code, b.iti_name, a.caste, a.minqul, "
    + "a.merit_from, a.merit_to, a.cal_date, a.cal_time FROM public.admission_timings a "
    + "LEFT JOIN public.iti b ON b.iti_code = a.iti_code "
    + "LEFT JOIN public.dist_mst c ON c.dist_code = a.dist_code "
    + "WHERE a.phase = :phase AND a.year = :year "
    + "AND (:distCode IS NULL OR a.dist_code = :distCode) "
    + "AND (:itiCode IS NULL OR a.iti_code = :itiCode) "
    + "AND (:govt IS NULL OR b.govt = :govt) "
    + "ORDER BY a.dist_code, a.iti_code, a.caste, a.minqul", nativeQuery = true)
List<Object[]> findScheduleRowsForDelete(
    @Param("phase") String phase,
    @Param("year") String year,
    @Param("distCode") String distCode,
    @Param("itiCode") String itiCode,
    @Param("govt") String govt
);

/** Deletes one schedule row by its identity column ({@code sid} is unique, unlike {@code temp_pk}). */
@Modifying
@Query(value = "DELETE FROM public.admission_timings WHERE sid = :sid", nativeQuery = true)
int deleteBySid(@Param("sid") Long sid);

// The /view search is the native findFilteredScheduleRows() added above; the JPQL version that used
// to live here returned the entity and therefore dropped every district row on null iti_code.
}
