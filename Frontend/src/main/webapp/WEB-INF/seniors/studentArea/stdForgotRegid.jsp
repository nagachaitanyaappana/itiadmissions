<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Forgot Registration ID | ITI Admission Portal</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
        <script> var contextPath = "${pageContext.request.contextPath}"; </script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js"></script>

        <style>
            body {
                background-color: #e6ffff;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

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

            .form-control-custom:focus {
                outline: none;
                border-color: #3b82f6;
                box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
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
                background: transparent;
                border: none;
                font-family: monospace;
                font-weight: bold;
                letter-spacing: 5px;
                width: 80px;
                pointer-events: none;
                text-align: center;
                font-size: 1.2rem;
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

            .proceed-btn:hover {
                background-color: #1d4ed8;
                color: white;
            }

            .home-link {
                color: #475569;
                text-decoration: none;
                font-weight: 600;
                display: flex;
                align-items: center;
            }

            .home-link:hover {
                color: #1e293b;
            }

            .reset-link {
                color: #64748b;
                text-decoration: none;
                font-weight: 500;
            }

            .refresh-icon {
                color: #2563eb;
                background: #dbeafe;
                border-radius: 6px;
                cursor: pointer;
                height: 100%;
                min-height: 44px;
                width: 44px;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: 0.2s;
            }

            .refresh-icon:hover {
                background: #bfdbfe;
            }

            .error-msg {
                color: #ef4444;
                font-size: 0.75rem;
                margin-top: 4px;
                display: block;
            }
        </style>

        <script>
            function dateChecking() {
                $.ajax({
                    type: 'GET',
                    url: API_BASE_URL + '/api/phase-data',
                    success: function (resp) {
                        if (resp.status === "SUCCESS" && resp.applicationToDate) {
                            var applicationToDateStr = resp.applicationToDate;
                            const currentDate = new Date();
                            const targetDate = new Date(applicationToDateStr);
                            if (currentDate > targetDate) {
                                $("#forgotIdForm").hide();
                                $("#dateexpiredMsg").html('Registration period has expired.').addClass('alert alert-danger');
                            }
                        }
                    }
                });
            }

            function validate() {
                var ssc_regno = document.getElementById("ssc_regno").value;
                var dob = document.getElementById("dob").value;
                var txtInput = document.getElementById("txtInput").value;
                var mainCaptcha = document.getElementById("mainCaptcha").value;

                if (ssc_regno == "") {
                    $("#ssc_regnoError").html("Hall Ticket Number is required.");
                    $("#ssc_regno").focus(); return false;
                }
                if (dob == "") {
                    $("#dobError").html("Date of Birth is required.");
                    $("#dob").focus(); return false;
                }
                if (txtInput == "") {
                    $("#captchaErr").html("Captcha is required.");
                    $("#txtInput").focus(); return false;
                }
                if (txtInput.trim() !== mainCaptcha.trim()) {
                    $("#captchaErr").html("Captcha does not match.");
                    console.log("Captcha Mismatch: Input='" + txtInput.trim() + "', Expected='" + mainCaptcha.trim() + "'");
                    generateCaptcha();
                    $("#txtInput").val('').focus();
                    return false;
                }

                findRegNumber();
            }

            function findRegNumber() {
                var ssc_regno = $("#ssc_regno").val();
                var dob = $("#dob").val();
                var captcha = $("#txtInput").val();
                $("#resp").empty();

                const data = {
                    sscRegno: ssc_regno,
                    dob: dob,
                    captcha: captcha
                };

                $.ajax({
                    type: "POST",
                    url: API_BASE_URL + "/forgotRegId",
                    data: JSON.stringify(data),
                    contentType: "application/json",
                    xhrFields: { withCredentials: true },
                    crossDomain: true,
                    cache: false,
                    success: function (resp) {
                        if (resp.status === "SUCCESS") {
                            window.location.href = "${pageContext.request.contextPath}/stdForgotRegidSuccess?regid=" + resp.regid;
                        } else {
                            $("#resp").html('<div class="alert alert-danger mt-3 py-2 text-center" style="font-size:0.85rem;">' + (resp.message || "No record found.") + '</div>');
                            generateCaptcha();
                        }
                    },
                    error: function (xhr) {
                        const msg = (xhr.responseJSON && xhr.responseJSON.message) ? xhr.responseJSON.message : "An error occurred while searching.";
                        $("#resp").html('<div class="alert alert-danger mt-3 py-2 text-center" style="font-size:0.85rem;">' + msg + '</div>');
                        generateCaptcha();
                    }
                });
            }

            function checkValue(id) {
                $("#" + id).html('');
            }

            function convertDateFormat() {
                var dob = $("#dob").val();
                if (!dob) return;
                var parts = dob.split('-');
                var year = parts[0];
                var month = parts[1];
                var day = parts[2];
                var convertedDate = day + '-' + month + '-' + year;
                $("#dobb").val(convertedDate);
            }
        </script>
    </head>

    <body onload="generateCaptcha(); dateChecking();">

        <header>
            <%@include file="/WEB-INF/seniors/header.jsp" %>
        </header>

        <main>
            <div class="container py-4">
                <h3 id="dateexpiredMsg" align="center" style="max-width: 500px; margin: 0 auto;"></h3>

                <div class="modern-card" id="forgotIdForm">
                    <div class="text-center">
                        <div class="portal-title">
                            <i class="fas fa-user-graduate me-2"></i> ITI Admission Portal
                        </div>
                        <div class="portal-subtitle">
                            Find Your <span style="font-weight: bold; color: #2563eb;">Registration</span> ID
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label-custom">Hall Ticket Number</label>
                        <input type="text" class="form-control-custom" id="ssc_regno"
                            placeholder="Enter Hall Ticket Number" maxlength="15"
                            onchange="checkValue('ssc_regnoError')">
                        <span id="ssc_regnoError" class="error-msg"></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label-custom">Date of Birth</label>
                        <input type="date" class="form-control-custom" id="dob"
                            onchange="checkValue('dobError'); convertDateFormat();">
                        <input type="hidden" id="dobb">
                        <span id="dobError" class="error-msg"></span>
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

                    <div class="d-flex align-items-center justify-content-between mt-4">
                        <a href="${pageContext.request.contextPath}/" class="home-link">
                            <i class="fas fa-home me-2"></i> Home
                        </a>

                        <button type="button" class="proceed-btn" onclick="validate()">
                            Submit <i class="fas fa-arrow-right ms-2"></i>
                        </button>

                        <a href="#" class="reset-link"
                            onclick="document.getElementById('ssc_regno').value=''; document.getElementById('dob').value=''; document.getElementById('txtInput').value='';">
                            Reset
                        </a>
                    </div>

                    <div id="resp"></div>
                </div>
            </div>
        </main>

        <footer>
            <%@include file="/WEB-INF/seniors/footer.jsp" %>
        </footer>

    </body>

    </html>