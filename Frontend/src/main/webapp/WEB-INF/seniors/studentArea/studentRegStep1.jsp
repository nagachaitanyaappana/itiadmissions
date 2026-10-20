<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Student Registration | ITI Admission Portal</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js?v=4"></script>
        <script type="text/javascript"
            src="${pageContext.request.contextPath}/js/customJs/stdAreaJs/studentRegJs.js?v=2"></script>
        <style>
            .registration-exists-container {
                display: flex;
                flex-direction: column;
                align-items: center;
                justify-content: center;
                min-height: 40vh;
                text-align: center;
                margin-top: 50px;
                background-color: #ffffff;
                padding: 40px;
                border-radius: 20px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.1);
            }

            .message-text {
                color: #0000ff;
                /* Blue */
                font-size: 1.25rem;
                font-weight: bold;
                display: flex;
                align-items: center;
                gap: 5px;
                flex-wrap: wrap;
                justify-content: center;
            }

            .reg-id-box {
                border: 3px solid #ff0000;
                /* Red border */
                padding: 2px 10px;
                display: inline-block;
                margin: 5px;
            }

            .btn-home-custom {
                background-color: #99ff33;
                /* Light Green as per image */
                border: 1px solid #000;
                color: #000;
                padding: 5px 25px;
                text-decoration: none;
                font-weight: bold;
                display: inline-block;
                margin-top: 30px;
                align-self: center;
            }

            .btn-home-custom:hover {
                background-color: #88ee22;
                color: #000;
            }
        </style>
    </head>

    <body onload="generateCaptcha();">

        <header>
            <%@include file="/WEB-INF/seniors/header.jsp" %>
        </header>

        <main>
            <div align="center" style="color: red;" id="tokenErrMsg"></div>

            <div class="container border p-2 mt-2 font-weight-bolder shadow-lg rounded-3"
                style="background-color: transparent; border:none !important;" id="formbody">

                <!-- ===== MESSAGE DISPLAY ===== -->
                <div id="existRegMsg"></div>

                <!-- ===== STEP 2: FULL REGISTRATION FORM ===== -->
                <div id="stdRegDiv" style="display:block !important; padding: 10px;">
                    <form id="registrationForm" action="${pageContext.request.contextPath}/stdRegSuccess" method="post">
                        <input type="hidden" name="regid" id="regid">

                        <script>
                            // Auto-fill from studentRegNew.jsp POST body and override studentRegJs.js hide command
                            $(document).ready(function () {
                                setTimeout(function () {
                                    // First fetch the boards so the options exist before we try to select one!
                                    getAllSSCBoards(function (boards) {
                                        var sscBoardSelect = $("#ssc_board");
                                        sscBoardSelect.empty();
                                        sscBoardSelect.append('<option value="">-Select-</option>');
                                        if (boards && boards.length > 0) {
                                            $.each(boards, function (index, board) {
                                                sscBoardSelect.append('<option value="' + board.boardCode + '">' + board.boardName + '</option>');
                                            });
                                        }

                                        $("#stdRegDiv").attr("style", "display: block !important; padding: 10px;");

                                        var regno = '${param.ssc_regnoo}';
                                        var board = '${param.boardCode}';
                                        var year = '${param.passingYear}';
                                        var rtype = '${param.resultType}';
                                        var dob = '${param.dob}';

                                        if (regno) $("#ssc_regno").val(regno);
                                        if (board) $("#ssc_board").val(board);
                                        if (year) $("#ssc_year").val(year);
                                        if (dob) {
                                            $("#dob").val(dob);
                                            $("#dob").attr("readonly", true);
                                            $("#dob").attr("tabindex", "-1");
                                        }

                                        if (rtype === 'Marks') {
                                            $("#ssc_type").val('sscm');
                                            ssctype('sscm');
                                        } else if (rtype === 'GPA') {
                                            $("#ssc_type").val('sscg');
                                            ssctype('sscg');
                                        }
                                    });
                                }, 50); // closes setTimeout
                            }); // closes document.ready
                        </script>

                        <div class="form-header"
                            style="background-color: #195695; color: white; padding: 10px; text-align: center; font-weight: bold; font-size: 1.1rem; border: 2px solid #195695; border-bottom: none;">
                            Registration Form for Admission into the industrial training Institute for the session
                            2025(Phase-1)
                        </div>

                        <div
                            style="background-color: #eef4fa; padding: 8px; border: 2px solid #195695; border-top: none; border-bottom: none; font-size: 0.85rem; font-weight: 600; color: #333;">
                            Attention: Enter data carefully, If any information found wrong in Marks/GPA, Caste, etc.,
                            the authority has the right to disqualify for admissions.
                        </div>

                        <table class="form-table"
                            style="width: 100%; border-collapse: collapse; border: 2px solid #195695; background-color: #fff;">
                            <style>
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

                                .form-table td.label-cell span {
                                    color: red;
                                }

                                .form-table td.input-cell {
                                    width: 30%;
                                    background-color: #fcfcfc;
                                }

                                .form-table .form-control,
                                .form-table .form-select {
                                    border: 1px solid #a6b8c7;
                                    border-radius: 2px;
                                    padding: 4px;
                                    font-size: 0.85rem;
                                    width: 100%;
                                }

                                .form-table input[type="radio"] {
                                    margin-right: 5px;
                                }

                                .form-table label {
                                    margin-right: 15px;
                                    font-weight: normal;
                                    font-size: 0.85rem;
                                    color: #333;
                                }

                                .error-text {
                                    color: red;
                                    font-size: 0.75rem;
                                    display: block;
                                    margin-top: 2px;
                                }
                            </style>

                            <!-- Row 1 -->
                            <tr>
                                <td class="label-cell">Hall Ticket Number<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" class="form-control" name="ssc_regno" id="ssc_regno" readonly
                                        tabindex="-1" style="background-color: #e9ecef;" />
                                    <span id="ssc_regnoError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Board<span>*</span>:</td>
                                <td class="input-cell">
                                    <select class="form-select" name="ssc_board" id="ssc_board"
                                        onchange="return checkValue('ssc_boardError')"></select>
                                    <span id="ssc_boardError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 2 -->
                            <tr>
                                <td class="label-cell">Year of Pass<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="ssc_year" id="ssc_year" class="form-control"
                                        onchange="return checkValue('ssc_yearError')" maxlength="4" />
                                    <span id="ssc_yearError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Month of Pass<span>*</span>:</td>
                                <td class="input-cell">
                                    <select class="form-select" name="ssc_month" id="ssc_month"
                                        onchange="return checkValue('ssc_monthError')">
                                        <option value="">-select-</option>
                                        <option value="3">March</option>
                                        <option value="4">Supplementary</option>
                                    </select>
                                    <span id="ssc_monthError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 3 -->
                            <tr>
                                <td class="label-cell">Applicant's Name<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="name" id="name" class="form-control"
                                        onchange="return checkValue('nameError')" oninput="convertToUppercase(this)" />
                                    <span id="nameError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Mobile Number<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="phno" id="phno" class="form-control"
                                        onchange="return checkValue('phnoError')" maxlength="10" />
                                    <span id="phnoError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 4 -->
                            <tr>
                                <td class="label-cell">Date of Birth(dd-mm-yyyy)<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="date" name="dob" id="dob" class="form-control"
                                        onchange="return checkValue('dobError')" readonly tabindex="-1"
                                        style="background-color: #e9ecef;" />
                                    <input type="hidden" id="dobb" />
                                    <span id="dobError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Aadhar Card Number<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="adarno" id="adarno" class="form-control"
                                        onchange="return checkValue('adarnoError')" autocomplete="off" maxlength="12" />
                                    <span id="adarnoError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 5 -->
                            <tr>
                                <td class="label-cell">Gender<span>*</span>:</td>
                                <td class="input-cell pt-2 pb-2">
                                    <select class="form-select" name="gen" id="gen"
                                        onchange="return checkValue('genError')">
                                        <option value="">-select-</option>
                                        <option value="male">Male</option>
                                        <option value="female">Female</option>
                                    </select>
                                    <span id="genError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Category<span>*</span>:</td>
                                <td class="input-cell">
                                    <select class="form-select" name="caste" id="caste"
                                        onchange="return checkValue('casteError')">
                                    </select>
                                    <span id="casteError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 6 -->
                            <tr>
                                <td class="label-cell">Father Name<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="fname" id="fname" class="form-control"
                                        onchange="return checkValue('fnameError')" oninput="convertToUppercase(this)" />
                                    <span id="fnameError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Physically Challenged<span>*</span>:</td>
                                <td class="input-cell pt-2 pb-2">
                                    <label><input type="radio" name="phc_radio" value="true"
                                            onchange="setPHC(this.value)"> Yes</label>
                                    <label><input type="radio" name="phc_radio" value="false"
                                            onchange="setPHC(this.value)"> No</label>
                                    <input type="hidden" name="phc" id="phc" />
                                    <span id="phcError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 7 -->
                            <tr>
                                <td class="label-cell">Mother's Name<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="mname" id="mname" class="form-control"
                                        onchange="return checkValue('mnameError')" oninput="convertToUppercase(this)" />
                                    <span id="mnameError" class="error-text"></span>
                                </td>
                                <td class="label-cell">PWD Category<span>*</span>:</td>
                                <td class="input-cell">
                                    <select class="form-select" name="pwd_category" id="pwd_category"
                                        onchange="return checkValue('pwd_categoryError')">
                                        <option value="0">--- Select ---</option>
                                        <option value="1">Blind</option>
                                        <option value="2">Deaf</option>
                                        <option value="3">Motor Disability</option>
                                        <option value="4">Mental Disability</option>
                                    </select>
                                    <span id="pwd_categoryError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 8 -->
                            <tr>
                                <td class="label-cell">Ex-Servicemen<span>*</span>:</td>
                                <td class="input-cell pt-2 pb-2">
                                    <label><input type="radio" name="exs_radio" value="yes"
                                            onchange="setEXS(this.value)"> Yes</label>
                                    <label><input type="radio" name="exs_radio" value="no"
                                            onchange="setEXS(this.value)"> No</label>
                                    <input type="hidden" name="exs" id="exs" />
                                    <span id="exsError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Qualification<span>*</span>:</td>
                                <td class="input-cell">
                                    <select class="form-select" name="ssc" id="ssc"
                                        onchange="checkValue('sscError'); toggleInterMarks(this.value);">
                                        <option value="">-Select-</option>
                                        <option value="SSC">SSC Passed</option>
                                        <option value="Inter">Inter Passed</option>
                                    </select>
                                    <span id="sscError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Inter Marks Row (Hidden by default) -->
                            <tr id="interMarksRow" style="display: none;">
                                <td class="label-cell">Inter Marks<span>*</span>:</td>
                                <td class="input-cell" colspan="3">
                                    <input type="text" class="form-control" name="inter_marks" id="inter_marks"
                                        onchange="return checkValue('interMarksError')" maxlength="4"
                                        placeholder="Enter Inter Marks" style="width: 50%;" />
                                    <span id="interMarksError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 9 -->
                            <tr>
                                <td class="label-cell">Address<span>*</span>:</td>
                                <td class="input-cell">
                                    <textarea rows="2" class="form-control" name="addr" id="addr"
                                        onchange="return checkValue('addrError')" style="resize: none;"></textarea>
                                    <span id="addrError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Local/Non Local<span>*</span>:</td>
                                <td class="input-cell">
                                    <select class="form-select" name="loconoc" id="loconoc"
                                        onchange="return checkValue('loconocError')">
                                        <option value="">-select-</option>
                                        <option value="Local">Local</option>
                                        <option value="NonLocal">Non-Local</option>
                                    </select>
                                    <span id="loconocError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 10 -->
                            <tr>
                                <td class="label-cell">Pincode<span>*</span>:</td>
                                <td class="input-cell">
                                    <input type="text" name="pincode" id="pincode" class="form-control"
                                        onchange="return checkValue('pincodeError')" maxlength="6" />
                                    <span id="pincodeError" class="error-text"></span>
                                </td>
                                <td class="label-cell">Email:</td>
                                <td class="input-cell">
                                    <input type="email" name="email" id="email" class="form-control"
                                        onchange="return checkValue('emailError')" maxlength="50" />
                                    <span id="emailError" class="error-text"></span>
                                </td>
                            </tr>

                            <!-- Row 11 -->
                            <tr>
                                <td class="label-cell">Economic Weaker Section<span>*</span>:</td>
                                <td class="input-cell pt-2 pb-2">
                                    <label><input type="radio" name="ews_radio" value="yes"
                                            onchange="setEWS(this.value)"> Yes</label>
                                    <label><input type="radio" name="ews_radio" value="no"
                                            onchange="setEWS(this.value)"> No</label>
                                    <input type="hidden" name="ews" id="ews" />
                                    <span id="ewsError" class="error-text"></span>
                                </td>
                                <td class="label-cell">SSC Marks Type<span>*</span>:</td>
                                <td class="input-cell pt-2 pb-2">
                                    <select class="form-select" name="ssc_type" id="ssc_type"
                                        onchange="return checkValue('ssc_typeError'), ssctype(this.value)">
                                        <option value="">-select-</option>
                                        <option value="sscm">MARKS</option>
                                        <option value="sscg">GPA</option>
                                    </select>
                                    <span id="ssc_typeError" class="error-text"></span>
                                </td>
                            </tr>
                        </table>

                        <script>
                            function setPHC(val) { document.getElementById('phc').value = val; checkValue('phcError'); checkPwd(val); }
                            function setEXS(val) { document.getElementById('exs').value = val; checkValue('exsError'); }
                            function setEWS(val) { document.getElementById('ews').value = val; checkValue('ewsError'); }
                        </script>

                        <!-- MARKS SECTION -->
                        <div
                            style="background-color: #eef4fa; padding: 15px; border: 2px solid #195695; border-top: none; text-align: center;">
                            <div style="display: inline-block; text-align: left;">
                                <label
                                    style="font-weight: 600; color:#195695; font-size: 0.9rem; margin-right: 10px;">Number
                                    of Languages*</label>
                                <label style="margin-right: 15px; font-size: 0.85rem;"><input type="radio"
                                        name="nl_radio" value="2" onchange="setLangs('2')"> two</label>
                                <label style="font-size: 0.85rem;"><input type="radio" name="nl_radio" value="3"
                                        onchange="setLangs('3')" checked> three</label>
                                <input type="hidden" name="noOfLangs" id="noOfLangs" value="3">
                                <span id="noOfLangsError" class="error-text text-center"></span>
                            </div>

                            <script>
                                function setLangs(val) {
                                    document.getElementById('noOfLangs').value = val;
                                    checkValue('noOfLangsError');
                                    marksdiv(val);
                                }
                            </script>

                            <table style="margin: 15px auto; width: 400px; text-align: left; font-size: 0.85rem;">
                                <tr>
                                    <th style="width: 10%;">SNO</th>
                                    <th style="width: 50%;">Subjects</th>
                                    <th style="width: 40%;">Marks / GPA</th>
                                </tr>
                                <tr>
                                    <td>1</td>
                                    <td>First language</td>
                                    <td><input type="text" name="first_lang" id="first_lang"
                                            class="form-control text-center p-1 m-1 h-75"
                                            onchange="return checkValue('first_langError'), calculateTotal()"
                                            maxlength="3" /><span id="first_langError" class="error-text"></span></td>
                                </tr>
                                <tr id="slrow">
                                    <td>2</td>
                                    <td>Second Language:</td>
                                    <td><input type="text" name="second_lang" id="second_lang"
                                            class="form-control text-center p-1 m-1 h-75"
                                            onchange="return checkValue('second_langError'), calculateTotal()"
                                            maxlength="3" /><span id="second_langError" class="error-text"></span></td>
                                </tr>
                                <tr id="tlrow">
                                    <td>3</td>
                                    <td><span id="tl_label">Third Language- English</span></td>
                                    <td><input type="text" name="third_lang" id="third_lang"
                                            class="form-control text-center p-1 m-1 h-75"
                                            onchange="return checkValue('third_langError'), calculateTotal()"
                                            maxlength="3" /><span id="third_langError" class="error-text"></span></td>
                                </tr>
                                <tr>
                                    <td>4</td>
                                    <td>Mathematics:</td>
                                    <td><input type="text" name="maths" id="maths"
                                            class="form-control text-center p-1 m-1 h-75"
                                            onchange="return checkValue('mathsError'), calculateTotal()"
                                            maxlength="3" /><span id="mathsError" class="error-text"></span></td>
                                </tr>
                                <tr>
                                    <td>5</td>
                                    <td>General Science</td>
                                    <td><input type="text" name="science" id="science"
                                            class="form-control text-center p-1 m-1 h-75"
                                            onchange="return checkValue('scienceError'), calculateTotal()"
                                            maxlength="3" /><span id="scienceError" class="error-text"></span></td>
                                </tr>
                                <tr>
                                    <td>6</td>
                                    <td>Social studies</td>
                                    <td><input type="text" name="social" id="social"
                                            class="form-control text-center p-1 m-1 h-75"
                                            onchange="return checkValue('socialError'), calculateTotal()"
                                            maxlength="3" /><span id="socialError" class="error-text"></span></td>
                                </tr>
                                <tr>
                                    <td></td>
                                    <td style="font-weight: 600; text-align: right;">Total :</td>
                                    <td><input type="text" id="total_marks"
                                            class="form-control text-center p-1 m-1 h-75" readonly tabindex="-1"
                                            style="background-color:#e9ecef;"></td>
                                </tr>
                            </table>
                            <script>
                                function calculateTotal() {
                                    var f1 = parseFloat(document.getElementById('first_lang').value) || 0;
                                    var f2 = parseFloat(document.getElementById('second_lang').value) || 0;
                                    var f3 = parseFloat(document.getElementById('third_lang').value) || 0;
                                    var f4 = parseFloat(document.getElementById('maths').value) || 0;
                                    var f5 = parseFloat(document.getElementById('science').value) || 0;
                                    var f6 = parseFloat(document.getElementById('social').value) || 0;

                                    var total = f1 + f2 + f3 + f4 + f5 + f6;
                                    document.getElementById('total_marks').value = total > 0 ? total : "";
                                }
                            </script>
                        </div>

                        <!-- PHOTO & DECLARATION SECTION -->
                        <table
                            style="width: 100%; border-collapse: collapse; border: 2px solid #195695; border-top: none; background-color: #eef4fa;">
                            <tr>
                                <td
                                    style="width: 20%; padding: 10px; border-right: 1px solid #195695; text-align: center; vertical-align: top; background: white;">
                                    <div style="font-size: 0.85rem; font-weight: 600; margin-bottom: 5px;">Upload Photo:
                                    </div>
                                    <input type="file" name="photo" id="photo"
                                        style="font-size: 0.75rem; width: 100%; margin-bottom: 10px;"
                                        onchange="validatePhoto(this)" accept="image/png, image/jpeg, image/jpg" />
                                    <span id="photoError" class="error-text py-1"></span>
                                    <div id="photoPreviewContainer"
                                        style="width: 100px; height: 120px; border: 1px dashed #ccc; margin: 0 auto; display: flex; align-items: center; justify-content: center; background: #fafafa; overflow: hidden;">
                                        <img id="photoPreview" src="" alt="Preview"
                                            style="max-width: 100%; max-height: 100%; display: none;" />
                                        <span id="photoPlaceholderText" style="font-size: 0.7rem; color: #aaa;">No
                                            image</span>
                                    </div>
                                    <input type="hidden" id="base64Image" />
                                    <div style="font-size: 0.7rem; color: red; margin-top: 5px; font-weight: 600;">File
                                        less than 200kb and must be jpg/png images</div>
                                </td>
                                <td style="width: 80%; padding: 20px; vertical-align: top;">
                                    <div
                                        style="display: flex; align-items: flex-start; gap: 10px; background-color: white; padding: 15px; border: 1px solid #a6b8c7; border-radius: 4px;">
                                        <input type="checkbox" id="consent" style="margin-top: 4px;"
                                            onchange="checkValue('consentError')">
                                        <div style="font-size: 0.85rem; color: #333; line-height: 1.4;">
                                            <strong style="color:#000;">Above information is correct to the best of my
                                                knowledge</strong> and I hereby give my consent to the use of Aadhaar
                                            Number provided in the application to carryout identity verification for
                                            admission process. If any information found wrong, the authority may cancel
                                            my admission at any time without any prior notice.
                                        </div>
                                    </div>
                                    <span id="consentError" class="error-text" style="margin-left: 25px;"></span>

                                    <div style="text-align: center; margin-top: 30px;">
                                        <input type="button" value="APPLY NOW" class="btn"
                                            style="background-color: #2563eb; color: white; padding: 8px 40px; font-weight: 600; border-radius: 2px;"
                                            onclick="return customSendForm()" />
                                    </div>
                                </td>
                            </tr>
                        </table>

                        <script>
                            function validatePhoto(input) {
                                document.getElementById('photoError').innerText = "";
                                var file = input.files[0];
                                if (file) {
                                    var fileSize = file.size / 1024; // KB
                                    var fileType = file.type;

                                    if (fileType !== "image/jpeg" && fileType !== "image/jpg" && fileType !== "image/png") {
                                        input.value = "";
                                        document.getElementById('photoError').innerText = "Only JPG and PNG formats are allowed.";
                                        hidePreview();
                                        return false;
                                    }
                                    if (fileSize > 200) {
                                        input.value = "";
                                        document.getElementById('photoError').innerText = "File size (" + fileSize.toFixed(1) + " KB) exceeds 200 KB.";
                                        hidePreview();
                                        return false;
                                    }

                                    // Base64 logic wrapper if uploadImage exists in siteScript.js
                                    if (typeof uploadImage === "function") {
                                        uploadImage();
                                    }

                                    // Show preview
                                    var reader = new FileReader();
                                    reader.onload = function (e) {
                                        document.getElementById('photoPreview').src = e.target.result;
                                        document.getElementById('photoPreview').style.display = "block";
                                        document.getElementById('photoPlaceholderText').style.display = "none";
                                    }
                                    reader.readAsDataURL(file);
                                } else {
                                    hidePreview();
                                }
                            }

                            function hidePreview() {
                                document.getElementById('photoPreview').src = "";
                                document.getElementById('photoPreview').style.display = "none";
                                document.getElementById('photoPlaceholderText').style.display = "block";
                            }

                            function customSendForm() {
                                // Add validation for EWS radio/hidden if necessary, then call default
                                if (!document.getElementById('consent').checked) {
                                    document.getElementById('consentError').innerText = "Please accept the declaration.";
                                    alert("Please accept the declaration.");
                                    return false;
                                }
                                return sendData();
                            }
                        </script>

                    </form>
                </div><!-- end stdRegDiv -->

            </div><!-- end container -->
        </main>

        <footer>
            <%@include file="/WEB-INF/seniors/footer.jsp" %>
        </footer>

    </body>

    </html>