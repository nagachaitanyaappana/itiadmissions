/**
 * Helpers for picking the SSC score (marks or GPA) of a candidate.
 *
 * The candidate's `ssc_type` decides which stored value represents the score:
 *   'sscm' -> the subject marks (ssc_*_marks, ssc_tot_marks)
 *   'sscg' -> the subject GPAs  (ssc_*_gpa,  ssc_tot_gpa)
 *
 * A GPA candidate legitimately stores 0 in every `ssc_*_marks` column (see
 * StudentApplicationServiceImpl.writeCandMarks, which zeroes the marks when
 * ssc_type is 'sscg'), so the value must never be chosen by "whichever column
 * happens to be non-null": that would show 0 instead of the real GPA.
 *
 * The module is written so it can be used both in the browser (it publishes
 * `window.SscScore`) and from a Node test (`module.exports`).
 */
(function (root, factory) {
    const api = factory();
    if (typeof module === 'object' && module.exports) {
        module.exports = api;
    }
    root.SscScore = api;
})(typeof globalThis !== 'undefined' ? globalThis : this, function () {
    'use strict';

    const TYPE_MARKS = 'marks';
    const TYPE_GPA = 'gpa';
    const TYPE_AUTO = 'auto';

    /** Lower-cased, trimmed ssc_type; '' when it is missing. */
    function normaliseType(sscType) {
        if (sscType === null || sscType === undefined) {
            return '';
        }
        return String(sscType).trim().toLowerCase();
    }

    /**
     * Resolves the score kind for an ssc_type.
     * @returns {'marks'|'gpa'|'auto'} 'auto' when the ssc_type is not one of the
     *          two known ones (legacy rows carry 'SSC', 'R' or 'others').
     */
    function resolveType(sscType) {
        const type = normaliseType(sscType);
        if (type === 'sscm') {
            return TYPE_MARKS;
        }
        if (type === 'sscg') {
            return TYPE_GPA;
        }
        return TYPE_AUTO;
    }

    /** True when the value holds something renderable. 0 and '0' are values. */
    function isPresent(value) {
        if (value === null || value === undefined) {
            return false;
        }
        if (typeof value === 'string') {
            return value.trim() !== '';
        }
        return true;
    }

    /** Renders a score: keeps a legitimate 0, shows '-' for null / empty. */
    function format(value) {
        if (!isPresent(value)) {
            return '-';
        }
        if (typeof value === 'string') {
            return value.trim();
        }
        return String(value);
    }

    /**
     * Picks the score to show for one subject (or for the total).
     *
     * @param {string} sscType    candidate ssc_type ('sscm' / 'sscg' / other)
     * @param {*} marksValue      value of the marks column
     * @param {*} gpaValue        value of the gpa column
     * @returns {string} the score, or '-' when nothing is recorded
     */
    function pick(sscType, marksValue, gpaValue) {
        const type = resolveType(sscType);
        if (type === TYPE_MARKS) {
            return format(marksValue);
        }
        if (type === TYPE_GPA) {
            // Never fall back to the marks column here: it is 0 for GPA
            // candidates, and 0 would be shown in place of the real GPA.
            return format(gpaValue);
        }
        // Unknown ssc_type: fall back to whichever value was actually recorded.
        // The GPA is preferred because the Phase 1 merit list ranks and prints
        // the GPA; the marks are used only when no GPA was recorded.
        if (isPresent(gpaValue)) {
            return format(gpaValue);
        }
        return format(marksValue);
    }

    /**
     * Label of the score column, matching the value shown in it.
     *
     * @param {string} sscType the candidate's ssc_type
     * @param {Object} [marks] the student_cand_marks row. Needed only for the
     *        legacy ssc_type values that are neither 'sscm' nor 'sscg': there
     *        the shown value is decided by which column was actually filled,
     *        so the label has to be decided the same way.
     */
    function label(sscType, marks) {
        const type = resolveType(sscType);
        if (type === TYPE_MARKS) {
            return 'Marks';
        }
        if (type === TYPE_GPA) {
            return 'GPA';
        }
        // Unknown ssc_type: mirror the fallback of pick().
        if (marks && isPresent(marks.ssc_tot_gpa)) {
            return 'GPA';
        }
        return 'Marks';
    }

    return {
        resolveType: resolveType,
        isPresent: isPresent,
        format: format,
        pick: pick,
        label: label,
        TYPE_MARKS: TYPE_MARKS,
        TYPE_GPA: TYPE_GPA,
        TYPE_AUTO: TYPE_AUTO
    };
});
