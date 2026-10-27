<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Edit Registration Details | ITI Admission Portal</title>
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

        /* ===== STEP 1: VERIFICATION CARD ===== */
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
            margin-bottom: 25px;
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

        /* ===== STEP 2: STRUCTURED EDIT FORM ===== */
        .form-table-container {
            max-width: 1050px;
            margin: 20px auto;
            background: #ffffff;
            border-radius: 12px;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            border: 2px solid #000000;
            overflow: hidden;
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

        .attention-banner {
            background-color: #eef4fa;
            padding: 10px 20px;
            font-size: 0.88rem;
            font-weight: 600;
            color: #1e3a8a;
            border-bottom: 1px solid #000000;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .prefill-summary {
            background-color: #f8fafc;
            padding: 10px 20px;
            font-size: 0.9rem;
            border-bottom: 2px solid #000000;
            color: #334155;
            text-align: center;
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

        .form-table td.label-cell span.req {
            color: #ef4444;
            margin-left: 2px;
        }

        .form-table td.input-cell {
            width: 28%;
            background-color: #ffffff;
        }

        .form-table .form-control,
        .form-table .form-select {
            border: 1px solid #a6b8c7;
            border-radius: 4px;
            padding: 6px 10px;
            font-size: 0.88rem;
            width: 100%;
        }

        .form-table .form-control:read-only {
            background-color: #f1f5f9;
            color: #475569;
            font-weight: 600;
            cursor: not-allowed;
        }

        .form-table .form-control:focus,
        .form-table .form-select:focus {
            border-color: #2f6fa5;
            box-shadow: 0 0 0 3px rgba(47, 111, 165, 0.15);
            outline: none;
        }

        .photo-preview-box {
            width: 100px;
            height: 120px;
            border: 2px dashed #94a3b8;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            overflow: hidden;
            background: #f8fafc;
        }

        .photo-preview-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .result-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.1);
            padding: 35px 32px;
            margin: 40px auto;
            max-width: 600px;
            border-top: 6px solid #16a34a;
            text-align: center;
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
            <!-- Update Result Alert/Card -->
            <div id="editResult" style="display:none;"></div>

            <!-- ============ GATE: LOOK UP REGISTRATION ============ -->
            <div class="registration-card" id="gateDiv">
                <div class="text-center">
                    <div class="header-title">
                        <i class="fas fa-user-edit"></i> ITI Admission Portal
                    </div>
                    <div class="header-subtitle">
                        Student <span style="font-weight: bold; color: #2f6fa5;">Edit Registration</span> Details
                    </div>
                </div>

                <div id="gateAlert"></div>

                <form name="EditForm" method="post" action="#" onsubmit="return fetchForEdit()">
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

            <!-- ============ EDIT FORM (Opens after lookup) ============ -->
            <div id="editDiv" style="display:none;">
                <div class="form-table-container">
                    <div class="form-header-bar">
                        Edit Registration Form for Admission into the Industrial Training Institute for the session <span class="sessionYearPhase"></span>
                    </div>
                    <div class="attention-banner">
                        <i class="fas fa-exclamation-triangle text-warning fs-5"></i>
                        <span>Attention: Enter data carefully. If any information is found wrong in Marks/GPA, Caste, etc., the authority has the right to disqualify the candidate.</span>
                    </div>

                    <div id="prefillInfo" class="prefill-summary"></div>

                    <form name="EditDetailsForm" method="post" action="#" onsubmit="return submitEdit()">
                        <table class="form-table">
                            <tr>
                                <td class="label-cell">Hall Ticket Number<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="sscRegDisp" class="form-control" readonly tabindex="-1"></td>
                                <td class="label-cell">Board<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="boardDisp" class="form-control" readonly tabindex="-1"></td>
                            </tr>
                            <tr>
                                <td class="label-cell">Year of Pass<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="sscYearDisp" class="form-control" readonly tabindex="-1"></td>
                                <td class="label-cell">Month of Pass<span class="req">*</span></td>
                                <td class="input-cell">
                                    <select id="ssc_month" class="form-select">
                                        <option value="">--Select Month--</option>
                                        <option value="03">March</option>
                                        <option value="04">Supplementary</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="label-cell">Applicant's Name<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="name" class="form-control" maxlength="50" oninput="this.value = this.value.toUpperCase()"></td>
                                <td class="label-cell">Father's Name<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="fname" class="form-control" maxlength="50" oninput="this.value = this.value.toUpperCase()"></td>
                            </tr>
                            <tr>
                                <td class="label-cell">Mother's Name<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="mname" class="form-control" maxlength="50" oninput="this.value = this.value.toUpperCase()"></td>
                                <td class="label-cell">Gender<span class="req">*</span></td>
                                <td class="input-cell">
                                    <div class="d-flex gap-3 align-items-center pt-1">
                                        <label class="form-check-label"><input type="radio" name="gender" value="male" class="form-check-input me-1"> Male</label>
                                        <label class="form-check-label"><input type="radio" name="gender" value="female" class="form-check-input me-1"> Female</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="label-cell">Date of Birth<span class="req">*</span></td>
                                <td class="input-cell"><input type="date" id="appdob" class="form-control"></td>
                                <td class="label-cell">Aadhaar Card Number<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="adarno" class="form-control" maxlength="12" onkeypress="return NumericsOnly(event);"></td>
                            </tr>
                            <tr>
                                <td class="label-cell">Mobile Number<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="phno" class="form-control" maxlength="10" onkeypress="return NumericsOnly(event);"></td>
                                <td class="label-cell">Email</td>
                                <td class="input-cell"><input type="email" id="email" class="form-control" maxlength="80"></td>
                            </tr>
                            <tr>
                                <td class="label-cell">Address<span class="req">*</span></td>
                                <td class="input-cell"><textarea id="addr" class="form-control" rows="2"></textarea></td>
                                <td class="label-cell">Pincode<span class="req">*</span></td>
                                <td class="input-cell"><input type="text" id="pincode" class="form-control" maxlength="6" onkeypress="return NumericsOnly(event);"></td>
                            </tr>
                            <tr>
                                <td class="label-cell">Caste Category<span class="req">*</span></td>
                                <td class="input-cell">
                                    <select id="casteSelect" class="form-select" onchange="loadSubCastes();">
                                        <option value="">--Select Caste--</option>
                                    </select>
                                </td>
                                <td class="label-cell">Sub Caste</td>
                                <td class="input-cell">
                                    <select id="subCasteSelect" class="form-select">
                                        <option value="">--Select Sub Category--</option>
                                    </select>
                                </td>
                            </tr>
                            <tr>
                                <td class="label-cell">Local / Non-Local<span class="req">*</span></td>
                                <td class="input-cell">
                                    <select id="local" class="form-select">
                                        <option value="">--Select Local Status--</option>
                                        <option value="Local">Local</option>
                                        <option value="NonLocal">Non-Local</option>
                                    </select>
                                </td>
                                <td class="label-cell">Physically Challenged<span class="req">*</span></td>
                                <td class="input-cell">
                                    <div class="d-flex gap-3 align-items-center pt-1">
                                        <label class="form-check-label"><input type="radio" name="phc" value="yes" class="form-check-input me-1"> Yes</label>
                                        <label class="form-check-label"><input type="radio" name="phc" value="no" class="form-check-input me-1"> No</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="label-cell">PWD Category</td>
                                <td class="input-cell">
                                    <select id="pwdCategory" class="form-select">
                                        <option value="">None</option>
                                        <option value="1">Blind</option>
                                        <option value="2">Deaf</option>
                                        <option value="3">Motor Disability</option>
                                        <option value="4">Mental Disability</option>
                                    </select>
                                </td>
                                <td class="label-cell">Ex-Servicemen<span class="req">*</span></td>
                                <td class="input-cell">
                                    <div class="d-flex gap-3 align-items-center pt-1">
                                        <label class="form-check-label"><input type="radio" name="exs" value="yes" class="form-check-input me-1"> Yes</label>
                                        <label class="form-check-label"><input type="radio" name="exs" value="no" class="form-check-input me-1"> No</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="label-cell">Qualification<span class="req">*</span></td>
                                <td class="input-cell">
                                    <select id="ssc" class="form-select">
                                        <option value="">--Select Qualification--</option>
                                        <option value="yes">SSC Passed</option>
                                        <option value="no">8th Passed</option>
                                    </select>
                                </td>
                                <td class="label-cell">Economic Weaker Section<span class="req">*</span></td>
                                <td class="input-cell">
                                    <div class="d-flex gap-3 align-items-center pt-1">
                                        <label class="form-check-label"><input type="radio" name="ews" value="yes" class="form-check-input me-1"> Yes</label>
                                        <label class="form-check-label"><input type="radio" name="ews" value="no" class="form-check-input me-1"> No</label>
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td class="label-cell">Photograph</td>
                                <td class="input-cell" colspan="3">
                                    <div class="d-flex flex-wrap gap-4 align-items-center">
                                        <div>
                                            <div class="small text-muted mb-1 fw-bold">Current Photo:</div>
                                            <div class="photo-preview-box">
                                                <img id="existingPhoto" alt="No Photo" style="display:none;">
                                                <span id="noPhotoText" class="text-muted small">No Photo</span>
                                            </div>
                                        </div>
                                        <div>
                                            <div class="small text-muted mb-1 fw-bold">New Photo Preview:</div>
                                            <div class="photo-preview-box" id="photoPrevBox">
                                                <span class="text-muted small">Select below</span>
                                            </div>
                                        </div>
                                        <div class="flex-grow-1" style="min-width: 220px;">
                                            <label class="form-label small">Upload New Photo (Optional):</label>
                                            <input type="file" id="photo" class="form-control form-control-sm" accept="image/png,image/jpeg" onchange="previewPhoto(this);">
                                            <div class="form-text text-muted" style="font-size:0.75rem;">Allowed formats: PNG, JPG (Max 200 KB)</div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        </table>

                        <div class="p-3 bg-light text-center border-top">
                            <div class="d-inline-flex gap-3">
                                <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">
                                    <i class="fas fa-home me-1"></i> Back to Home
                                </a>
                                <button type="submit" class="btn btn-primary-custom" id="saveEditBtn">
                                    <i class="fas fa-save me-1"></i> Save Changes
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </main>

    <script type="text/javascript">
        var CURRENT_REGID = null;

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

        function fetchForEdit() {
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

                var regid = document.getElementById("regid_gate").value.trim();
                var hallticket = document.getElementById("ssc_regno_gate").value.trim().toUpperCase();
                var dob = document.getElementById("dob_gate").value;

                $.get('${backendBaseUrl}/api/student/' + encodeURIComponent(regid), function (s) {
                    submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');

                    if (String(s.sscRegNo || '').toUpperCase() !== hallticket) {
                        $("#gateAlert").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;"><i class="fas fa-exclamation-triangle me-2"></i>Hall Ticket Number does not match this Registration ID.</div>');
                        refreshCaptcha();
                        return;
                    }
                    if (s.dob && String(s.dob).substring(0, 10) !== dob) {
                        $("#gateAlert").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;"><i class="fas fa-exclamation-triangle me-2"></i>Date of Birth does not match this Registration ID.</div>');
                        refreshCaptcha();
                        return;
                    }

                    CURRENT_REGID = s.regid;
                    prefill(s);
                    document.getElementById("gateDiv").style.display = "none";
                    document.getElementById("editDiv").style.display = "";
                    window.scrollTo(0, 0);

                }).fail(function () {
                    submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');
                    $("#gateAlert").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;"><i class="fas fa-exclamation-circle me-2"></i>No registration found for Registration ID <b>' + regid + '</b>.</div>');
                    refreshCaptcha();
                });

            }).fail(function () {
                submitBtn.prop("disabled", false).html('<i class="fas fa-arrow-right"></i> Submit');
                $("#gateAlert").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;">Verification service temporarily unavailable. Please retry.</div>');
            });

            return false;
        }

        function prefill(s) {
            var boardMap = { '28': 'Andhra Pradesh State Board (SSC)', '51': 'CBSE', '52': 'ICSE', '36': 'Telangana' };
            var board = boardMap[String(s.sscBoard)] || (s.sscBoard || '-');

            document.getElementById("prefillInfo").innerHTML =
                '<strong>Registration ID:</strong> <span class="badge bg-primary fs-6 me-2">' + s.regid + '</span> '
                + '<strong>Hall Ticket:</strong> ' + (s.sscRegNo || '-') + ' &nbsp;|&nbsp; '
                + '<strong>Board:</strong> ' + board + ' &nbsp;|&nbsp; '
                + '<strong>Year:</strong> ' + (s.sscYear || '-') + ' &nbsp;|&nbsp; '
                + '<strong>Result Type:</strong> ' + (s.sscType === 'sscm' ? 'Marks' : 'GPA');

            document.getElementById("sscRegDisp").value = s.sscRegNo || '';
            document.getElementById("boardDisp").value = board;
            document.getElementById("sscYearDisp").value = s.sscYear || '';
            document.getElementById("ssc_month").value = s.sscMonth || '';
            document.getElementById("name").value = s.name || '';
            document.getElementById("fname").value = s.fname || '';
            document.getElementById("mname").value = s.mname || '';
            setRadio("gender", s.gender || '');
            document.getElementById("appdob").value = s.dob ? String(s.dob).substring(0, 10) : '';
            document.getElementById("adarno").value = s.adarno || '';
            document.getElementById("phno").value = s.phno || '';
            document.getElementById("email").value = s.email || '';
            document.getElementById("addr").value = s.addr || '';
            document.getElementById("pincode").value = s.pincode || '';
            document.getElementById("local").value = s.local || '';
            document.getElementById("pwdCategory").value = (s.pwdCategory && s.pwdCategory !== 'N') ? s.pwdCategory : '';
            document.getElementById("ssc").value = s.sscPassed === true ? 'yes' : (s.sscPassed === false ? 'no' : '');

            if (s.caste) {
                $('#casteSelect').val(s.caste);
                loadSubCastes(s.subCaste);
            }

            setRadio("phc", s.phc === true ? 'yes' : (s.phc === false ? 'no' : ''));
            setRadio("exs", s.exservice === true ? 'yes' : (s.exservice === false ? 'no' : ''));
            setRadio("ews", s.economicWeakerSection === true ? 'yes' : (s.economicWeakerSection === false ? 'no' : ''));

            // Load existing photo
            $.get('${backendBaseUrl}/api/student/photo/' + s.regid, function (r) {
                var img = document.getElementById("existingPhoto");
                var noPhotoText = document.getElementById("noPhotoText");
                if (r && r.photo) {
                    img.src = 'data:image/jpeg;base64,' + r.photo;
                    img.style.display = 'block';
                    noPhotoText.style.display = 'none';
                } else {
                    img.style.display = 'none';
                    noPhotoText.style.display = 'inline';
                }
            });
        }

        function radioVal(name) {
            var els = document.getElementsByName(name);
            for (var i = 0; i < els.length; i++) {
                if (els[i].checked) { return els[i].value; }
            }
            return "";
        }

        function setRadio(name, value) {
            var els = document.getElementsByName(name);
            for (var i = 0; i < els.length; i++) {
                els[i].checked = (els[i].value === value);
            }
        }

        function previewPhoto(input) {
            var box = document.getElementById("photoPrevBox");
            box.innerHTML = "";
            if (!input || !input.files || input.files.length === 0) {
                box.innerHTML = '<span class="text-muted small">Select below</span>';
                return;
            }
            var file = input.files[0];
            if (file.type !== "image/png" && file.type !== "image/jpeg") {
                input.value = "";
                alert("Please select a PNG or JPEG image.");
                box.innerHTML = '<span class="text-muted small">Select below</span>';
                return;
            }
            var img = document.createElement("img");
            img.src = URL.createObjectURL(file);
            img.style.width = "100%";
            img.style.height = "100%";
            img.style.objectFit = "cover";
            box.appendChild(img);
        }

        function loadCastes() {
            $.get('${backendBaseUrl}/api/student/castes', function (list) {
                $.each(list, function (i, c) {
                    $('#casteSelect').append('<option value="' + c.casteCode + '">' + c.casteName + '</option>');
                });
            });
        }

        function loadSubCastes(preselect) {
            var code = document.getElementById("casteSelect").value;
            var sel = document.getElementById("subCasteSelect");
            sel.innerHTML = '<option value="">--Select Sub Category--</option>';
            if (!code) { return; }
            $.get('${backendBaseUrl}/api/student/subcastes/' + encodeURIComponent(code))
                .done(function (list) {
                    (list || []).forEach(function (r) {
                        var label = (r.subCasteName && r.subCasteName !== '') ? r.subCasteName : ('Sub-caste ' + r.subCasteId);
                        var opt = document.createElement('option');
                        opt.value = r.subCasteId;
                        opt.textContent = label + ' (' + r.subCasteId + ')';
                        if (preselect && String(preselect) === String(r.subCasteId)) {
                            opt.selected = true;
                        }
                        sel.appendChild(opt);
                    });
                });
        }

        function validateEdit() {
            var req = [
                ["name", "Applicant's Name"],
                ["fname", "Father's Name"],
                ["mname", "Mother's Name"],
                ["appdob", "Date of Birth"],
                ["phno", "Mobile Number"],
                ["addr", "Address"],
                ["pincode", "Pincode"],
                ["local", "Local/Non-Local"],
                ["casteSelect", "Caste"]
            ];
            for (var i = 0; i < req.length; i++) {
                var el = document.getElementById(req[i][0]);
                if (!el.value || !el.value.trim()) {
                    alert("Please enter " + req[i][1] + ".");
                    el.focus();
                    return false;
                }
            }
            if (!radioVal("gender")) {
                alert("Please select Gender.");
                return false;
            }
            if (!/^\d{10}$/.test(document.getElementById("phno").value.trim())) {
                alert("Mobile Number must be 10 digits.");
                document.getElementById("phno").focus();
                return false;
            }
            var ad = document.getElementById("adarno").value.trim();
            if (ad !== "" && !/^\d{12}$/.test(ad)) {
                alert("Aadhaar Card Number must be 12 digits.");
                document.getElementById("adarno").focus();
                return false;
            }
            var pin = document.getElementById("pincode").value.trim();
            if (pin !== "" && !/^\d{6}$/.test(pin)) {
                alert("Pincode must be 6 digits.");
                document.getElementById("pincode").focus();
                return false;
            }
            return true;
        }

        function submitEdit() {
            if (!validateEdit()) return false;

            var saveBtn = $("#saveEditBtn");
            saveBtn.prop("disabled", true).html('<i class="fas fa-spinner fa-spin me-1"></i> Saving Changes...');

            var fileInput = document.getElementById("photo");
            var hasPhoto = fileInput && fileInput.files && fileInput.files.length > 0;
            if (hasPhoto) {
                var fd = new FormData();
                fd.append("photo", fileInput.files[0]);
                $.ajax({
                    url: '${backendBaseUrl}/api/student/photo/' + CURRENT_REGID,
                    type: 'POST',
                    data: fd,
                    processData: false,
                    contentType: false,
                    success: function () {
                        updateDetails();
                    },
                    error: function (xhr) {
                        saveBtn.prop("disabled", false).html('<i class="fas fa-save me-1"></i> Save Changes');
                        var msg = "Failed to upload the photograph.";
                        if (xhr.responseJSON && xhr.responseJSON.error) { msg = xhr.responseJSON.error; }
                        alert(msg);
                    }
                });
            } else {
                updateDetails();
            }
            return false;
        }

        function updateDetails() {
            var saveBtn = $("#saveEditBtn");
            var payload = {
                name: document.getElementById("name").value.trim(),
                fname: document.getElementById("fname").value.trim(),
                mname: document.getElementById("mname").value.trim(),
                gender: radioVal("gender"),
                dob: document.getElementById("appdob").value,
                adarno: document.getElementById("adarno").value.trim(),
                phno: document.getElementById("phno").value.trim(),
                email: document.getElementById("email").value.trim(),
                addr: document.getElementById("addr").value.trim(),
                pincode: document.getElementById("pincode").value.trim(),
                caste: document.getElementById("casteSelect").value,
                subCaste: document.getElementById("subCasteSelect").value,
                local: document.getElementById("local").value,
                sscMonth: document.getElementById("ssc_month").value,
                pwdCategory: document.getElementById("pwdCategory").value,
                sscPassed: document.getElementById("ssc").value === "" ? null : document.getElementById("ssc").value === 'yes',
                economicWeakerSection: radioVal("ews") === "yes",
                phc: radioVal("phc") === "yes",
                exservice: radioVal("exs") === "yes"
            };

            $.ajax({
                url: '${backendBaseUrl}/api/student/update/' + CURRENT_REGID,
                type: 'PUT',
                contentType: 'application/json',
                data: JSON.stringify(payload),
                success: function () {
                    saveBtn.prop("disabled", false).html('<i class="fas fa-save me-1"></i> Save Changes');

                    var resultHtml = '<div class="result-card">'
                        + '<i class="fas fa-check-circle" style="font-size: 3.5rem; color: #16a34a;"></i>'
                        + '<h3 class="mt-3 fw-bold" style="color: #14532d;">Registration Details Updated!</h3>'
                        + '<p class="text-muted">Your registration details have been updated successfully for Registration ID <b>' + CURRENT_REGID + '</b>.</p>'
                        + '<div class="d-flex flex-wrap gap-2 justify-content-center mt-4">'
                        + '  <a href="${pageContext.request.contextPath}/student-apply" class="btn btn-primary-custom">'
                        + '    <i class="fas fa-paper-plane me-1"></i> Apply for ITI'
                        + '  </a>'
                        + '  <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">'
                        + '    <i class="fas fa-home me-1"></i> Back to Home'
                        + '  </a>'
                        + '</div>'
                        + '</div>';

                    $("#editDiv").hide();
                    $("#editResult").html(resultHtml).slideDown('fast');
                    window.scrollTo(0, 0);
                },
                error: function (xhr) {
                    saveBtn.prop("disabled", false).html('<i class="fas fa-save me-1"></i> Save Changes');
                    var msg = (xhr.responseJSON && xhr.responseJSON.message) ? xhr.responseJSON.message
                        : "Failed to update details. Please check the values and try again.";
                    alert(msg);
                }
            });
        }

        $(document).ready(function () {
            loadCastes();
            $.get('${backendBaseUrl}/api/reports/current-admission-phase', function (data) {
                if (data && data.year) {
                    $('.sessionYearPhase').text(String(data.year) + ' (Phase-' + data.phase + ')');
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
