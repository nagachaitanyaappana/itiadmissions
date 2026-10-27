<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Student Registration | ITI Admission Portal</title>
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
        }

        /* ===== STEP 1: REGISTRATION CARD (UnifiedApp design) ===== */
        .registration-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.1);
            padding: 35px 32px;
            margin: 40px auto;
            max-width: 560px;
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
            font-size: 1.75rem;
        }

        .header-subtitle {
            color: #2f6fa5;
            font-size: 1rem;
            font-weight: 600;
            margin-bottom: 28px;
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

        .registration-card .form-control,
        .registration-card .form-select {
            border-radius: 10px;
            border: 1px solid #cbd5e1;
            padding: 10px 14px;
            font-size: 0.95rem;
            color: #0f172a;
            background-color: #f8fafc;
            transition: all 0.2s ease;
        }

        .registration-card .form-control:focus,
        .registration-card .form-select:focus {
            background-color: #ffffff;
            border-color: #2f6fa5;
            box-shadow: 0 0 0 4px rgba(47, 111, 165, 0.15);
            outline: none;
        }

        .captcha-container {
            display: flex;
            gap: 10px;
            align-items: stretch;
        }

        .captcha-refresh {
            background-color: #e0f2fe;
            color: #0284c7;
            border: 1px solid #bae6fd;
            border-radius: 10px;
            width: 50px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.2s;
        }

        .captcha-refresh:hover {
            background-color: #bae6fd;
            color: #0c4a6e;
        }

        .captcha-box {
            color: #0f172a;
            font-family: 'Courier New', Courier, monospace;
            font-size: 1.6rem;
            font-weight: 800;
            letter-spacing: 8px;
            border-radius: 10px;
            flex-grow: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            user-select: none;
            background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
            padding: 0 10px;
            border: 1px solid #a5b4fc;
            text-align: center;
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
        }

        .btn-secondary-custom:hover {
            background-color: #e2e8f0;
            color: #0f172a !important;
        }

        .buttons-row {
            display: flex;
            gap: 12px;
            margin-top: 30px;
        }

        .buttons-row button,
        .buttons-row a {
            flex: 1;
            display: flex;
            justify-content: center;
            align-items: center;
            gap: 8px;
        }

        .error-msg {
            color: #ef4444;
            font-size: 0.8rem;
            font-weight: 500;
            margin-top: 4px;
            display: block;
        }

        /* ===== ALREADY REGISTERED CARD ===== */
        .registration-exists-card {
            background: #ffffff;
            border-radius: 20px;
            box-shadow: 0 15px 50px rgba(0, 0, 0, 0.1);
            padding: 40px 35px;
            margin: 40px auto;
            max-width: 620px;
            border-top: 6px solid #2f6fa5;
            text-align: center;
        }

        .exists-icon {
            font-size: 3rem;
            color: #2f6fa5;
            margin-bottom: 12px;
        }

        .reg-id-badge {
            background: #eef4fa;
            border: 2px dashed #2f6fa5;
            border-radius: 10px;
            padding: 12px 24px;
            display: inline-block;
            margin: 18px 0;
        }

        .reg-id-number {
            color: #195695;
            font-size: 1.6rem;
            font-weight: 800;
            letter-spacing: 2px;
            margin-left: 6px;
        }

        /* ===== STEP 2: FULL REGISTRATION FORM (UnifiedApp Step 1) ===== */
        .form-header {
            background-color: #2f6fa5;
            color: white;
            padding: 12px 16px;
            text-align: center;
            font-weight: bold;
            font-size: 1.15rem;
            border: 2px solid #2f6fa5;
            border-top-left-radius: 10px;
            border-top-right-radius: 10px;
        }

        .form-warning {
            background-color: #eef4fa;
            padding: 10px 16px;
            border: 2px solid #2f6fa5;
            border-top: none;
            border-bottom: none;
            font-size: 0.88rem;
            font-weight: 600;
            color: #1e3a8a;
        }

        .form-table {
            width: 100%;
            border-collapse: collapse;
            border: 2px solid #2f6fa5;
            background-color: #fff;
        }

        .form-table td {
            border: 1px solid #2f6fa5;
            padding: 7px 10px;
            vertical-align: middle;
        }

        .form-table td.label-cell {
            background-color: #eef4fa;
            color: #195695;
            font-weight: 600;
            width: 20%;
            font-size: 0.86rem;
        }

        .form-table td.label-cell span {
            color: #ef4444;
            margin-left: 2px;
        }

        .form-table td.input-cell {
            width: 30%;
            background-color: #fcfcfc;
        }

        .form-table .form-control,
        .form-table .form-select {
            border: 1px solid #a6b8c7;
            border-radius: 4px;
            padding: 6px 9px;
            font-size: 0.86rem;
            width: 100%;
        }

        .form-table .form-control:focus,
        .form-table .form-select:focus {
            border-color: #2f6fa5;
            box-shadow: 0 0 0 3px rgba(47, 111, 165, 0.2);
            outline: none;
        }

        .form-table input[type="radio"] {
            margin-right: 4px;
        }

        .form-table label {
            margin-right: 14px;
            font-weight: normal;
            font-size: 0.86rem;
            color: #333;
            cursor: pointer;
        }

        .marks-section {
            background-color: #eef4fa;
            padding: 18px;
            border: 2px solid #2f6fa5;
            border-top: none;
            text-align: center;
        }

        .marks-table {
            margin: 15px auto;
            width: 100%;
            max-width: 480px;
            text-align: left;
            font-size: 0.88rem;
            border-collapse: collapse;
            border: 1px solid #2f6fa5;
            background: #ffffff;
        }

        .marks-table th {
            background-color: #2f6fa5;
            color: #ffffff;
            padding: 8px 12px;
            font-weight: 600;
            border: 1px solid #2f6fa5;
        }

        .marks-table td {
            padding: 6px 10px;
            border: 1px solid #2f6fa5;
        }

        .photo-declaration-table {
            width: 100%;
            border-collapse: collapse;
            border: 2px solid #2f6fa5;
            border-top: none;
            background-color: #eef4fa;
            border-bottom-left-radius: 10px;
            border-bottom-right-radius: 10px;
            overflow: hidden;
        }

        #photoPreviewContainer {
            width: 110px;
            height: 130px;
            border: 2px dashed #a6b8c7;
            border-radius: 6px;
            margin: 8px auto;
            display: flex;
            align-items: center;
            justify-content: center;
            background: #fafafa;
            overflow: hidden;
        }

        .btn-apply-now {
            background: linear-gradient(135deg, #2f6fa5, #1e4f7a);
            color: #ffffff !important;
            padding: 10px 45px;
            font-weight: 700;
            font-size: 1rem;
            border-radius: 6px;
            border: none;
            box-shadow: 0 4px 15px rgba(47, 111, 165, 0.35);
            transition: all 0.2s;
        }

        .btn-apply-now:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(47, 111, 165, 0.45);
            color: #ffffff !important;
        }

        /* Modal styling */
        .modal-header-custom {
            background-color: #2f6fa5;
            color: #ffffff;
        }

        .review-table td {
            padding: 6px 12px;
            font-size: 0.9rem;
        }

        .review-table td:first-child {
            font-weight: 600;
            color: #195695;
            width: 40%;
        }
    </style>
