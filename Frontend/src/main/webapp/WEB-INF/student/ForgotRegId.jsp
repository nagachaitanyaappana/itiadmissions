<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Forgot Registration ID | ITI Admission Portal</title>
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

        .regid-badge {
            background: #dcfce7;
            border: 2px dashed #16a34a;
            color: #14532d;
            border-radius: 12px;
            padding: 14px 20px;
            font-size: 1.5rem;
            font-weight: 800;
            letter-spacing: 1px;
            margin: 18px 0;
            display: inline-block;
        }

        .error-msg {
            color: #ef4444;
            font-size: 0.8rem;
            margin-top: 4px;
            display: block;
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
            <!-- Result Card (shown on success) -->
            <div id="forgotResult" style="display: none;"></div>

            <!-- Lookup Gate Card -->
            <div class="registration-card" id="gateDiv">
                <div class="text-center">
                    <div class="header-title">
                        <i class="fas fa-user-graduate"></i> ITI Admission Portal
                    </div>
                    <div class="header-subtitle">
                        Find Your <span style="font-weight: bold; color: #2f6fa5;">Registration ID</span>
                    </div>
                </div>

                <div id="alertBox"></div>

                <form name="ForgotRegidForm" method="post" action="#" onsubmit="return fetchRegId()">
                    <div class="mb-3">
                        <label class="form-label" for="ssc_regno">
                            SSC Hall Ticket Number <span class="req">*</span>
                        </label>
                        <input type="text" class="form-control" name="ssc_regno" id="ssc_regno"
                               maxlength="15" placeholder="Enter SSC Hall Ticket Number"
                               onkeypress="return NumericsOnly(event);" autocomplete="off">
                        <span id="ssc_regnoError" class="error-msg"></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label" for="dob">
                            Date of Birth <span class="req">*</span>
                        </label>
                        <input type="date" class="form-control" name="dob" id="dob">
                        <span id="dobError" class="error-msg"></span>
                    </div>

                    <div class="mb-4">
                        <label class="form-label" for="captcha">
                            Captcha Verification <span class="req">*</span>
                        </label>
                        <div class="captcha-container mb-2">
                            <div class="captcha-refresh" onclick="refreshCaptcha()" title="Refresh Captcha">
                                <i class="fas fa-sync-alt"></i>
                            </div>
                            <img id="captchaImage" src="${pageContext.request.contextPath}/captcha" class="captcha-img" alt="Captcha" />
                            <div class="flex-grow-1">
                                <input type="text" class="form-control" id="captcha" name="captcha"
                                       placeholder="Enter Captcha" maxlength="6" autocomplete="off">
                            </div>
                        </div>
                        <span id="captchaErr" class="error-msg"></span>
                    </div>

                    <div class="buttons-row">
                        <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">
                            <i class="fas fa-home"></i> Home
                        </a>
                        <button type="button" class="btn btn-secondary-custom" onclick="resetForm()">
                            <i class="fas fa-undo"></i> Reset
                        </button>
                        <button type="submit" class="btn btn-primary-custom" id="mysubmit">
                            <i class="fas fa-search"></i> Submit
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </main>

    <script type="text/javascript">
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
            $("#captcha").val("");
            $("#captchaErr").text("");
        }

        function resetForm() {
            document.getElementById("ssc_regno").value = "";
            document.getElementById("dob").value = "";
            document.getElementById("captcha").value = "";
            $(".error-msg").text("");
            $("#alertBox").empty();
            refreshCaptcha();
        }

        function validate() {
            var valid = true;
            $(".error-msg").text("");
            $("#alertBox").empty();

            var ssc_regno = $("#ssc_regno").val().trim();
            if (!ssc_regno) {
                $("#ssc_regnoError").text("SSC Hall Ticket Number is required.");
                $("#ssc_regno").focus();
                valid = false;
            }

            var dob = $("#dob").val();
            if (!dob) {
                $("#dobError").text("Date of Birth is required.");
                if (valid) $("#dob").focus();
                valid = false;
            }

            var captcha = $("#captcha").val().trim();
            if (!captcha) {
                $("#captchaErr").text("Captcha is required.");
                if (valid) $("#captcha").focus();
                valid = false;
            }

            return valid;
        }

        function fetchRegId() {
            if (!validate()) return false;

            var entered = document.getElementById("captcha").value.trim().toUpperCase();
            var submitBtn = $("#mysubmit");
            submitBtn.prop("disabled", true).html('<i class="fas fa-spinner fa-spin"></i> Checking...');

            $.get('${pageContext.request.contextPath}/captcha/text', function (serverCaptcha) {
                if (entered !== String(serverCaptcha).trim().toUpperCase()) {
                    submitBtn.prop("disabled", false).html('<i class="fas fa-search"></i> Submit');
                    $("#captchaErr").text("Captcha does not match. Please try again.");
                    refreshCaptcha();
                    document.getElementById("captcha").focus();
                    return;
                }

                var hallticket = document.getElementById("ssc_regno").value.trim().toUpperCase();
                var dob = document.getElementById("dob").value;

                $.get('${backendBaseUrl}/api/student/hallticket/' + encodeURIComponent(hallticket), function (s) {
                    submitBtn.prop("disabled", false).html('<i class="fas fa-search"></i> Submit');

                    if (s.dob && String(s.dob).substring(0, 10) !== dob) {
                        $("#alertBox").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;"><i class="fas fa-exclamation-triangle me-2"></i>Date of Birth does not match this Hall Ticket Number.</div>');
                        refreshCaptcha();
                        return;
                    }

                    var resultHtml = '<div class="result-card">'
                        + '<i class="fas fa-check-circle" style="font-size: 3.5rem; color: #16a34a;"></i>'
                        + '<h3 class="mt-3 fw-bold" style="color: #14532d;">Registration ID Found!</h3>'
                        + '<p class="text-muted mb-1">Here are your registration details:</p>'
                        + '<div class="regid-badge"><span style="font-size:1rem;color:#475569;display:block;font-weight:600;">Registration ID</span>' + s.regid + '</div>'
                        + '<div class="bg-light p-3 rounded-3 mb-4 text-start" style="border: 1px solid #e2e8f0;">'
                        + '  <div class="row g-2">'
                        + '    <div class="col-sm-6"><strong>Hall Ticket:</strong> ' + (s.sscRegNo || '-') + '</div>'
                        + '    <div class="col-sm-6"><strong>Applicant Name:</strong> ' + (s.name || '-') + '</div>'
                        + '    <div class="col-sm-6"><strong>Year of Passing:</strong> ' + (s.sscYear || '-') + '</div>'
                        + '    <div class="col-sm-6"><strong>Date of Birth:</strong> ' + (s.dob ? String(s.dob).substring(0, 10) : '-') + '</div>'
                        + '  </div>'
                        + '</div>'
                        + '<div class="d-flex flex-wrap gap-2 justify-content-center">'
                        + '  <a href="${pageContext.request.contextPath}/student-apply" class="btn btn-primary-custom">'
                        + '    <i class="fas fa-paper-plane"></i> Apply for ITI'
                        + '  </a>'
                        + '  <a href="${pageContext.request.contextPath}/student-edit-details" class="btn btn-secondary-custom">'
                        + '    <i class="fas fa-edit"></i> Edit Registration'
                        + '  </a>'
                        + '  <a href="${pageContext.request.contextPath}/" class="btn btn-secondary-custom">'
                        + '    <i class="fas fa-home"></i> Home'
                        + '  </a>'
                        + '</div>'
                        + '</div>';

                    $("#gateDiv").hide();
                    $("#forgotResult").html(resultHtml).slideDown('fast');
                    window.scrollTo(0, 0);

                }).fail(function () {
                    submitBtn.prop("disabled", false).html('<i class="fas fa-search"></i> Submit');
                    $("#alertBox").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;"><i class="fas fa-exclamation-circle me-2"></i>No registration found for Hall Ticket Number <b>' + hallticket + '</b>. Please register first.</div>');
                    refreshCaptcha();
                });

            }).fail(function () {
                submitBtn.prop("disabled", false).html('<i class="fas fa-search"></i> Submit');
                $("#alertBox").html('<div class="alert alert-danger py-2 text-center" style="font-size:0.9rem;">Verification service temporarily unavailable. Please retry.</div>');
            });

            return false;
        }

        $(document).ready(function () {
            $('#captcha').keypress(function (ev) {
                if (ev.keyCode === 13) {
                    $('#mysubmit').click();
                }
            });
        });
    </script>

    <%@ include file="../jsp/footer.jsp" %>
</body>
</html>
