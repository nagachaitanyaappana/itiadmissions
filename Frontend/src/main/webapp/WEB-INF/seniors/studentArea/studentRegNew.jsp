<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="ISO-8859-1">
        <title>STUDENT REGISTRATION</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
        <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>

        <style>
            /* Premium Styling for Registration Card */
            body {
                background: linear-gradient(135deg, #e0e7ff 0%, #f1f5f9 100%);
                font-family: 'Inter', 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                min-height: 100vh;
            }

            .registration-card {
                background: #ffffff;
                border-radius: 20px;
                box-shadow: 0 15px 50px rgba(0, 0, 0, 0.1);
                padding: 40px 35px;
                margin: 60px auto;
                max-width: 520px;
                border-top: 6px solid #2563eb;
            }

            .header-title {
                font-weight: 800;
                color: #1e3a8a;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 12px;
                font-size: 1.8rem;
            }

            .header-subtitle {
                color: #3b82f6;
                font-size: 1rem;
                font-weight: 600;
                margin-bottom: 35px;
                text-align: center;
            }

            .form-label {
                font-weight: 600;
                color: #334155;
                font-size: 0.9rem;
                margin-bottom: 8px;
            }

            .form-control,
            .form-select {
                border-radius: 10px;
                border: 1px solid #cbd5e1;
                padding: 12px 15px;
                font-size: 0.95rem;
                color: #0f172a;
                background-color: #f8fafc;
                transition: all 0.2s ease;
            }

            .form-control:focus,
            .form-select:focus {
                background-color: #ffffff;
                border-color: #3b82f6;
                box-shadow: 0 0 0 4px rgba(59, 130, 246, 0.15);
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
                width: 55px;
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
                font-weight: 700;
                letter-spacing: 6px;
                border-radius: 10px;
                flex-grow: 1;
                display: flex;
                align-items: center;
                justify-content: center;
                user-select: none;
                background: linear-gradient(135deg, #e0e7ff, #c7d2fe);
                padding: 0;
                border: 1px solid #a5b4fc;
                text-align: center;
            }

            .btn-primary-custom {
                background: linear-gradient(135deg, #2563eb, #1d4ed8);
                border: none;
                border-radius: 10px;
                padding: 12px 20px;
                font-weight: 600;
                font-size: 1rem;
                transition: all 0.3s;
                color: #ffffff !important;
                box-shadow: 0 4px 15px rgba(37, 99, 235, 0.3);
            }

            .btn-primary-custom:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(37, 99, 235, 0.4);
                color: #ffffff !important;
            }

            .btn-secondary-custom {
                background-color: #f1f5f9;
                border: 1px solid #cbd5e1;
                border-radius: 10px;
                padding: 12px 20px;
                font-weight: 600;
                font-size: 0.95rem;
                color: #475569 !important;
                transition: all 0.3s;
            }

            .btn-secondary-custom:hover {
                background-color: #e2e8f0;
                color: #0f172a !important;
            }

            .btn-warning-custom {
                background-color: #fffbeb;
                border: 1px solid #fcd34d;
                border-radius: 10px;
                padding: 12px 20px;
                font-weight: 600;
                font-size: 0.95rem;
                color: #b45309 !important;
                transition: all 0.3s;
            }

            .btn-warning-custom:hover {
                background-color: #fef3c7;
                color: #92400e !important;
            }

            .buttons-row {
                display: flex;
                gap: 12px;
                margin-top: 35px;
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
                margin-top: 5px;
                display: block;
            }
        </style>

        <script> var contextPath = "${pageContext.request.contextPath}"; </script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js?v=3"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/customJs/stdAreaJs/studentRegNewJs.js?v=4"></script>
        <script>
            $(document).ready(function () {
                // Populate Boards Dropdown using siteScript.js API
                getAllSSCBoards(function(boards) {
                    try {
                        var boardSelect = $("#boardCode");
                        boardSelect.empty();
                        boardSelect.append('<option value="">Select Board</option>');
                        if (boards && boards.length > 0) {
                            $.each(boards, function (index, board) {
                                boardSelect.append('<option value="' + board.boardCode + '">' + board.boardName + '</option>');
                            });
                        } else {
                            boardSelect.append('<option value="">Error loading boards</option>');
                        }
                    } catch (e) {
                        console.error("Error loading boards: ", e);
                    }
                });
                
                // Generate Captcha once
                generateCaptcha();
            });
        </script>
    </head>

    <body>
    <header>
        <%@include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <main>
        <div class="container-fluid py-4">
            <div class="registration-card">
                <h2 class="header-title">
                    <i class="fas fa-user-graduate"></i> ITI Admission Portal
                </h2>
                <p class="header-subtitle">Start Your <strong>Registration</strong> Journey</p>

                <form action="./stdRegStep1" method="post" id="regForm">
                    <div class="mb-3">
                        <label class="form-label">SSC/10th Board</label>
                        <select class="form-select" id="boardCode" name="boardCode"
                            onchange="return checkValue('boardCodeError')">
                            <!-- Populated via API JS -->
                        </select>
                        <span id="boardCodeError" class="error-msg"></span>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Hall Ticket Number</label>
                        <input type="text" class="form-control" name="ssc_regnoo" id="ssc_regnoo"
                            onchange="return checkValue('ssc_regnooError')" maxlength="15"
                            placeholder="Enter Hall Ticket Number" />
                        <span id="ssc_regnooError" class="error-msg"></span>
                    </div>

                    <div class="row mb-3">
                        <div class="col-4">
                            <label class="form-label">Year of Passing</label>
                            <input type="text" class="form-control" name="passingYear" id="passingYear"
                                onchange="return checkValue('passingYearError')" maxlength="4"
                                placeholder="Enter Year" />
                            <span id="passingYearError" class="error-msg"></span>
                        </div>
                        <div class="col-4">
                            <label class="form-label">Date of Birth</label>
                            <input type="date" class="form-control" name="dob" id="dob"
                                onchange="return checkValue('dobError')" />
                            <span id="dobError" class="error-msg"></span>
                        </div>
                        <div class="col-4">
                            <label class="form-label">Result Type</label>
                            <select class="form-select" name="resultType" id="resultType"
                                onchange="return checkValue('resultTypeError')">
                                <option value="">Enter Result Type</option>
                                <option value="Marks">Marks</option>
                                <option value="GPA">GPA</option>
                            </select>
                            <span id="resultTypeError" class="error-msg"></span>
                        </div>
                    </div>

                    <div class="mb-3">
                        <label class="form-label">Captcha</label>
                        <div class="captcha-container">
                            <button type="button" class="captcha-refresh" onclick="generateCaptcha();"
                                title="Refresh Captcha">
                                <i class="fas fa-sync-alt"></i>
                            </button>
                            <input type="text" id="mainCaptcha" readonly="readonly"
                                class="form-control captcha-box" />
                            <input type="text" id="txtInput" class="form-control" maxlength="4"
                                autocomplete="off" onchange="return checkValue('captchaErr')"
                                placeholder="Enter Captcha" style="flex-grow: 1;" />
                        </div>
                        <span id="captchaErr" class="error-msg"></span>
                    </div>

                    <div class="buttons-row">
                        <a href="./" class="btn btn-secondary-custom text-decoration-none">
                            <i class="fas fa-home"></i> Home
                        </a>
                        <button type="button" class="btn btn-primary-custom" onclick="return customValidate();">
                            Proceed <i class="fas fa-arrow-right"></i>
                        </button>
                        <button type="reset" class="btn btn-secondary-custom"
                            onclick="$('.error-msg').text('');">
                            Reset
                        </button>
                    </div>
                </form>

                <div align="center" id="existRegMsg" class="mt-4"></div>
            </div>
        </div>
    </main>

    <script>
        // Custom wrapper for validation before calling backend check
        function customValidate() {
            var isValid = true;

            var boardCode = $("#boardCode").val();
            if (boardCode == "" || boardCode == null) {
                $("#boardCodeError").html("Please select a Board.");
                isValid = false;
            }

            var passingYear = $("#passingYear").val();
            if (passingYear == "" || passingYear == null) {
                $("#passingYearError").html("Year of Passing is required.");
                isValid = false;
            } else if (!passingYear.match('^[0-9]{4}$')) {
                $("#passingYearError").html("Invalid Year format (YYYY).");
                isValid = false;
            }

            var resultType = $("#resultType").val();
            if (resultType == "" || resultType == null) {
                $("#resultTypeError").html("Please select Result Type.");
                isValid = false;
            }

            if (isValid) {
                return validate();
            }

            return false;
        }
    </script>

    <footer>
        <%@include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>
    </body>

    </html>