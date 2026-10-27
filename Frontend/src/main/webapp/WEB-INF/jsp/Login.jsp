<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <title>Official Login - AP ITI ADMISSIONS</title>
        <style>
            :root {
                --navy-blue: #002D62;
                --india-orange: #FF9933;
                --india-green: #128807;
                --white: #FFFFFF;
            }

            body {
                background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
                min-height: 100vh;
            }

            .login-section {
                padding: 80px 0;
                display: flex;
                justify-content: center;
                align-items: center;
            }

            .login-card {
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(10px);
                border-radius: 20px;
                border-top: 5px solid var(--navy-blue);
                box-shadow: 0 15px 35px rgba(0, 0, 0, 0.2);
                padding: 40px;
                width: 100%;
                max-width: 450px;
                transition: transform 0.3s ease;
            }

            .login-card:hover {
                transform: translateY(-5px);
            }

            .login-header {
                text-align: center;
                margin-bottom: 30px;
            }

            .login-header h2 {
                color: var(--navy-blue);
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                font-size: 24px;
            }

            .login-header p {
                color: #666;
                font-size: 14px;
            }

            .form-label {
                color: var(--navy-blue);
                font-weight: 600;
                font-size: 14px;
            }

            .form-control {
                border-radius: 10px;
                padding: 12px 15px;
                border: 1px solid #ddd;
                transition: border-color 0.3s ease;
            }

            .form-control:focus {
                border-color: var(--india-orange);
                box-shadow: 0 0 0 0.2rem rgba(255, 153, 51, 0.25);
            }

            .captcha-container {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 20px;
            }

            #captchaDisplay {
                background-color: #eee;
                border: 2px dashed var(--india-green);
                color: var(--navy-blue);
                font-family: 'Courier New', Courier, monospace;
                font-weight: 900;
                font-size: 24px;
                text-align: center;
                letter-spacing: 5px;
                pointer-events: none;
                user-select: none;
                width: 150px;
            }

            .btn-refresh {
                background-color: var(--india-green);
                color: white;
                border: none;
                border-radius: 10px;
                padding: 10px 15px;
                transition: all 0.3s ease;
            }

            .btn-refresh:hover {
                background-color: #0e6b05;
                transform: rotate(180deg);
            }

            .btn-login {
                background-color: var(--india-orange);
                color: white;
                border: none;
                border-radius: 10px;
                padding: 12px;
                width: 100%;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 1px;
                transition: all 0.3s ease;
                margin-top: 20px;
            }

            .btn-login:hover {
                background-color: #e67e22;
                box-shadow: 0 5px 15px rgba(230, 126, 34, 0.4);
            }

            #errorMsg {
                background-color: #ffebee;
                color: #c62828;
                padding: 10px;
                border-radius: 10px;
                margin-bottom: 20px;
                font-size: 13px;
                font-weight: 600;
                display: none;
                text-align: center;
            }

            .shake {
                animation: shake 0.5s cubic-bezier(.36, .07, .19, .97) both;
            }

            @keyframes shake {

                10%,
                90% {
                    transform: translate3d(-1px, 0, 0);
                }

                20%,
                80% {
                    transform: translate3d(2px, 0, 0);
                }

                30%,
                50%,
                70% {
                    transform: translate3d(-4px, 0, 0);
                }

                40%,
                60% {
                    transform: translate3d(4px, 0, 0);
                }
            }

            footer {
                background-color: var(--navy-blue);
            }
        </style>
    </head>

    <body>
        <header>
            <%@ include file="header.jsp" %>
        </header>

        <section class="login-section">
            <div class="login-card">
                <div class="login-header">
                    <i class="fas fa-user-shield fa-3x mb-3" style="color: var(--navy-blue);"></i>
                    <h2>Official Login</h2>
                    <p>Please enter your credentials to access the portal</p>
                </div>

                <div id="errorMsg"></div>

                <div class="mb-3">
                    <label for="username" class="form-label">Username</label>
                    <input type="text" class="form-control" id="username" placeholder="Enter username"
                        autocomplete="off">
                </div>

                <div class="mb-3">
                    <label for="password" class="form-label">Password</label>
                    <input type="password" class="form-control" id="password" placeholder="Enter password">
                </div>

                <div class="mb-3">
                    <label for="captcha" class="form-label">Enter Captcha</label>
                    <div class="captcha-container">
                        <input type="text" id="captchaDisplay" class="form-control" readonly>
                        <button class="btn-refresh" onclick="refreshCaptcha()" title="Refresh Captcha">
                            <i class="fas fa-sync-alt"></i>
                        </button>
                    </div>
                    <input type="text" class="form-control" id="captcha" placeholder="Type the characters above"
                        maxlength="4">
                </div>

                <button id="loginBtn" class="btn-login" onclick="handleLogin()">Login to Portal</button>

                <div class="mt-4 text-center">
                    <a href="./" class="text-decoration-none"
                        style="color: var(--navy-blue); font-size: 13px; font-weight: 600;">
                        <i class="fas fa-arrow-left me-1"></i> Back to Home
                    </a>
                </div>
            </div>
        </section>

        <footer>
            <%@ include file="footer.jsp" %>
        </footer>

        <script
            src="${pageContext.request.contextPath}/js/customJs/officialLoginJs.js?v=${System.currentTimeMillis()}"></script>
    </body>

    </html>