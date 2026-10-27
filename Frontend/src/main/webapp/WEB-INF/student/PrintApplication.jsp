<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Print Application | ITI Admission Portal</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>

    <style>
        @page {
            size: A4;
            margin: 10mm;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f1f5f9;
            color: #1e293b;
            line-height: 1.35;
        }

        .no-print-zone {
            background: linear-gradient(135deg, #2f6fa5, #1e4f7a);
            color: white;
            padding: 14px 20px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.12);
        }

        .btn-print {
            background: white;
            color: #2f6fa5;
            border: none;
            padding: 8px 24px;
            font-weight: 700;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.95rem;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-print:hover {
            background: #f8fafc;
            color: #1e4f7a;
            transform: translateY(-1px);
        }

        .btn-home {
            background: rgba(255, 255, 255, 0.15);
            color: white;
            border: 1px solid rgba(255, 255, 255, 0.4);
            padding: 8px 20px;
            font-weight: 600;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.95rem;
            transition: all 0.2s;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }

        .btn-home:hover {
            background: rgba(255, 255, 255, 0.25);
            color: white;
        }

        .print-wrapper {
            background: white;
            width: 210mm;
            min-height: 297mm;
            margin: 20px auto;
            padding: 14mm 16mm;
            box-shadow: 0 0 25px rgba(0, 0, 0, 0.08);
            box-sizing: border-box;
            position: relative;
        }

        /* Official Header */
        .official-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #2f6fa5;
            padding-bottom: 12px;
            margin-bottom: 12px;
        }

        .logo-box img {
            height: 75px;
            width: auto;
            object-fit: contain;
        }

        .header-center {
            text-align: center;
            flex-grow: 1;
            padding: 0 10px;
        }

        .header-center h1 {
            font-size: 1.25rem;
            margin: 0;
            color: #0f172a;
            text-transform: uppercase;
            font-weight: 800;
            letter-spacing: 0.5px;
        }

        .header-center h2 {
            font-size: 1.05rem;
            margin: 3px 0;
            color: #1e3a8a;
            text-transform: uppercase;
            font-weight: 700;
        }

        .header-center h3 {
            font-size: 0.95rem;
            margin: 2px 0;
            color: #334155;
            text-transform: uppercase;
            font-weight: 600;
        }

        .ack-banner {
            text-align: center;
            font-size: 0.9rem;
            color: #1e3a8a;
            margin-bottom: 14px;
            font-weight: 700;
            background-color: #eef4fa;
            padding: 6px 12px;
            border-radius: 4px;
            border: 1px solid #cbd5e1;
        }

        .reg-id-display {
            text-align: left;
            font-size: 1.35rem;
            font-weight: 800;
            color: #0f172a;
            margin-bottom: 12px;
            border-bottom: 2px solid #000000;
            padding-bottom: 6px;
        }

        .reg-id-display span {
            color: #2f6fa5;
        }

        /* Section Headers */
        .section-header {
            font-size: 0.85rem;
            font-weight: 700;
            text-transform: uppercase;
            margin: 12px 0 6px 0;
            color: #195695;
            border-bottom: 1px solid #195695;
            padding-bottom: 3px;
        }

        .section-header.center {
            text-align: center;
        }

        /* Qualification Area */
        .qual-container {
            display: flex;
            justify-content: space-between;
            gap: 15px;
            margin-bottom: 14px;
        }

        .qual-data {
            flex: 1;
        }

        .qual-data table {
            width: 100%;
            border-collapse: collapse;
        }

        .qual-data td {
            padding: 4px 6px;
            font-size: 0.85rem;
            border: 1px solid #000000;
        }

        .qual-data td.lbl {
            width: 32%;
            font-weight: 600;
            background-color: #eef4fa;
            color: #195695;
        }

        .qual-data td.val {
            font-weight: 700;
            color: #0f172a;
        }

        .photo-box {
            width: 110px;
            height: 130px;
            border: 1px solid #000000;
            padding: 2px;
            background: #f8fafc;
            display: flex;
            align-items: center;
            justify-content: center;
            flex-shrink: 0;
        }

        .photo-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        /* Clean High-Contrast Tables with Black Borders */
        .print-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 12px;
            font-size: 0.82rem;
        }

        .print-table th,
        .print-table td {
            border: 1px solid #000000;
            padding: 5px 8px;
            vertical-align: middle;
        }

        .print-table th {
            background-color: #eef4fa;
            color: #195695;
            font-weight: 700;
            text-align: center;
            font-size: 0.82rem;
        }

        .print-table td.label-cell {
            background-color: #eef4fa;
            color: #195695;
            font-weight: 600;
            width: 25%;
        }

        .print-table td.value-cell {
            font-weight: 600;
            color: #0f172a;
        }

        /* Fee & Notes */
        .info-section {
            font-size: 0.76rem;
            color: #334155;
            margin-top: 14px;
            border-top: 1px solid #000000;
            padding-top: 10px;
        }

        .info-section p {
            margin: 3px 0;
        }

        .fee-table {
            width: 55%;
            border-collapse: collapse;
            margin: 6px 0 6px 40px;
            font-size: 0.76rem;
        }

        .fee-table th,
        .fee-table td {
            border: 1px solid #000000;
            padding: 4px 8px;
            text-align: center;
        }

        .fee-table th {
            background-color: #eef4fa;
            font-weight: 600;
        }

        .note-box {
            background-color: #f8fafc;
            border: 1px solid #000000;
            padding: 8px 12px;
            margin-top: 8px;
            font-size: 0.75rem;
        }

        .note-box strong {
            color: #0f172a;
        }

        .footer-sig {
            margin-top: 35px;
            display: flex;
            justify-content: flex-end;
        }

        .sig-box {
            text-align: center;
            font-size: 0.85rem;
            font-weight: 600;
            width: 220px;
        }

        .sig-line {
            border-top: 1px solid #000000;
            margin-top: 30px;
            padding-top: 5px;
        }

        @media print {
            .no-print-zone {
                display: none !important;
            }
            body {
                background: white !important;
                padding: 0 !important;
            }
            .print-wrapper {
                margin: 0 !important;
                padding: 5mm !important;
                box-shadow: none !important;
                width: 100% !important;
            }
        }
    </style>
