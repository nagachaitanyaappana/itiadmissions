/**
 * Regression tests for the SSC marks/GPA selection.
 *
 * Run with:  node --test itiadmissions/Frontend/src/test/js/
 *
 * These cover the Phase 1 candidate score display: the value shown must be
 * selected by the candidate's ssc_type, because a GPA candidate legitimately
 * stores 0 in every ssc_*_marks column.
 */
const test = require('node:test');
const assert = require('node:assert');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

const WEBAPP_JS = path.resolve(__dirname, '../../../src/main/webapp/js');
const SscScore = require(path.join(WEBAPP_JS, 'sscScore.js'));

// ---------------------------------------------------------------------------
// SscScore.pick()
// ---------------------------------------------------------------------------

test('pick: a GPA candidate shows the GPA even though the marks are 0', () => {
    // Real row of regid 26070400 (ssc_type = 'sscg').
    assert.strictEqual(SscScore.pick('sscg', 0, '10'), '10');
    assert.strictEqual(SscScore.pick('sscg', 0, 10), '10');
});

test('pick: a marks candidate shows the marks even though a GPA is stored', () => {
    // Real row of regid 26070365 (ssc_type = 'SSC', tot_marks 400, tot_gpa 6.00).
    assert.strictEqual(SscScore.pick('sscm', 400, '6.00'), '400');
});

test('pick: a legitimate 0 is a value, not a missing value', () => {
    assert.strictEqual(SscScore.pick('sscm', 0, '6.00'), '0');
    assert.strictEqual(SscScore.pick('sscg', 0, 0), '0');
    assert.strictEqual(SscScore.pick('sscg', 0, '0'), '0');
});

test('pick: missing values render as a dash', () => {
    assert.strictEqual(SscScore.pick('sscg', 0, null), '-');
    assert.strictEqual(SscScore.pick('sscg', 0, undefined), '-');
    assert.strictEqual(SscScore.pick('sscg', 0, ''), '-');
    assert.strictEqual(SscScore.pick('sscm', null, '6.00'), '-');
});

test('pick: ssc_type is matched case-insensitively and trimmed', () => {
    assert.strictEqual(SscScore.pick('SSCG', 0, '9.5'), '9.5');
    assert.strictEqual(SscScore.pick(' sscm ', 480, '9.5'), '480');
});

test('pick: an unknown ssc_type falls back to the recorded value', () => {
    // Legacy rows carry 'SSC', 'R' or 'others'.
    assert.strictEqual(SscScore.pick('SSC', 400, '6.00'), '6.00');
    assert.strictEqual(SscScore.pick(null, 400, '6.00'), '6.00');
    assert.strictEqual(SscScore.pick('R', 0, null), '0');
});

test('resolveType: maps the known ssc_type values', () => {
    assert.strictEqual(SscScore.resolveType('sscm'), 'marks');
    assert.strictEqual(SscScore.resolveType('sscg'), 'gpa');
    assert.strictEqual(SscScore.resolveType('SSC'), 'auto');
});

test('label: the column header follows the ssc_type', () => {
    assert.strictEqual(SscScore.label('sscm'), 'Marks');
    assert.strictEqual(SscScore.label('sscg'), 'GPA');
});

test('label: a legacy ssc_type follows the value that is shown', () => {
    // 'SSC' rows: the shown value is the GPA when one was recorded.
    assert.strictEqual(SscScore.label('SSC', {ssc_tot_gpa: '6.00', ssc_tot_marks: 400}), 'GPA');
    assert.strictEqual(SscScore.label('SSC', {ssc_tot_gpa: null, ssc_tot_marks: 400}), 'Marks');
});

// ---------------------------------------------------------------------------
// renderMarks() in verifyApplication.js
// ---------------------------------------------------------------------------

/** Minimal DOM stub: enough for renderMarks() to run. */
function makeDom() {
    const nodes = {};
    const make = (id) => ({
        id,
        textContent: '',
        innerHTML: '',
        style: {},
        value: ''
    });
    ['marksBody', 'totalScore', 'scoreHeader'].forEach(id => { nodes[id] = make(id); });
    return {
        nodes,
        getElementById: (id) => nodes[id] || null
    };
}

