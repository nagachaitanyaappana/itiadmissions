<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>Official Login - AP ITI ADMISSIONS</title>
    <style>
        :root {
            --portal-blue: #2f6fa5;
            --portal-blue-dark: #1e4f7a;
            --portal-navy: #195695;
        }

        html, body {
            height: 100vh;
            max-height: 100vh;
            margin: 0;
            padding: 0;
            overflow: hidden; /* Fits to screen without vertical scrollbars */
        }

        body.login-page-body {
            background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
        }

        /* Compact Header scoped specifically for Login Screen to fit the screen */
        .login-page-body .bg-white.py-3 {
            padding-top: 4px !important;
            padding-bottom: 4px !important;
        }

        .login-page-body .header-logo {
            max-height: 46px !important;
        }

        .login-page-body .itilogo-img {
            height: 50px !important;
        }

        .login-page-body .dgt-logo {
            height: 36px !important;
        }

        .login-page-body .header-text-main {
            font-size: 17px !important;
            line-height: 1.15 !important;
            margin-top: 2px !important;
        }

        .login-page-body .header-text-sub {
            font-size: 12px !important;
            margin-bottom: 2px !important;
        }

        .login-page-body .top-header-bar {
            font-size: 13px !important;
            padding: 3px 0 !important;
            letter-spacing: 1px !important;
        }

        /* Announcement bar and news marquee hidden on login to save vertical height */
        .login-page-body .announcement-bar {
            display: none !important;
        }

        .login-page-body .news-marquee {
            display: none !important;
        }

        .login-page-body .navbar {
            padding-top: 2px !important;
            padding-bottom: 2px !important;
            min-height: 36px !important;
        }

        .login-page-body .navbar .nav-link {
            padding: 4px 14px !important;
            font-size: 13px !important;
        }

        /* Main Login Section (Vertically and Horizontally Centered) */
        .login-section {
            flex: 1 1 auto;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 8px 15px;
            margin: auto 0;
        }

        .login-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 16px;
            border-top: 5px solid var(--portal-blue);
            box-shadow: 0 10px 30px rgba(0, 0, 0, 0.12);
            padding: 20px 30px 16px 30px;
            width: 100%;
            max-width: 410px;
            transition: transform 0.2s ease;
        }

        .login-card:hover {
            transform: translateY(-2px);
        }

        .login-header {
            text-align: center;
            margin-bottom: 12px;
        }

        .login-header i {
            color: var(--portal-blue);
            font-size: 1.8rem;
            margin-bottom: 4px;
        }

        .login-header h2 {
            color: var(--portal-blue);
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-size: 18px;
            margin-bottom: 2px;
        }

        .login-header p {
            color: #64748b;
            font-size: 12px;
            margin-bottom: 0;
        }

        .form-label {
            color: var(--portal-navy);
            font-weight: 600;
            font-size: 12px;
            margin-bottom: 3px;
        }

        .form-control {
            border-radius: 8px;
            padding: 6px 12px;
            font-size: 13px;
            border: 1px solid #cbd5e1;
            transition: border-color 0.2s ease, box-shadow 0.2s ease;
        }

        .form-control:focus {
            border-color: var(--portal-blue);
            box-shadow: 0 0 0 0.15rem rgba(47, 111, 165, 0.25);
        }

        .captcha-container {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 6px;
        }

        #captchaDisplay {
            height: 35px;
            border-radius: 6px;
            border: 1px solid #94a3b8;
            background-color: #f1f5f9;
        }

        .btn-refresh {
            background-color: var(--portal-blue);
            color: white;
            border: none;
            border-radius: 8px;
            height: 35px;
            width: 38px;
            display: flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-refresh:hover {
            background-color: var(--portal-blue-dark);
            transform: rotate(180deg);
        }

        .btn-login {
            background: linear-gradient(135deg, var(--portal-blue), var(--portal-blue-dark));
            color: white;
            border: none;
            border-radius: 8px;
            padding: 8.5px;
            width: 100%;
            font-weight: 700;
            font-size: 13.5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 10px;
            box-shadow: 0 4px 12px rgba(47, 111, 165, 0.25);
            transition: all 0.2s ease;
        }

        .btn-login:hover {
            background: linear-gradient(135deg, var(--portal-blue-dark), #153a5b);
            color: white;
            box-shadow: 0 6px 16px rgba(47, 111, 165, 0.35);
        }

        .back-home-link {
            margin-top: 10px;
            text-align: center;
        }

        .back-home-link a {
            color: var(--portal-blue);
            font-size: 12px;
            font-weight: 600;
            text-decoration: none;
        }

        .back-home-link a:hover {
            text-decoration: underline;
        }

        #errorMsg {
            background-color: #fee2e2;
            color: #991b1b;
            padding: 6px 10px;
            border-radius: 8px;
            margin-bottom: 8px;
            font-size: 12px;
            font-weight: 600;
            display: none;
            text-align: center;
        }

        .shake {
            animation: shake 0.5s cubic-bezier(.36, .07, .19, .97) both;
        }

        @keyframes shake {
            10%, 90% { transform: translate3d(-1px, 0, 0); }
            20%, 80% { transform: translate3d(2px, 0, 0); }
            30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
            40%, 60% { transform: translate3d(4px, 0, 0); }
        }

        /* Compact Footer */
        .login-page-body footer {
            margin-top: auto;
            width: 100%;
        }

        .login-page-body .lower-footer {
            background-color: var(--portal-blue) !important;
            padding: 6px 0 !important;
            font-size: 12px !important;
        }

        /* Fallback for very small screens (mobile landscape) */
        @media (max-height: 550px) {
            html, body {
                height: auto;
                max-height: none;
                overflow-y: auto;
            }
        }
    </style>
</head>

<body class="login-page-body">
    <header>
        <%@ include file="header.jsp" %>
    </header>

    <main class="login-section">
        <div class="login-card">
            <div class="login-header">
                <i class="fas fa-user-shield"></i>
                <h2>Official Login</h2>
                <p>Please enter your credentials to access the portal</p>
            </div>

            <div id="errorMsg"></div>

            <div class="mb-2">
                <label for="username" class="form-label">Username</label>
                <input type="text" class="form-control" id="username" placeholder="Enter username" autocomplete="off">
            </div>

            <div class="mb-2">
                <label for="password" class="form-label">Password</label>
                <input type="password" class="form-control" id="password" placeholder="Enter password">
            </div>

            <div class="mb-2">
                <label for="captcha" class="form-label">Enter Captcha</label>
                <div class="captcha-container">
                    <img id="captchaDisplay" src="${pageContext.request.contextPath}/captcha" alt="captcha" style="height:35px;">
                    <button type="button" class="btn-refresh" onclick="refreshCaptcha()" title="Refresh Captcha">
                        <i class="fas fa-sync-alt"></i>
                    </button>
                </div>
                <input type="text" class="form-control" id="captcha" placeholder="Type the characters above" maxlength="4">
            </div>

            <button id="loginBtn" class="btn-login" onclick="handleLogin()">Login to Portal</button>

            <div class="back-home-link">
                <a href="${pageContext.request.contextPath}/">
                    <i class="fas fa-arrow-left me-1"></i> Back to Home
                </a>
            </div>
        </div>
    </main>

    <%@ include file="footer.jsp" %>

    <script src="${pageContext.request.contextPath}/js/customJs/officialLoginJs.js?v=${System.currentTimeMillis()}"></script>
</body>

</html>
