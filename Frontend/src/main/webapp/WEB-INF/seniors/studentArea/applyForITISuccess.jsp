<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Application Successful | ITI Admission Portal</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            body {
                background-color: #f8f9fa;
            }

            .success-card {
                max-width: 700px;
                margin: 80px auto;
                border-radius: 12px;
                box-shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
                background: white;
                padding: 50px 40px;
                text-align: center;
            }

            .icon-circle {
                width: 80px;
                height: 80px;
                background-color: #198754;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto 30px auto;
                box-shadow: 0 4px 10px rgba(25, 135, 84, 0.2);
            }

            .icon-circle i {
                font-size: 2.5rem;
                color: white;
            }

            .success-text {
                color: #212529;
                font-size: 1.4rem;
                font-weight: 600;
                margin-bottom: 25px;
                line-height: 1.6;
            }

            .reg-id-highlight {
                font-weight: 800;
                color: #2563eb;
            }

            .print-link {
                display: inline-block;
                margin-left: 10px;
                color: #9c4c00;
                text-decoration: underline;
                font-weight: 600;
            }

            .goto-home-btn, .print-btn {
                padding: 10px 25px;
                border-radius: 6px;
                text-decoration: none;
                font-weight: 600;
                display: inline-flex;
                align-items: center;
                transition: 0.3s;
                border: none;
            }

            .goto-home-btn {
                background-color: #198754;
                color: white;
            }

            .goto-home-btn:hover {
                background-color: #157347;
                color: white;
                transform: scale(1.05);
            }

            .print-btn {
                background-color: #ffffff;
                color: #2563eb;
                border: 1px solid #2563eb;
            }

            .print-btn:hover {
                background-color: #f1f6fe;
                transform: scale(1.05);
            }
        </style>
    </head>

    <body>

    <header>
        <%@include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <main>
        <div class="container">
            <div class="success-card">
                <!-- Success Icon -->
                <div class="icon-circle">
                    <i class="fas fa-check"></i>
                </div>

                <!-- Information Text -->
                <div class="success-text">
                    You have successfully <span style="color: #198754;">Applied</span> for ITI with registration ID
                    :
                    <span class="reg-id-highlight">${regid != null ? regid : '20000454'}</span>
                </div>

                <!-- Navigation -->
                <div class="d-flex justify-content-center gap-3 mt-4">
                    <button type="button" class="print-btn" onclick="window.open('${pageContext.request.contextPath}/printApplication?regid=${regid}', '_blank')">
                        <i class="fas fa-print me-2"></i> Print Application
                    </button>
                    <a href="${pageContext.request.contextPath}/" class="goto-home-btn">
                        <i class="fas fa-home me-2"></i> Go to Home
                    </a>
                </div>
            </div>
        </div>
    </main>

    <footer>
        <%@include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

    </body>

    </html>