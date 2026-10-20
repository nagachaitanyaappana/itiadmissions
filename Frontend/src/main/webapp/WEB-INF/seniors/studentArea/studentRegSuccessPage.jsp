<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Registration Successful | ITI Admission Portal</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <style>
            body {
                background-color: #f8f9fa;
            }

            .theme-card {
                max-width: 650px;
                width: 100%;
                border-radius: 8px;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.05);
            }

            .icon-circle {
                width: 80px;
                height: 80px;
                background-color: #198754;
                border-radius: 50%;
                display: flex;
                align-items: center;
                justify-content: center;
                margin: 0 auto;
            }

            .icon-circle i {
                font-size: 2.5rem;
                color: white;
            }

            .btn-outline-custom {
                color: #0d6efd;
                border: 1px solid #0d6efd;
                background-color: white;
            }

            .btn-outline-custom:hover {
                background-color: #f1f6fe;
            }
        </style>
    </head>

    <body>

    <header>
        <%@include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <main>
        <div class="container my-5 d-flex justify-content-center" style="min-height: 50vh; align-items: center;">
            <div class="card theme-card border-0 p-5 text-center bg-white">

                <div class="mb-4">
                    <div class="icon-circle">
                        <i class="fas fa-check"></i>
                    </div>
                </div>

                <h3 class="fw-bold mb-3" style="color: #212529;">You have successfully been registered</h3>

                <p class="fs-5 mb-2" style="color: #495057;">
                    Note your registration ID : <span style="color: #2563eb; font-weight: 700;">${regid != null ?
                        regid : '20000454'}</span>
                </p>

                <p class="mb-4" style="color: #6c757d; font-size: 1.05rem;">
                    You need to apply for ITI from the option <strong>APPLY ITI</strong> in Home Screen.
                </p>

                <div class="d-flex justify-content-center gap-3 mt-3">
                    <a href="${pageContext.request.contextPath}/printApplication?regid=${regid}"
                        class="btn btn-outline-custom px-4 py-2 fw-bold text-decoration-none rounded-1" target="_blank">
                        <i class="fas fa-print me-2"></i> Print Application
                    </a>
                    <a href="${pageContext.request.contextPath}/"
                        class="btn btn-success px-4 py-2 fw-bold text-decoration-none rounded-1"
                        style="background-color: #198754; border-color: #198754;">
                        Go to Home <i class="fas fa-arrow-right ms-2"></i>
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