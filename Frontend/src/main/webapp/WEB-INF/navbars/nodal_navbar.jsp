<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     NODAL dashboard navbar (roleId 10).
     Exact navigation menu matching itiadmissions project.
     UI/design styled via #menu-bar in style.css / iti-portal.css.
     =================================================================== --%>
<!-- Shared homepage title and announcement rows -->
<div class="top-header-bar text-center px-2">
    AP ITI ADMISSIONS - 2026
</div>
<div class="announcement-bar px-3">
    A Common Application for seeking Admission into all courses of Advanced Technology Centers (ATC's), Govt. ITI's and Pvt. ITI's in Andhra Pradesh State
</div>

<nav class="navbar navbar-expand-lg custom-navbar role-dashboard-navbar">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#NodalNav" aria-controls="NodalNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="NodalNav">
<ul class="navbar-nav nav-menu mx-auto">
    <li class="nav-item"><a href="${pageContext.request.contextPath}/authHome" class="nav-link">Home</a></li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="NodalMenu0" role="button" data-bs-toggle="dropdown" aria-expanded="false">ITI Services</a>
        <ul class="dropdown-menu" aria-labelledby="NodalMenu0">
            <li><a href="${pageContext.request.contextPath}/services/password-change" class="dropdown-item">Change User Password</a></li>
            <li><a href="${pageContext.request.contextPath}/services/registration" class="dropdown-item">Add ITI Master</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="NodalMenu1" role="button" data-bs-toggle="dropdown" aria-expanded="false">ITI Reports</a>
        <ul class="dropdown-menu" aria-labelledby="NodalMenu1">
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-state" class="dropdown-item">API Dashboard (State)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/phase-wise-admissions-details" class="dropdown-item">Phase Wise Admissions Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/today-schedule-itis" class="dropdown-item">Today Schedule ITIs</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/trade-wise-report" class="dropdown-item">Trade Wise Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-report-dist-wise" class="dropdown-item">Applicant Report Dist Wise</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dist-iti-trade-wise-seats-abstract" class="dropdown-item">DIST/ITI/Trade Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/duration-wise-trade-seats-abstract" class="dropdown-item">Duration Wise Trade Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/govt-or-pvt-dist-wise-seats-abstract" class="dropdown-item">Govt or Pvt Dist Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/student-reg-details" class="dropdown-item">Student Reg Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/students-not-admitted" class="dropdown-item">Students Not Admitted</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report" class="dropdown-item">Verification Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract" class="dropdown-item">Caste Wise Admissions Abstract</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="NodalMenu2" role="button" data-bs-toggle="dropdown" aria-expanded="false">Admissions</a>
        <ul class="dropdown-menu" aria-labelledby="NodalMenu2">
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase" class="dropdown-item">ADMISSIONS PHASE 1</a></li>
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase" class="dropdown-item">Admission Counseling (Rank)</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/reprint-verified-application" class="dropdown-item">Application Reprint</a></li>
            <li><a href="${pageContext.request.contextPath}/jsp/permitted_shift_unit_nodal_report.jsp" class="dropdown-item">DGT Permitted Shifts Report</a></li>
        </ul>
    </li>
    <li class="nav-item"><a href="#" class="nav-link">SCVT Exams</a></li>
    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link">Logout</a></li>
    
</ul>
    </div>
  </div>
</nav>
<div class="role-welcome-strip"><c:if test="${not empty sessionScope.username}">
        <c:set var="nodalDisplay" value="${not empty sessionScope.distName ? sessionScope.distName : (not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username)}" />
        <div class="role-welcome-content">
            <div class="welcome-badge">
                <i class="fas fa-map-marker-alt"></i>
                <span>Welcome <strong>Nodal Officer</strong>,</span>
                <span class="welcome-highlight">${nodalDisplay}</span>
            </div>
        </div>
    </c:if></div>
