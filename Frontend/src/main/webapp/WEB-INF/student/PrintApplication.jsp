<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<title>:: ITI :: Acknowledgement of Application</title>
<link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/iti.png" />
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/legacy-form.css">
<style>
    body { background: #fff; }
    .pa-wrap { width: 92%; margin: 0 auto; font-family: Arial, Verdana, sans-serif; color: #000; }
    .pa-title { text-align: center; font-weight: bold; font-size: 16px; margin: 6px 0 10px; }
    .pa-regid { font-size: 20px; margin: 6px 0; }
    .pa-regid b { font-size: 22px; }
    .pa-banner { width: 100%; }
    .pa-section-title { text-align: center; text-decoration: underline; font-weight: bold; font-size: 15px; margin: 14px 0 6px; }
    table.pa-table { width: 100%; border-collapse: collapse; margin: 4px 0 10px; }
    table.pa-table td, table.pa-table th { border: 1px solid #000; padding: 5px 8px; font-size: 13px; }
    table.pa-table td.data { background: #e4eeb9; font-weight: bold; width: 30%; }
    table.pa-table th { background: #cbd6b2; }
    table.pa-table td.center, table.pa-table th.center { text-align: center; }
    .pa-photo { float: right; width: 150px; height: 150px; border: 1px solid #000; object-fit: cover; }
    .pa-cols { width: 100%; border-collapse: separate; border-spacing: 10px 0; }
    .pa-cols > tbody > tr > td { vertical-align: top; width: 50%; }
    .pa-fee { margin: 6px 0 6px 120px; border-collapse: collapse; }
    .pa-fee th, .pa-fee td { border: 1px solid #000; padding: 4px 14px; text-align: center; }
    .pa-note { background: #cbd6b2; border: 1px solid #000; padding: 8px 12px; font-size: 13px; }
    .pa-sign { text-align: right; margin: 24px 10px 10px; font-weight: bold; }
    .pa-toolbar { text-align: center; margin: 10px 0 0; }
    .pa-toolbar input { padding: 6px 22px; font-weight: bold; background: greenyellow; border: 1px solid #000; cursor: pointer; }
    @media print {
        .no-print { display: none !important; }
        .pa-wrap { width: 100%; }
    }
</style>
</head>
<body>

<table class="pa-cols"><tbody><tr><td colspan="2" style="text-align:center;">
    <img src="${pageContext.request.contextPath}/images/itiap.jpg" class="pa-banner" alt="ITIAP">
</td></tr></tbody></table>

<div class="pa-wrap">
    <div id="paTitle" class="pa-title"></div>

    <div class="pa-regid">Registration ID <b>: <span id="paRegid">&nbsp;</span></b></div>

    <img id="paPhoto" class="pa-photo" alt=" -NA">

    <table class="pa-table" style="width:60%;">
        <tbody>
            <tr><td colspan="2" class="pa-section-title" style="border:none;">QUALIFICATION DETAILS</td></tr>
            <tr><td class="data">Hall Ticket</td><td id="paHall">&nbsp;</td></tr>
            <tr><td class="data">Board</td><td id="paBoard">&nbsp;</td></tr>
            <tr><td class="data">Year of Pass</td><td id="paYearPass">&nbsp;</td></tr>
            <tr><td class="data">Applied Date</td><td id="paAppliedDate">&nbsp;</td></tr>
        </tbody>
    </table>

    <div style="clear:both;"></div>

    <table class="pa-cols"><tbody><tr>
        <td>
            <div class="pa-section-title">PERSONAL DETAILS</div>
            <table class="pa-table">
                <tbody>
                    <tr><td class="data">Name</td><td id="paName">&nbsp;</td></tr>
                    <tr><td class="data">Father Name</td><td id="paFather">&nbsp;</td></tr>
                    <tr><td class="data">Mother Name</td><td id="paMother">&nbsp;</td></tr>
                    <tr><td class="data">D.O.B</td><td id="paDob">&nbsp;</td></tr>
                    <tr><td class="data">Address</td><td id="paAddr">&nbsp;</td></tr>
                    <tr><td class="data">Pincode</td><td id="paPincode">&nbsp;</td></tr>
                    <tr><td class="data">Email</td><td id="paEmail">&nbsp;</td></tr>
                    <tr><td class="data">Economic Weaker Section</td><td id="paEws">&nbsp;</td></tr>
                    <tr><td class="data">Is Trainee Dual Mode</td><td id="paDualMode">&nbsp;</td></tr>
                </tbody>
            </table>
        </td>
        <td>
            <div class="pa-section-title">RESERVATION DETAILS</div>
            <table class="pa-table">
                <tbody>
                    <tr><td class="data">Gender</td><td id="paGender">&nbsp;</td></tr>
                    <tr><td class="data">Caste</td><td id="paCaste">&nbsp;</td></tr>
                    <tr><td class="data">Ex-Service</td><td id="paExService">&nbsp;</td></tr>
                    <tr><td class="data">Physically Handicapped</td><td id="paPh">&nbsp;</td></tr>
                    <tr><td class="data">Local Status</td><td id="paLocal">&nbsp;</td></tr>
                    <tr><td class="data">Aadhar No</td><td id="paAadhaar">&nbsp;</td></tr>
                    <tr><td class="data">Phone No</td><td id="paPhone">&nbsp;</td></tr>
                </tbody>
            </table>
        </td>
    </tr></tbody></table>

    <div class="pa-section-title" id="paMarksTitle">Marks/GPA</div>
    <table class="pa-table" style="width:75%;margin:0 auto;">
        <tbody>
            <tr>
                <th class="center">Subject</th><th class="center" id="paMarksCol1">GPA</th>
                <th class="center">Subject</th><th class="center" id="paMarksCol2">GPA</th>
            </tr>
            <tr><td class="center">First Language</td><td class="center" id="paFirst">&nbsp;</td>
                <td class="center">Maths</td><td class="center" id="paMath">&nbsp;</td></tr>
            <tr><td class="center">Second Language</td><td class="center" id="paSecond">&nbsp;</td>
                <td class="center">Science</td><td class="center" id="paScience">&nbsp;</td></tr>
            <tr><td class="center">Third Language</td><td class="center" id="paThird">&nbsp;</td>
                <td class="center">Social</td><td class="center" id="paSocial">&nbsp;</td></tr>
            <tr><td class="center" style="text-align:right;font-weight:bold;">TOTAL</td>
                <td class="center" colspan="3" id="paTotal">&nbsp;</td></tr>
        </tbody>
    </table>

    <div class="pa-section-title" id="paListTitle"></div>
    <table class="pa-table" id="paListTable">
        <tbody id="paListBody"></tbody>
    </table>

</div>

<script type="text/javascript">
    var BASE = '${backendBaseUrl}';
    var REGID = new URLSearchParams(window.location.search).get('regid');
    var PA = {};

    function esc(v) {
        if (v === null || v === undefined) { return ''; }
        return String(v).replace(/[&<>"]/g, function (c) {
            return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
        });
    }
    function val(v) {
        if (v === null || v === undefined || String(v).trim() === '') { return '&nbsp;'; }
        return esc(v);
    }
    function setText(id, v) { document.getElementById(id).innerHTML = val(v); }

    function boardName(code) {
        var map = { '28': 'Andhra Pradesh State Board (SSC)', '51': 'CBSE', '52': 'ICSE', '36': 'Telangana' };
        return map[String(code)] || code || '';
    }

    function loadStudent() {
        return $.get(BASE + '/api/student/' + REGID, function (s) {
            PA.student = s;
            document.getElementById('paRegid').innerHTML = val(s.regid);
            setText('paHall', s.sscRegNo);
            setText('paBoard', boardName(s.sscBoard));
            setText('paYearPass', s.sscYear);
            if (s.entryDate) {
                setText('paAppliedDate', String(s.entryDate).substring(0, 10));
            }
            setText('paName', s.name);
            setText('paFather', s.fname);
            setText('paMother', s.mname);
            setText('paDob', s.dob ? String(s.dob).substring(0, 10) : '');
            setText('paAddr', s.addr);
            setText('paPincode', s.pincode);
            setText('paEmail', s.email);
            setText('paEws', s.economicWeakerSection ? 'YES' : 'NO');
            setText('paDualMode', s.isTraineeDualMode === true ? 'YES' : 'NO');
            var gender = s.gender ? (s.gender.charAt(0).toUpperCase() + s.gender.slice(1)) : '';
            setText('paGender', gender);
            setText('paCaste', s.caste);
            setText('paExService', s.exservice ? 'YES' : 'NO');
            setText('paPh', s.phc ? 'YES' : 'NO');
            setText('paLocal', s.local === 'NonLocal' ? 'Non-Local' : (s.local || ''));
            setText('paAadhaar', s.adarno);
            setText('paPhone', s.phno);
        });
    }

    function loadPhoto() {
        $.get(BASE + '/api/student/photo/' + REGID, function (r) {
            if (r && r.photo) {
                document.getElementById('paPhoto').src = 'data:image/jpg;base64,' + r.photo;
            }
        });
    }

    function loadMarks() {
        return $.get(BASE + '/api/student/marks/' + REGID, function (m) {
            if (!m) { return; }
            PA.marks = m;
            var marksType = (PA.student && PA.student.sscType === 'sscm');
            var colName = marksType ? 'Marks' : 'GPA';
            document.getElementById('paMarksCol1').textContent = colName;
            document.getElementById('paMarksCol2').textContent = colName;
            setText('paFirst', marksType ? m.sscFirstLangMarks : m.sscFirstLangGpa);
            setText('paSecond', marksType ? m.sscSecondLangMarks : m.sscSecondLangGpa);
            setText('paThird', marksType ? m.sscEngMarks : m.sscEngGpa);
            setText('paMath', marksType ? m.sscMathMarks : m.sscMathGpa);
            setText('paScience', marksType ? m.sscSciMarks : m.sscSciGpa);
            setText('paSocial', marksType ? m.sscSocialMarks : m.sscSocialGpa);
            setText('paTotal', marksType ? m.sscTotMarks : m.sscTotGpa);
        });
    }

    function loadSelections() {
        return $.get(BASE + '/admission/student-trade-selection/' + REGID, function (list) {
            var phaseOne = String(PA.phase) === '1';
            document.getElementById('paListTitle').textContent =
                (phaseOne ? 'Applied District List' : 'Applied ITIs List') + ' (Phase-' + PA.phase + ')';

            var rows = (list || []).filter(function (r) {
                return phaseOne ? r.distCode : r.itiCode;
            });
            // Phase 1 stores one row per district; de-dupe defensively so a district
            // is never listed twice if legacy/seed rows carry an iti_code.
            if (phaseOne) {
                var seen = {};
                rows = rows.filter(function (r) {
                    if (seen[r.distCode]) { return false; }
                    seen[r.distCode] = true;
                    return true;
                });
            }
            var nameOf = function (r) { return phaseOne ? (r.distName || r.distCode) : (r.itiName || r.itiCode); };

            var body = document.getElementById('paListBody');
            var html = '<tr><th class="center" style="width:60px;">S.No</th>'
                + '<th class="center">' + (phaseOne ? 'District Name' : 'ITI Name') + '</th>'
                + '<th class="center" style="width:60px;">S.No</th>'
                + '<th class="center">' + (phaseOne ? 'District Name' : 'ITI Name') + '</th></tr>';

            for (var i = 0; i < rows.length; i += 2) {
                html += '<tr><td class="center">' + (i + 1) + '</td><td>' + esc(nameOf(rows[i])) + '</td>';
                if (i + 1 < rows.length) {
                    html += '<td class="center">' + (i + 2) + '</td><td>' + esc(nameOf(rows[i + 1])) + '</td>';
                } else {
                    html += '<td class="center">&nbsp;</td><td>&nbsp;</td>';
                }
                html += '</tr>';
            }
            if (rows.length === 0) {
                html += '<tr><td class="center" colspan="4">No selection found.</td></tr>';
            }
            body.innerHTML = html;
        });
    }

    $(document).ready(function () {
        if (!REGID) {
            document.getElementById('paTitle').textContent = 'Registration Id is missing.';
            return;
        }
        $.get(BASE + '/api/reports/current-admission-phase', function (data) {
            PA.phase = (data && data.phase) ? data.phase : '';
            var year = (data && data.year) ? data.year : '';
            document.getElementById('paTitle').textContent =
                'Acknowledgement of Submission of Application for Admission into ITI for the session '
                + year + '(Phase-' + PA.phase + ')';
        }).always(function () {
            // Selections need the phase first, so chain them after phase is known.
            loadStudent().always(function () {
                loadPhoto();
                // Legacy Application_print_student.jsp auto-prints on load (window.print()).
                $.when(loadMarks(), loadSelections()).always(function () {
                    window.print();
                });
            });
        });
    });
</script>
</body>
</html>
