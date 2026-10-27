<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Apply for ITI | ITI Admission Portal</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>

    <style>
        body {
            background: linear-gradient(135deg, #e0e7ff 0%, #f1f5f9 100%);
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        main {
            flex: 1;
        }

        /* ===== STEP 1: GATE CARD ===== */
        .registration-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.1);
            padding: 35px 32px;
            margin: 40px auto;
            max-width: 520px;
            border-top: 6px solid #2f6fa5;
        }

        .header-title {
            font-weight: 800;
            color: #1e3a8a;
            margin-bottom: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 12px;
            font-size: 1.65rem;
        }

        .header-subtitle {
            color: #2f6fa5;
            font-size: 0.95rem;
            font-weight: 600;
            margin-bottom: 20px;
            text-align: center;
        }

        .form-label {
            font-weight: 600;
            color: #334155;
            font-size: 0.9rem;
            margin-bottom: 6px;
        }

        .form-label span.req {
            color: #ef4444;
            margin-left: 2px;
        }

        .registration-card .form-control {
            border-radius: 10px;
            border: 1px solid #cbd5e1;
            padding: 10px 14px;
            font-size: 0.95rem;
            color: #0f172a;
            background-color: #f8fafc;
            transition: all 0.2s ease;
        }

        .registration-card .form-control:focus {
            background-color: #ffffff;
            border-color: #2f6fa5;
            box-shadow: 0 0 0 4px rgba(47, 111, 165, 0.15);
            outline: none;
        }

        .captcha-container {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .captcha-img {
            height: 44px;
            width: 135px;
            border-radius: 10px;
            border: 1px solid #cbd5e1;
            background-color: #ffffff;
            object-fit: contain;
            user-select: none;
        }

        .captcha-refresh {
            background-color: #e0f2fe;
            color: #0284c7;
            border: 1px solid #bae6fd;
            border-radius: 10px;
            width: 44px;
            height: 44px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
            flex-shrink: 0;
        }

        .captcha-refresh:hover {
            background-color: #bae6fd;
            color: #0c4a6e;
            transform: rotate(180deg);
        }

        .btn-primary-custom {
            background: linear-gradient(135deg, #2f6fa5, #1e4f7a);
            border: none;
            border-radius: 10px;
            padding: 11px 20px;
            font-weight: 600;
            font-size: 0.95rem;
            transition: all 0.3s;
            color: #ffffff !important;
            box-shadow: 0 4px 15px rgba(47, 111, 165, 0.3);
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-primary-custom:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(47, 111, 165, 0.4);
            color: #ffffff !important;
        }

        .btn-secondary-custom {
            background-color: #f1f5f9;
            border: 1px solid #cbd5e1;
            border-radius: 10px;
            padding: 11px 20px;
            font-weight: 600;
            font-size: 0.95rem;
            color: #475569 !important;
            transition: all 0.3s;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-secondary-custom:hover {
            background-color: #e2e8f0;
            color: #0f172a !important;
        }

        .buttons-row {
            display: flex;
            gap: 12px;
            margin-top: 25px;
        }

        .buttons-row button,
        .buttons-row a {
            flex: 1;
        }

        .error-msg {
            color: #ef4444;
            font-size: 0.8rem;
            margin-top: 4px;
            display: block;
        }

        /* ===== STEP 2: APPLICATION & SELECTION CONTAINERS ===== */
        .step2-container {
            max-width: 1100px;
            margin: 20px auto;
        }

        .form-table-container {
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: 2px solid #000000;
            overflow: hidden;
            margin-bottom: 25px;
        }

        .form-header-bar {
            background-color: #2f6fa5;
            color: #ffffff;
            padding: 14px 20px;
            text-align: center;
            font-weight: 700;
            font-size: 1.15rem;
            border-bottom: 2px solid #000000;
        }

        .form-subheader-bar {
            background-color: #195695;
            color: #ffffff;
            padding: 10px 16px;
            font-weight: 600;
            font-size: 1rem;
            border-bottom: 1px solid #000000;
        }

        .form-table {
            width: 100%;
            border-collapse: collapse;
        }

        .form-table td,
        .form-table th {
            border: 1px solid #000000;
            padding: 8px 12px;
            vertical-align: middle;
        }

        .form-table td.label-cell {
            background-color: #eef4fa;
            color: #195695;
            font-weight: 600;
            width: 22%;
            font-size: 0.88rem;
        }

        .form-table td.value-cell {
            width: 28%;
            background-color: #ffffff;
            font-size: 0.9rem;
            color: #0f172a;
        }

        /* Selection table */
        .selection-table {
            width: 100%;
            border-collapse: collapse;
        }

        .selection-table th {
            background-color: #2f6fa5;
            color: #ffffff;
            border: 1px solid #000000;
            padding: 10px 12px;
            text-align: center;
            font-weight: 600;
            font-size: 0.9rem;
        }

        .selection-table td {
            border: 1px solid #000000;
            padding: 8px 10px;
            vertical-align: middle;
            background-color: #ffffff;
        }

        .selection-table .form-select {
            border: 1px solid #a6b8c7;
            border-radius: 4px;
            padding: 6px 10px;
            font-size: 0.88rem;
            width: 100%;
        }

        .selection-table .form-select:focus {
            border-color: #2f6fa5;
            box-shadow: 0 0 0 3px rgba(47, 111, 165, 0.15);
            outline: none;
        }

        .btn-delete-row {
            background-color: #fee2e2;
            color: #dc2626;
            border: 1px solid #fca5a5;
            border-radius: 6px;
            padding: 4px 12px;
            font-size: 0.82rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-delete-row:hover {
            background-color: #dc2626;
            color: #ffffff;
        }

        .apply-success-card {
            border: 2px solid #16a34a;
            background-color: #f0fdf4;
            color: #14532d;
            border-radius: 12px;
            padding: 20px;
            margin-bottom: 25px;
            text-align: center;
            box-shadow: 0 6px 20px rgba(22, 163, 74, 0.15);
        }
    </style>

    <%@ include file="_windowGate.jsp" %>
</head>
<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <main>
        <div class="container py-4">

            <!-- ============ GATE: LOOK UP REGISTRATION ============ -->
            <div class="registration-card" id="gateDiv">
                <div class="text-center">
                    <div class="header-title">
                        <i class="fas fa-file-signature"></i> ITI Admission Portal
                    </div>
                    <div class="header-subtitle">
                        Student <span style="font-weight: bold; color: #2f6fa5;">Apply for ITI</span> Form
                    </div>
                </div>

                <div class="alert alert-info py-2 text-start small mb-3">
                    <i class="fas fa-info-circle me-1"></i>
                    <strong>Note:</strong> Applicants must register details first via
                    <a href="${pageContext.request.contextPath}/student-registration" class="alert-link text-decoration-underline">Student Registration</a>.
                    Keep your Registration ID handy before proceeding.
                </div>

                <div id="gateAlert"></div>

                <form name="EditForm_phase2" method="post" action="#" onsubmit="return fetchApplication()">
                    <div class="mb-3">
                        <label class="form-label" for="ssc_regno_gate">
                            SSC Hall Ticket Number <span class="req">*</span>
                        </label>
                        <input type="text" class="form-control" name="ssc_regno" id="ssc_regno_gate"
                               maxlength="15" placeholder="Enter SSC Hall Ticket Number"
                               onkeypress="return NumericsOnly(event);" autocomplete="off">
                        <span id="gateSscError" class="error-msg"></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="dob_gate">
                            Date of Birth <span class="req">*</span>
                        </label>
                        <input type="date" class="form-control" name="dob" id="dob_gate">
                        <span id="gateDobError" class="error-msg"></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="regid_gate">
                            Registration ID <span class="req">*</span>
                        </label>
                        <input type="text" class="form-control" name="regid" id="regid_gate"
                               maxlength="10" placeholder="Enter Registration ID"
                               onkeypress="return NumericsOnly(event);" autocomplete="off">
                        <span id="gateRegidError" class="error-msg"></span>
                    </div>

                    <div class="mb-4">
                        <label class="form-label" for="captcha_gate">
                            Captcha Verification <span class="req">*</span>
                        </label>
                        <div class="captcha-container mb-2">
                            <div class="captcha-refresh" onclick="refreshCaptcha()" title="Refresh Captcha">
                                <i class="fas fa-sync-alt"></i>
                            </div>
                            <img id="captchaImage" src="${pageContext.request.contextPath}/captcha" class="captcha-img" alt="Captcha" />
                            <div class="flex-grow-1">
                                <input type="text" class="form-control" id="captcha_gate" name="captcha"
                                       placeholder="Enter Captcha" maxlength="6" autocomplete="off">
                            </div>
                        </div>
                        <span id="gateCaptchaError" class="error-msg"></span>
                    </div>

                    <div class="buttons-row">
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">
                            <i class="fas fa-home"></i> Home
                        </a>
                        <button type="button" class="btn btn-secondary-custom" onclick="resetGateForm()">
                            <i class="fas fa-undo"></i> Reset
                        </button>
                        <button type="submit" class="btn btn-primary-custom" id="gateSubmitBtn">
                            <i class="fas fa-arrow-right"></i> Submit
                        </button>
                    </div>
                </form>
            </div>

            <!-- ============ STEP 2: APPLICATION & SELECTIONS ============ -->
            <div id="selectDiv" class="step2-container" style="display:none;">

                <!-- Success Banner (shown after save) -->
                <div id="applySuccess" style="display:none;"></div>

                <!-- Result Alert Message -->
                <div id="selectResult"></div>

                <!-- Applicant Personal Details Card -->
                <div class="form-table-container">
                    <div class="form-header-bar">
                        Applicant Registration Details &mdash; <span class="sessionYearPhase"></span>
                    </div>
                    <div id="applyDetails"></div>
                </div>

                <!-- SSC Marks Card -->
                <div class="form-table-container" id="applyMarksContainer" style="display:none;">
                    <div class="form-subheader-bar" id="applyMarksTitle">
                        SSC Details (read-only)
                    </div>
                    <div id="applyMarks"></div>
                </div>

                <!-- Choices Selection Card -->
                <div class="form-table-container">
                    <div class="form-header-bar" id="selectHeading">
                        Selection of Choices (Step 2)
                    </div>

                    <div class="p-3 bg-light border-bottom">
                        <div class="alert alert-info mb-0 py-2" id="selectInstruction">
                            Select the options you want to be considered for, in order of preference (maximum 60).
                            <strong>Save the list</strong> &mdash; a merit list is prepared only for candidates who have saved selections.
                        </div>
                    </div>

                    <div class="table-responsive p-3">
                        <table class="selection-table" id="locDeptTable">
                            <thead>
                                <tr>
                                    <th style="width:60px;">S.No</th>
                                    <th style="width:250px;">District</th>
                                    <th id="govtColHead" style="width:160px;">Government / Private</th>
                                    <th id="itiColHead">ITI Institute</th>
                                    <th style="width:90px;">Action</th>
                                </tr>
                            </thead>
                            <tbody id="locDeptBody"></tbody>
                        </table>
                    </div>

                    <div class="p-3 bg-light border-top">
                        <div class="form-check mb-3">
                            <input class="form-check-input" type="checkbox" id="consent" name="aadhar">
                            <label class="form-check-label small fw-semibold text-secondary" for="consent">
                                I hereby consent to the use of Aadhaar Numbers provided in the application to carry out Identity Validation for ITI college admission process.
                            </label>
                        </div>

                        <div class="d-flex flex-wrap gap-2 justify-content-between align-items-center">
                            <input type="button" id="addRowBtn" class="btn btn-secondary-custom" value="Add Row" onclick="addSelectRow();">
                            <input type="button" id="saveSelBtn" class="btn btn-primary-custom" value="Save Selections" onclick="saveSelections();">
                        </div>
                    </div>
                </div>

                <!-- Available Trades and Seats Information for Selected ITI -->
                <div id="itiInfo" class="mb-4"></div>

                <!-- Saved Selections Card -->
                <div class="form-table-container" id="savedSelectionsContainer">
                    <div class="form-subheader-bar">
                        <i class="fas fa-list-check me-2"></i> Your Current Saved Selections
                    </div>
                    <div class="p-3" id="savedSelections"></div>
                </div>

            </div>

        </div>
    </main>

    <script type="text/javascript">
        var CURRENT_REGID = null;
        var APPLIED_CODES = [];
        var CURRENT_SSC_TYPE = null;
        var CURRENT_YEAR = '';
        var CURRENT_PHASE = '';
        var MAX_CHOICES = 60;
        var DISTRICT_OPTIONS = null;

        function NumericsOnly(evt) {
            var charCode = (evt.which) ? evt.which : event.keyCode;
            if (charCode > 31 && (charCode < 48 || charCode > 57)) {
                return false;
            }
            return true;
        }

        function refreshCaptcha() {
            var timestamp = (new Date()).getTime();
            $("#captchaImage").attr("src", "${pageContext.request.contextPath}/captcha?ts=" + timestamp);
            $("#captcha_gate").val("");
            $("#gateCaptchaError").text("");
        }

        function resetGateForm() {
            document.getElementById("ssc_regno_gate").value = "";
            document.getElementById("dob_gate").value = "";
            document.getElementById("regid_gate").value = "";
            document.getElementById("captcha_gate").value = "";
            $(".error-msg").text("");
            $("#gateAlert").empty();
            refreshCaptcha();
        }

        function validateGate() {
            var valid = true;
            $(".error-msg").text("");
            $("#gateAlert").empty();

            var ssc_regno = $("#ssc_regno_gate").val().trim();
            if (!ssc_regno) {
                $("#gateSscError").text("SSC Hall Ticket Number is required.");
                $("#ssc_regno_gate").focus();
                valid = false;
            }

            var dob = $("#dob_gate").val();
            if (!dob) {
                $("#gateDobError").text("Date of Birth is required.");
                if (valid) $("#dob_gate").focus();
                valid = false;
            }

            var regid = $("#regid_gate").val().trim();
            if (!regid) {
                $("#gateRegidError").text("Registration ID is required.");
                if (valid) $("#regid_gate").focus();
                valid = false;
            }

            var captcha = $("#captcha_gate").val().trim();
            if (!captcha) {
                $("#gateCaptchaError").text("Captcha is required.");
                if (valid) $("#captcha_gate").focus();
                valid = false;
            }

            return valid;
        }

        function fetchApplication() {
            if (!validateGate()) return false;

            var entered = document.getElementById("captcha_gate").value.trim().toUpperCase();
            var submitBtn = $("#gateSubmitBtn");
            submitBtn.prop("disabled", true).html('<i class="fas fa-spinner fa-spin"></i> Checking...');

            $.get('${pageContext.request.contextPath}/captcha/text', function (serverCaptcha) {
                if (entered !== String(serverCaptcha).trim().toUpperCase()) {
                    submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');
                    $("#gateCaptchaError").text("Captcha does not match. Please try again.");
                    refreshCaptcha();
                    document.getElementById("captcha_gate").focus();
                    return;
                }

                loadApplication();
            }).fail(function () {
                submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');
                $("#gateAlert").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;">Verification service temporarily unavailable. Please retry.</div>');
            });

            return false;
        }

        function loadApplication() {
            var regid = document.getElementById("regid_gate").value.trim();
            var ssc_regno = document.getElementById("ssc_regno_gate").value.trim();
            var dob = document.getElementById("dob_gate").value;
            var submitBtn = $("#gateSubmitBtn");

            $.get('${backendBaseUrl}/api/student/apply-gate', {
                regid: regid,
                dob: dob,
                ssc_regno: ssc_regno
            }, function (res) {
                submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');
                var status = res && res.status;
                if (status === 'expired') {
                    gateError('Application date has expired.');
                    return;
                }
                if (status === 'admitted') {
                    var msg = 'Candidate already admitted';
                    if (res.iti_name) msg += ' at ITI: ' + res.iti_name;
                    if (res.adm_num) msg += ' (Admission No: ' + res.adm_num + ')';
                    if (res.trade_name) msg += ' - Trade: ' + res.trade_name;
                    gateError(msg);
                    return;
                }
                if (status === 'norecords' || !res.record) {
                    gateError('No registration record found for the provided details.');
                    return;
                }

                var s = res.record;
                CURRENT_REGID = s.regid;
                CURRENT_SSC_TYPE = s.sscType;
                document.getElementById("gateDiv").style.display = "none";
                renderRegistrationDetails(s);

                $.get('${backendBaseUrl}/api/student/marks/' + s.regid, function (m) {
                    renderMarksDetails(s, m);
                }).fail(function () {
                    renderMarksDetails(s, null);
                });

                initSelectionStep();
                window.scrollTo(0, 0);

            }).fail(function () {
                submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');
                gateError('No registration record found for the provided details.');
            });
        }

        function gateError(message) {
            $("#gateAlert").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;"><i class="fas fa-exclamation-triangle me-2"></i>' + message + '</div>');
            refreshCaptcha();
        }

        function aplEsc(v) {
            if (v === null || v === undefined) { return ''; }
            return String(v).replace(/[&<>"]/g, function (c) {
                return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
            });
        }

        function aplVal(v) {
            if (v === null || v === undefined || String(v).trim() === '') { return '&nbsp;'; }
            return aplEsc(v);
        }

        function aplPair(l1, v1, l2, v2) {
            return '<tr><td class="label-cell">' + l1 + '</td><td class="value-cell">' + aplVal(v1)
                + '</td><td class="label-cell">' + l2 + '</td><td class="value-cell">' + aplVal(v2) + '</td></tr>';
        }

        function renderRegistrationDetails(s) {
            var dob = s.dob ? String(s.dob).substring(0, 10) : '';
            var boardMap = { '28': 'Andhra Pradesh State Board (SSC)', '51': 'CBSE', '52': 'ICSE', '36': 'Telangana' };
            var board = boardMap[String(s.sscBoard)] || s.sscBoard || '';
            var gender = s.gender ? (s.gender.charAt(0).toUpperCase() + s.gender.slice(1)) : '';
            var localVal = s.local === 'NonLocal' ? 'Non-Local' : (s.local || '');
            var monthMap = { '03': 'March', '04': 'Supplementary' };
            var month = monthMap[String(s.sscMonth)] || s.sscMonth || '';
            var pwdMap = { '1': 'Blind', '2': 'Deaf', '3': 'Motor Disability', '4': 'Mental Disability' };
            var pwd = (s.pwdCategory && s.pwdCategory !== 'N' && String(s.pwdCategory).trim() !== '')
                ? (pwdMap[String(s.pwdCategory)] || s.pwdCategory)
                : 'None';
            var qual = (s.sscPassed === true) ? 'SSC Passed' : (s.sscPassed === false ? '8th Passed' : '');

            var h = '<table class="form-table">'
                + aplPair('Hall Ticket Number', s.sscRegNo, 'Board', board)
                + aplPair('Year of Pass', s.sscYear, 'Month of Pass', month)
                + aplPair("Applicant's Name", s.name, 'Mobile Number', s.phno)
                + aplPair('Date of Birth', dob, 'Aadhaar Number', s.adarno)
                + aplPair("Father's Name", s.fname, 'Gender', gender)
                + aplPair("Mother's Name", s.mname, 'Physically Challenged', s.phc ? 'Yes' : 'No')
                + aplPair('Address', s.addr, 'PWD Category', pwd)
                + aplPair('Ex-Service Man', s.exservice ? 'Yes' : 'No', 'Qualification', qual)
                + aplPair('Pincode', s.pincode, 'Email', s.email)
                + aplPair('Caste', s.caste, 'Local / Non-Local', localVal)
                + '<tr><td class="label-cell">Economic Weaker Section</td><td class="value-cell" colspan="3">'
                    + (s.economicWeakerSection ? 'Yes' : 'No') + '</td></tr>'
                + '</table>';

            document.getElementById("applyDetails").innerHTML = h;
        }

        function renderMarksDetails(s, m) {
            var container = document.getElementById("applyMarksContainer");
            var box = document.getElementById("applyMarks");
            if (!m) {
                container.style.display = "none";
                box.innerHTML = '';
                return;
            }

            var gpa = (s.sscType !== 'sscm');
            var suffix = gpa ? 'GPA' : 'Marks';
            var second = gpa ? m.sscSecondLangGpa : m.sscSecondLangMarks;
            var numLang = (second !== null && second !== undefined && String(second).trim() !== '') ? 'Three' : 'Two';
            var rows = gpa
                ? [['First Language', m.sscFirstLangGpa], ['Second Language', m.sscSecondLangGpa],
                   ['Third Language - English', m.sscEngGpa], ['Mathematics', m.sscMathGpa],
                   ['General Science', m.sscSciGpa], ['Social Studies', m.sscSocialGpa], ['Total', m.sscTotGpa]]
                : [['First Language', m.sscFirstLangMarks], ['Second Language', m.sscSecondLangMarks],
                   ['Third Language - English', m.sscEngMarks], ['Mathematics', m.sscMathMarks],
                   ['General Science', m.sscSciMarks], ['Social Studies', m.sscSocialMarks], ['Total', m.sscTotMarks]];

            document.getElementById("applyMarksTitle").innerHTML =
                '<i class="fas fa-graduation-cap me-2"></i> SSC Subject-wise ' + suffix + ' (Number of Languages: ' + numLang + ')';

            var h = '<table class="selection-table">'
                + '<thead><tr><th style="width:10%;">S.No</th><th style="width:60%;">Subject Name</th><th style="width:30%;">' + suffix + '</th></tr></thead><tbody>';

            for (var i = 0; i < rows.length; i++) {
                var isTot = (i === rows.length - 1);
                h += '<tr' + (isTot ? ' style="background-color:#f8fafc;font-weight:bold;"' : '') + '>'
                    + '<td class="text-center">' + (isTot ? '' : (i + 1)) + '</td>'
                    + '<td>' + rows[i][0] + '</td>'
                    + '<td class="text-center fw-bold">' + aplVal(rows[i][1]) + '</td>'
                    + '</tr>';
            }
            h += '</tbody></table>';

            box.innerHTML = h;
            container.style.display = "block";
        }

        function isPhaseOne() {
            return String(CURRENT_PHASE) === '1';
        }

        function loadDistrictOptions(after) {
            if (DISTRICT_OPTIONS) { after(); return; }
            $.get('${backendBaseUrl}/api/districts', function (list) {
                DISTRICT_OPTIONS = list || [];
                after();
            }).fail(function () {
                alert("Could not load district list. Please refresh.");
            });
        }

        function initSelectionStep() {
            document.getElementById("selectDiv").style.display = "block";
            var phaseOne = isPhaseOne();

            document.getElementById("selectHeading").innerHTML = phaseOne
                ? '<i class="fas fa-map-marker-alt me-2"></i> Selection of Districts (Step 2)'
                : '<i class="fas fa-university me-2"></i> Selection of ITIs (Step 2)';

            document.getElementById("selectInstruction").innerHTML = phaseOne
                ? 'Phase 1: Select the districts you want to be considered for (maximum 60). <strong>Save the list</strong> &mdash; a merit list is prepared only for candidates who have selected at least one district.'
                : 'Phase ' + CURRENT_PHASE + ': Select the district and ITI combinations you want to be considered for (maximum 60). <strong>Save the list</strong> &mdash; a merit list is prepared only for candidates who have selected at least one ITI.';

            document.getElementById("itiColHead").style.display = phaseOne ? "none" : "";
            document.getElementById("govtColHead").style.display = phaseOne ? "none" : "";
            document.getElementById("addRowBtn").value = phaseOne ? "Add District" : "Add ITI";
            document.getElementById("saveSelBtn").value = phaseOne ? "Save District Selections" : "Save ITI Selections";

            loadDistrictOptions(function () {
                if (document.getElementById("locDeptBody").rows.length === 0) {
                    addSelectRow();
                }
                loadSavedSelections();
            });
        }

        function addSelectRow(distCode, itiCode) {
            var phaseOne = isPhaseOne();
            var body = document.getElementById("locDeptBody");
            if (body.rows.length >= MAX_CHOICES) {
                alert("A maximum of " + MAX_CHOICES + " selections can be made.");
                return;
            }
            var row = body.insertRow(-1);
            var cSno = row.insertCell(0);
            var cDist = row.insertCell(1);
            var cGov = row.insertCell(2);
            var cIti = row.insertCell(3);
            var cDel = row.insertCell(4);

            cSno.className = "text-center fw-bold";
            cGov.className = "text-center fw-semibold text-secondary";
            cDel.className = "text-center";

            var districtSelect = document.createElement("select");
            districtSelect.className = "form-select selDistrict";
            districtSelect.innerHTML = '<option value="">--Select District--</option>';
            DISTRICT_OPTIONS.forEach(function (d) {
                var o = document.createElement("option");
                o.value = d.code;
                o.textContent = d.name;
                districtSelect.appendChild(o);
            });
            districtSelect.onchange = function () {
                if (phaseOne && isDuplicateDistrict(this)) {
                    alert("You have already selected this District.");
                    this.value = "";
                    return;
                }
                if (!phaseOne) {
                    loadItisForRow(this);
                }
            };
            cDist.appendChild(districtSelect);

            if (phaseOne) {
                cGov.style.display = "none";
                cIti.style.display = "none";
            } else {
                var itiSelect = document.createElement("select");
                itiSelect.className = "form-select selIti";
                itiSelect.innerHTML = '<option value="">--Select ITI--</option>';
                itiSelect.onchange = function () {
                    if (isAlreadyAppliedIti(this.value)) {
                        alert("You have already selected this ITI.");
                        this.value = "";
                        return;
                    }
                    updateGovtCell(this);
                    showTrades(this.value);
                };
                cIti.appendChild(itiSelect);
            }

            var remove = document.createElement("button");
            remove.type = "button";
            remove.className = "btn-delete-row";
            remove.innerHTML = '<i class="fas fa-trash-alt me-1"></i> Delete';
            remove.onclick = function () {
                body.deleteRow(row.rowIndex - 1);
                renumberRows();
            };
            cDel.appendChild(remove);

            if (distCode) { districtSelect.value = distCode; }
            renumberRows();
            if (distCode && !phaseOne) { loadItisForRow(districtSelect, itiCode); }
        }

        function renumberRows() {
            var rows = document.getElementById("locDeptBody").rows;
            for (var i = 0; i < rows.length; i++) {
                rows[i].cells[0].innerHTML = (i + 1);
            }
        }

        function loadItisForRow(districtSelect, preselectIti) {
            var itiSelect = districtSelect.closest("tr").querySelector(".selIti");
            var distCode = districtSelect.value;
            itiSelect.innerHTML = '<option value="">--Select ITI--</option>';
            if (!distCode) { return; }
            $.get('${backendBaseUrl}/admission/eligible-itis/' + encodeURIComponent(distCode),
                function (list) {
                    var seen = {};
                    (list || []).forEach(function (i) {
                        if (seen[i.itiCode]) { return; }
                        seen[i.itiCode] = true;
                        var o = document.createElement("option");
                        o.value = i.itiCode;
                        o.textContent = i.itiName + ' (' + i.ncvtCode + ')';
                        o.dataset.govt = i.govt;
                        itiSelect.appendChild(o);
                    });
                    if (preselectIti) {
                        itiSelect.value = preselectIti;
                        updateGovtCell(itiSelect);
                    }
                });
        }

        function updateGovtCell(itiSelect) {
            var cell = itiSelect.closest("tr").querySelector("td:nth-child(3)");
            if (!cell) { return; }
            var opt = itiSelect.options[itiSelect.selectedIndex];
            var govt = opt ? opt.dataset.govt : "";
            cell.innerHTML = (govt === 'G') ? '<span class="badge bg-primary">Government</span>' : (govt === 'P' ? '<span class="badge bg-secondary">Private</span>' : (govt || ''));
        }

        function isDuplicateDistrict(select) {
            var value = select.value;
            if (!value) { return false; }
            var all = document.querySelectorAll(".selDistrict");
            for (var i = 0; i < all.length; i++) {
                if (all[i] !== select && all[i].value === value) { return true; }
            }
            return APPLIED_CODES.indexOf(value) !== -1;
        }

        function isAlreadyAppliedIti(value) {
            return !!value && APPLIED_CODES.indexOf(value) !== -1;
        }

        function showTrades(itiCode) {
            var box = document.getElementById("itiInfo");
            if (!itiCode) { box.innerHTML = ""; return; }
            $.get('${backendBaseUrl}/admission/iti/' + encodeURIComponent(itiCode) + '/info',
                function (info) { renderTrades(itiCode, box, info); })
             .fail(function () { renderTrades(itiCode, box, null); });
        }

        function renderTrades(itiCode, box, info) {
            var head = '';
            if (info) {
                head = '<div class="alert alert-primary mb-2 text-center">'
                    + '<h6 class="fw-bold mb-1">' + (info.itiName || '') + ' (' + itiCode + ')</h6>'
                    + '<p class="small text-muted mb-0">' + (info.address || '') + ' ' + (info.pinCode || '') + '</p>'
                    + (info.website ? '<p class="small mb-0"><a href="' + info.website + '" target="_blank">' + info.website + '</a></p>' : '')
                    + '</div>';
            }
            $.get('${backendBaseUrl}/admission/iti/' + encodeURIComponent(itiCode) + '/trades',
                function (list) {
                    var html = head
                        + '<div class="card p-3 mb-3 border-dark">'
                        + '<h6 class="fw-bold text-center mb-2" style="color:#195695;">Available Trades and Seat Matrix</h6>'
                        + '<table class="selection-table mx-auto" style="max-width: 650px;">'
                        + '<thead><tr><th>Trade Name</th><th style="width: 140px;">Number of Seats</th></tr></thead><tbody>';
                    (list || []).forEach(function (t) {
                        html += '<tr><td>' + (t.tradeName || t.tradeShort) + '</td><td class="text-center fw-bold">'
                            + (t.strength == null ? 0 : t.strength) + '</td></tr>';
                    });
                    html += '</tbody></table></div>';
                    box.innerHTML = html;
                }).fail(function () { box.innerHTML = head; });
        }

        function collectChoices() {
            var phaseOne = isPhaseOne();
            var rows = document.getElementById("locDeptBody").rows;
            var choices = [];
            for (var i = 0; i < rows.length; i++) {
                var distSelect = rows[i].querySelector(".selDistrict");
                var distCode = distSelect ? distSelect.value : "";
                if (phaseOne) {
                    if (!distCode) continue;
                    choices.push({ distCode: distCode });
                } else {
                    var itiEl = rows[i].querySelector(".selIti");
                    var itiCode = itiEl ? itiEl.value : "";
                    if (!itiCode) continue;
                    choices.push({ distCode: distCode, itiCode: itiCode });
                }
            }
            return choices;
        }

        function saveSelections() {
            if (!CURRENT_REGID) { alert("Please load your application first."); return false; }
            if (!$("#consent").prop("checked")) {
                alert("Aadhaar Identity Validation consent is required to submit selections.");
                $('#consent').focus();
                return false;
            }
            var phaseOne = isPhaseOne();
            var choices = collectChoices();
            if (choices.length === 0) {
                alert(phaseOne ? "Please select at least one district." : "Please select at least one ITI.");
                return false;
            }

            var saveBtn = $("#saveSelBtn");
            saveBtn.prop("disabled", true).val("Saving Selections...");

            $.ajax({
                url: '${backendBaseUrl}/admission/student-trade-selection/' + CURRENT_REGID,
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify({ regid: CURRENT_REGID, choices: choices }),
                success: function (r) {
                    saveBtn.prop("disabled", false).val(phaseOne ? "Save District Selections" : "Save ITI Selections");
                    var what = (r && r.districtOnly) ? 'district' : 'ITI';
                    showSelectMessage(true, 'Saved ' + r.saved + ' ' + what + ' selection(s) successfully for session '
                        + r.year + ' (Phase ' + r.phase + ').');
                    showApplicationSuccess(CURRENT_REGID);
                    loadSavedSelections();
                    window.scrollTo(0, 0);
                },
                error: function (xhr) {
                    saveBtn.prop("disabled", false).val(phaseOne ? "Save District Selections" : "Save ITI Selections");
                    var msg = "Could not save selections.";
                    if (xhr.responseJSON && xhr.responseJSON.error) { msg = xhr.responseJSON.error; }
                    showSelectMessage(false, msg);
                }
            });
            return false;
        }

        function loadSavedSelections() {
            if (!CURRENT_REGID) return;
            var phaseOne = isPhaseOne();
            $.get('${backendBaseUrl}/admission/student-trade-selection/' + CURRENT_REGID,
                function (list) {
                    APPLIED_CODES = [];
                    (list || []).forEach(function (r) {
                        var code = phaseOne ? (r.distCode || '') : (r.itiCode || '');
                        if (code && APPLIED_CODES.indexOf(code) === -1) { APPLIED_CODES.push(code); }
                    });
                    var box = document.getElementById("savedSelections");
                    if (!list || list.length === 0) {
                        box.innerHTML = '<p class="text-center text-muted my-3">' + (phaseOne ? 'No district selections saved yet.' : 'No ITI selections saved yet.') + '</p>';
                        return;
                    }

                    var html = '<table class="selection-table">'
                        + '<thead><tr><th style="width:60px;">S.No</th><th>District Name</th>'
                        + (phaseOne ? '' : '<th style="width:160px;">Government/Private</th><th>College Name</th>')
                        + '<th style="width:100px;">Action</th></tr></thead><tbody>';

                    list.forEach(function (r, idx) {
                        html += '<tr><td class="text-center fw-bold">' + (idx + 1) + '</td><td>'
                            + (r.distName || r.distCode) + '</td>';
                        if (!phaseOne) {
                            var govt = (r.govt === 'G') ? '<span class="badge bg-primary">Government</span>' : (r.govt === 'P' ? '<span class="badge bg-secondary">Private</span>' : '');
                            html += '<td class="text-center">' + govt + '</td><td>' + (r.itiName || r.itiCode) + '</td>';
                        }
                        var delCode = phaseOne ? r.distCode : r.itiCode;
                        var delType = phaseOne ? 'dist' : 'iti';
                        html += '<td class="text-center"><button type="button" class="btn-delete-row" '
                            + 'onclick="deleteSavedSelection(\'' + delType + '\',\'' + delCode + '\')"><i class="fas fa-trash-alt me-1"></i> Delete</button></td>';
                        html += '</tr>';
                    });
                    html += '</tbody></table>';
                    box.innerHTML = html;
                });
        }

        function deleteSavedSelection(type, code) {
            if (!CURRENT_REGID) return;
            var url = '${backendBaseUrl}/admission/student-trade-selection/' + CURRENT_REGID;
            if (type === 'dist') {
                url += '/dist/' + encodeURIComponent(code);
            } else {
                url += '/' + encodeURIComponent(code);
            }
            $.ajax({
                url: url,
                type: 'DELETE',
                success: function () {
                    loadSavedSelections();
                },
                error: function (xhr) {
                    var msg = "Could not delete selection.";
                    if (xhr.responseJSON && xhr.responseJSON.error) { msg = xhr.responseJSON.error; }
                    alert(msg);
                }
            });
        }

        function showSelectMessage(ok, msg) {
            document.getElementById("selectResult").innerHTML =
                '<div class="alert ' + (ok ? 'alert-success' : 'alert-danger') + ' alert-dismissible fade show py-2 text-center" role="alert">'
                + '<i class="fas ' + (ok ? 'fa-check-circle' : 'fa-exclamation-circle') + ' me-2"></i>' + msg
                + '<button type="button" class="btn-close py-2" data-bs-dismiss="alert"></button>'
                + '</div>';
        }

        function showApplicationSuccess(regid) {
            var box = document.getElementById("applySuccess");
            box.innerHTML = '<div class="apply-success-card">'
                + '<i class="fas fa-check-circle" style="font-size: 2.5rem; color: #16a34a;"></i>'
                + '<h4 class="mt-2 fw-bold" style="color: #14532d;">Application Submitted Successfully!</h4>'
                + '<p class="mb-3">You have successfully applied for ITI admissions with Registration ID: <strong>' + regid + '</strong>.</p>'
                + '<a href="${pageContext.request.contextPath}/print-application?regid=' + regid + '" target="_blank" class="btn btn-primary-custom">'
                + '<i class="fas fa-print me-2"></i> Print / Download Application'
                + '</a>'
                + '</div>';
            box.style.display = "block";
        }

        $(document).ready(function () {
            $.get('${backendBaseUrl}/api/reports/current-admission-phase', function (data) {
                if (data && data.year) {
                    CURRENT_YEAR = String(data.year);
                    CURRENT_PHASE = data.phase;
                    $('.sessionYearPhase').text(CURRENT_YEAR + ' (Phase-' + CURRENT_PHASE + ')');
                }
            });

            $('#captcha_gate').keypress(function (ev) {
                if (ev.keyCode === 13) {
                    $('#gateSubmitBtn').click();
                }
            });
        });
    </script>

    <%@ include file="../jsp/footer.jsp" %>
</body>
</html>
