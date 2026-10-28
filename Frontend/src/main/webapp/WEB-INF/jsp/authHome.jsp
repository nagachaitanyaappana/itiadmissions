<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>:: ITI Portal - Dashboard ::</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal-theme.css">
    <style>
        html, body {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            background-color: #f4f7fa;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        .main-dashboard-content {
            flex: 1 0 auto;
        }
        .dashboard-hero {
            background: linear-gradient(135deg, #195695 0%, #2f6fa5 100%);
            color: #ffffff;
            border-radius: 10px;
            padding: 24px 28px;
            box-shadow: 0 4px 14px rgba(25, 86, 149, 0.15);
            margin-bottom: 24px;
        }
        .card-custom {
            border: 1px solid #dbe2ea;
            border-radius: 10px;
            background: #ffffff;
            box-shadow: 0 2px 8px rgba(0,0,0,0.04);
            margin-bottom: 24px;
            overflow: hidden;
        }
        .card-custom .card-header-custom {
            background-color: #2f6fa5;
            color: #ffffff;
            font-weight: 600;
            font-size: 1.05rem;
            padding: 12px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .info-table th {
            width: 38%;
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            padding: 10px 14px;
            border-bottom: 1px solid #e2e8f0;
        }
        .info-table td {
            color: #1e293b;
            padding: 10px 14px;
            border-bottom: 1px solid #e2e8f0;
        }
    </style>
</head>
<body>

    <!-- Header Banner -->
    <center>
        <img src="${pageContext.request.contextPath}/images/gen.jpg" width="100%" alt="ITI Portal Banner" />
    </center>

    <!-- Header with dynamic navbar inclusion based on role -->
    <%@ include file="../reports/header.jsp" %>

    <div class="main-dashboard-content">
        <div class="container py-4">

            <div class="dashboard-hero">
                <div class="d-flex flex-wrap justify-content-between align-items-center">
                    <div>
                        <h2><i class="fas fa-user-check me-2"></i> Welcome, ${sessionScope.fullName != null && !empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</h2>
                        <p>Department of Technical Education & Training, Government of Andhra Pradesh</p>
                    </div>
                    <div>
                        <span class="badge bg-light text-dark px-3 py-2 fs-6">
                            <i class="fas fa-circle text-success me-1"></i> Role ID: ${sessionScope.roleId}
                        </span>
                    </div>
                </div>
            </div>

            <div class="row justify-content-center">
                <div class="col-lg-6 mb-4">
                    <div class="card-custom">
                        <div class="card-header-custom">
                            <span><i class="fas fa-id-card me-2"></i> Session Summary</span>
                        </div>
                        <div class="card-body p-0">
                            <table class="table info-table mb-0">
                                <tbody>
                                    <tr>
                                        <th>Username / ID</th>
                                        <td><code>${sessionScope.username}</code></td>
                                    </tr>
                                    <tr>
                                        <th>Full Name</th>
                                        <td>${sessionScope.fullName}</td>
                                    </tr>
                                    <tr>
                                        <th>Role ID</th>
                                        <td>${sessionScope.roleId}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <%@ include file="footer.jsp" %>

</body>
</html>
