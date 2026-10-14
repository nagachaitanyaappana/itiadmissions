package com.server.backend.service.Admission;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import org.springframework.stereotype.Service;

import com.server.backend.DTO.Call_Letter_Letter_DTO;
import com.server.backend.DTO.Call_Letter_Print_DTO;
import com.server.backend.Repository.Admission.Call_Letter_Print_Repository;

/**
 * Builds the printable call-letter payload. Mirrors the legacy generator:
 * <ul>
 *   <li>single mode = {@code call_letterAction} (look up one candidate by register number);</li>
 *   <li>bulk mode = {@code call_letter_generate.jsp} (rank range + caste/gender filter);</li>
 *   <li>header/fees = {@code iti_params} codes 15/16/17/18-21 and the current phase/year.</li>
 * </ul>
 */
@Service
public class Call_Letter_Print_ServiceImpl implements Call_Letter_Print_Service {

    private final Call_Letter_Print_Repository repository;

    public Call_Letter_Print_ServiceImpl(Call_Letter_Print_Repository repository) {
        this.repository = repository;
    }

    @Override
    public Call_Letter_Print_DTO getCallLetterPrint(
            String distCode, String regid, String fromRank, String toRank, String caste) {

        String dist = trim(distCode);
        if (dist.isEmpty()) {
            throw new IllegalArgumentException("District is required.");
        }

        String year = null;
        String phase = null;
        List<Object[]> yp = repository.findCurrentYearPhase();
        if (!yp.isEmpty() && yp.get(0) != null) {
            Object[] r = yp.get(0);
            year = r[0] == null ? null : r[0].toString();
            phase = r[1] == null ? null : r[1].toString();
        }

        String singleRegid = trim(regid);
        List<Object[]> rows;
        if (!singleRegid.isEmpty()) {
            rows = repository.findCandidateByRegid(singleRegid, dist);
        } else {
            Integer from = parseInt(fromRank);
            Integer to = parseInt(toRank);
            if (from == null || to == null) {
                throw new IllegalArgumentException("From Rank and To Rank are required.");
            }
            if (from <= 0 || to <= 0 || from > to) {
                throw new IllegalArgumentException("Invalid merit rank range.");
            }
            rows = repository.findCandidatesByRankRange(dist, from, to);
        }

        List<Object[]> timings = repository.findTimings(dist);

        Call_Letter_Print_DTO out = new Call_Letter_Print_DTO();
        out.setYear(year);
        out.setPhase(phase);
        out.setHeading(upper(repository.findParam("15")));
        out.setHeadingShort(upper(repository.findParam("16")));
        out.setDirComm(upper(repository.findParam("17")));
        out.setFeeUrbanEngg(repository.findParam("18"));
        out.setFeeUrbanNonEngg(repository.findParam("19"));
        out.setFeeRuralEngg(repository.findParam("20"));
        out.setFeeRuralNonEngg(repository.findParam("21"));

        List<Object[]> district = repository.findDistrict(dist);
        if (!district.isEmpty() && district.get(0) != null) {
            Object[] dr = district.get(0);
            out.setDistrict(dr[0] == null ? null : dr[0].toString());
            out.setStateCode(dr[1] == null ? null : dr[1].toString());
        }

        boolean filterWomen = "w".equalsIgnoreCase(trim(caste));
        boolean filterPhc = "phc".equalsIgnoreCase(trim(caste));
        boolean filterExs = "exs".equalsIgnoreCase(trim(caste));
        boolean filterAll = trim(caste).isEmpty() || "all".equalsIgnoreCase(trim(caste));

        Set<String> seen = new HashSet<>();
        for (Object[] row : rows) {
            String rRank = text(row[0]);
            String rReg = text(row[1]);
            String name = text(row[2]);
            String fname = text(row[3]);
            String addr = text(row[4]);
            String cs = text(row[5]);
            String gender = text(row[6]);
            boolean phc = asBool(row[7]);
            boolean exs = asBool(row[8]);

            // Ranks can have more than one row per candidate; keep the best (lowest) one.
            if (rReg != null && !seen.add(rReg)) {
                continue;
            }

            // A single register-number lookup ignores the caste filter, as the legacy single-letter
            // screen did; the bulk screen applies it (all / women / phc / exs / exact caste).
            if (singleRegid.isEmpty()) {
                if (filterWomen) {
                    if (gender == null || !gender.toLowerCase().startsWith("f")) {
                        continue;
                    }
                } else if (filterPhc) {
                    if (!phc) {
                        continue;
                    }
                } else if (filterExs) {
                    if (!exs) {
                        continue;
                    }
                } else if (!filterAll) {
                    if (cs == null || !cs.equalsIgnoreCase(trim(caste))) {
                        continue;
                    }
                }
            }

            Call_Letter_Letter_DTO letter = new Call_Letter_Letter_DTO();
            letter.setRank(rRank);
            letter.setRegid(rReg);
            letter.setName(name);
            letter.setFname(fname);
            letter.setAddress(addr);
            letter.setCaste(cs);
            letter.setGender(gender);
            letter.setYear(year);
            letter.setPhase(phase);

            Integer rankNum = parseInt(rRank);
            if (rankNum != null) {
                for (Object[] t : timings) {
                    Integer mf = asInt(t[0]);
                    Integer mt = asInt(t[1]);
                    if (mf != null && mt != null && rankNum >= mf && rankNum <= mt) {
                        letter.setCalDate(text(t[2]));
                        letter.setCalTime(text(t[3]));
                        break;
                    }
                }
            }

            out.getLetters().add(letter);
        }

        return out;
    }

    private static String trim(String s) {
        return s == null ? "" : s.trim();
    }

    private static String text(Object o) {
        return o == null ? null : o.toString();
    }

    private static String upper(String s) {
        return s == null ? null : s.toUpperCase();
    }

    private static Integer parseInt(String s) {
        if (s == null) {
            return null;
        }
        try {
            return Integer.valueOf(s.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private static Integer asInt(Object o) {
        return o instanceof Number n ? n.intValue() : parseInt(text(o));
    }

    private static boolean asBool(Object o) {
        if (o instanceof Boolean b) {
            return b;
        }
        return "true".equalsIgnoreCase(text(o));
    }
}