</head>
<body>

    <div class="no-print-zone">
        <div class="d-flex justify-content-center align-items-center gap-3">
            <button class="btn-print" onclick="window.print()">
                <i class="fas fa-print"></i> Download & Print Application
            </button>
            <a href="${pageContext.request.contextPath}/" class="btn-home">
                <i class="fas fa-home"></i> Back to Home
            </a>
        </div>
        <p class="small mb-0 mt-2 text-white-50">Verify all candidate details before printing. Recommended page setting: A4.</p>
    </div>

    <div class="print-wrapper">
        <!-- Official Header -->
        <div class="official-header">
            <div class="logo-box">
                <img src="${pageContext.request.contextPath}/images/ap.png" alt="AP Emblem" onerror="this.style.display='none'">
            </div>
            <div class="header-center">
                <h1>Government of Andhra Pradesh</h1>
                <h2>Department of Employment and Training</h2>
                <h3>Industrial Training Institutes</h3>
            </div>
            <div class="logo-box">
                <img src="${pageContext.request.contextPath}/images/itilogo.png" alt="ITI Logo" onerror="this.src='${pageContext.request.contextPath}/images/iti.png'">
            </div>
        </div>

        <div class="ack-banner" id="paTitle">
            Acknowledgement of Submission of Application for Admission into ITI
        </div>

        <div class="reg-id-display">
            Registration ID : <span id="paRegid">&nbsp;</span>
        </div>

        <!-- Qualification Details -->
        <div class="section-header">Qualification Details</div>
        <div class="qual-container">
            <div class="qual-data">
                <table>
                    <tr><td class="lbl">Hall Ticket</td><td class="val" id="paHall">&nbsp;</td></tr>
                    <tr><td class="lbl">Board</td><td class="val" id="paBoard">&nbsp;</td></tr>
                    <tr><td class="lbl">Year of Pass</td><td class="val" id="paYearPass">&nbsp;</td></tr>
                    <tr><td class="lbl">Applied Date</td><td class="val" id="paAppliedDate">&nbsp;</td></tr>
                </table>
            </div>
            <div class="photo-box">
                <img id="paPhoto" alt="Candidate Photo" style="display:none;">
                <span id="noPhotoTxt" class="text-muted small" style="font-size:0.75rem;">Photo Not Available</span>
            </div>
        </div>

        <!-- Personal Details -->
        <div class="section-header center">Personal Details</div>
        <table class="print-table">
            <tr><td class="label-cell">Name</td><td class="value-cell" id="paName">&nbsp;</td></tr>
            <tr><td class="label-cell">Father Name</td><td class="value-cell" id="paFather">&nbsp;</td></tr>
            <tr><td class="label-cell">Mother Name</td><td class="value-cell" id="paMother">&nbsp;</td></tr>
            <tr><td class="label-cell">Date of Birth</td><td class="value-cell" id="paDob">&nbsp;</td></tr>
            <tr><td class="label-cell">Address</td><td class="value-cell" id="paAddr">&nbsp;</td></tr>
            <tr><td class="label-cell">Pincode</td><td class="value-cell" id="paPincode">&nbsp;</td></tr>
            <tr><td class="label-cell">Email</td><td class="value-cell" id="paEmail">&nbsp;</td></tr>
            <tr><td class="label-cell">Economic Weaker Section</td><td class="value-cell" id="paEws">&nbsp;</td></tr>
        </table>

        <!-- Reservation Details -->
        <div class="section-header center">Reservation Details</div>
        <table class="print-table">
            <tr>
                <td class="label-cell" style="width:20%;">Gender</td><td class="value-cell" style="width:30%;" id="paGender">&nbsp;</td>
                <td class="label-cell" style="width:20%;">Caste</td><td class="value-cell" style="width:30%;" id="paCaste">&nbsp;</td>
            </tr>
            <tr>
                <td class="label-cell">Sub Caste</td><td class="value-cell" id="paSubCaste">&nbsp;</td>
                <td class="label-cell">Ex-Service</td><td class="value-cell" id="paExService">&nbsp;</td>
            </tr>
            <tr>
                <td class="label-cell">Physically Challenged</td><td class="value-cell" id="paPh">&nbsp;</td>
                <td class="label-cell">Local Status</td><td class="value-cell" id="paLocal">&nbsp;</td>
            </tr>
            <tr>
                <td class="label-cell">Aadhaar Number</td><td class="value-cell" id="paAadhaar">&nbsp;</td>
                <td class="label-cell">Mobile Number</td><td class="value-cell" id="paPhone">&nbsp;</td>
            </tr>
        </table>

        <!-- Marks / GPA Section -->
        <div class="section-header center" id="paMarksTitle">Marks / GPA</div>
        <table class="print-table" style="text-align:center;">
            <thead>
                <tr>
                    <th style="width:14%;">First Lang</th>
                    <th style="width:14%;">Second Lang</th>
                    <th style="width:14%;">English</th>
                    <th style="width:14%;">Mathematics</th>
                    <th style="width:14%;">Science</th>
                    <th style="width:14%;">Social Studies</th>
                    <th style="width:16%;">Total (<span id="paMarksCol1">Marks</span>)</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td id="paFirst">&nbsp;</td>
                    <td id="paSecond">&nbsp;</td>
                    <td id="paThird">&nbsp;</td>
                    <td id="paMath">&nbsp;</td>
                    <td id="paScience">&nbsp;</td>
                    <td id="paSocial">&nbsp;</td>
                    <td id="paTotal" style="font-weight:700; background-color:#f8fafc;">&nbsp;</td>
                </tr>
            </tbody>
        </table>

        <!-- Applied Choices List -->
        <div class="section-header center" id="paListTitle">Applied Selections</div>
        <table class="print-table" id="paListTable">
            <tbody id="paListBody"></tbody>
        </table>

        <!-- Fee Structure and Instructions -->
        <div class="info-section">
            <p><strong>Fee Structure:</strong></p>
            <p style="margin-left: 10px;">a. Tuition Fees for Private ITIs per annum:</p>
            <table class="fee-table">
                <tr><th>Trade Category</th><th>Urban ITIs</th><th>Rural ITIs</th></tr>
                <tr><td>Engineering Trades</td><td>₹ 16,500</td><td>₹ 15,000</td></tr>
                <tr><td>Non-Engineering Trades</td><td>₹ 13,200</td><td>₹ 12,000</td></tr>
            </table>
            <p style="margin-left: 10px;">b. Tuition fee for Government ITIs is <strong>NIL</strong> (Free Education).</p>

            <div class="note-box">
                <strong>Important Instructions:</strong>
                <p>1) For Certificate Verification, the candidate can visit any nearest Government ITI.</p>
                <p>2) During Certificate Verification, the candidate should bring all original certificates: SSC or Equivalent Certificate, Caste Certificate, Physically Challenged (PH), Ex-Servicemen, Nativity/Study, Transfer Certificate (TC), Aadhaar Card, and other relevant documents.</p>
                <p>3) Furnish two sets of attested xerox copies and bring this acknowledgement registration slip to the verification center.</p>
            </div>
        </div>

        <!-- Signature -->
        <div class="footer-sig">
            <div class="sig-box">
                <div class="sig-line">Signature of the Applicant</div>
            </div>
        </div>
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

        function setText(id, v) {
            var el = document.getElementById(id);
            if (el) el.innerHTML = val(v);
        }

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
                var gender = s.gender ? (s.gender.charAt(0).toUpperCase() + s.gender.slice(1)) : '';
                setText('paGender', gender);
                setText('paCaste', s.caste);
                setText('paSubCaste', s.subCaste);
                setText('paExService', s.exservice ? 'YES' : 'NO');
                setText('paPh', s.phc ? 'YES' : 'NO');
                setText('paLocal', s.local === 'NonLocal' ? 'Non-Local' : (s.local || ''));
                setText('paAadhaar', s.adarno);
                setText('paPhone', s.phno);
            });
        }

        function loadPhoto() {
            $.get(BASE + '/api/student/photo/' + REGID, function (r) {
                var img = document.getElementById('paPhoto');
                var noPhotoTxt = document.getElementById('noPhotoTxt');
                if (r && r.photo) {
                    img.src = 'data:image/jpeg;base64,' + r.photo;
                    img.style.display = 'block';
                    if (noPhotoTxt) noPhotoTxt.style.display = 'none';
                }
            });
        }

        function loadMarks() {
            return $.get(BASE + '/api/student/marks/' + REGID, function (m) {
                if (!m) return;
                PA.marks = m;
                var marksType = (PA.student && PA.student.sscType === 'sscm');
                var colName = marksType ? 'Marks' : 'GPA';
                document.getElementById('paMarksCol1').textContent = colName;
                document.getElementById('paMarksTitle').textContent = 'Subject-wise ' + colName;
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

                if (phaseOne) {
                    var seen = {};
                    rows = rows.filter(function (r) {
                        if (seen[r.distCode]) return false;
                        seen[r.distCode] = true;
                        return true;
                    });
                }

                var nameOf = function (r) { return phaseOne ? (r.distName || r.distCode) : (r.itiName || r.itiCode); };
                var body = document.getElementById('paListBody');
                var html = '<tr><th style="width:60px;">S.No</th>'
                    + '<th>' + (phaseOne ? 'District Name' : 'ITI Name') + '</th>'
                    + '<th style="width:60px;">S.No</th>'
                    + '<th>' + (phaseOne ? 'District Name' : 'ITI Name') + '</th></tr>';

                for (var i = 0; i < rows.length; i += 2) {
                    html += '<tr><td class="text-center fw-bold">' + (i + 1) + '</td><td>' + esc(nameOf(rows[i])) + '</td>';
                    if (i + 1 < rows.length) {
                        html += '<td class="text-center fw-bold">' + (i + 2) + '</td><td>' + esc(nameOf(rows[i + 1])) + '</td>';
                    } else {
                        html += '<td class="text-center">&nbsp;</td><td>&nbsp;</td>';
                    }
                    html += '</tr>';
                }
                if (rows.length === 0) {
                    html += '<tr><td class="text-center text-muted" colspan="4">No selection recorded.</td></tr>';
                }
                body.innerHTML = html;
            });
        }

        $(document).ready(function () {
            if (!REGID) {
                document.getElementById('paTitle').textContent = 'Registration ID is missing from URL.';
                return;
            }

            $.get(BASE + '/api/reports/current-admission-phase', function (data) {
                PA.phase = (data && data.phase) ? data.phase : '1';
                var year = (data && data.year) ? data.year : '';
                document.getElementById('paTitle').textContent =
                    'Acknowledgement of Submission of Application for Admission into ITI for the session '
                    + year + ' (Phase-' + PA.phase + ')';
            }).always(function () {
                loadStudent().always(function () {
                    loadPhoto();
                    $.when(loadMarks(), loadSelections()).always(function () {
                        // Auto-print option if user opened as print view
                        var autoPrint = new URLSearchParams(window.location.search).get('print');
                        if (autoPrint === 'true') {
                            setTimeout(function () { window.print(); }, 800);
                        }
                    });
                });
            });
        });
    </script>
</body>
</html>
