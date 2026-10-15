<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
    <head>
        <title>:: ITI :: Student Registration</title>

    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<title>:: ITI  ::</title>
<link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/iti.png" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/expe1011.css">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>

<style>
    #menu-bar {
  width: 100%;
  margin: 0px 0px 0px 0px;
  padding: 0px 0px 0px 0px;
  height: 30px;
  line-height: 100%;
  border-radius: 0px;
  -webkit-border-radius: 24px;
  -moz-border-radius: 24px;
  box-shadow: 2px 2px 2px #666666;
  -webkit-box-shadow: 2px 2px 2px #666666;
  -moz-box-shadow: 2px 2px 2px #666666;
  background: #e4eeb9;
  
/*border: solid 1px #6D6D6D*/
  position:relative;
  z-index:999;
}
#menu-bar li {
  margin: 0px 0px 6px 0px;
  padding: 0px 6px 0px 6px;
  float: left;
  position: relative;
  list-style: none;
}
#menu-bar a {
  font-weight: bold;
  font-family: verdana;
 /*font-style: oblique;*/
  font-size: 14px;
  color: #000000;
    background: #e4eeb9;
  text-decoration: none;
  display: block;
  padding: 6px 20px 6px 20px;
  margin: 0;
  margin-bottom: 6px;
 /*border-radius: 10px;*/
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
 /*text-shadow: 0px 0px 0px #000000;*/
}
#menu-bar li ul li a {
  margin: 0;
}
#menu-bar .active a, #menu-bar li:hover > a {
  background:blue;
  background: lightblue;
 background: -ms-linear-gradient(top,  #EB4954,  #A19197);
  background: -webkit-gradient(linear, left top, left bottom, from(#EB4954), to(#A19197));
  background: -moz-linear-gradient(top,  #EB4954,  #A19197);
  color: white;
  -webkit-box-shadow: 0 1px 1px rgba(0, 0, 0, .2);
  -moz-box-shadow: 0 1px 1px rgba(0, 0, 0, .2);
  box-shadow: 0 1px 1px rgba(0, 0, 0, .2);
 /*text-shadow: 3px 2px 3px #FFFFFF;*/
}
#menu-bar ul li:hover a, #menu-bar li:hover li a {
  background: lightgoldenrodyellow;
 /*border: none;*/
  color: #000000;
  -box-shadow: none;
 -webkit-box-shadow: none;
  -moz-box-shadow: none;
}
#menu-bar ul a:hover {
  background: lightblue!important;
  color: black !important;
  border-radius: 0;
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
}
#menu-bar li:hover > ul {
  display: block;
}
#menu-bar ul {
  background: block;
  background: linear-gradient(top,  #FFD21C,  #CF7688);
  background: -ms-linear-gradient(top,  #FFD21C,  #CF7688);
  background: -webkit-gradient(linear, left top, left bottom, from(#FFD21C), to(#CF7688));
  background: -moz-linear-gradient(top,  #FFD21C,  #CF7688);
  display: none;
  margin: 0;
  padding: 0;
  width: 300px;
  position: absolute;
  top: 30px;
  left: 0;
  border-radius: 0px;
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
  -webkit-box-shadow: 2px 2px 3px #222222;
  -moz-box-shadow: 2px 2px 3px #222222;
  box-shadow: 2px 2px 3px #222222;
}
#menu-bar ul li {
  float: none;
  margin: 0;
  padding: 0;
}
#menu-bar ul a {
  padding:10px 0px 10px 15px;
   background: gold;
  color:grey;
  font-size:13px;
  font-style:normal;
  font-family:verdana;
  font-weight: normal;
  text-shadow: 2px 2px 3px #FFFFFF;
}
#menu-bar ul li:first-child > a {
  border-top-left-radius: 10px;
  -webkit-border-top-left-radius: 10px;
  -moz-border-radius-topleft: 10px;
  border-top-right-radius: 10px;
  -webkit-border-top-right-radius: 10px;
  -moz-border-radius-topright: 10px;
}
#menu-bar ul li:last-child > a {
  border-bottom-left-radius: 10px;
  -webkit-border-bottom-left-radius: 10px;
  -moz-border-radius-bottomleft: 10px;
  border-bottom-right-radius: 10px;
  -webkit-border-bottom-right-radius: 10px;
  -moz-border-radius-bottomright: 10px;
}
#menu-bar:after {
  content: ".";
  display: block;
  clear: both;
  visibility: hidden;
  line-height: 0;
  height: 0;
}
#menu-bar {
  display: inline-block;
}
  html[xmlns] #menu-bar {
  display: block;
}
* html #menu-bar {
  height: 1%;
} 
</style>

        <script type="text/javascript">
            
            $(function() {
                $('#ssc_regno').keyup(function() {
                    this.value = this.value.toLocaleUpperCase();
                });
             });
             
            function NumericsOnly(evt) {
                var charCode = (evt.which) ? evt.which : event.keyCode;
                if (charCode > 31 && (charCode < 48 || charCode > 57)) return false;
                return true;
            }

            function limitText(el, n) { if (el.value.length > n) el.value = el.value.substring(0, n); }

            function validate() {
                
                //captcha
                var captcha = document.getElementById("captcha").value;
                if(captcha === null || captcha === ""){
                    document.getElementById("captcha").focus();
                    alert("plese eneter Captcha"); return false;
                }
                //ssc_board
                var ssc_board = document.getElementById("ssc_board").value;
                if(ssc_board === null || ssc_board === ""){
                    document.getElementById("ssc_board").focus();
                    alert("plese eneter SSC/8th Board"); return false;
                }
                //ssc_regno
                var ssc_regno = document.getElementById("ssc_regno").value;
                if(ssc_regno === null || ssc_regno === ""){
                    document.getElementById("ssc_regno").focus();
                    alert("plese eneter SSC/8th Hall Ticket Number"); return false;
                }
                //passed_year
                var passed_year = document.getElementById("passed_year").value;
                if(passed_year === null || passed_year === ""){
                    document.getElementById("passed_year").focus();
                    alert("plese eneter Year Of Passing"); return false;
                }
                //ssc_type
                var ssc_type = document.getElementById("ssc_type").value;
                if(ssc_type === null || ssc_type === ""){
                    document.getElementById("ssc_type").focus();
                    alert("plese eneter Result Type"); return false;
                }
                
            return true;   
            }
            function getDate() {

                var passed_year = $('#passed_year').val();

                var d = new Date();
                var n = d.getFullYear();

                if (passed_year > n) {
                    alert("Year Of Passing cannot be greater than " + n + "");
                    $('#passed_year').val('');
                    $('#passed_year').focus();

                    return false;
                }
                return true;
            }    
            
            
        </script>
 
        <script type="text/javascript">
                $(document).ready(function () {
                    $.ajaxSetup({
                        cache: false
                    });
                     
                $("#captchaRef").click(function () {
                        var timestamp = (new Date()).getTime();
                        var newSrc = $("#captchaImage").attr("src").split("?");
                        newSrc = newSrc[0] + "?" + timestamp;
                        $("#captchaImage").attr("src", newSrc);
                        $("#captchaImage").slideDown("fast");

                    });
                });

                $(document).ready(function () {
                    $('#captcha').keypress(function (ev) {
                        if (ev.keyCode === 13) 
                            $('#mysubmit').click();
                    });
                });
            
        </script>
        <script type="text/javascript">
            var SESSION_YEAR = '';

            // Current session year/phase come from admissions.admission_phase (current = true) via
            // the reports endpoint, mirroring itiap_new's open_application_entry.jsp lookup.
            $(document).ready(function () {
                $.get('${backendBaseUrl}/api/reports/current-admission-phase', function (data) {
                    if (data && data.year) {
                        SESSION_YEAR = String(data.year);
                        $('#sessionYearPhase').text(SESSION_YEAR + '(Phase-' + data.phase + ')');
                        $('#sessionYearPhase2').text(SESSION_YEAR + '(Phase-' + data.phase + ')');
                    }
                });
            });

            // Proceed: validate -> check captcha -> POST /api/student/save -> show RegId
            function submitRegistration() {
                if (!validate()) return false;
                if (!getDate()) return false;

                var enteredCaptcha = document.getElementById("captcha").value.trim().toUpperCase();
                $.get('${pageContext.request.contextPath}/captcha/text', function (serverCaptcha) {
                    if (enteredCaptcha !== String(serverCaptcha).trim().toUpperCase()) {
                        alert("Captcha does not match. Please try again.");
                        $("#captchaRef").click();
                        document.getElementById("captcha").value = "";
                        document.getElementById("captcha").focus();
                        return;
                    }
                    var payload = {
                        sscBoard: document.getElementById("ssc_board").value,
                        sscRegNo: document.getElementById("ssc_regno").value.trim(),
                        sscYear:  document.getElementById("passed_year").value,
                        sscType:  document.getElementById("ssc_type").value,
                        year:     SESSION_YEAR
                    };
                    $.ajax({
                        url: '${backendBaseUrl}/api/student/save',
                        type: 'POST',
                        contentType: 'application/json',
                        data: JSON.stringify(payload),
                        success: function (student) {
                            var resumed = student && student.resumed === true;
                            document.getElementById("regFormDiv").style.display = "none";
                            if (resumed) {
                                $('#regResult').html(
                                    '<div style="background-color:#d4edda;border:2px solid #28a745;padding:20px;margin:10px auto;width:60%;">'
                                    + '<h3 style="color:#155724;">Already Registered for this SSC Hall Ticket</h3>'
                                    + '<p style="font-size:18px;color:#155724;">An application already exists for this SSC Hall Ticket Number and the details match. '
                                    + 'Your existing Registration ID is: <b>' + student.regid + '</b></p>'
                                    + '<p style="color:#155724;">Your earlier registration details are loaded below. Please verify/complete the personal details and SSC marks, then click <b>APPLY NOW</b> to continue.</p>'
                                    + '</div>');
                                resumeExisting(student.regid);
                            } else {
                                $('#regResult').html(
                                    '<div style="background-color:#d4edda;border:2px solid #28a745;padding:20px;margin:10px auto;width:60%;">'
                                    + '<h3 style="color:#155724;">SSC Details Verified!</h3>'
                                    + '<p style="color:#155724;">Now complete your application details and SSC marks below, then click <b>APPLY NOW</b> to get your Registration ID.</p>'
                                    + '</div>');
                                showStep2(null, document.getElementById("ssc_type").value);
                            }
                            window.scrollTo(0, 0);
                        },
                        error: function (xhr) {
                            var msg = 'Registration failed. Please try again.';
                            if (xhr.responseJSON && xhr.responseJSON.message) msg = xhr.responseJSON.message;
                            $('#regResult').html('<div style="background-color:#f8d7da;border:2px solid #dc3545;padding:15px;margin:10px auto;width:60%;color:#721c24;"><b>Error:</b> ' + msg + '</div>');
                        }
                    });
                });
                return false;
            }
        </script>

        <script type="text/javascript">
            // ================= Stage 2: personal details + SSC marks =================
            // Option A split: registration now collects everything except the ITI/district
            // selection, which lives on /student-apply. Mirrors open_Application_Interface_Student.jsp.
            var CURRENT_REGID = null;
            var CURRENT_SSC_TYPE = null;
            var __castesLoaded = false;

            function regVal(id) { var v = document.getElementById(id).value.trim(); return v === "" ? null : v; }

            function radioVal(name) {
                var els = document.getElementsByName(name);
                for (var i = 0; i < els.length; i++) { if (els[i].checked) { return els[i].value; } }
                return "";
            }

            function regPreviewPhoto(input) {
                var img = document.getElementById("uploadPreview");
                if (!img) { return; }
                img.src = "";
                if (!input || !input.files || input.files.length === 0) { return; }
                var file = input.files[0];
                if (file.type !== "image/png" && file.type !== "image/jpeg") {
                    input.value = "";
                    alert("Please select a PNG or JPEG image.");
                    return;
                }
                img.src = URL.createObjectURL(file);
            }

            function loadCastes() {
                if (__castesLoaded) { return; }
                __castesLoaded = true;
                $.get('${backendBaseUrl}/api/student/castes', function (list) {
                    $.each(list, function (i, c) {
                        $('#casteSelect').append('<option value="' + c.casteCode + '">' + c.casteName + '</option>');
                    });
                });
            }

            function loadSubCastes() {
                var code = document.getElementById("casteSelect").value;
                var sel = document.getElementById("subCasteSelect");
                sel.innerHTML = '<option value="">--Select Sub Caste--</option>';
                if (!code) { return; }
                $.get('${backendBaseUrl}/api/student/subcastes/' + encodeURIComponent(code))
                    .done(function (list) {
                        (list || []).forEach(function (r) {
                            var label = (r.subCasteName && r.subCasteName !== '') ? r.subCasteName : ('Sub-caste ' + r.subCasteId);
                            var opt = document.createElement('option');
                            opt.value = r.subCasteId; opt.textContent = label + ' (' + r.subCasteId + ')';
                            sel.appendChild(opt);
                        });
                    });
            }

            function showStep2(regid, sscType) {
                CURRENT_REGID = regid;
                CURRENT_SSC_TYPE = sscType;
                loadCastes();
                document.getElementById("sscRegDisp").value = document.getElementById("ssc_regno").value;
                document.getElementById("boardDisp").value = boardName();
                document.getElementById("sscYearDisp").value = document.getElementById("passed_year").value;
                document.getElementById("regFormDiv").style.display = "none";
                if (sscType === 'sscm') {
                    document.getElementById("gpaRow").style.display = "none";
                    document.querySelectorAll('.gpaRow2').forEach(function (r) { r.style.display = "none"; });
                    document.getElementById("marksRow").style.display = "";
                    document.querySelectorAll('.marksRow2').forEach(function (r) { r.style.display = ""; });
                } else {
                    document.getElementById("marksRow").style.display = "none";
                    document.querySelectorAll('.marksRow2').forEach(function (r) { r.style.display = "none"; });
                    document.getElementById("gpaRow").style.display = "";
                    document.querySelectorAll('.gpaRow2').forEach(function (r) { r.style.display = ""; });
                }
                document.getElementById("step2Div").style.display = "";
            }

            function setRadio(name, value) {
                var els = document.getElementsByName(name);
                for (var i = 0; i < els.length; i++) { els[i].checked = (els[i].value === value); }
            }

            // Resume path: an application for this SSC Hall Ticket already exists. Load the
            // saved record (and marks) and re-open the personal-details form so the candidate
            // can verify/complete it instead of being sent straight to district selection.
            function resumeExisting(regid) {
                $.get('${backendBaseUrl}/api/student/' + regid, function (s) {
                    showStep2(s.regid, s.sscType);
                    prefillExisting(s);
                    $.get('${backendBaseUrl}/api/student/marks/' + regid, function (m) { prefillMarks(m); });
                    window.scrollTo(0, 0);
                }).fail(function () {
                    alert("Could not load the existing registration. Please try again.");
                });
            }

            function prefillExisting(s) {
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
                setRadio("phc", s.phc === true ? 'yes' : (s.phc === false ? 'no' : ''));
                setRadio("exs", s.exservice === true ? 'yes' : (s.exservice === false ? 'no' : ''));
                setRadio("ews", s.economicWeakerSection === true ? 'yes' : (s.economicWeakerSection === false ? 'no' : ''));
                if (s.caste) {
                    if (!$('#casteSelect option[value="' + s.caste + '"]').length) {
                        $('#casteSelect').append('<option value="' + s.caste + '" selected>' + s.caste + '</option>');
                    } else {
                        $('#casteSelect').val(s.caste);
                    }
                }
                if (s.subCaste && !$('#subCasteSelect option[value="' + s.subCaste + '"]').length) {
                    $('#subCasteSelect').append('<option value="' + s.subCaste + '" selected>' + s.subCaste + '</option>');
                }
                if (s.regid) {
                    $.get('${backendBaseUrl}/api/student/photo/' + s.regid, function (r) {
                        var img = document.getElementById("uploadPreview");
                        if (r && r.photo) { img.src = 'data:image/jpeg;base64,' + r.photo; }
                    });
                }
            }

            function prefillMarks(m) {
                if (!m) { return; }
                var gpa = (CURRENT_SSC_TYPE !== 'sscm');
                var map = gpa
                    ? [["g_firstlang","sscFirstLangGpa"],["g_secondlang","sscSecondLangGpa"],["g_english","sscEngGpa"],
                       ["g_math","sscMathGpa"],["g_science","sscSciGpa"],["g_social","sscSocialGpa"],["g_total","sscTotGpa"]]
                    : [["m_firstlang","sscFirstLangMarks"],["m_secondlang","sscSecondLangMarks"],["m_english","sscEngMarks"],
                       ["m_math","sscMathMarks"],["m_science","sscSciMarks"],["m_social","sscSocialMarks"],["m_total","sscTotMarks"]];
                for (var i = 0; i < map.length; i++) {
                    var el = document.getElementById(map[i][0]);
                    if (el && m[map[i][1]] !== null && m[map[i][1]] !== undefined) { el.value = m[map[i][1]]; }
                }
                if (typeof recalcTotal === 'function') { recalcTotal(); }
            }

            function validateDetails() {
                function required(id, label) {
                    var el = document.getElementById(id);
                    if (!el || String(el.value).trim() === "") {
                        alert("Please enter " + label);
                        if (el && el.focus) { el.focus(); }
                        return false;
                    }
                    return true;
                }

                if (!required("ssc_month", "SSC Month")) return false;
                if (!required("name", "Applicants name")) return false;
                if (!required("phno", "mobile number")) return false;
                if (!/^\d{10}$/.test(document.getElementById("phno").value.trim())) { alert("Mobile Number must be 10 digits."); return false; }
                if (!required("appdob", "Date of Birth")) return false;
                if (!required("adarno", "Adhar No")) return false;
                if (!/^\d{12}$/.test(document.getElementById("adarno").value.trim())) { alert("Aadhar Number must be 12 digits."); return false; }
                if (!radioVal("gender")) { alert("Please Select Gender"); return false; }
                if (!required("fname", "Father name")) return false;
                if (!required("mname", "Mother name")) return false;
                if (!required("addr", "Address")) return false;
                if (!required("local", "Local/Non local")) return false;
                if (!required("casteSelect", "Caste")) return false;
                if (!radioVal("phc")) { alert("Please Select Physically Challenged"); return false; }
                if (radioVal("phc") === "yes" && String(document.getElementById("pwdCategory").value).trim() === "") { alert("please Enter PWD category"); return false; }
                if (!radioVal("exs")) { alert("Please Select Ex-Servicemen"); return false; }
                if (!required("ssc", "Qualification Id")) return false;
                if (!radioVal("ews")) { alert("Please Select Economic Weaker Section"); return false; }

                var email = document.getElementById("email").value.trim();
                if (email === "") { alert("Please Enter Email"); return false; }
                if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) { alert("Please Enter valid Email"); return false; }

                var p = document.getElementById("photo");
                if (!p || !p.files || p.files.length === 0) { alert("Please upload your photograph (PNG or JPEG)."); return false; }

                var consent = document.getElementById("consent");
                if (!consent || !consent.checked) { alert("Consent is required"); return false; }

                var board = document.getElementById("ssc_board") ? document.getElementById("ssc_board").value : '';
                var year = document.getElementById("passed_year") ? document.getElementById("passed_year").value : '';
                var qual = document.getElementById("ssc").value;
                if (!(year === "2020" && qual === "yes" && board === "28")) {
                    var gpa = (CURRENT_SSC_TYPE !== 'sscm');
                    var suffix = gpa ? 'GPA' : 'Marks';
                    var fields = [
                        [gpa ? "g_firstlang" : "m_firstlang", "First Language " + suffix],
                        [gpa ? "g_english" : "m_english", "Third Language " + suffix],
                        [gpa ? "g_math" : "m_math", "Maths " + suffix],
                        [gpa ? "g_science" : "m_science", "Science " + suffix],
                        [gpa ? "g_social" : "m_social", "Social " + suffix]
                    ];
                    for (var i = 0; i < fields.length; i++) {
                        if (!required(fields[i][0], fields[i][1])) return false;
                    }
                    var sub2 = document.getElementById("sub2");
                    if (sub2 && sub2.checked) {
                        if (!required(gpa ? "g_secondlang" : "m_secondlang", "Second Language " + suffix)) return false;
                    }
                }
                return true;
            }

            function doSubmitDetailsAndMarks() {
                if (!validateDetails()) return false;
                var btn = document.getElementById("regSaveBtn");
                btn.disabled = true; btn.value = "Saving...";

                var payload = {
                    regid: CURRENT_REGID,
                    sscRegNo: document.getElementById("ssc_regno").value.trim(),
                    sscBoard: document.getElementById("ssc_board").value,
                    sscYear: document.getElementById("passed_year").value,
                    sscType: CURRENT_SSC_TYPE || document.getElementById("ssc_type").value,
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
                    exservice: radioVal("exs") === "yes",
                    year: SESSION_YEAR
                };

                var m = {};
                if (CURRENT_SSC_TYPE === 'sscm') {
                    m.sscFirstLangMarks = regVal("m_firstlang"); m.sscSecondLangMarks = regVal("m_secondlang");
                    m.sscEngMarks = regVal("m_english"); m.sscMathMarks = regVal("m_math");
                    m.sscSciMarks = regVal("m_science"); m.sscSocialMarks = regVal("m_social");
                    m.sscTotMarks = regVal("m_total");
                    // Legacy convert(): derive subject GPAs from marks so ssc_*_gpa is always
                    // populated (the merit ranking reads only the GPA columns).
                    m.sscFirstLangGpa = marksToGpa(m.sscFirstLangMarks, false);
                    m.sscSecondLangGpa = marksToGpa(m.sscSecondLangMarks, true);
                    m.sscEngGpa = marksToGpa(m.sscEngMarks, false);
                    m.sscMathGpa = marksToGpa(m.sscMathMarks, false);
                    m.sscSciGpa = marksToGpa(m.sscSciMarks, false);
                    m.sscSocialGpa = marksToGpa(m.sscSocialMarks, false);
                    // Legacy add(): tot_gpa = average of subject GPAs (5 when "two" languages, else 6).
                    var twoLang = !!(document.getElementById("sub1") && document.getElementById("sub1").checked);
                    var gpaVals = twoLang
                        ? [m.sscFirstLangGpa, m.sscEngGpa, m.sscMathGpa, m.sscSciGpa, m.sscSocialGpa]
                        : [m.sscFirstLangGpa, m.sscSecondLangGpa, m.sscEngGpa, m.sscMathGpa, m.sscSciGpa, m.sscSocialGpa];
                    var gpaSum = 0;
                    for (var gi = 0; gi < gpaVals.length; gi++) { gpaSum += parseFloat(gpaVals[gi]) || 0; }
                    m.sscTotGpa = String(Math.round((gpaSum / gpaVals.length) * 10) / 10);
                } else {
                    m.sscFirstLangGpa = regVal("g_firstlang"); m.sscSecondLangGpa = regVal("g_secondlang");
                    m.sscEngGpa = regVal("g_english"); m.sscMathGpa = regVal("g_math");
                    m.sscSciGpa = regVal("g_science"); m.sscSocialGpa = regVal("g_social");
                    m.sscTotGpa = regVal("g_total");
                }

                var fd = new FormData();
                fd.append("application", new Blob([JSON.stringify(payload)], { type: "application/json" }));
                fd.append("marks", new Blob([JSON.stringify(m)], { type: "application/json" }));
                var fileInput = document.getElementById("photo");
                if (fileInput && fileInput.files && fileInput.files.length > 0) { fd.append("photo", fileInput.files[0]); }

                $.ajax({
                    url: '${backendBaseUrl}/api/student/register',
                    type: 'POST', data: fd, processData: false, contentType: false,
                    success: function (saved) {
                        if (saved && saved.regid) { CURRENT_REGID = saved.regid; }
                        document.getElementById("step2Div").style.display = "none";
                        $('#step2Result').html(
                            '<div style="background-color:#d4edda;border:2px solid #28a745;padding:20px;margin:10px auto;width:70%;">'
                            + '<h3 style="color:#155724;">Registration Successful!</h3>'
                            + '<p style="color:#155724;">Your application details and SSC marks are saved. Please note down your Registration ID: <b>'
                            + CURRENT_REGID + '</b></p>'
                            + '<p><a href="${pageContext.request.contextPath}/student-apply">Click here to continue to Step 2 - Apply for ITI (select your districts)</a></p></div>');
                        window.scrollTo(0, 0);
                    },
                    error: function (xhr) {
                        btn.disabled = false; btn.value = "APPLY NOW";
                        var msg = (xhr.responseJSON && xhr.responseJSON.message) ? xhr.responseJSON.message
                            : "Failed to save application details. Please check the values and try again.";
                        alert(msg);
                    }
                });
                return false;
            }

            // ================= Confirmation modal (registration3) =================
            // Review every entered detail before the real save (photo -> update -> marks).
            function optText(id) {
                var el = document.getElementById(id);
                if (!el) { return ''; }
                if (el.tagName === 'SELECT') { return (el.options[el.selectedIndex] ? el.options[el.selectedIndex].text : ''); }
                return el.value;
            }
            function yesNo(name) {
                var v = radioVal(name);
                return v === 'yes' ? 'Yes' : (v === 'no' ? 'No' : '');
            }
            function confirmSubmit() {
                if (!validateDetails()) return false;
                var gpa = (CURRENT_SSC_TYPE !== 'sscm');
                var gender = radioVal("gender");
                document.getElementById("c_sscregno").textContent = optText("ssc_regno");
                document.getElementById("c_board").textContent = boardName();
                document.getElementById("c_year").textContent = optText("passed_year");
                document.getElementById("c_sscmonth").textContent = optText("ssc_month");
                document.getElementById("c_name").textContent = document.getElementById("name").value.trim();
                document.getElementById("c_fname").textContent = document.getElementById("fname").value.trim();
                document.getElementById("c_mname").textContent = document.getElementById("mname").value.trim();
                document.getElementById("c_gender").textContent = gender ? (gender.charAt(0).toUpperCase() + gender.slice(1)) : '';
                document.getElementById("c_dob").textContent = optText("appdob");
                document.getElementById("c_adarno").textContent = optText("adarno");
                document.getElementById("c_phno").textContent = optText("phno");
                document.getElementById("c_email").textContent = optText("email");
                document.getElementById("c_addr").textContent = optText("addr");
                document.getElementById("c_pincode").textContent = optText("pincode");
                document.getElementById("c_caste").textContent = optText("casteSelect");
                document.getElementById("c_subcaste").textContent = optText("subCasteSelect");
                document.getElementById("c_local").textContent = optText("local");
                document.getElementById("c_phc").textContent = yesNo("phc");
                document.getElementById("c_pwd").textContent = optText("pwdCategory") || 'None';
                document.getElementById("c_exs").textContent = yesNo("exs");
                document.getElementById("c_qual").textContent = optText("ssc");
                document.getElementById("c_ews").textContent = yesNo("ews");
                document.getElementById("c_langs").textContent = (document.getElementById("sub2") && document.getElementById("sub2").checked) ? 'Three' : 'Two';
                document.getElementById("c_ssctype").textContent = gpa ? 'GPA' : 'Marks';
                document.getElementById("c_mogpa").textContent = gpa ? 'GPA' : 'Marks';
                var p = gpa
                    ? ['g_firstlang','g_secondlang','g_english','g_math','g_science','g_social','g_total']
                    : ['m_firstlang','m_secondlang','m_english','m_math','m_science','m_social','m_total'];
                var t = ['c_firstlang','c_secondlang','c_english','c_math','c_science','c_social','c_total'];
                for (var i = 0; i < p.length; i++) {
                    var el = document.getElementById(p[i]);
                    document.getElementById(t[i]).textContent = el ? el.value : '';
                }
                document.getElementById("confirmModal").style.display = "block";
                return false;
            }

            function boardName() {
                var sel = document.getElementById("ssc_board");
                return (sel && sel.options[sel.selectedIndex]) ? sel.options[sel.selectedIndex].text : '';
            }

            function proceedSubmit() {
                document.getElementById("confirmModal").style.display = "none";
                doSubmitDetailsAndMarks();
                return false;
            }

            function closeConfirm() {
                document.getElementById("confirmModal").style.display = "none";
                return false;
            }

            // ================= SSC total auto-computation =================
            // Marks total = sum of the six subject marks.
            // GPA total   = average of the subject GPAs (5 subjects when "two" languages,
            //               else 6), rounded to one decimal. Port of the legacy
            //               add()/addtotalmarks() in web/js/applicationScript.js, which is
            //               what the merit ranking reads (ssc_tot_gpa / ssc_tot_marks).
            function recalcTotal() {
                function num(id) {
                    var el = document.getElementById(id);
                    if (!el) { return null; }
                    var v = parseFloat(el.value);
                    return isNaN(v) ? null : v;
                }
                var twoLang = !!(document.getElementById("sub1") && document.getElementById("sub1").checked);

                var gpaIds = twoLang
                    ? ["g_firstlang", "g_english", "g_math", "g_science", "g_social"]
                    : ["g_firstlang", "g_secondlang", "g_english", "g_math", "g_science", "g_social"];
                var anyGpa = false, gpaSum = 0, i;
                for (i = 0; i < gpaIds.length; i++) { var g = num(gpaIds[i]); if (g !== null) { anyGpa = true; gpaSum += g; } }
                var gTotal = document.getElementById("g_total");
                if (gTotal) { gTotal.value = anyGpa ? (Math.round((gpaSum / gpaIds.length) * 10) / 10) : ""; }

                var markIds = ["m_firstlang", "m_secondlang", "m_english", "m_math", "m_science", "m_social"];
                var anyMark = false, markSum = 0;
                for (i = 0; i < markIds.length; i++) { var m = num(markIds[i]); if (m !== null) { anyMark = true; markSum += m; } }
                var mTotal = document.getElementById("m_total");
                if (mTotal) { mTotal.value = anyMark ? markSum : ""; }
            }

            // Port of the legacy web/js/conversionLogic.js convert(secondLang, source, target).
            // Derives a subject GPA from its marks. The second language uses a different scale.
            // In legacy the "sscm" (marks) branch wired each marks input's onchange to this, so
            // cand_marks.ssc_*_gpa was ALWAYS populated; the merit ranking orders solely by GPA,
            // hence the derived values must still be stored when the candidate entered marks.
            function marksToGpa(marks, secondLang) {
                var m = parseFloat(marks);
                if (isNaN(m)) { m = 0; }
                var gpa;
                if (secondLang) {
                    if (m >= 90) gpa = '10';
                    else if (m >= 80) gpa = '9';
                    else if (m >= 70) gpa = '8';
                    else if (m >= 60) gpa = '7';
                    else if (m >= 50) gpa = '6';
                    else if (m >= 40) gpa = '5';
                    else if (m >= 30) gpa = '4';
                    else if (m >= 20) gpa = '3';
                    else gpa = '0';
                } else {
                    if (m >= 92) gpa = '10';
                    else if (m >= 83) gpa = '9';
                    else if (m >= 75) gpa = '8';
                    else if (m >= 67) gpa = '7';
                    else if (m >= 59) gpa = '6';
                    else if (m >= 51) gpa = '5';
                    else if (m >= 43) gpa = '4';
                    else if (m >= 35) gpa = '3';
                    else gpa = '0';
                }
                return gpa;
            }

            $(function () {
                var subjectIds = ["g_firstlang", "g_secondlang", "g_english", "g_math", "g_science", "g_social",
                                  "m_firstlang", "m_secondlang", "m_english", "m_math", "m_science", "m_social"];
                subjectIds.forEach(function (id) {
                    var el = document.getElementById(id);
                    if (el) { el.addEventListener("input", recalcTotal); el.addEventListener("change", recalcTotal); }
                });
                ["sub1", "sub2"].forEach(function (id) {
                    var el = document.getElementById(id);
                    if (el) { el.addEventListener("change", recalcTotal); }
                });
                ["g_total", "m_total"].forEach(function (id) {
                    var el = document.getElementById(id);
                    if (el) { el.readOnly = true; el.style.backgroundColor = "silver"; }
                });
            });

            $(document).on('change', '#casteSelect', loadSubCastes);
        </script>

        <style>
             #submit,#submit1,#reset{
                font-weight: bolder;
                border: none;
                width: 25%;
                border-radius: 4px;
            }
            #submit{ background-color: lightgreen; } 
            #submit1{ background-color: lightsalmon; width: 25%; }
            #reset{ background-color: tomato; }
            #captchaRef{
                background-color: #00c6fb; 
                size: auto;
                border-radius: 4px;
                border: none; 
                font-weight: bolder;
            }
            table{ 
                width: 60%; 
                height: 30%;
                background-color: #cbd6b2;
                border: 2px solid black;
            }
            #heading{ 
                color: black; 
                text-align: center; 
                font-size: larger; 
                background-color: #cbd6b2; 
                 
            }
            .container{ background-color: #00c6fb;}
            td{ padding-bottom: 10px; padding-left: 10px; font-weight: bolder; }

            /* Stage 2 - legacy registration form look (open_Application_Interface_Student.jsp) */
            #step2Table{ width:auto; height:auto; margin:0 auto; background-color:#b7e2f3; border:1px solid #000; }
            #step2Table td{ font-weight:normal; color:#000; padding:6px 8px; vertical-align:top; border:1px solid #7ba7c9; }
            #step2Table table{ width:auto; height:auto; margin:0 auto; background-color:#b7e2f3; border:1px solid #000; }
            #step2Table input[type=text], #step2Table input[type=date],
            #step2Table select, #step2Table textarea{ background-color:#fff; }
        </style>
        
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/legacy-form.css">
    <%@ include file="_windowGate.jsp" %>
    <body class="lg-page">
        
<center>
    <img src="${pageContext.request.contextPath}/images/gen.jpg" id="banner-id" width="100%">
</center>

<div id="regResult"></div>

<div id="regFormDiv">
        <form name="open_Application_Step1_form" method="post" action="#" onsubmit="return submitRegistration()">
            <h2 style="background-color: lightgreen" align="center"  class="style4">
                Registration Form for Admission into the Industrial Training Institute for the session 
                <span id="sessionYearPhase"></span></h2>
            
            <table align="center">
                <tr bgcolor="#3399ff">
                    <td colspan="3" id="heading"><u>Registration Form-Step1</u></td>
                    
                </tr>
                <tr>
                    <td>SSC/8th Board<font color="red">*</font></td>
                    <td><select name="ssc_board" id="ssc_board">
                            <option value="">--Select Board Here--</option>
                            <option value='28' >Andhra Pradesh State Board (SSC)</option><option value='35' >Andman & Nicobar Islands State Board</option><option value='54' >AP-OSC</option><option value='53' >AP-OSSC</option><option value='12' >Arunachal Pradesh State Board</option><option value='18' >Assam State Board</option><option value='10' >Bihar State Board</option><option value='51' >CBSE</option><option value='4 ' >Chandigarh State Board</option><option value='22' >Chhattisgarh State Board</option><option value='26' >Dadra & Nagar Haveli State Board</option><option value='25' >Daman & Diu State Board</option><option value='7 ' >Delhi State Board</option><option value='30' >Goa State Board</option><option value='24' >Gujarat State Board</option><option value='6 ' >Haryana State Board</option><option value='2 ' >Himachal Pradesh State Board</option><option value='52' >ICSE</option><option value='1 ' >Jammu & Kashmir State Board</option><option value='20' >Jharkhand State Board</option><option value='29' >Karnataka State Board</option><option value='32' >Kerala State Board</option><option value='31' >Lakshadweep State Board</option><option value='23' >Madhya Pradesh State Board</option><option value='27' >Maharashtra State Board</option><option value='14' >Manipur State Board</option><option value='17' >Meghalaya State Board</option><option value='15' >Mizoram State Board</option><option value='13' >Nagaland State Board</option><option value='21' >Orissa State Board</option><option value='60' >Other</option><option value='34' >Pondicherry State Board</option><option value='3 ' >Punjab State Board</option><option value='8 ' >Rajasthan State Board</option><option value='11' >Sikkim State Board</option><option value='33' >Tamil nadu State Board</option><option value='36' >Telangana</option><option value='16' >Tripura State Board</option><option value='5 ' >Uttarakhand State Board</option><option value='9 ' >Utter Pradesh State Board</option><option value='19' >West Bengal State Board</option>
                        </select>
                    </td>
                </tr>
                <tr>
                    <td>SSC/8th Hall Ticket Number<font color="red">*</font></td>
                    <td><input type="text"  name="ssc_regno" id="ssc_regno" pattern='[0-9A-Z]{6,15}' title="number should be 6 to 15 digits" maxlength="15" onkeydown="limitText(this, 15);" /></td>
                </tr>
                <tr>
                    <td>Year Of Passing<font color="red">*</font></td>
                    <td><input type="text" name="passed_year" maxlength="4" value="" onkeydown="limitText(this,15);" onkeypress="return NumericsOnly(event);" onchange="return getDate();" id="passed_year"></td>
                </tr>
                <tr>
                    <td>Result Type<font color="red">*</font></td>
                    <td colspan="2">
                        <select name="ssc_type" id="ssc_type"><option value="" selected="selected">--Select--</option>
                            <option value="sscg">GPA</option>
                            <option value="sscm">Marks</option></select> </td>
                </tr>
                <tr>
                    <td><label for="email">Captcha<font color="red">*</font></label></td>
                    <td><input type="text" autocomplete="off" id="captcha"  name="captcha" maxlength="4" />
                    </td>
                </tr>
                <tr>
                    <td></td>
                    <td>
                        <button type="button" id='captchaRef' style="padding:5px 10px;cursor:pointer;">&#8635; New Captcha</button>
                    <img src="${pageContext.request.contextPath}/captcha" id='captchaImage'  border="0" width="135px" height="30px"></td>

                    </td> 
                     
                </tr>
                <tr>
                    <td align="right"><a href="${pageContext.request.contextPath}/"><input type="button" name="back"   id="submit1"  value="Home"/></a></td>
                    <td> 
                        <input type="submit" name="Submit" id='mysubmit' value="Proceed"/>
                        
                        <input type="reset" name="Reset"   id="reset"/>
                    </td>
                    <td></td>
                </tr>
               
                 
                <tr>
                    <div align="center" style="color:red;">   </div>
                </tr>
            </table>  
                
  
        </form><br> 
</div>

<div id="step2Result"></div>

<!-- ============ STAGE 2: PERSONAL DETAILS + SSC MARKS ============ -->
<div id="step2Div" style="display:none;">
    <form name="RegistrationDetailsForm" method="post" action="#" onsubmit="return confirmSubmit()">
        <h2 style="background-color: lightcyan" align="center" class="style4">
            Registration Form for Admission into the industrial training Institute for the session
            <span id="sessionYearPhase2"></span></h2>
        <b>Attention: Enter data carefully, If any information found wrong&nbsp; in Marks/GPA, Caste, etc. , the authority has the right to disqualify for admissions.</b>

        <table align="center" bgcolor="#b7e2f3" border="1" id="step2Table">
            <tr bgcolor="#1e43cc"><td colspan="4">&nbsp;</td></tr>

            <tr>
                <td><font color="#d42424"><b>Hall Ticket Number* :</b></font></td>
                <td><input type="text" id="sscRegDisp" readonly="readonly"></td>
                <td><font color="#d42424"><b>Board :</b></font></td>
                <td><input type="text" id="boardDisp" readonly="readonly"></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Year of Pass* :</b></font></td>
                <td><input type="text" id="sscYearDisp" readonly="readonly"></td>
                <td><font color="#d42424"><b>Month of Pass* :</b></font></td>
                <td><select id="ssc_month"><option value="">---Select --</option><option value="03">March</option><option value="04">Supplymentary</option></select></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Applicants Name:*</b></font></td>
                <td><input type="text" id="name" maxlength="50"></td>
                <td><font color="#d42424"><b>Mobile Number*:</b></font></td>
                <td><input type="text" id="phno" maxlength="10" onkeypress="return NumericsOnly(event);"></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Date of Birth(dd-mm-yyyy):*</b></font></td>
                <td><input type="date" id="appdob"></td>
                <td><font color="#d42424"><b>Aadhar Card Number:*</b></font></td>
                <td><input type="text" id="adarno" maxlength="12" onkeypress="return NumericsOnly(event);"></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Gender:*</b></font></td>
                <td>Male:<input type="radio" name="gender" value="male"> Female:<input type="radio" name="gender" value="female"></td>
                <td><font color="#d42424"><b>Category:*</b></font></td>
                <td>
                    <select id="casteSelect"><option value="">--Select Caste--</option></select>
                    <font color="#d42424"><b>Sub Category:*</b></font>
                    <select id="subCasteSelect"><option value="">-- Select Sub Category --</option></select>
                </td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Father Name*:</b></font></td>
                <td><input type="text" id="fname" maxlength="50"></td>
                <td><font color="#d42424"><b>Physically Challenged:*</b></font></td>
                <td>Yes: <input type="radio" name="phc" value="yes"> No: <input type="radio" name="phc" value="no"></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>mothers Name*:</b></font></td>
                <td><input type="text" id="mname" maxlength="50"></td>
                <td><font color="#d42424"><b>PWD Category:*</b></font></td>
                <td><select id="pwdCategory"><option value="">--- Select ---</option><option value="">None</option><option value="1">Blind</option><option value="2">Deaf</option><option value="3">Motor Disability</option><option value="4">Mental Disability</option></select></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Ex-Servicemen:*</b></font></td>
                <td>Yes: <input type="radio" name="exs" value="yes"> No: <input type="radio" name="exs" value="no"></td>
                <td><font color="#d42424"><b>Qualification:*</b></font></td>
                <td><select id="ssc"><option value="">--- Select ---</option><option value="yes">SSC Passed</option><option value="no">8th Passed</option></select></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Address:*</b></font></td>
                <td><textarea id="addr" rows="3" cols="30"></textarea></td>
                <td><font color="#d42424"><b>Local/Non Local:*</b></font></td>
                <td><select id="local"><option value="">--- Select ---</option><option value="Local">Local</option><option value="NonLocal">Non Local</option></select></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Pincode:</b></font></td>
                <td><input type="text" id="pincode" maxlength="6" onkeypress="return NumericsOnly(event);"></td>
                <td><font color="#d42424"><b>Email:</b></font></td>
                <td><input type="text" id="email" maxlength="80"></td>
            </tr>
            <tr>
                <td><font color="#d42424"><b>Economic Weaker Section:*</b></font></td>
                <td colspan="3">Yes: <input type="radio" name="ews" value="yes"> No: <input type="radio" name="ews" value="no"></td>
            </tr>
            <tr>
                <td colspan="4" align="center">
                    <font><b>Number of Languages*</b></font>
                    <input type="radio" id="sub1" name="subjects" value="sub1"> <label for="sub1">two</label>
                    <input type="radio" id="sub2" name="subjects" value="sub2" checked="checked"> <label for="sub2">three</label><br>

                    <table align="center" bgcolor="#b7e2f3" id="gpaRow">
                        <tr><td colspan="3"></td></tr>
                        <tr><td width="34" height="21">SNO</td><td width="252">Subject</td><td width="92">GPA</td></tr>
                        <tr class="gpaRow2"><td>1</td><td>First language</td><td><input type="text" id="g_firstlang" maxlength="3" style="width:60px;"></td></tr>
                        <tr class="gpaRow2"><td>2</td><td>Second Language</td><td><input type="text" id="g_secondlang" maxlength="3" style="width:60px;"></td></tr>
                        <tr class="gpaRow2"><td>3</td><td>Third Language- English</td><td><input type="text" id="g_english" maxlength="3" style="width:60px;"></td></tr>
                        <tr class="gpaRow2"><td>4</td><td>Mathematics</td><td><input type="text" id="g_math" maxlength="3" style="width:60px;"></td></tr>
                        <tr class="gpaRow2"><td>5</td><td>General Science</td><td><input type="text" id="g_science" maxlength="3" style="width:60px;"></td></tr>
                        <tr class="gpaRow2"><td>6</td><td>Social Studies</td><td><input type="text" id="g_social" maxlength="3" style="width:60px;"></td></tr>
                        <tr class="gpaRow2"><td colspan="2" align="right">Total :</td><td><input type="text" id="g_total" maxlength="4" style="width:60px;"></td></tr>
                    </table>

                    <table align="center" bgcolor="#b7e2f3" id="marksRow" style="display:none;">
                        <tr><td colspan="3"></td></tr>
                        <tr><td width="34" height="21">SNO</td><td width="252"></td><td width="92">Marks</td></tr>
                        <tr class="marksRow2"><td>1</td><td>First language</td><td><input type="text" id="m_firstlang" maxlength="3" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                        <tr class="marksRow2"><td>2</td><td>Second Language</td><td><input type="text" id="m_secondlang" maxlength="3" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                        <tr class="marksRow2"><td>3</td><td>Third Language- English</td><td><input type="text" id="m_english" maxlength="3" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                        <tr class="marksRow2"><td>4</td><td>Mathematics</td><td><input type="text" id="m_math" maxlength="3" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                        <tr class="marksRow2"><td>5</td><td>General Science</td><td><input type="text" id="m_science" maxlength="3" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                        <tr class="marksRow2"><td>6</td><td>Social Studies</td><td><input type="text" id="m_social" maxlength="3" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                        <tr class="marksRow2"><td colspan="2" align="right">Total :</td><td><input type="text" id="m_total" maxlength="4" onkeypress="return NumericsOnly(event);" style="width:60px;"></td></tr>
                    </table>
                </td>
            </tr>

            <tr><td colspan="4"><font color="#d42424">&nbsp;</font></td></tr>

            <tr align="center" bgcolor="#b7e2f3">
                <td colspan="2">Upload Photo : <input type="file" id="photo" name="photo" accept="image/png,image/jpeg" onchange="regPreviewPhoto(this);">&nbsp;&nbsp;&nbsp;<img id="uploadPreview" width="100" height="100"><br>
                    <font color="red">File less than 200kb and Must be jpg,png,jpeg images</font></td>
                <td colspan="2" align="left">
                    <input type="checkbox" id="consent" name="aadhar">
                    <label for="consent"> Above information is correct to the best of my knowledge and I hereby give my consent to the use of Aadhaar Number provided in the application to carryout identity verification for admission process.  If any information found wrong, the authority may cancel my admission at any time without any prior notice.</label>
                </td>
            </tr>
            <tr>
                <td align="center" colspan="4">
                    <input type="submit" id="regSaveBtn" value="APPLY NOW">
                </td>
            </tr>
        </table>
    </form>
</div>

<!-- ============ CONFIRMATION MODAL (review before saving) ============ -->
<div id="confirmModal" class="lg-modal-overlay">
    <div class="lg-modal">
        <h3>YOUR APPLICATION WITH FOLLOWING DETAILS, YOU WANT SUBMIT</h3>
        <center>
            <table>
                <tr><td>Hall Ticket Number</td><td>: <span id="c_sscregno"></span></td></tr>
                <tr><td>Board</td><td>: <span id="c_board"></span></td></tr>
                <tr><td>Year of Pass</td><td>: <span id="c_year"></span></td></tr>
                <tr><td>Month of Pass</td><td>: <span id="c_sscmonth"></span></td></tr>
                <tr><td>Applicant's Name</td><td>: <span id="c_name"></span></td></tr>
                <tr><td>Father Name</td><td>: <span id="c_fname"></span></td></tr>
                <tr><td>Mother Name</td><td>: <span id="c_mname"></span></td></tr>
                <tr><td>Gender</td><td>: <span id="c_gender"></span></td></tr>
                <tr><td>Date of Birth</td><td>: <span id="c_dob"></span></td></tr>
                <tr><td>Aadhaar Number</td><td>: <span id="c_adarno"></span></td></tr>
                <tr><td>Mobile Number</td><td>: <span id="c_phno"></span></td></tr>
                <tr><td>Email</td><td>: <span id="c_email"></span></td></tr>
                <tr><td>Address</td><td>: <span id="c_addr"></span></td></tr>
                <tr><td>Pincode</td><td>: <span id="c_pincode"></span></td></tr>
                <tr><td>Caste</td><td>: <span id="c_caste"></span></td></tr>
                <tr><td>Sub Caste</td><td>: <span id="c_subcaste"></span></td></tr>
                <tr><td>Local / Non-Local</td><td>: <span id="c_local"></span></td></tr>
                <tr><td>Physically Challenged</td><td>: <span id="c_phc"></span></td></tr>
                <tr><td>PWD Category</td><td>: <span id="c_pwd"></span></td></tr>
                <tr><td>Ex-Servicemen</td><td>: <span id="c_exs"></span></td></tr>
                <tr><td>Qualification</td><td>: <span id="c_qual"></span></td></tr>
                <tr><td>Economic Weaker Section</td><td>: <span id="c_ews"></span></td></tr>
                <tr><td>Number of Languages</td><td>: <span id="c_langs"></span></td></tr>
                <tr><td>SSC Type</td><td>: <span id="c_ssctype"></span></td></tr>
            </table>
            <br>
            <table border="1">
                <tr><th>SNO</th><th>Subject Name</th><th id="c_mogpa">GPA</th></tr>
                <tr><td>1</td><td>First Language</td><td id="c_firstlang"></td></tr>
                <tr><td>2</td><td>Second Language</td><td id="c_secondlang"></td></tr>
                <tr><td>3</td><td>Third Language - English</td><td id="c_english"></td></tr>
                <tr><td>4</td><td>Mathematics</td><td id="c_math"></td></tr>
                <tr><td>5</td><td>General Science</td><td id="c_science"></td></tr>
                <tr><td>6</td><td>Social Studies</td><td id="c_social"></td></tr>
                <tr><td></td><td>Total</td><td id="c_total"></td></tr>
            </table>
        </center>
        <div class="lg-modal-btns">
            <button type="button" class="lg-btn lg-btn-blue" style="padding:12px 30px;font-size:16px;" onclick="return proceedSubmit();">YES</button>
            <button type="button" class="lg-btn lg-btn-blue" style="padding:12px 30px;font-size:16px;" onclick="return closeConfirm();">NO</button>
        </div>
    </div>
</div>
        
<style>
    #footer{
        position:fixed;
        bottom:0px;
        width:100%;
        height:25px;
        padding-top: 8px;
        text-align: center;
        background-color: #0E4878;
        border-top: 1px #000000 solid;
        font-size: 12px;
        font-family: arial, verdana;
        color: #ffffff;
    }
</style>



<br><br>
<br><br>

<div id="footer">
    2013 @ All Rights Reserved &nbsp;&nbsp; Designed by &nbsp; National Informatics Center
    <font color="white"><a href="http://www.ap.nic.in" title="">National Informatics Center </a></font>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font color="white"><a href="${pageContext.request.contextPath}/">Disclaimer</a></font>

</div>


<%@ include file="../footer.jsp" %>
    </body>
</html>