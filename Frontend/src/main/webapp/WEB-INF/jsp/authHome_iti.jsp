<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>:: ITI - Institute Dashboard ::</title>
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
        .dashboard-hero h2 {
            font-size: 1.6rem;
            font-weight: 700;
            margin-bottom: 6px;
        }
        .dashboard-hero p {
            margin-bottom: 0;
            opacity: 0.9;
            font-size: 0.95rem;
        }
        .meta-pill {
            display: inline-flex;
            align-items: center;
            background: rgba(255, 255, 255, 0.18);
            border: 1px solid rgba(255, 255, 255, 0.3);
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.85rem;
            margin-right: 8px;
            margin-top: 10px;
            color: #fff;
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
        .card-custom .card-body {
            padding: 20px;
        }
        .info-table th {
            width: 38%;
            background-color: #f8fafc;
            color: #475569;
            font-weight: 600;
            font-size: 0.9rem;
            padding: 10px 14px;
            border-bottom: 1px solid #e2e8f0;
        }
        .info-table td {
            color: #1e293b;
            font-size: 0.95rem;
            padding: 10px 14px;
            border-bottom: 1px solid #e2e8f0;
        }
        .quick-tile {
            display: flex;
            align-items: center;
            padding: 14px 16px;
            border-radius: 8px;
            border: 1px solid #e2e8f0;
            background: #fbfcfe;
            text-decoration: none;
            color: #1e293b;
            transition: all 0.2s ease;
            margin-bottom: 12px;
        }
        .quick-tile:hover {
            background: #f0f6fc;
            border-color: #2f6fa5;
            color: #195695;
            transform: translateY(-2px);
            box-shadow: 0 3px 10px rgba(47, 111, 165, 0.15);
        }
        .quick-tile-icon {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            background: #e6f0f9;
            color: #2f6fa5;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.2rem;
            margin-right: 14px;
            flex-shrink: 0;
        }
        .quick-tile:hover .quick-tile-icon {
            background: #2f6fa5;
            color: #ffffff;
        }
        .history-table th {
            background-color: #2f6fa5 !important;
            color: #ffffff !important;
            font-weight: 600;
            font-size: 0.9rem;
            text-transform: uppercase;
            padding: 10px 12px;
            border: 1px solid #195695;
        }
        .history-table td {
            padding: 10px 12px;
            font-size: 0.9rem;
            vertical-align: middle;
            border-bottom: 1px solid #e2e8f0;
        }
        .history-table tbody tr:hover {
            background-color: #f8fafc;
        }
    </style>
</head>
<body>

    <!-- Header Banner -->
    <center>
        <img src="${pageContext.request.contextPath}/images/gen.jpg" id="banner-id" width="100%" alt="ITI Portal Banner" />
    </center>

    <!-- ITI Navbar -->
    <%@ include file="../navbars/iti_navbar.jsp" %>

    <div class="main-dashboard-content">
        <div class="container py-4">

            <!-- Hero Welcome Card -->
            <div class="dashboard-hero">
                <div class="d-flex flex-wrap justify-content-between align-items-center">
                    <div>
                        <h2><i class="fas fa-building me-2"></i> ITI Institute Dashboard</h2>
                        <p>Department of Technical Education & Training, Government of Andhra Pradesh</p>
                        <div class="d-flex flex-wrap">
                            <span class="meta-pill"><i class="fas fa-user-shield me-2"></i> Role: ITI Institute (Role 4)</span>
                            <span class="meta-pill"><i class="fas fa-id-badge me-2"></i> User: ${sessionScope.username}</span>
                            <c:if test="${not empty sessionScope.itiName}">
                                <span class="meta-pill"><i class="fas fa-university me-2"></i> ITI: ${sessionScope.itiName}</span>
                            </c:if>
                            <span class="meta-pill"><i class="fas fa-sign-in-alt me-2"></i> Total Logins: ${sessionScope.loginCount != null ? sessionScope.loginCount : 1}</span>
                        </div>
                    </div>
                    <div class="text-end mt-3 mt-md-0">
                        <span class="badge bg-light text-dark px-3 py-2 fs-6 shadow-sm">
                            <i class="fas fa-circle text-success me-1"></i> Active Session
                        </span>
                    </div>
                </div>
            </div>

            <div class="row">
                <!-- Left Column: ITI Details & Quick Actions -->
                <div class="col-lg-5 mb-4">
                    <!-- ITI Session Profile -->
                    <div class="card-custom">
                        <div class="card-header-custom">
                            <span><i class="fas fa-id-card me-2"></i> ITI Profile</span>
                            <span class="badge bg-light text-primary">Institute Level</span>
                        </div>
                        <div class="card-body p-0">
                            <table class="table info-table mb-0">
                                <tbody>
                                    <tr>
                                        <th>Principal / Incharge</th>
                                        <td><strong>${sessionScope.fullName != null && !empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username}</strong></td>
                                    </tr>
                                    <tr>
                                        <th>ITI Name</th>
                                        <td><strong>${sessionScope.itiName != null ? sessionScope.itiName : 'ITI Institute'}</strong></td>
                                    </tr>
                                    <tr>
                                        <th>ITI Code / Username</th>
                                        <td><code>${sessionScope.username}</code></td>
                                    </tr>
                                    <c:if test="${not empty sessionScope.distName}">
                                        <tr>
                                            <th>District</th>
                                            <td>${sessionScope.distName}</td>
                                        </tr>
                                    </c:if>
                                    <tr>
                                        <th>Total Logins</th>
                                        <td><span class="badge bg-primary fs-7">${sessionScope.loginCount} Sessions</span></td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Quick Actions -->
                    <div class="card-custom">
                        <div class="card-header-custom">
                            <span><i class="fas fa-bolt me-2"></i> ITI Key Operations</span>
                        </div>
                        <div class="card-body">
                            <a href="${pageContext.request.contextPath}/VerifyApplication" class="quick-tile">
                                <div class="quick-tile-icon"><i class="fas fa-user-check"></i></div>
                                <div>
                                    <div class="fw-bold">Verification for Online Applications</div>
                                    <small class="text-muted">Verify incoming student applications</small>
                                </div>
                            </a>
                            <a href="${pageContext.request.contextPath}/AdmissionCounseling" class="quick-tile">
                                <div class="quick-tile-icon"><i class="fas fa-users-cog"></i></div>
                                <div>
                                    <div class="fw-bold">Admissions - Counseling</div>
                                    <small class="text-muted">Process student counseling admissions</small>
                                </div>
                            </a>
                            <a href="${pageContext.request.contextPath}/reports/dsc-list" class="quick-tile">
                                <div class="quick-tile-icon"><i class="fas fa-clipboard-list"></i></div>
                                <div>
                                    <div class="fw-bold">DSC Candidate List</div>
                                    <small class="text-muted">View selected DSC candidate listings</small>
                                </div>
                            </a>
                            <a href="${pageContext.request.contextPath}/PrintAdmissionSlip" class="quick-tile">
                                <div class="quick-tile-icon"><i class="fas fa-print"></i></div>
                                <div>
                                    <div class="fw-bold">Print Admission Slip</div>
                                    <small class="text-muted">Generate & print admission acknowledgement slips</small>
                                </div>
                            </a>
                            <a href="${pageContext.request.contextPath}/reports/applicant-report" class="quick-tile">
                                <div class="quick-tile-icon"><i class="fas fa-file-alt"></i></div>
                                <div>
                                    <div class="fw-bold">Applicant Report</div>
                                    <small class="text-muted">Detailed institute applicant summaries</small>
                                </div>
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Right Column: Recent Login History -->
                <div class="col-lg-7 mb-4">
                    <div class="card-custom">
                        <div class="card-header-custom">
                            <span><i class="fas fa-history me-2"></i> Recent Login History</span>
                            <span class="badge bg-light text-primary">Last 5 Sessions</span>
                        </div>
                        <div class="card-body">
                            <p class="text-muted mb-3" style="font-size: 0.92rem;">
                                You have logged into the AP ITI Admission Portal a total of 
                                <strong class="text-primary">${sessionScope.loginCount != null ? sessionScope.loginCount : 1} times</strong>.
                                Below is the audit trail of your most recent sessions:
                            </p>
                            <div class="table-responsive">
                                <table class="table history-table table-bordered mb-0">
                                    <thead>
                                        <tr>
                                            <th style="width: 12%; text-align: center;">S.No</th>
                                            <th><i class="far fa-clock me-1"></i> Login Date &amp; Time</th>
                                            <th style="width: 25%; text-align: center;">Status</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty sessionScope.lastLogins}">
                                                <c:forEach var="dt" items="${sessionScope.lastLogins}" varStatus="st">
                                                    <tr>
                                                        <td class="text-center fw-bold text-secondary">${st.count}</td>
                                                        <td>
                                                            <i class="far fa-calendar-check text-primary me-2"></i>
                                                            <span class="fw-semibold">${dt}</span>
                                                        </td>
                                                        <td class="text-center">
                                                            <span class="badge bg-success px-2 py-1">
                                                                <i class="fas fa-check-circle me-1"></i> Success
                                                            </span>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="3" class="text-center py-4 text-muted">
                                                        <i class="fas fa-info-circle me-1"></i> No prior login records recorded.
                                                    </td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- Unified Global Footer -->
    <%@ include file="footer.jsp" %>

</body>
</html>
