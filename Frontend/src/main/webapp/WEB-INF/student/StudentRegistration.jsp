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
                            var heading = resumed
                                ? 'Already Registered for this SSC Hall Ticket'
                                : 'Registration Successful!';
                            var regLine = resumed
                                ? '<p style="font-size:18px;color:#155724;">An application already exists for this SSC Hall Ticket Number and the details match. '
                                  + 'Your existing Registration ID is: <b>' + student.regid + '</b></p>'
                                : '<p style="font-size:18px;color:#155724;">Your Registration ID is: <b>' + student.regid + '</b></p>';
                            var note = resumed
                                ? '<p style="color:#155724;">Your registration details are already on record.</p>'
                                  + '<p><a href="${pageContext.request.contextPath}/student-apply">Click here to continue to Apply for ITI (select your districts)</a></p>'
                                : '<p style="color:#155724;">Please note down your Registration ID. Now complete your application details below.</p>';
                            $('#regResult').html(
                                '<div style="background-color:#d4edda;border:2px solid #28a745;padding:20px;margin:10px auto;width:60%;">'
                                + '<h3 style="color:#155724;">' + heading + '</h3>'
                                + regLine + note
                                + '</div>');
                            document.getElementById("regFormDiv").style.display = "none";
                            if (!resumed) { showStep2(student.regid, document.getElementById("ssc_type").value); }
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
                var box = document.getElementById("photoPrev");
                box.innerHTML = "";
                if (!input || !input.files || input.files.length === 0) { return; }
                var file = input.files[0];
                if (file.type !== "image/png" && file.type !== "image/jpeg") {
                    input.value = "";
                    alert("Please select a PNG or JPEG image.");
                    return;
                }
                var img = document.createElement("img");
                img.src = URL.createObjectURL(file);
                img.style.width = "90px";
                img.style.height = "110px";
                img.style.border = "1px solid #666";
                box.appendChild(img);
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

            function validateDetails() {
                var req = [["name","Name"],["fname","Father's Name"],["appdob","Date of Birth"],["phno","Mobile Number"],["addr","Address"],["local","Local/Non-Local"],["casteSelect","Caste"]];
                for (var i = 0; i < req.length; i++) {
                    var el = document.getElementById(req[i][0]);
                    if (!el.value || !el.value.trim()) { alert("Please enter " + req[i][1] + "."); el.focus(); return false; }
                }
                if (!radioVal("gender")) { alert("Please select Gender."); return false; }
                if (!/^\d{10}$/.test(document.getElementById("phno").value.trim())) { alert("Mobile Number must be 10 digits."); return false; }
                var ad = document.getElementById("adarno").value.trim();
                if (ad !== "" && !/^\d{12}$/.test(ad)) { alert("Aadhaar must be 12 digits."); return false; }
                var pin = document.getElementById("pincode").value.trim();
                if (pin !== "" && !/^\d{6}$/.test(pin)) { alert("Pincode must be 6 digits."); return false; }
                var p = document.getElementById("photo");
                if (!p || !p.files || p.files.length === 0) { alert("Please upload your photograph (PNG or JPEG)."); return false; }
                return true;
            }

            function doSubmitDetailsAndMarks() {
                if (!CURRENT_REGID) { alert("Registration Id missing. Please restart registration."); return false; }
                if (!validateDetails()) return false;
                var btn = document.getElementById("regSaveBtn");
                btn.disabled = true; btn.value = "Saving...";

                var fd = new FormData();
                var fileInput = document.getElementById("photo");
                if (fileInput && fileInput.files && fileInput.files.length > 0) { fd.append("photo", fileInput.files[0]); }
                $.ajax({
                    url: '${backendBaseUrl}/api/student/photo/' + CURRENT_REGID,
                    type: 'POST', data: fd, processData: false, contentType: false,
                    success: function () {
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
                            type: 'PUT', contentType: 'application/json',
                            data: JSON.stringify(payload),
                            success: function () {
                                var m = { regid: CURRENT_REGID, year: SESSION_YEAR };
                                if (CURRENT_SSC_TYPE === 'sscm') {
                                    m.sscFirstLangMarks = regVal("m_firstlang"); m.sscSecondLangMarks = regVal("m_secondlang");
                                    m.sscEngMarks = regVal("m_english"); m.sscMathMarks = regVal("m_math");
                                    m.sscSciMarks = regVal("m_science"); m.sscSocialMarks = regVal("m_social");
                                    m.sscTotMarks = regVal("m_total");
                                } else {
                                    m.sscFirstLangGpa = regVal("g_firstlang"); m.sscSecondLangGpa = regVal("g_secondlang");
                                    m.sscEngGpa = regVal("g_english"); m.sscMathGpa = regVal("g_math");
                                    m.sscSciGpa = regVal("g_science"); m.sscSocialGpa = regVal("g_social");
                                    m.sscTotGpa = regVal("g_total");
                                }
                                $.ajax({
                                    url: '${backendBaseUrl}/api/student/marks/save',
                                    type: 'POST', contentType: 'application/json',
                                    data: JSON.stringify(m),
                                    success: function () {
                                        document.getElementById("step2Div").style.display = "none";
                                        $('#step2Result').html(
                                            '<div style="background-color:#d4edda;border:2px solid #28a745;padding:20px;margin:10px auto;width:70%;">'
                                            + '<h3 style="color:#155724;">Details and Marks Saved!</h3>'
                                            + '<p style="color:#155724;">Your application details and SSC marks are saved for Registration Id <b>'
                                            + CURRENT_REGID + '</b>.</p>'
                                            + '<p><a href="${pageContext.request.contextPath}/student-apply">Click here to continue to Step 2 - Apply for ITI (select your districts)</a></p></div>');
                                        window.scrollTo(0, 0);
                                    },
                                    error: function () { btn.disabled = false; btn.value = "APPLY NOW"; alert("Details saved but marks could not be saved. Please retry from Edit Registration."); }
                                });
                            },
                            error: function (xhr) {
                                btn.disabled = false; btn.value = "APPLY NOW";
                                var msg = (xhr.responseJSON && xhr.responseJSON.message) ? xhr.responseJSON.message
                                    : "Failed to save application details. Please check the values and try again.";
                                alert(msg);
                            }
                        });
                    },
                    error: function (xhr) {
                        btn.disabled = false; btn.value = "APPLY NOW";
                        var msg = "Failed to upload the photograph. Please try again.";
                        if (xhr.responseJSON && xhr.responseJSON.error) { msg = xhr.responseJSON.error; }
                        alert(msg);
                    }
                });
                return false;
            }

            // ================= Confirmation modal (registration3) =================
            // Review the entered details before the real save (photo -> update -> marks).
            function confirmSubmit() {
                if (!validateDetails()) return false;
                var gpa = (CURRENT_SSC_TYPE !== 'sscm');
                var name = document.getElementById("name").value.trim();
                var fname = document.getElementById("fname").value.trim();
                document.getElementById("c_sscregno").textContent = document.getElementById("ssc_regno") ? document.getElementById("ssc_regno").value : '';
                document.getElementById("c_board").textContent = boardName();
                document.getElementById("c_year").textContent = document.getElementById("passed_year") ? document.getElementById("passed_year").value : '';
                document.getElementById("c_name").textContent = name + (fname ? ' ' + fname : '');
                document.getElementById("c_dob").textContent = document.getElementById("appdob").value;
                var casteSel = document.getElementById("casteSelect");
                document.getElementById("c_caste").textContent = casteSel.options[casteSel.selectedIndex] ? casteSel.options[casteSel.selectedIndex].text : '';
                var monthSel = document.getElementById("ssc_month");
                document.getElementById("c_sscmonth").textContent = monthSel.options[monthSel.selectedIndex] ? monthSel.options[monthSel.selectedIndex].text : '';
                var qualSel = document.getElementById("ssc");
                document.getElementById("c_qual").textContent = qualSel.options[qualSel.selectedIndex] ? qualSel.options[qualSel.selectedIndex].text : '';
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
            #step2Table{ width:60%; background-color:#b7e2f3; border:1px solid #000; }
            #step2Table td{ font-weight:normal; color:#000; padding:6px 8px; border:1px solid #7ba7c9; }
            #step2Table td:first-child{ background-color:#b7e2f3; color:#1e43cc; font-weight:bold; }
            #step2Table td.sec, #step2Table tr.sec td{ background-color:#1e43cc; color:#fff; font-weight:bold; text-align:center; }
            #step2Table td.sec a, #step2Table tr.sec td a{ color:#fff; }
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

        <table align="center" bgcolor="#b7e2f3" border="1" id="step2Table" style="width:70%;">
            <tr bgcolor="#1e43cc"><td colspan="2" class="sec" style="color:#fff;text-align:center;font-size:larger;"><u>Registration Form-Step2</u></td></tr>
            <tr><td><font color="#d42424"><b>Hall Ticket Number*</b></font></td><td><input type="text" id="sscRegDisp" readonly="readonly"></td></tr>
            <tr><td><font color="#d42424"><b>Board</b></font></td><td><input type="text" id="boardDisp" readonly="readonly"></td></tr>
            <tr><td><font color="#d42424"><b>Year of Pass*</b></font></td><td><input type="text" id="sscYearDisp" readonly="readonly"></td></tr>
            <tr><td><font color="#d42424"><b>Month of Pass*</b></font></td><td><select id="ssc_month"><option value="">---Select --</option><option value="03">March</option><option value="04">Supplymentary</option></select></td></tr>
            <tr><td><font color="#d42424"><b>Applicants Name*</b></font></td><td><input type="text" id="name" maxlength="50"></td></tr>
            <tr><td><font color="#d42424"><b>Father Name*</b></font></td><td><input type="text" id="fname" maxlength="50"></td></tr>
            <tr><td><font color="#d42424"><b>mothers Name*</b></font></td><td><input type="text" id="mname" maxlength="50"></td></tr>
            <tr><td><font color="#d42424"><b>Gender*</b></font></td><td>Male <input type="radio" name="gender" value="male"> Female <input type="radio" name="gender" value="female"></td></tr>
            <tr><td><font color="#d42424"><b>Date of Birth(dd-mm-yyyy):*</b></font></td><td><input type="date" id="appdob"></td></tr>
            <tr><td><font color="#d42424"><b>Aadhar Card Number*</b></font></td><td><input type="text" id="adarno" maxlength="12" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr><td><font color="#d42424"><b>Mobile Number*</b></font></td><td><input type="text" id="phno" maxlength="10" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr><td><font color="#d42424"><b>Email</b></font></td><td><input type="text" id="email" maxlength="80"></td></tr>
            <tr><td><font color="#d42424"><b>Address*</b></font></td><td><textarea id="addr" rows="3" cols="40"></textarea></td></tr>
            <tr><td><font color="#d42424"><b>Pincode</b></font></td><td><input type="text" id="pincode" maxlength="6" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr><td><font color="#d42424"><b>Photograph (Passport size)*</b></font></td>
                <td><input type="file" id="photo" accept="image/png,image/jpeg" onchange="regPreviewPhoto(this);">
                    <div id="photoPrev"></div></td></tr>
            <tr><td><font color="#d42424"><b>Caste*</b></font></td><td><select id="casteSelect"><option value="">--Select Caste--</option></select></td></tr>
            <tr><td><font color="#d42424"><b>Sub Caste</b></font></td><td><select id="subCasteSelect"><option value="">-- Select Sub Category --</option></select></td></tr>
            <tr><td><font color="#d42424"><b>Local/Non Local*</b></font></td><td><select id="local"><option value="">---Select --</option><option value="Local">Local</option><option value="NonLocal">Non Local</option></select></td></tr>
            <tr><td><font color="#d42424"><b>Physically Challenged*</b></font></td><td>Yes <input type="radio" name="phc" value="yes"> No <input type="radio" name="phc" value="no"></td></tr>
            <tr><td><font color="#d42424"><b>PWD Category</b></font></td><td><select id="pwdCategory"><option value="">---Select --</option><option value="1">Blind</option><option value="2">Deaf</option><option value="3">Motor Disability</option><option value="4">Mental Disability</option></select></td></tr>
            <tr><td><font color="#d42424"><b>Ex-Servicemen*</b></font></td><td>Yes <input type="radio" name="exs" value="yes"> No <input type="radio" name="exs" value="no"></td></tr>
            <tr><td><font color="#d42424"><b> Qualification:*</b></font></td><td><select id="ssc"><option value="">---Select --</option><option value="yes">SSC Passed</option><option value="no">8th Passed</option></select></td></tr>
            <tr><td><font color="#d42424"><b>Economic Weaker Section*</b></font></td><td>Yes <input type="radio" name="ews" value="yes"> No <input type="radio" name="ews" value="no"></td></tr>
            <tr id="gpaRow"><td colspan="2" class="sec"><b>Number of Languages*</b>&nbsp;&nbsp;<input type="radio" name="subjects" value="sub1"> two&nbsp;&nbsp;<input type="radio" name="subjects" value="sub2" checked="checked"> three</td></tr>
            <tr class="gpaRow2"><td>First Language GPA</td><td><input type="text" id="g_firstlang" maxlength="3"></td></tr>
            <tr class="gpaRow2"><td>Second Language GPA</td><td><input type="text" id="g_secondlang" maxlength="3"></td></tr>
            <tr class="gpaRow2"><td>English GPA</td><td><input type="text" id="g_english" maxlength="3"></td></tr>
            <tr class="gpaRow2"><td>Mathematics GPA</td><td><input type="text" id="g_math" maxlength="3"></td></tr>
            <tr class="gpaRow2"><td>Science GPA</td><td><input type="text" id="g_science" maxlength="3"></td></tr>
            <tr class="gpaRow2"><td>Social GPA</td><td><input type="text" id="g_social" maxlength="3"></td></tr>
            <tr class="gpaRow2"><td>Total GPA</td><td><input type="text" id="g_total" maxlength="4"></td></tr>
            <tr id="marksRow" style="display:none;"><td colspan="2" class="sec"><b>SSC Marks - Marks system (as per your registration)</b></td></tr>
            <tr class="marksRow2" style="display:none;"><td>First Language Marks</td><td><input type="text" id="m_firstlang" maxlength="3" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr class="marksRow2" style="display:none;"><td>Second Language Marks</td><td><input type="text" id="m_secondlang" maxlength="3" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr class="marksRow2" style="display:none;"><td>English Marks</td><td><input type="text" id="m_english" maxlength="3" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr class="marksRow2" style="display:none;"><td>Mathematics Marks</td><td><input type="text" id="m_math" maxlength="3" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr class="marksRow2" style="display:none;"><td>Science Marks</td><td><input type="text" id="m_science" maxlength="3" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr class="marksRow2" style="display:none;"><td>Social Marks</td><td><input type="text" id="m_social" maxlength="3" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr class="marksRow2" style="display:none;"><td>Total Marks</td><td><input type="text" id="m_total" maxlength="4" onkeypress="return NumericsOnly(event);"></td></tr>
            <tr>
                <td colspan="2" style="text-align:center;">
                    <input type="button" value="Back to Home" onclick="window.location='${pageContext.request.contextPath}/';">
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
                <tr><td>Applicant's Name</td><td>: <span id="c_name"></span></td></tr>
                <tr><td>Date of Birth</td><td>: <span id="c_dob"></span></td></tr>
                <tr><td>Category</td><td>: <span id="c_caste"></span></td></tr>
                <tr><td>Month of Pass</td><td>: <span id="c_sscmonth"></span></td></tr>
                <tr><td>Qualification</td><td>: <span id="c_qual"></span></td></tr>
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