<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Edit Registration | ITI Admission Portal</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/customJs/stdAreaJs/editRegJs.js?v=2"></script>

    <style>
        body {
            background-color: #f0f4fc; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        /* Verification Card (Image 4 style) */
        .modern-card {
            max-width: 480px;
            width: 100%;
            background: #fff;
            border-radius: 12px;
            border-top: 4px solid #2563eb;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            margin: 50px auto;
            padding: 40px 35px;
        }
        .portal-title {
            color: #1e3a8a;
            font-weight: 800;
            font-size: 1.8rem;
            margin-bottom: 5px;
        }
        .portal-subtitle {
            color: #3b82f6;
            font-size: 0.95rem;
            margin-bottom: 30px;
        }
        .form-label-custom {
            font-size: 0.85rem;
            color: #475569;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .form-control-custom {
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            padding: 10px 15px;
            font-size: 0.95rem;
            width: 100%;
            display: block;
        }
        .captcha-box-modern {
            background-color: #e0e7ff;
            color: #3730a3;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            height: 100%;
            min-height: 44px;
        }
        .input-captcha-modern {
            background: transparent; border: none; font-family: monospace; font-weight: bold; letter-spacing: 5px; width: 80px; pointer-events: none; text-align: center; font-size: 1.2rem;
        }
        .proceed-btn {
            background-color: #2563eb;
            color: white;
            border-radius: 6px;
            padding: 10px 30px;
            font-weight: 600;
            border: none;
            transition: 0.2s;
        }
        .proceed-btn:hover { background-color: #1d4ed8; color: white; }
        .refresh-icon {
            color: #2563eb;
            background: #dbeafe;
            border-radius: 6px;
            cursor: pointer;
            height: 100%;
            min-height: 44px;
            width: 44px;
            display: flex; align-items: center; justify-content: center;
        }
        .error-msg {
            color: #ef4444;
            font-size: 0.75rem;
            margin-top: 4px;
            display: block;
        }

        /* Full Form Layout (Image 5 style) */
        .form-table-container {
            max-width: 1100px;
            margin: 20px auto;
            background: white;
            padding: 0;
            border: 2px solid #195695;
        }
        .form-header {
            background-color: #195695;
            color: white;
            padding: 10px;
            text-align: center;
            font-weight: bold;
            font-size: 1.1rem;
        }
        .attention-banner {
            background-color: #eef4fa;
            padding: 8px;
            font-size: 0.85rem;
            font-weight: 600;
            color: #333;
            border-bottom: 2px solid #195695;
        }
        .form-table {
            width: 100%;
            border-collapse: collapse;
        }
        .form-table td {
            border: 1px solid #195695;
            padding: 6px 10px;
            vertical-align: middle;
        }
        .form-table td.label-cell {
            background-color: #eef4fa;
            color: #195695;
            font-weight: 600;
            width: 20%;
            font-size: 0.85rem;
        }
        .form-table td.label-cell span { color: red; }
        .form-table td.input-cell {
            width: 30%;
        }
        .form-table .form-control, .form-table .form-select {
            border: 1px solid #a6b8c7;
            border-radius: 2px;
            padding: 4px;
            font-size: 0.85rem;
            width: 100%;
        }
        .form-table .form-control:read-only {
            background-color: #e9ecef;
        }
    </style>
</head>
<body onload="generateCaptcha();">

    <header>
        <%@include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <main>
        <div class="container py-4">
            <h3 id="dateexpiredMsg" align="center" style="max-width: 500px; margin: 0 auto; color: red;"></h3>

            <!-- STEP 1: VERIFICATION (Image 4 Style) -->
            <div class="modern-card" id="formOne">
                <div class="text-center">
                    <div class="portal-title">ITI Admission Portal</div>
                    <div class="portal-subtitle">Student <span style="font-weight: bold; color: #2563eb;">Edit</span> Registration</div>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">SSC Hall Ticket Number</label>
                    <input type="text" class="form-control-custom" id="ssc_regnoo" placeholder="Enter Hall Ticket Number"
                           maxlength="15" onchange="checkValue('ssc_regnoError')">
                    <span id="ssc_regnoError" class="error-msg"></span>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">Registration ID</label>
                    <input type="text" class="form-control-custom" id="regid" placeholder="Enter Registration ID"
                           maxlength="10" onchange="checkValue('regidError')">
                    <span id="regidError" class="error-msg"></span>
                </div>

                <div class="mb-3">
                    <label class="form-label-custom">Date of Birth</label>
                    <input type="date" class="form-control-custom" id="dobb" 
                           onchange="checkValue('dobbError'), convertDateFormat();">
                    <input type="hidden" id="dobbspan">
                    <span id="dobbError" class="error-msg"></span>
                </div>

                <div class="mb-4">
                    <label class="form-label-custom">Captcha</label>
                    <div class="d-flex gap-2 align-items-center">
                        <div class="refresh-icon" onclick="generateCaptcha()" title="Refresh Captcha">
                            <i class="fas fa-sync-alt"></i>
                        </div>
                        <div class="captcha-box-modern flex-grow-1">
                            <input type="text" id="mainCaptcha" class="input-captcha-modern" readonly>
                        </div>
                        <div class="flex-grow-1" style="flex-basis: 50%;">
                            <input type="text" id="txtInput" class="form-control-custom" placeholder="Enter Captcha" 
                                   maxlength="4" autocomplete="off" onchange="checkValue('captchaErr')">
                        </div>
                    </div>
                    <span id="captchaErr" class="error-msg"></span>
                </div>

                <div class="text-center mt-4">
                    <button type="button" class="proceed-btn w-100" onclick="validate()">
                        Submit <i class="fas fa-arrow-right ms-2"></i>
                    </button>
                </div>
                
                <div id="errorMsg" class="mt-3"></div>
            </div>

            <!-- STEP 2: FULL FORM (Image 5 Style) -->
            <div id="formTwo" style="display:none;">
                <div class="form-table-container shadow-sm">
                    <div class="form-header">
                        Edit Registration Form for Admission into the Industrial Training Institute for the session 2025
                    </div>
                    <div class="attention-banner">
                        Attention: Enter data carefully, If any information found wrong in Marks/GPA, Caste, etc., the authority has the right to disqualify for admissions.
                    </div>

                    <table class="form-table">
                        <tr>
                            <td class="label-cell">Hall Ticket Number<span>*</span>:</td>
                            <td class="input-cell"><input type="text" class="form-control" name="ssc_regno" id="ssc_regno" readonly tabindex="-1" /></td>
                            <td class="label-cell">Board<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="ssc_board" id="ssc_board" onchange="return checkValue('ssc_boardError')"></select>
                                <span id="ssc_boardError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Year of Pass SSC<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="ssc_year" id="ssc_year" class="form-control" onchange="return checkValue('ssc_yearError')" maxlength="4" />
                                <span id="ssc_yearError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Month of Pass<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="ssc_month" id="ssc_month" onchange="return checkValue('ssc_monthError')">
                                    <option value="">-select-</option>
                                    <option value="3">March</option>
                                    <option value="4">Supplementary</option>
                                </select>
                                <span id="ssc_monthError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Applicant's Name<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="name" id="name" class="form-control" onchange="return checkValue('nameError')" oninput="convertToUppercase(this)" />
                                <span id="nameError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Mobile Number<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="phno" id="phno" class="form-control" onchange="return checkValue('phnoError')" maxlength="10" />
                                <span id="phnoError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Date of Birth<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="date" name="dob" id="dob" class="form-control" onchange="return checkValue('dobError')" />
                                <span id="dobError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Aadhar Card Number<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="adarno" id="adarno" class="form-control" onchange="return checkValue('adarnoError')" maxlength="12" />
                                <span id="adarnoError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Gender<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="gen" id="gen" onchange="return checkValue('genError')">
                                    <option value="">-select-</option>
                                    <option value="male">Male</option>
                                    <option value="female">Female</option>
                                </select>
                                <span id="genError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Category<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="caste" id="caste" onchange="return checkValue('casteError')"></select>
                                <span id="casteError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Father Name<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="fname" id="fname" class="form-control" onchange="return checkValue('fnameError')" oninput="convertToUppercase(this)" />
                                <span id="fnameError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Mother's Name<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="mname" id="mname" class="form-control" onchange="return checkValue('mnameError')" oninput="convertToUppercase(this)" />
                                <span id="mnameError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Physically Challenged<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="phc" id="phc" onchange="return checkValue('phcError'), checkPwd(this.value)">
                                    <option value="">-select-</option>
                                    <option value="true">Yes</option>
                                    <option value="false">No</option>
                                </select>
                                <span id="phcError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">PWD Category:</td>
                            <td class="input-cell">
                                <select class="form-select" name="pwd_category" id="pwd_category">
                                    <option value="0">None</option>
                                    <option value="1">Blind</option>
                                    <option value="2">Deaf</option>
                                    <option value="3">Motor Disability</option>
                                    <option value="4">Mental Disability</option>
                                </select>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Ex-Servicemen<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="exs" id="exs" onchange="return checkValue('exsError')">
                                    <option value="">-select-</option>
                                    <option value="true">Yes</option>
                                    <option value="false">No</option>
                                </select>
                                <span id="exsError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Qualification<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="ssc" id="ssc" onchange="checkValue('sscError'); toggleInterMarks(this.value);">
                                    <option value="">-select-</option>
                                    <option value="SSC">SSC Passed</option>
                                    <option value="Inter">Inter Passed</option>
                                </select>
                                <span id="sscError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr id="interMarksRow" style="display: none;">
                            <td class="label-cell">Inter Marks<span>*</span>:</td>
                            <td class="input-cell" colspan="3">
                                <input type="text" class="form-control" name="inter_marks" id="inter_marks" onchange="return checkValue('interMarksError')" maxlength="4" placeholder="Enter Inter Marks" style="width: 50%;" />
                                <span id="interMarksError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Address<span>*</span>:</td>
                            <td class="input-cell">
                                <textarea rows="2" class="form-control" name="addr" id="addr" onchange="return checkValue('addrError')"></textarea>
                                <span id="addrError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Local/Non Local<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="loconoc" id="loconoc" onchange="return checkValue('loconocError')">
                                    <option value="">-select-</option>
                                    <option value="Local">Local</option>
                                    <option value="NonLocal">Non-Local</option>
                                </select>
                                <span id="loconocError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Pincode<span>*</span>:</td>
                            <td class="input-cell">
                                <input type="text" name="pincode" id="pincode" class="form-control" onchange="return checkValue('pincodeError')" maxlength="6" />
                                <span id="pincodeError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">Email:</td>
                            <td class="input-cell">
                                <input type="email" name="email" id="email" class="form-control" onchange="return checkValue('emailError')" />
                                <span id="emailError" class="error-msg"></span>
                            </td>
                        </tr>
                        <tr>
                            <td class="label-cell">Economic Weaker Section<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="ews" id="ews" onchange="return checkValue('ewsError')">
                                    <option value="">-select-</option>
                                    <option value="true">Yes</option>
                                    <option value="false">No</option>
                                </select>
                                <span id="ewsError" class="error-msg"></span>
                            </td>
                            <td class="label-cell">SSC Marks Type<span>*</span>:</td>
                            <td class="input-cell">
                                <select class="form-select" name="ssc_type" id="ssc_type" onchange="return checkValue('ssc_typeError'), ssctype(this.value)">
                                    <option value="">-select-</option>
                                    <option value="sscm">MARKS</option>
                                    <option value="sscg">GPA</option>
                                </select>
                                <span id="ssc_typeError" class="error-msg"></span>
                            </td>
                        </tr>
                    </table>

                    <div style="background-color: #eef4fa; padding: 20px; border-bottom: 2px solid #195695; text-align: center;">
                        <div class="mb-3">
                            <label class="form-label fw-bold" style="color: #195695;">Number of Languages*</label>
                            <select name="noOfLangs" id="noOfLangs" class="form-select d-inline-block w-auto ms-2" onchange="return checkValue('noOfLangsError'), marksdiv(this.value)">
                                <option value="">-select-</option>
                                <option value="3">THREE</option>
                                <option value="2">TWO</option>
                            </select>
                            <span id="noOfLangsError" class="error-msg"></span>
                        </div>

                        <div id="marksrow" style="display:none; max-width: 450px; margin: 0 auto;">
                            <table class="table table-bordered table-sm bg-white shadow-sm">
                                <thead class="bg-primary text-white">
                                    <tr>
                                        <th style="width: 10%;">#</th>
                                        <th style="width: 50%;">Subject Name</th>
                                        <th style="width: 40%;">Marks / GPA</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr><td>1</td><td>First language</td><td><input type="text" id="first_lang" class="form-control text-center p-1" onchange="calculateTotal()" maxlength="3"></td></tr>
                                    <tr><td>2</td><td>Second language</td><td><input type="text" id="second_lang" class="form-control text-center p-1" onchange="calculateTotal()" maxlength="3"></td></tr>
                                    <tr><td>3</td><td><span id="tl_label">Third Language- English</span></td><td><input type="text" id="third_lang" class="form-control text-center p-1" onchange="calculateTotal()" maxlength="3"></td></tr>
                                    <tr><td>4</td><td>Mathematics</td><td><input type="text" id="maths" class="form-control text-center p-1" onchange="calculateTotal()" maxlength="3"></td></tr>
                                    <tr><td>5</td><td>General Science</td><td><input type="text" id="science" class="form-control text-center p-1" onchange="calculateTotal()" maxlength="3"></td></tr>
                                    <tr><td>6</td><td>Social Studies</td><td><input type="text" id="social" class="form-control text-center p-1" onchange="calculateTotal()" maxlength="3"></td></tr>
                                    <tr class="bg-light"><td></td><td class="text-end fw-bold">Total:</td><td><input type="text" id="total_marks" class="form-control text-center p-1 fw-bold" readonly style="background-color: #eee;"></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- PHOTO & UPDATE -->
                    <div class="p-4 bg-white text-center">
                        <div class="row align-items-center">
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Current Photo</label>
                                <div id="imageContainer" class="border p-2 bg-light mx-auto" style="width:150px; height:180px;"></div>
                            </div>
                            <div class="col-md-4">
                                <label class="form-label fw-bold">Update Photo</label>
                                <input type="file" id="photo" class="form-control form-control-sm" onchange="uploadImage()">
                                <small class="text-danger fw-bold" style="font-size: 0.7rem;">Max size: 200 KB (JPG/PNG)</small>
                                <input type="hidden" id="base64Image" />
                                <input type="hidden" id="oldImage" />
                            </div>
                            <div class="col-md-4">
                               <div class="form-check text-start mb-3">
                                    <input class="form-check-input" type="checkbox" id="consent">
                                    <label class="form-check-label small" for="consent">
                                        I hereby consent to verify my identity for admission.
                                    </label>
                                </div>
                                <button type="button" class="btn btn-success btn-lg w-100" onclick="return sendData()">Update Application</button>
                            </div>
                        </div>
                        <span id="consentError" class="error-msg mt-2"></span>
                    </div>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <%@include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

</body>
</html>