<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registration ID Found | ITI Admission Portal</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        body { background-color: #f8f9fa; }
        .theme-card {
            max-width: 650px;
            width: 100%;
            border-radius: 8px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.05);
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
        .icon-circle i { font-size: 2.5rem; color: white; }
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
                
                <h3 class="fw-bold mb-4" style="color: #212529;">Registration ID Found</h3>
                
                <p class="fs-4 mb-5" style="color: #495057;">
                    Your Registration number is <span style="color: #2563eb; font-weight: 700;">${regid != null ? regid : 'NOT FOUND'}</span>
                </p>

                <div class="d-flex justify-content-center mt-3 gap-3">
                    <a href="${pageContext.request.contextPath}/printApplication?regid=${regid}" class="btn btn-outline-primary px-4 py-2 fw-bold text-decoration-none rounded-1" target="_blank">
                        Print Application <i class="fas fa-print ms-2"></i>
                    </a>
                    <a href="${pageContext.request.contextPath}/" class="btn btn-success px-4 py-2 fw-bold text-decoration-none rounded-1" style="background-color: #198754; border-color: #198754;">
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
