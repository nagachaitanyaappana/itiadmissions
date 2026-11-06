<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     DISTRICT dashboard navbar (roleId 3).
     Exact navigation menu matching itiadmissions project.
     UI/design styled via #menu-bar in style.css / iti-portal.css.
     =================================================================== --%>
<nav class="navbar navbar-expand-lg custom-navbar role-dashboard-navbar">
  <div class="container-fluid">
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#DistrictNav" aria-controls="DistrictNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="DistrictNav">
<ul class="navbar-nav nav-menu mx-auto">
    <li class="nav-item"><a href="${pageContext.request.contextPath}/authHome" class="nav-link">Home</a></li>
    <li class="nav-item"><a href="#" class="nav-link">ITI Services</a></li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="DistrictMenu0" role="button" data-bs-toggle="dropdown" aria-expanded="false">ITI Reports</a>
        <ul class="dropdown-menu" aria-labelledby="DistrictMenu0">
            <li><a href="${pageContext.request.contextPath}/reports/applicant-address-with-mobile" class="dropdown-item">Applicant Address With Mobile</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-district" class="dropdown-item">API Dashboard (District)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract" class="dropdown-item">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report" class="dropdown-item">Verification Report</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="DistrictMenu1" role="button" data-bs-toggle="dropdown" aria-expanded="false">Admissions</a>
        <ul class="dropdown-menu" aria-labelledby="DistrictMenu1">
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase" class="dropdown-item">ADMISSIONS PHASE 1</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list" class="dropdown-item">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/SeatMatrix" class="dropdown-item">seatmatrix</a></li>
            <li><a href="${pageContext.request.contextPath}/CallLetterView" class="dropdown-item">Call Letter</a></li>
            <li><a href="${pageContext.request.contextPath}/iti-trade-selection" class="dropdown-item">DGT Permitted Shifts Units</a></li>
            <li><a href="${pageContext.request.contextPath}/AddTrade" class="dropdown-item">Add Trade</a></li>
            <li><a href="${pageContext.request.contextPath}/ReservationEntry" class="dropdown-item">Reservation Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/SeatCorrection" class="dropdown-item">Seat Correction</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report" class="dropdown-item">DGT Permitted Shifts Units Report</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/discharge" class="dropdown-item">Discharge Admission</a></li>
            <li><a href="${pageContext.request.contextPath}/ScheduleEntry" class="dropdown-item">Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/DeleteScheduleEntry" class="dropdown-item">Delete Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/VerifyApplication" class="dropdown-item">Verification For Online Application</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-verify" class="dropdown-item">Shift &amp; Unit Verification</a></li>
            <li><a href="${pageContext.request.contextPath}/MeritList" class="dropdown-item">Generate Merit List</a></li>
            <li><a href="${pageContext.request.contextPath}/OpenPoolDistrict" class="dropdown-item">Open General Pool</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="DistrictMenu2" role="button" data-bs-toggle="dropdown" aria-expanded="false">SCVT Exams</a>
        <ul class="dropdown-menu" aria-labelledby="DistrictMenu2">
            <li><a href="${pageContext.request.contextPath}/scvt/exam-verification" class="dropdown-item">SCVT Exam Verification</a></li>
            <li><a href="${pageContext.request.contextPath}/scvt/certificate" class="dropdown-item">SCVT Certificate</a></li>
        </ul>
    </li>
    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link">Logout</a></li>
    
</ul>
    </div>
  </div>
</nav>
<div class="role-welcome-strip"><c:if test="${not empty sessionScope.username}">
        <c:set var="districtDisplay" value="${not empty sessionScope.distName ? sessionScope.distName : (not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username)}" />
        <div class="role-welcome-content">
            <div class="welcome-badge">
                <i class="fas fa-city"></i>
                <span>Welcome <strong>District</strong>,</span>
                <span class="welcome-highlight">${districtDisplay}</span>
            </div>
        </div>
    </c:if></div>
