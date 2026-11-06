<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     ITI dashboard navbar (roleId 4).
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
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#ItiNav" aria-controls="ItiNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="ItiNav">
<ul class="navbar-nav nav-menu mx-auto">
    <li class="nav-item"><a href="${pageContext.request.contextPath}/authHome" class="nav-link">Home</a></li>

    <li class="nav-item"><a href="#" class="nav-link">ITI Services</a>
        
    </li>

    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="ItiMenu0" role="button" data-bs-toggle="dropdown" aria-expanded="false">ITI Reports</a>
        <ul class="dropdown-menu" aria-labelledby="ItiMenu0">
            <li><a href="${pageContext.request.contextPath}/admissions/search" class="dropdown-item">Search</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-iti" class="dropdown-item">API Dashboard (ITI)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-report" class="dropdown-item">Applicant Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admission-report" class="dropdown-item">Admission Report</a></li>
        </ul>
    </li>

    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="ItiMenu1" role="button" data-bs-toggle="dropdown" aria-expanded="false">Admissions</a>
        <ul class="dropdown-menu" aria-labelledby="ItiMenu1">
            <li><a href="${pageContext.request.contextPath}/MeritList" class="dropdown-item">MeritList with GPA</a></li>
            <li><a href="${pageContext.request.contextPath}/VerifyApplication" class="dropdown-item">Verification For Online Application</a></li>
            <li><a href="${pageContext.request.contextPath}/ScheduleEntry" class="dropdown-item">Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/CallLetterView" class="dropdown-item">Call Letter</a></li>
            <li><a href="${pageContext.request.contextPath}/AdmissionCounseling/Start" class="dropdown-item">Admission Counselling</a></li>
            <li><a href="${pageContext.request.contextPath}/DeleteScheduleEntry" class="dropdown-item">Delete Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/admission-update" class="dropdown-item">Admission Update</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/search" class="dropdown-item">Search</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/admission-image-upload" class="dropdown-item">Admission Image Upload</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list" class="dropdown-item">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/print-admission-slip" class="dropdown-item">Print Admission Slip</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/reprint-verified-application" class="dropdown-item">Reprint Verified Application</a></li>
            <li><a href="${pageContext.request.contextPath}/OpenPoolIti" class="dropdown-item">Open General Pool</a></li>
        </ul>
    </li>

    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link">Logout</a></li>

    
</ul>
    </div>
  </div>
</nav>
<div class="role-welcome-strip"><c:if test="${not empty sessionScope.username}">
        <c:set var="itiDisplay" value="${not empty sessionScope.itiName ? sessionScope.itiName : (not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username)}" />
        <div class="role-welcome-content">
            <div class="welcome-badge">
                <i class="fas fa-university"></i>
                <span>Welcome <strong>ITI</strong>,</span>
                <span class="welcome-highlight">${itiDisplay}</span>
            </div>
        </div>
    </c:if></div>