</head>
<body>

    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <%@ include file="_windowGate.jsp" %>

    <main class="py-4">
        <div class="container">

            <!-- Global Alert Container -->
            <div id="globalAlert" class="mb-3"></div>

            <!-- ========================================== -->
            <!-- STEP 1: REGISTRATION CARD (UnifiedApp UI)   -->
            <!-- ========================================== -->
            <div id="step1Div">
                <div class="registration-card">
                    <h2 class="header-title">
                        <i class="fas fa-user-graduate"></i> ITI Admission Portal
                    </h2>
                    <p class="header-subtitle">Start Your <strong>Registration</strong> Journey</p>

                    <form id="step1Form" onsubmit="return false;">
                        <div class="mb-3">
                            <label class="form-label" for="ssc_board">SSC / 10th Board<span class="req">*</span></label>
                            <select class="form-select" id="ssc_board" name="ssc_board" onchange="clearError('ssc_boardError')">
                                <option value="">--Select Board Here--</option>
                                <option value="28" selected>Andhra Pradesh State Board (SSC)</option>
                                <option value="35">Andman & Nicobar Islands State Board</option>
                                <option value="54">AP-OSC</option>
                                <option value="53">AP-OSSC</option>
                                <option value="12">Arunachal Pradesh State Board</option>
                                <option value="18">Assam State Board</option>
                                <option value="10">Bihar State Board</option>
                                <option value="51">CBSE</option>
                                <option value="4">Chandigarh State Board</option>
                                <option value="22">Chhattisgarh State Board</option>
                                <option value="26">Dadra & Nagar Haveli State Board</option>
                                <option value="25">Daman & Diu State Board</option>
                                <option value="7">Delhi State Board</option>
                                <option value="30">Goa State Board</option>
                                <option value="24">Gujarat State Board</option>
                                <option value="6">Haryana State Board</option>
                                <option value="2">Himachal Pradesh State Board</option>
                                <option value="52">ICSE</option>
                                <option value="1">Jammu & Kashmir State Board</option>
                                <option value="20">Jharkhand State Board</option>
                                <option value="29">Karnataka State Board</option>
                                <option value="32">Kerala State Board</option>
                                <option value="31">Lakshadweep State Board</option>
                                <option value="23">Madhya Pradesh State Board</option>
                                <option value="27">Maharashtra State Board</option>
                                <option value="14">Manipur State Board</option>
                                <option value="17">Meghalaya State Board</option>
                                <option value="15">Mizoram State Board</option>
                                <option value="13">Nagaland State Board</option>
                                <option value="21">Orissa State Board</option>
                                <option value="60">Other</option>
                                <option value="34">Pondicherry State Board</option>
                                <option value="3">Punjab State Board</option>
                                <option value="8">Rajasthan State Board</option>
                                <option value="11">Sikkim State Board</option>
                                <option value="33">Tamil nadu State Board</option>
                                <option value="36">Telangana</option>
                                <option value="16">Tripura State Board</option>
                                <option value="5">Uttarakhand State Board</option>
                                <option value="9">Utter Pradesh State Board</option>
                                <option value="19">West Bengal State Board</option>
                            </select>
                            <span id="ssc_boardError" class="error-msg"></span>
                        </div>

                        <div class="mb-3">
                            <label class="form-label" for="ssc_regno">Hall Ticket Number<span class="req">*</span></label>
                            <input type="text" class="form-control" name="ssc_regno" id="ssc_regno"
                                onchange="clearError('ssc_regnoError')" maxlength="15"
                                placeholder="Enter Hall Ticket Number" />
                            <span id="ssc_regnoError" class="error-msg"></span>
                        </div>

                        <div class="row mb-3">
                            <div class="col-6">
                                <label class="form-label" for="passed_year">Year of Passing<span class="req">*</span></label>
                                <input type="text" class="form-control" name="passed_year" id="passed_year"
                                    onchange="clearError('passed_yearError')" maxlength="4"
                                    placeholder="e.g. 2024" onkeypress="return numericsOnly(event);" />
                                <span id="passed_yearError" class="error-msg"></span>
                            </div>
                            <div class="col-6">
                                <label class="form-label" for="ssc_type">Result Type<span class="req">*</span></label>
                                <select class="form-select" name="ssc_type" id="ssc_type"
                                    onchange="clearError('ssc_typeError')">
                                    <option value="">--Select--</option>
                                    <option value="sscm">Marks</option>
                                    <option value="sscg">GPA</option>
                                </select>
                                <span id="ssc_typeError" class="error-msg"></span>
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label" for="captchaInput">Captcha<span class="req">*</span></label>
                            <div class="captcha-container">
                                <button type="button" class="captcha-refresh" onclick="loadCaptcha();" title="Refresh Captcha">
                                    <i class="fas fa-sync-alt"></i>
                                </button>
                                <input type="text" id="mainCaptcha" readonly="readonly" class="form-control captcha-box" />
                                <input type="text" id="captchaInput" class="form-control" maxlength="4"
                                    autocomplete="off" onchange="clearError('captchaErr')"
                                    placeholder="Enter Captcha" style="flex-grow: 1;" />
                            </div>
                            <span id="captchaErr" class="error-msg"></span>
                        </div>

                        <div class="buttons-row">
                            <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">
                                <i class="fas fa-home"></i> Home
                            </a>
                            <button type="button" class="btn btn-primary-custom" id="step1SubmitBtn" onclick="submitStep1();">
                                Proceed <i class="fas fa-arrow-right"></i>
                            </button>
                            <button type="reset" class="btn btn-secondary-custom" onclick="resetStep1();">
                                Reset
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- ALREADY REGISTERED CARD                    -->
            <!-- ========================================== -->
            <div id="alreadyRegisteredDiv" style="display: none;">
                <div class="registration-exists-card">
                    <div class="exists-icon">
                        <i class="fas fa-id-card"></i>
                    </div>
                    <h3 class="fw-bold mb-2 text-primary">Already Registered</h3>
                    <p class="text-muted mb-2">An application already exists for SSC Hall Ticket Number: <b id="existHallTicket"></b></p>
                    <div class="reg-id-badge">
                        <span>Your Registration ID is:</span>
                        <span class="reg-id-number" id="existRegId"></span>
                    </div>
                    <p class="text-secondary small mt-2 px-md-4" style="line-height: 1.6;">
                        You are already registered for this admission session. If you wish to select or update your ITI / Trade choices, please proceed to <b>Trade Selection</b>. If you need to edit your details, use <b>Edit Details</b>.
                    </p>
                    <div class="d-flex justify-content-center gap-3 mt-4 flex-wrap">
                        <a href="${pageContext.request.contextPath}/student-apply" class="btn btn-primary-custom">
                            <i class="fas fa-clipboard-check"></i> Go to Trade Selection (Apply)
                        </a>
                        <a href="${pageContext.request.contextPath}/student-edit-details" class="btn btn-secondary-custom">
                            <i class="fas fa-edit"></i> Edit Application Details
                        </a>
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">
                            <i class="fas fa-home"></i> Home
                        </a>
                    </div>
                </div>
            </div>

            <!-- ========================================== -->
            <!-- STEP 2: FULL REGISTRATION FORM             -->
            <!-- ========================================== -->
            <div id="step2Div" style="display: none;">
                <form id="step2Form" onsubmit="return false;">
                    <div class="form-header">
                        Registration Form for Admission into the Industrial Training Institute for the session <span id="sessionYearPhase">2026(Phase-2)</span>
                    </div>
                    <div class="form-warning">
                        <i class="fas fa-exclamation-triangle me-1"></i> Attention: Enter data carefully. If any information is found incorrect in Marks/GPA, Caste, etc., the authority has the right to disqualify for admissions.
                    </div>

                    <table class="form-table">
                        <!-- Row 1 -->
                        <tr>
                            <td class="label-cell">Hall Ticket Number<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" class="form-control" id="s2_ssc_regno" readonly tabindex="-1" style="background-color: #e9ecef;" />
                            </td>
                            <td class="label-cell">Board<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" class="form-control" id="s2_board_disp" readonly tabindex="-1" style="background-color: #e9ecef;" />
                                <input type="hidden" id="s2_board_code" />
                            </td>
                        </tr>

                        <!-- Row 2 -->
                        <tr>
                            <td class="label-cell">Year of Pass<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" class="form-control" id="s2_ssc_year" readonly tabindex="-1" style="background-color: #e9ecef;" />
                            </td>
                            <td class="label-cell">Month of Pass<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" id="ssc_month" onchange="clearError('ssc_monthError')">
                                    <option value="">-select-</option>
                                    <option value="03" selected>March</option>
                                    <option value="04">Supplementary</option>
                                </select>
                                <span id="ssc_monthError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 3 -->
                        <tr>
                            <td class="label-cell">Applicant's Name<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" id="name" class="form-control" maxlength="50"
                                    onchange="clearError('nameError')" oninput="this.value = this.value.toUpperCase();"
                                    placeholder="Full Name as per SSC" />
                                <span id="nameError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Mobile Number<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" id="phno" class="form-control" maxlength="10"
                                    onchange="clearError('phnoError')" onkeypress="return numericsOnly(event);"
                                    placeholder="10-digit Mobile Number" />
                                <span id="phnoError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 4 -->
                        <tr>
                            <td class="label-cell">Date of Birth (dd-mm-yyyy)<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="date" id="dob" class="form-control" onchange="clearError('dobError')" />
                                <span id="dobError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Aadhaar Card Number<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" id="adarno" class="form-control" maxlength="12"
                                    onkeypress="return numericsOnly(event);" onchange="validateAadhaarInput();"
                                    placeholder="12-digit Aadhaar Number" autocomplete="off" />
                                <span id="adarnoError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 5 -->
                        <tr>
                            <td class="label-cell">Gender<span>*</span>:</td>
                            <td class="input-cell pt-2 pb-2">
                                <label><input type="radio" name="gender" value="male" onchange="clearError('genderError')"> Male</label>
                                <label><input type="radio" name="gender" value="female" onchange="clearError('genderError')"> Female</label>
                                <span id="genderError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Category (Caste)<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" id="casteSelect" onchange="loadSubCastes(); clearError('casteSelectError');">
                                    <option value="">--Select Caste--</option>
                                </select>
                                <span id="casteSelectError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 6 -->
                        <tr>
                            <td class="label-cell">Father Name<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" id="fname" class="form-control" maxlength="50"
                                    onchange="clearError('fnameError')" oninput="this.value = this.value.toUpperCase();"
                                    placeholder="Father's Full Name" />
                                <span id="fnameError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Sub Category (Sub Caste):</td>
                            <td class="input-cell">
                                <select class="form-select" id="subCasteSelect" onchange="clearError('subCasteSelectError')">
                                    <option value="">-- Select Sub Category --</option>
                                </select>
                                <span id="subCasteSelectError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 7 -->
                        <tr>
                            <td class="label-cell">Mother's Name<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" id="mname" class="form-control" maxlength="50"
                                    onchange="clearError('mnameError')" oninput="this.value = this.value.toUpperCase();"
                                    placeholder="Mother's Full Name" />
                                <span id="mnameError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Physically Challenged<span>*</span>:</td>
                            <td class="input-cell pt-2 pb-2">
                                <label><input type="radio" name="phc" value="yes" onchange="togglePhc(true); clearError('phcError');"> Yes</label>
                                <label><input type="radio" name="phc" value="no" value="no" checked onchange="togglePhc(false); clearError('phcError');"> No</label>
                                <span id="phcError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 8 -->
                        <tr>
                            <td class="label-cell">PWD Category:</td>
                            <td class="input-cell">
                                <select class="form-select" id="pwdCategory" disabled onchange="clearError('pwdCategoryError')">
                                    <option value="">--- Select ---</option>
                                    <option value="1">Blind</option>
                                    <option value="2">Deaf</option>
                                    <option value="3">Motor Disability</option>
                                    <option value="4">Mental Disability</option>
                                </select>
                                <span id="pwdCategoryError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Ex-Servicemen<span>*</span>:</td>
                            <td class="input-cell pt-2 pb-2">
                                <label><input type="radio" name="exs" value="yes" onchange="clearError('exsError')"> Yes</label>
                                <label><input type="radio" name="exs" value="no" checked onchange="clearError('exsError')"> No</label>
                                <span id="exsError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 9 -->
                        <tr>
                            <td class="label-cell">Qualification<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" id="ssc" onchange="toggleInter(this.value); clearError('sscError');">
                                    <option value="">-Select-</option>
                                    <option value="SSC" selected>SSC Passed</option>
                                    <option value="Inter">Inter Passed</option>
                                    <option value="8th">8th Passed</option>
                                </select>
                                <span id="sscError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Local / Non-Local<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" id="local" onchange="clearError('localError')">
                                    <option value="">-select-</option>
                                    <option value="Local" selected>Local</option>
                                    <option value="NonLocal">Non-Local</option>
                                </select>
                                <span id="localError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Inter Marks Row (Hidden by default) -->
                        <tr id="interMarksRow" style="display: none;">
                            <td class="label-cell">Inter Marks<span>*</span>:</td>
                            <td class="input-cell" colspan="3">
                                <input type="text" class="form-control" id="inter_marks" maxlength="4"
                                    placeholder="Enter Inter Total Marks" style="max-width: 250px;"
                                    onkeypress="return numericsOnly(event);" onchange="clearError('interMarksError')" />
                                <span id="interMarksError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 10 -->
                        <tr>
                            <td class="label-cell">Address<span>*</span>:</td>
                            <td class="input-cell">
                                <textarea rows="2" class="form-control" id="addr" onchange="clearError('addrError')"
                                    placeholder="Permanent Address" style="resize: none;"></textarea>
                                <span id="addrError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Pincode<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" id="pincode" class="form-control" maxlength="6"
                                    onkeypress="return numericsOnly(event);" onchange="clearError('pincodeError')"
                                    placeholder="6-digit Pincode" />
                                <span id="pincodeError" class="error-msg"></span>
                            </td>
                        </tr>

                        <!-- Row 11 -->
                        <tr>
                            <td class="label-cell">Email ID<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="email" id="email" class="form-control" maxlength="80"
                                    onchange="clearError('emailError')" placeholder="e.g. applicant@email.com" />
                                <span id="emailError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Economic Weaker Section (EWS)<span>*</span>:</td>
                            <td class="input-cell pt-2 pb-2">
                                <label><input type="radio" name="ews" value="yes" onchange="clearError('ewsError')"> Yes</label>
                                <label><input type="radio" name="ews" value="no" checked onchange="clearError('ewsError')"> No</label>
                                <span id="ewsError" class="error-msg"></span>
                            </td>
                        </tr>
                    </table>

                    <!-- MARKS SECTION (UnifiedApp Step 1) -->
                    <div class="marks-section">
                        <div class="d-inline-block text-center mb-2">
                            <label class="fw-bold text-primary me-2">Number of Languages<span class="text-danger">*</span>:</label>
                            <label><input type="radio" name="noOfLangs" value="2" onchange="setLanguages('2')"> Two</label>
                            <label><input type="radio" name="noOfLangs" value="3" checked onchange="setLanguages('3')"> Three</label>
                        </div>

                        <table class="marks-table">
                            <thead>
                                <tr>
                                    <th style="width: 12%; text-align: center;">SNO</th>
                                    <th style="width: 53%;">Subjects</th>
                                    <th style="width: 35%; text-align: center;" id="marksHeaderLabel">Marks</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr>
                                    <td class="text-center">1</td>
                                    <td>First Language</td>
                                    <td>
                                        <input type="text" id="m_firstlang" class="form-control text-center form-control-sm"
                                            maxlength="4" oninput="calculateTotal(); clearError('m_firstlangError');" />
                                        <span id="m_firstlangError" class="error-msg"></span>
                                    </td>
                                </tr>
                                <tr id="secondLangRow">
                                    <td class="text-center">2</td>
                                    <td>Second Language</td>
                                    <td>
                                        <input type="text" id="m_secondlang" class="form-control text-center form-control-sm"
                                            maxlength="4" oninput="calculateTotal(); clearError('m_secondlangError');" />
                                        <span id="m_secondlangError" class="error-msg"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="text-center">3</td>
                                    <td>Third Language - English</td>
                                    <td>
                                        <input type="text" id="m_english" class="form-control text-center form-control-sm"
                                            maxlength="4" oninput="calculateTotal(); clearError('m_englishError');" />
                                        <span id="m_englishError" class="error-msg"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="text-center">4</td>
                                    <td>Mathematics</td>
                                    <td>
                                        <input type="text" id="m_math" class="form-control text-center form-control-sm"
                                            maxlength="4" oninput="calculateTotal(); clearError('m_mathError');" />
                                        <span id="m_mathError" class="error-msg"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="text-center">5</td>
                                    <td>General Science</td>
                                    <td>
                                        <input type="text" id="m_science" class="form-control text-center form-control-sm"
                                            maxlength="4" oninput="calculateTotal(); clearError('m_scienceError');" />
                                        <span id="m_scienceError" class="error-msg"></span>
                                    </td>
                                </tr>
                                <tr>
                                    <td class="text-center">6</td>
                                    <td>Social Studies</td>
                                    <td>
                                        <input type="text" id="m_social" class="form-control text-center form-control-sm"
                                            maxlength="4" oninput="calculateTotal(); clearError('m_socialError');" />
                                        <span id="m_socialError" class="error-msg"></span>
                                    </td>
                                </tr>
                                <tr style="background-color: #f1f5f9; font-weight: bold;">
                                    <td colspan="2" class="text-end pe-3" id="totalLabel">Total Marks:</td>
                                    <td>
                                        <input type="text" id="total_marks" class="form-control text-center form-control-sm fw-bold"
                                            readonly tabindex="-1" style="background-color: #e2e8f0;" />
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- PHOTO & DECLARATION SECTION (UnifiedApp Step 1) -->
                    <table class="photo-declaration-table">
                        <tr>
                            <td style="width: 28%; padding: 16px; border-right: 1px solid #2f6fa5; text-align: center; vertical-align: top; background: white;">
                                <div style="font-size: 0.9rem; font-weight: 700; color: #195695; margin-bottom: 6px;">
                                    Upload Photo<span class="text-danger">*</span>:
                                </div>
                                <input type="file" id="photo" name="photo" accept="image/png, image/jpeg, image/jpg"
                                    class="form-control form-control-sm mb-2" onchange="previewPhoto(this);" />
                                <span id="photoError" class="error-msg mb-2"></span>

                                <div id="photoPreviewContainer">
                                    <img id="photoPreview" src="" alt="Preview" style="max-width: 100%; max-height: 100%; display: none;" />
                                    <span id="photoPlaceholder" style="font-size: 0.75rem; color: #94a3b8;">
                                        <i class="fas fa-camera fa-2x mb-1 d-block"></i>No image
                                    </span>
                                </div>
                                <div style="font-size: 0.72rem; color: #dc2626; margin-top: 6px; font-weight: 600;">
                                    Size: 10KB to 200KB. Formats: JPG / PNG only.
                                </div>
                            </td>

                            <td style="width: 72%; padding: 24px; vertical-align: top;">
                                <div class="p-3 bg-white rounded border d-flex gap-3 align-items-start shadow-sm">
                                    <input type="checkbox" id="consent" class="form-check-input mt-1" onchange="clearError('consentError')" />
                                    <label for="consent" style="font-size: 0.88rem; color: #334155; line-height: 1.5; margin: 0; cursor: pointer;">
                                        <strong>Above information is correct to the best of my knowledge</strong> and I hereby give my consent to the use of Aadhaar Number provided in the application to carry out identity verification for the admission process. If any information is found incorrect, the authority has the right to cancel my admission at any time without prior notice.
                                    </label>
                                </div>
                                <span id="consentError" class="error-msg ms-2"></span>

                                <div class="text-center mt-4">
                                    <button type="button" class="btn btn-apply-now" onclick="confirmBeforeSubmit();">
                                        APPLY NOW <i class="fas fa-paper-plane ms-2"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                    </table>
                </form>
            </div>

            <!-- ========================================== -->
            <!-- SUCCESS CARD                               -->
            <!-- ========================================== -->
            <div id="successDiv" style="display: none;">
                <div class="registration-exists-card" style="border-top-color: #16a34a;">
                    <div class="exists-icon" style="color: #16a34a;">
                        <i class="fas fa-check-circle"></i>
                    </div>
                    <h3 class="fw-bold mb-2 text-success">Registration Successful!</h3>
                    <p class="text-muted">Your application details and SSC marks have been successfully saved.</p>
                    <div class="reg-id-badge" style="border-color: #16a34a; background-color: #f0fdf4;">
                        <span style="color: #15803d;">Your Registration ID is:</span>
                        <span class="reg-id-number" id="successRegId" style="color: #15803d;"></span>
                    </div>
                    <p class="text-secondary small mt-2 px-md-4">
                        Please note down your Registration ID for future reference. Now click the button below to proceed to Step 2 to select your ITIs and trades.
                    </p>
                    <div class="d-flex justify-content-center gap-3 mt-4 flex-wrap">
                        <a href="${pageContext.request.contextPath}/student-apply" class="btn btn-primary-custom" style="background: linear-gradient(135deg, #16a34a, #15803d);">
                            Continue to Step 2: Trade Selection <i class="fas fa-arrow-right ms-1"></i>
                        </a>
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">
                            <i class="fas fa-home"></i> Home
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </main>

    <!-- ========================================== -->
    <!-- CONFIRMATION REVIEW MODAL                  -->
    <!-- ========================================== -->
    <div class="modal fade" id="confirmModal" tabindex="-1" aria-labelledby="confirmModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div class="modal-content">
                <div class="modal-header modal-header-custom">
                    <h5 class="modal-title fw-bold" id="confirmModalLabel">
                        <i class="fas fa-clipboard-check me-2"></i> Review Application Details Before Submission
                    </h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body p-4">
                    <p class="text-muted small mb-3">Please verify that all details entered below are accurate before final submission:</p>

                    <div class="table-responsive mb-3">
                        <table class="table table-bordered table-striped review-table">
                            <tbody>
                                <tr>
                                    <td>Hall Ticket Number:</td>
                                    <td id="c_sscregno"></td>
                                </tr>
                                <tr>
                                    <td>Board:</td>
                                    <td id="c_board"></td>
                                </tr>
                                <tr>
                                    <td>Year / Month of Pass:</td>
                                    <td><span id="c_year"></span> / <span id="c_month"></span></td>
                                </tr>
                                <tr>
                                    <td>Applicant Name:</td>
                                    <td id="c_name"></td>
                                </tr>
                                <tr>
                                    <td>Father's Name:</td>
                                    <td id="c_fname"></td>
                                </tr>
                                <tr>
                                    <td>Mother's Name:</td>
                                    <td id="c_mname"></td>
                                </tr>
                                <tr>
                                    <td>Date of Birth:</td>
                                    <td id="c_dob"></td>
                                </tr>
                                <tr>
                                    <td>Gender:</td>
                                    <td id="c_gender"></td>
                                </tr>
                                <tr>
                                    <td>Aadhaar Number:</td>
                                    <td id="c_adarno"></td>
                                </tr>
                                <tr>
                                    <td>Mobile Number:</td>
                                    <td id="c_phno"></td>
                                </tr>
                                <tr>
                                    <td>Email:</td>
                                    <td id="c_email"></td>
                                </tr>
                                <tr>
                                    <td>Category / Sub-Category:</td>
                                    <td><span id="c_caste"></span> / <span id="c_subcaste"></span></td>
                                </tr>
                                <tr>
                                    <td>Physically Challenged:</td>
                                    <td><span id="c_phc"></span> (<span id="c_pwd"></span>)</td>
                                </tr>
                                <tr>
                                    <td>Ex-Servicemen:</td>
                                    <td id="c_exs"></td>
                                </tr>
                                <tr>
                                    <td>Qualification:</td>
                                    <td id="c_qual"></td>
                                </tr>
                                <tr>
                                    <td>Local / Non-Local:</td>
                                    <td id="c_local"></td>
                                </tr>
                                <tr>
                                    <td>Economic Weaker Section (EWS):</td>
                                    <td id="c_ews"></td>
                                </tr>
                                <tr>
                                    <td>Address & Pincode:</td>
                                    <td><span id="c_addr"></span>, <span id="c_pincode"></span></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <h6 class="fw-bold text-primary mt-3 mb-2">Marks / GPA Summary:</h6>
                    <div class="table-responsive">
                        <table class="table table-bordered table-sm text-center">
                            <thead style="background-color: #2f6fa5; color: white;">
                                <tr>
                                    <th>Subject</th>
                                    <th id="c_marks_label">Marks / GPA</th>
                                </tr>
                            </thead>
                            <tbody>
                                <tr><td>First Language</td><td id="c_sub1"></td></tr>
                                <tr id="c_sub2_row"><td>Second Language</td><td id="c_sub2"></td></tr>
                                <tr><td>Third Language (English)</td><td id="c_sub3"></td></tr>
                                <tr><td>Mathematics</td><td id="c_sub4"></td></tr>
                                <tr><td>General Science</td><td id="c_sub5"></td></tr>
                                <tr><td>Social Studies</td><td id="c_sub6"></td></tr>
                                <tr class="fw-bold table-light">
                                    <td id="c_tot_label">Total</td>
                                    <td id="c_tot_val"></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary-custom" data-bs-dismiss="modal">
                        <i class="fas fa-edit me-1"></i> Edit Details
                    </button>
                    <button type="button" class="btn btn-primary-custom" id="finalSubmitBtn" onclick="submitFinalRegistration();">
                        <i class="fas fa-check-circle me-1"></i> Yes, Submit Application
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- ========================================== -->
    <!-- JAVASCRIPT LOGIC                           -->
    <!-- ========================================== -->
    <script type="text/javascript">
        var BACKEND_URL = "${backendBaseUrl}";
        var SESSION_YEAR = "2026";
        var CURRENT_REGID = null;
        var CURRENT_SSC_TYPE = "sscm"; // "sscm" or "sscg"
        var __castesLoaded = false;
        var confirmModalInstance = null;

        // Initialize Page
        $(document).ready(function () {
            // Load Captcha
            loadCaptcha();

            // Load Admission Phase info
            $.get(BACKEND_URL + '/api/reports/current-admission-phase', function (data) {
                if (data && data.year) {
                    SESSION_YEAR = String(data.year);
                    var phaseStr = SESSION_YEAR + "(Phase-" + (data.phase || '1') + ")";
                    $('#sessionYearPhase').text(phaseStr);
                }
            }).fail(function() {
                console.log("Could not load current admission phase info.");
            });

            // Auto uppercase for Hall Ticket
            $('#ssc_regno').on('input', function () {
                this.value = this.value.toUpperCase();
            });

            // Enter key on captcha triggers proceed
            $('#captchaInput').keypress(function (ev) {
                if (ev.keyCode === 13) {
                    submitStep1();
                }
            });

            // Bootstrap modal instance
            var modalEl = document.getElementById('confirmModal');
            if (modalEl) {
                confirmModalInstance = new bootstrap.Modal(modalEl);
            }
        });

        function clearError(errId) {
            $('#' + errId).text('');
        }

        function numericsOnly(evt) {
            var charCode = (evt.which) ? evt.which : event.keyCode;
            if (charCode > 31 && (charCode < 48 || charCode > 57)) return false;
            return true;
        }

        // ================= CAPTCHA =================
        function loadCaptcha() {
            $.get('${pageContext.request.contextPath}/captcha/text?_=' + new Date().getTime(), function (text) {
                if (text && text.trim().length > 0) {
                    $('#mainCaptcha').val(text.trim());
                }
            }).fail(function () {
                // Fallback local random generation
                var chars = '0123456789';
                var code = '';
                for (var i = 0; i < 4; i++) {
                    code += chars.charAt(Math.floor(Math.random() * chars.length));
                }
                $('#mainCaptcha').val(code);
            });
        }

        // ================= VERHOEFF AADHAAR CHECK =================
        function verhoeffCheck(str) {
            var d = [
                [0,1,2,3,4,5,6,7,8,9],
                [1,2,3,4,0,6,7,8,9,5],
                [2,3,4,0,1,7,8,9,5,6],
                [3,4,0,1,2,8,9,5,6,7],
                [4,0,1,2,3,9,5,6,7,8],
                [5,9,8,7,6,0,4,3,2,1],
                [6,5,9,8,7,1,0,4,3,2],
                [7,6,5,9,8,2,1,0,4,3],
                [8,7,6,5,9,3,2,1,0,4],
                [9,8,7,6,5,4,3,2,1,0]
            ];
            var p = [
                [0,1,2,3,4,5,6,7,8,9],
                [1,5,7,6,2,8,3,0,9,4],
                [5,8,0,3,7,9,6,1,4,2],
                [8,9,1,6,0,4,3,5,2,7],
                [9,4,5,3,1,2,6,8,7,0],
                [4,2,8,6,5,7,3,9,0,1],
                [2,7,9,3,8,0,6,4,1,5],
                [7,0,4,6,9,1,3,2,5,8]
            ];
            var c = 0;
            String(str).replace(/\D+/g, "").split("").reverse().join("").replace(/[\d]/g, function (u, i) {
                c = d[c][p[i & 7][parseInt(u, 10)]];
            });
            return (c === 0);
        }

        function validateAadhaarInput() {
            var val = $('#adarno').val().trim();
            if (val.length === 0) return true;
            if (val.length !== 12) {
                $('#adarnoError').text("Aadhaar Number must be exactly 12 digits.");
                return false;
            }
            if (!verhoeffCheck(val)) {
                $('#adarnoError').text("Invalid Aadhaar number (checksum failed).");
                return false;
            }
            $('#adarnoError').text("");
            return true;
        }

        // ================= RESET STEP 1 =================
        function resetStep1() {
            $('.error-msg').text('');
            loadCaptcha();
        }

        // ================= STEP 1 SUBMISSION =================
        function submitStep1() {
            $('.error-msg').text('');
            var isValid = true;

            var board = $('#ssc_board').val();
            if (!board) {
                $('#ssc_boardError').text("Please select a Board.");
                isValid = false;
            }

            var regno = $('#ssc_regno').val().trim();
            if (!regno) {
                $('#ssc_regnoError').text("Hall Ticket Number is required.");
                isValid = false;
            } else if (regno.length < 4 || regno.length > 15) {
                $('#ssc_regnoError').text("Hall Ticket Number must be between 4 and 15 characters.");
                isValid = false;
            }

            var year = $('#passed_year').val().trim();
            var curYear = new Date().getFullYear();
            if (!year) {
                $('#passed_yearError').text("Year of Passing is required.");
                isValid = false;
            } else if (!/^[0-9]{4}$/.test(year) || parseInt(year) > curYear) {
                $('#passed_yearError').text("Invalid Year of Passing (cannot exceed " + curYear + ").");
                isValid = false;
            }

            var sscType = $('#ssc_type').val();
            if (!sscType) {
                $('#ssc_typeError').text("Please select Result Type.");
                isValid = false;
            }

            var enteredCaptcha = $('#captchaInput').val().trim();
            var expectedCaptcha = $('#mainCaptcha').val().trim();
            if (!enteredCaptcha) {
                $('#captchaErr').text("Please enter Captcha.");
                isValid = false;
            } else if (enteredCaptcha.toUpperCase() !== expectedCaptcha.toUpperCase()) {
                $('#captchaErr').text("Captcha does not match. Please try again.");
                loadCaptcha();
                $('#captchaInput').val('').focus();
                isValid = false;
            }

            if (!isValid) return false;

            var btn = $('#step1SubmitBtn');
            btn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin"></i> Checking...');

            var payload = {
                sscBoard: board,
                sscRegNo: regno,
                sscYear: year,
                sscType: sscType,
                year: SESSION_YEAR
            };

            $.ajax({
                url: BACKEND_URL + '/api/student/save',
                type: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(payload),
                success: function (student) {
                    btn.prop('disabled', false).html('Proceed <i class="fas fa-arrow-right"></i>');
                    if (student && student.resumed === true) {
                        // Already registered student
                        $('#step1Div').hide();
                        $('#existHallTicket').text(student.sscRegNo || regno);
                        $('#existRegId').text(student.regid);
                        $('#alreadyRegisteredDiv').slideDown('fast');
                        window.scrollTo(0, 0);
                    } else {
                        // New student -> Proceed to Step 2
                        initStep2(student, regno, board, year, sscType);
                    }
                },
                error: function (xhr) {
                    btn.prop('disabled', false).html('Proceed <i class="fas fa-arrow-right"></i>');
                    var msg = "Verification failed. Please try again.";
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        msg = xhr.responseJSON.message;
                    }
                    $('#globalAlert').html('<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                        '<strong>Error:</strong> ' + msg +
                        '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button></div>');
                    loadCaptcha();
                }
            });
        }

        // ================= INITIALIZE STEP 2 =================
        function initStep2(student, regno, boardCode, year, sscType) {
            CURRENT_SSC_TYPE = sscType;
            CURRENT_REGID = student ? student.regid : null;

            $('#s2_ssc_regno').val(regno);
            $('#s2_board_code').val(boardCode);
            var boardName = $('#ssc_board option:selected').text();
            $('#s2_board_disp').val(boardName);
            $('#s2_ssc_year').val(year);

            // Configure Marks vs GPA UI
            if (CURRENT_SSC_TYPE === 'sscm') {
                $('#marksHeaderLabel').text('Marks (Max 100)');
                $('#totalLabel').text('Total Marks:');
            } else {
                $('#marksHeaderLabel').text('GPA (Max 10)');
                $('#totalLabel').text('Total GPA:');
            }

            // Load Castes
            loadCastes();

            // Transition UI
            $('#step1Div').hide();
            $('#step2Div').slideDown('fast');
            window.scrollTo(0, 0);
        }

        // ================= CASTES & SUB-CASTES =================
        function loadCastes() {
            if (__castesLoaded) return;
            $.get(BACKEND_URL + '/api/student/castes', function (list) {
                __castesLoaded = true;
                var sel = $('#casteSelect');
                sel.empty().append('<option value="">--Select Caste--</option>');
                $.each(list || [], function (i, c) {
                    sel.append('<option value="' + c.casteCode + '">' + c.casteName + '</option>');
                });
            }).fail(function () {
                console.log("Could not load castes from server.");
            });
        }

        function loadSubCastes() {
            var code = $('#casteSelect').val();
            var sel = $('#subCasteSelect');
            sel.empty().append('<option value="">-- Select Sub Category --</option>');
            if (!code) return;

            $.get(BACKEND_URL + '/api/student/subcastes/' + encodeURIComponent(code), function (list) {
                (list || []).forEach(function (r) {
                    var label = (r.subCasteName && r.subCasteName !== '') ? r.subCasteName : ('Sub-caste ' + r.subCasteId);
                    sel.append('<option value="' + r.subCasteId + '">' + label + '</option>');
                });
            }).fail(function () {
                console.log("Could not load sub-castes.");
            });
        }

        // ================= DYNAMIC TOGGLES =================
        function togglePhc(isYes) {
            var pwdSelect = $('#pwdCategory');
            if (isYes) {
                pwdSelect.prop('disabled', false);
            } else {
                pwdSelect.val('').prop('disabled', true);
                clearError('pwdCategoryError');
            }
        }

        function toggleInter(val) {
            if (val === 'Inter') {
                $('#interMarksRow').show();
            } else {
                $('#interMarksRow').hide();
                $('#inter_marks').val('');
                clearError('interMarksError');
            }
        }

        function setLanguages(num) {
            var row = $('#secondLangRow');
            var input = $('#m_secondlang');
            if (num === '2') {
                row.hide();
                input.val('0');
            } else {
                row.show();
                if (input.val() === '0') input.val('');
            }
            calculateTotal();
        }

        // ================= PHOTO PREVIEW & VALIDATION =================
        function previewPhoto(input) {
            clearError('photoError');
            var file = (input && input.files && input.files.length > 0) ? input.files[0] : null;
            if (!file) {
                resetPhotoPreview();
                return;
            }

            // Size 10KB - 200KB
            if (file.size < 10000 || file.size > 200000) {
                $('#photoError').text("File size must be between 10KB and 200KB.");
                input.value = '';
                resetPhotoPreview();
                return;
            }

            // Extension check
            var ext = file.name.substring(file.name.lastIndexOf('.') + 1).toLowerCase();
            if (ext !== 'jpg' && ext !== 'jpeg' && ext !== 'png') {
                $('#photoError').text("Only JPG and PNG image formats are allowed.");
                input.value = '';
                resetPhotoPreview();
                return;
            }

            var reader = new FileReader();
            reader.onload = function (e) {
                $('#photoPreview').attr('src', e.target.result).show();
                $('#photoPlaceholder').hide();
            };
            reader.readAsDataURL(file);
        }

        function resetPhotoPreview() {
            $('#photoPreview').attr('src', '').hide();
            $('#photoPlaceholder').show();
        }

        // ================= MARKS TO GPA CONVERSION =================
        function marksToGpa(marks, isSecondLang) {
            var m = parseFloat(marks);
            if (isNaN(m)) m = 0;
            if (isSecondLang) {
                if (m >= 90) return '10';
                if (m >= 80) return '9';
                if (m >= 70) return '8';
                if (m >= 60) return '7';
                if (m >= 50) return '6';
                if (m >= 40) return '5';
                if (m >= 30) return '4';
                if (m >= 20) return '3';
                return '0';
            } else {
                if (m >= 92) return '10';
                if (m >= 83) return '9';
                if (m >= 75) return '8';
                if (m >= 67) return '7';
                if (m >= 59) return '6';
                if (m >= 51) return '5';
                if (m >= 43) return '4';
                if (m >= 35) return '3';
                return '0';
            }
        }

        // ================= MARKS CALCULATION =================
        function calculateTotal() {
            var isTwoLang = $('input[name="noOfLangs"]:checked').val() === '2';
            var ids = isTwoLang
                ? ['m_firstlang', 'm_english', 'm_math', 'm_science', 'm_social']
                : ['m_firstlang', 'm_secondlang', 'm_english', 'm_math', 'm_science', 'm_social'];

            var sum = 0;
            var anyEntered = false;

            for (var i = 0; i < ids.length; i++) {
                var val = parseFloat($('#' + ids[i]).val());
                if (!isNaN(val)) {
                    anyEntered = true;
                    sum += val;
                }
            }

            if (!anyEntered) {
                $('#total_marks').val('');
                return;
            }

            if (CURRENT_SSC_TYPE === 'sscm') {
                $('#total_marks').val(Math.round(sum));
            } else {
                var avg = Math.round((sum / ids.length) * 10) / 10;
                $('#total_marks').val(avg);
            }
        }

        // ================= VALIDATION BEFORE CONFIRMATION =================
        function validateStep2() {
            $('.error-msg').text('');
            var valid = true;

            function requireField(id, msg) {
                var val = $('#' + id).val();
                if (!val || String(val).trim() === '') {
                    $('#' + id + 'Error').text(msg);
                    valid = false;
                    return false;
                }
                return true;
            }

            requireField('ssc_month', "Please select Month of Pass.");
            requireField('name', "Applicant's Name is required.");

            var phno = $('#phno').val().trim();
            if (!phno) {
                $('#phnoError').text("Mobile number is required.");
                valid = false;
            } else if (!/^[0-9]{10}$/.test(phno)) {
                $('#phnoError').text("Mobile number must be 10 digits.");
                valid = false;
            }

            requireField('dob', "Date of birth is required.");

            var adar = $('#adarno').val().trim();
            if (!adar) {
                $('#adarnoError').text("Aadhaar Number is required.");
                valid = false;
            } else if (!validateAadhaarInput()) {
                valid = false;
            }

            if (!$('input[name="gender"]:checked').val()) {
                $('#genderError').text("Please select Gender.");
                valid = false;
            }

            requireField('casteSelect', "Please select Category (Caste).");
            requireField('fname', "Father's Name is required.");
            requireField('mname', "Mother's Name is required.");

            if ($('input[name="phc"]:checked').val() === 'yes') {
                var pwd = $('#pwdCategory').val();
                if (!pwd) {
                    $('#pwdCategoryError').text("Please select PWD category.");
                    valid = false;
                }
            }

            requireField('ssc', "Please select Qualification.");

            if ($('#ssc').val() === 'Inter') {
                requireField('inter_marks', "Please enter Inter Marks.");
            }

            requireField('local', "Please select Local / Non-Local.");
            requireField('addr', "Address is required.");

            var pin = $('#pincode').val().trim();
            if (!pin) {
                $('#pincodeError').text("Pincode is required.");
                valid = false;
            } else if (!/^[0-9]{6}$/.test(pin)) {
                $('#pincodeError').text("Pincode must be 6 digits.");
                valid = false;
            }

            var email = $('#email').val().trim();
            if (!email) {
                $('#emailError').text("Email ID is required.");
                valid = false;
            } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                $('#emailError').text("Please enter a valid email address.");
                valid = false;
            }

            // Subject marks validation
            var isTwoLang = $('input[name="noOfLangs"]:checked').val() === '2';
            var subjects = [
                { id: 'm_firstlang', name: 'First Language' },
                { id: 'm_secondlang', name: 'Second Language', skipIf2: true },
                { id: 'm_english', name: 'Third Language' },
                { id: 'm_math', name: 'Mathematics' },
                { id: 'm_science', name: 'General Science' },
                { id: 'm_social', name: 'Social Studies' }
            ];

            var maxLimit = (CURRENT_SSC_TYPE === 'sscm') ? 100 : 10;
            subjects.forEach(function (sub) {
                if (sub.skipIf2 && isTwoLang) return;
                var v = $('#' + sub.id).val().trim();
                if (v === '') {
                    $('#' + sub.id + 'Error').text(sub.name + " is required.");
                    valid = false;
                } else {
                    var n = parseFloat(v);
                    if (isNaN(n) || n < 0 || n > maxLimit) {
                        $('#' + sub.id + 'Error').text("Value must be 0 - " + maxLimit);
                        valid = false;
                    }
                }
            });

            // Photo
            var photoInput = document.getElementById('photo');
            if (!photoInput || !photoInput.files || photoInput.files.length === 0) {
                $('#photoError').text("Please upload photograph.");
                valid = false;
            }

            // Consent
            if (!$('#consent').is(':checked')) {
                $('#consentError').text("Please check the consent box to proceed.");
                valid = false;
            }

            return valid;
        }

        // ================= SHOW CONFIRMATION MODAL =================
        function confirmBeforeSubmit() {
            if (!validateStep2()) {
                window.scrollTo({ top: 300, behavior: 'smooth' });
                return false;
            }

            // Populate Modal review fields
            $('#c_sscregno').text($('#s2_ssc_regno').val());
            $('#c_board').text($('#s2_board_disp').val());
            $('#c_year').text($('#s2_ssc_year').val());
            $('#c_month').text($('#ssc_month option:selected').text());
            $('#c_name').text($('#name').val());
            $('#c_fname').text($('#fname').val());
            $('#c_mname').text($('#mname').val());
            $('#c_dob').text($('#dob').val());
            var g = $('input[name="gender"]:checked').val();
            $('#c_gender').text(g ? g.toUpperCase() : '');
            $('#c_adarno').text($('#adarno').val());
            $('#c_phno').text($('#phno').val());
            $('#c_email').text($('#email').val());
            $('#c_caste').text($('#casteSelect option:selected').text());
            $('#c_subcaste').text($('#subCasteSelect option:selected').text() || 'N/A');
            var isPhc = $('input[name="phc"]:checked').val() === 'yes';
            $('#c_phc').text(isPhc ? 'Yes' : 'No');
            $('#c_pwd').text(isPhc ? ($('#pwdCategory option:selected').text() || 'None') : 'None');
            $('#c_exs').text($('input[name="exs"]:checked').val() === 'yes' ? 'Yes' : 'No');
            $('#c_qual').text($('#ssc option:selected').text());
            $('#c_local').text($('#local option:selected').text());
            $('#c_ews').text($('input[name="ews"]:checked').val() === 'yes' ? 'Yes' : 'No');
            $('#c_addr').text($('#addr').val());
            $('#c_pincode').text($('#pincode').val());

            var isTwoLang = $('input[name="noOfLangs"]:checked').val() === '2';
            $('#c_marks_label').text(CURRENT_SSC_TYPE === 'sscm' ? 'Marks (100)' : 'GPA (10)');
            $('#c_tot_label').text(CURRENT_SSC_TYPE === 'sscm' ? 'Total Marks' : 'Total GPA');
            $('#c_sub1').text($('#m_firstlang').val());
            if (isTwoLang) {
                $('#c_sub2_row').hide();
            } else {
                $('#c_sub2_row').show();
                $('#c_sub2').text($('#m_secondlang').val());
            }
            $('#c_sub3').text($('#m_english').val());
            $('#c_sub4').text($('#m_math').val());
            $('#c_sub5').text($('#m_science').val());
            $('#c_sub6').text($('#m_social').val());
            $('#c_tot_val').text($('#total_marks').val());

            if (confirmModalInstance) {
                confirmModalInstance.show();
            } else {
                $('#confirmModal').modal('show');
            }
        }

        // ================= FINAL REGISTRATION SUBMISSION =================
        function submitFinalRegistration() {
            var submitBtn = $('#finalSubmitBtn');
            submitBtn.prop('disabled', true).html('<i class="fas fa-spinner fa-spin me-1"></i> Submitting...');

            var isTwoLang = $('input[name="noOfLangs"]:checked').val() === '2';
            var qual = $('#ssc').val();

            var appDto = {
                regid: CURRENT_REGID,
                sscRegNo: $('#s2_ssc_regno').val().trim(),
                sscBoard: $('#s2_board_code').val(),
                sscYear: $('#s2_ssc_year').val().trim(),
                sscMonth: $('#ssc_month').val(),
                sscType: CURRENT_SSC_TYPE,
                year: SESSION_YEAR,
                name: $('#name').val().trim(),
                fname: $('#fname').val().trim(),
                mname: $('#mname').val().trim(),
                gender: $('input[name="gender"]:checked').val(),
                dob: $('#dob').val(),
                adarno: $('#adarno').val().trim(),
                phno: parseInt($('#phno').val().trim(), 10),
                email: $('#email').val().trim(),
                addr: $('#addr').val().trim(),
                pincode: parseInt($('#pincode').val().trim(), 10),
                caste: $('#casteSelect').val(),
                subCaste: $('#subCasteSelect').val() || null,
                local: $('#local').val(),
                economicWeakerSection: $('input[name="ews"]:checked').val() === 'yes',
                phc: $('input[name="phc"]:checked').val() === 'yes',
                pwdCategory: $('#pwdCategory').val() || '',
                exservice: $('input[name="exs"]:checked').val() === 'yes',
                sscPassed: qual === 'SSC' || qual === 'Inter',
                interPassed: qual === 'Inter',
                interMarks: $('#inter_marks').val() ? parseInt($('#inter_marks').val(), 10) : 0
            };

            var marksDto = {};
            if (CURRENT_SSC_TYPE === 'sscm') {
                marksDto.sscFirstLangMarks = parseInt($('#m_firstlang').val(), 10) || 0;
                marksDto.sscSecondLangMarks = isTwoLang ? 0 : (parseInt($('#m_secondlang').val(), 10) || 0);
                marksDto.sscEngMarks = parseInt($('#m_english').val(), 10) || 0;
                marksDto.sscMathMarks = parseInt($('#m_math').val(), 10) || 0;
                marksDto.sscSciMarks = parseInt($('#m_science').val(), 10) || 0;
                marksDto.sscSocialMarks = parseInt($('#m_social').val(), 10) || 0;
                marksDto.sscTotMarks = parseInt($('#total_marks').val(), 10) || 0;

                // Derive GPAs so merit ranking has GPA representation
                marksDto.sscFirstLangGpa = marksToGpa(marksDto.sscFirstLangMarks, false);
                marksDto.sscSecondLangGpa = isTwoLang ? '0' : marksToGpa(marksDto.sscSecondLangMarks, true);
                marksDto.sscEngGpa = marksToGpa(marksDto.sscEngMarks, false);
                marksDto.sscMathGpa = marksToGpa(marksDto.sscMathMarks, false);
                marksDto.sscSciGpa = marksToGpa(marksDto.sscSciMarks, false);
                marksDto.sscSocialGpa = marksToGpa(marksDto.sscSocialMarks, false);

                var gpaArr = isTwoLang
                    ? [marksDto.sscFirstLangGpa, marksDto.sscEngGpa, marksDto.sscMathGpa, marksDto.sscSciGpa, marksDto.sscSocialGpa]
                    : [marksDto.sscFirstLangGpa, marksDto.sscSecondLangGpa, marksDto.sscEngGpa, marksDto.sscMathGpa, marksDto.sscSciGpa, marksDto.sscSocialGpa];

                var gpaSum = 0;
                for (var gi = 0; gi < gpaArr.length; gi++) {
                    gpaSum += parseFloat(gpaArr[gi]) || 0;
                }
                marksDto.sscTotGpa = String(Math.round((gpaSum / gpaArr.length) * 10) / 10);
            } else {
                marksDto.sscFirstLangGpa = $('#m_firstlang').val();
                marksDto.sscSecondLangGpa = isTwoLang ? '0' : $('#m_secondlang').val();
                marksDto.sscEngGpa = $('#m_english').val();
                marksDto.sscMathGpa = $('#m_math').val();
                marksDto.sscSciGpa = $('#m_science').val();
                marksDto.sscSocialGpa = $('#m_social').val();
                marksDto.sscTotGpa = $('#total_marks').val();
            }

            var fd = new FormData();
            fd.append("application", new Blob([JSON.stringify(appDto)], { type: "application/json" }));
            fd.append("marks", new Blob([JSON.stringify(marksDto)], { type: "application/json" }));
            var fileEl = document.getElementById('photo');
            if (fileEl && fileEl.files && fileEl.files.length > 0) {
                fd.append("photo", fileEl.files[0]);
            }

            $.ajax({
                url: BACKEND_URL + '/api/student/register',
                type: 'POST',
                data: fd,
                processData: false,
                contentType: false,
                success: function (saved) {
                    if (confirmModalInstance) {
                        confirmModalInstance.hide();
                    } else {
                        $('#confirmModal').modal('hide');
                    }
                    submitBtn.prop('disabled', false).html('<i class="fas fa-check-circle me-1"></i> Yes, Submit Application');

                    var finalRegId = (saved && saved.regid) ? saved.regid : CURRENT_REGID;
                    $('#step2Div').hide();
                    $('#successRegId').text(finalRegId);
                    $('#successDiv').slideDown('fast');
                    window.scrollTo(0, 0);
                },
                error: function (xhr) {
                    submitBtn.prop('disabled', false).html('<i class="fas fa-check-circle me-1"></i> Yes, Submit Application');
                    var msg = "Failed to save registration. Please verify details and try again.";
                    if (xhr.responseJSON && xhr.responseJSON.message) {
                        msg = xhr.responseJSON.message;
                    }
                    alert(msg);
                }
            });
        }
    </script>

    <%@ include file="../jsp/footer.jsp" %>
</body>
</html>
