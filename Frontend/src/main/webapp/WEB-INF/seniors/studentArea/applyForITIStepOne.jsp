<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Apply for ITI | ITI Admission Portal</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js"></script>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/customJs/applyForITIJs.js?v=2"></script>

    <style>
        body {
            background-color: #f0f4fc; 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .modern-card {
            max-width: 480px;
            width: 100%;
            background: #fff;
            border-radius: 12px;
            border-top: 4px solid #2563eb;
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
            margin: 60px auto;
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
        .proceed-btn {
            background-color: #2563eb;
            color: white;
            border-radius: 6px;
            padding: 12px 30px;
            font-weight: 600;
            border: none;
            transition: 0.2s;
            width: 100%;
        }
        .proceed-btn:hover { background-color: #1d4ed8; transform: translateY(-1px); }
        .captcha-box-modern {
            background-color: #e0e7ff;
            color: #3730a3;
            border-radius: 6px;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 44px;
        }
        .input-captcha-modern {
            background: transparent; border: none; font-family: monospace; font-weight: bold; letter-spacing: 5px; width: 80px; pointer-events: none; text-align: center; font-size: 1.2rem;
        }
        .refresh-icon {
            color: #2563eb;
            background: #dbeafe;
            border-radius: 6px;
            cursor: pointer;
            height: 44px;
            width: 44px;
            display: flex; align-items: center; justify-content: center;
        }
        .error-msg {
            color: #ef4444;
            font-size: 0.75rem;
            margin-top: 4px;
            display: block;
        }
    </style>
</head>
<body onload="generateCaptcha();">

    <header>
        <%@include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <main>
        <div class="container">
            <div class="modern-card">
                <div class="text-center">
                    <div class="portal-title">ITI Admission Portal</div>
                    <div class="portal-subtitle">Apply for <span style="font-weight: bold; color: #2563eb;">ITI Admission</span> (Phase ${activePhase != null ? activePhase : 'Inactive'})</div>
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
                    <span id="dobbError" class="error-msg"></span>
                    <input type="hidden" id="dobbspan">
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

                <div class="d-flex justify-content-center gap-3">
                    <a href="${pageContext.request.contextPath}/" class="btn btn-outline-secondary px-4 py-2 fw-bold text-decoration-none rounded-1 d-inline-flex align-items-center" style="border: 1px solid #cbd5e1; color: #475569;">
                        <i class="fas fa-home me-2"></i> <span>Home</span>
                    </a>
                    <button type="button" class="proceed-btn px-4 d-inline-flex align-items-center" onclick="validate()">
                        <span>Proceed to Application</span> <i class="fas fa-arrow-right ms-2"></i>
                    </button>
                </div>
                
                <div id="errorMsg" class="mt-3 text-center"></div>
            </div>
        </div>
    </main>

    <footer>
        <%@include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

</body>
</html>