/** Loads verifyApplication.js into a sandbox with the given DOM stub. */
function loadVerifyApplication(dom) {
    const source = fs.readFileSync(path.join(WEBAPP_JS, 'verifyApplication.js'), 'utf8');
    const sandbox = {
        window: { SscScore },
        document: dom,
        console,
        fetch: () => Promise.reject(new Error('not used')),
        alert: () => {},
        SESSION_ROLE_ID: '3',
        SESSION_INS_CODE: 'D1',
        SESSION_USERNAME: 'tester',
        SESSION_DIST_NAME: 'Test District',
        API_BASE_URL: 'http://localhost:6050'
    };
    sandbox.globalThis = sandbox;
    vm.createContext(sandbox);
    vm.runInContext(source, sandbox, {filename: 'verifyApplication.js'});
    return sandbox;
}

test('renderMarks: GPA candidate renders the GPA total, not 0', () => {
    const dom = makeDom();
    const app = loadVerifyApplication(dom);

    app.renderMarks({
        ssc_first_lang_marks: 0, ssc_first_lang_gpa: '10',
        ssc_second_lang_marks: 0, ssc_second_lang_gpa: '10',
        ssc_eng_marks: 0, ssc_eng_gpa: '9',
        ssc_math_marks: 0, ssc_math_gpa: '10',
        ssc_sci_marks: 0, ssc_sci_gpa: '9',
        ssc_social_marks: 0, ssc_social_gpa: '9',
        ssc_tot_marks: 0, ssc_tot_gpa: '10'
    }, 'sscg');

    assert.strictEqual(dom.nodes.totalScore.textContent, '10');
    assert.strictEqual(dom.nodes.scoreHeader.textContent, 'GPA');
    assert.ok(dom.nodes.marksBody.innerHTML.includes('>10<'), 'subject rows must show the GPA');
    assert.ok(!dom.nodes.marksBody.innerHTML.includes('>0<'), 'the 0 marks must not be rendered');
});

test('renderMarks: marks candidate renders the marks total', () => {
    const dom = makeDom();
    const app = loadVerifyApplication(dom);

    app.renderMarks({
        ssc_first_lang_marks: 78, ssc_first_lang_gpa: '6.00',
        ssc_second_lang_marks: 75, ssc_second_lang_gpa: '6.10',
        ssc_eng_marks: 80, ssc_eng_gpa: '6.30',
        ssc_math_marks: 82, ssc_math_gpa: '6.60',
        ssc_sci_marks: 84, ssc_sci_gpa: '6.90',
        ssc_social_marks: 81, ssc_social_gpa: '6.20',
        ssc_tot_marks: 400, ssc_tot_gpa: '6.00'
    }, 'sscm');

    assert.strictEqual(dom.nodes.totalScore.textContent, '400');
    assert.strictEqual(dom.nodes.scoreHeader.textContent, 'Marks');
});

test('renderMarks: a genuine 0 total is kept', () => {
    const dom = makeDom();
    const app = loadVerifyApplication(dom);

    app.renderMarks({
        ssc_tot_marks: 0, ssc_tot_gpa: null
    }, 'sscm');

    assert.strictEqual(dom.nodes.totalScore.textContent, '0');
});

test('renderMarks: missing marks data shows a dash', () => {
    const dom = makeDom();
    const app = loadVerifyApplication(dom);

    app.renderMarks(null, 'sscg');

    assert.strictEqual(dom.nodes.totalScore.textContent, '-');
});

// ---------------------------------------------------------------------------
// JSP wiring
// ---------------------------------------------------------------------------

test('verifyApplication.jsp loads sscScore.js before verifyApplication.js', () => {
    const jsp = fs.readFileSync(
        path.resolve(__dirname, '../../../src/main/webapp/WEB-INF/checkmeritschedule/verifyApplication.jsp'),
        'utf8'
    );
    const helperAt = jsp.indexOf('js/sscScore.js');
    const pageAt = jsp.indexOf('js/verifyApplication.js');
    assert.ok(helperAt > -1, 'sscScore.js must be included by the page');
    assert.ok(pageAt > -1, 'verifyApplication.js must be included by the page');
    assert.ok(helperAt < pageAt, 'sscScore.js must be loaded before verifyApplication.js');
});

test('verifyApplication.jsp exposes the score column header', () => {
    const jsp = fs.readFileSync(
        path.resolve(__dirname, '../../../src/main/webapp/WEB-INF/checkmeritschedule/verifyApplication.jsp'),
        'utf8'
    );
    assert.ok(jsp.includes('id="scoreHeader"'), 'the score column header needs the scoreHeader id');
});
