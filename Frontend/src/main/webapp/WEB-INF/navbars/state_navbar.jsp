<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     STATE / ADMIN dashboard navbar (roleId 2, and fallback).
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
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#StateNav" aria-controls="StateNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="StateNav">
<ul class="navbar-nav nav-menu mx-auto">
    <li class="nav-item"><a href="${pageContext.request.contextPath}/authHome" class="nav-link">Home</a></li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="StateMenu0" role="button" data-bs-toggle="dropdown" aria-expanded="false">ITI Services</a>
        <ul class="dropdown-menu" aria-labelledby="StateMenu0">
            <li><a href="${pageContext.request.contextPath}/services/password-change" class="dropdown-item">Change User Password</a></li>
            <li><a href="${pageContext.request.contextPath}/services/dget-iti-code" class="dropdown-item">DGET ITI CODE</a></li>
            <li><a href="${pageContext.request.contextPath}/services/register-new-user" class="dropdown-item">New User Creation</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="StateMenu1" role="button" data-bs-toggle="dropdown" aria-expanded="false">ITI Reports</a>
        <ul class="dropdown-menu" aria-labelledby="StateMenu1">
            <li><a href="${pageContext.request.contextPath}/reports/students-not-admitted" class="dropdown-item">Students Not Admitted</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-state" class="dropdown-item">API Dashboard (State)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/phase-wise-admissions-details" class="dropdown-item">Phase Wise Admissions Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/today-schedule-itis" class="dropdown-item">Today Schedule ITIs</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dist-iti-trade-wise-seats-abstract" class="dropdown-item">DIST/ITI/Trade Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/duration-wise-trade-seats-abstract" class="dropdown-item">Duration Wise Trade Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/govt-or-pvt-dist-wise-seats-abstract" class="dropdown-item">Govt or Pvt Dist Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report" class="dropdown-item">Verification Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract" class="dropdown-item">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/district-schedule" class="dropdown-item">District Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report" class="dropdown-item">Shift Unit Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admitted-seats-abstract" class="dropdown-item">Admitted Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/all-resource-role" class="dropdown-item">All Resource Role</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/distwise-admitted-seats-abstract" class="dropdown-item">DistWise Admitted Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/trade-dist-wise-admission-report" class="dropdown-item">Trade/Dist Wise Admission Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/tradewise-vacant-position" class="dropdown-item">TradeWise Vacant Position</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="StateMenu2" role="button" data-bs-toggle="dropdown" aria-expanded="false">Admissions</a>
        <ul class="dropdown-menu" aria-labelledby="StateMenu2">
            <li><a href="${pageContext.request.contextPath}/admissions/search" class="dropdown-item">Search</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list" class="dropdown-item">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/discharge-admission" class="dropdown-item">DISCHARGE ADMISSION</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/status-master" class="dropdown-item">Freeze / UnFreeze</a></li>
        </ul>
    </li>
    <li class="nav-item dropdown"><a href="#" class="nav-link dropdown-toggle" id="StateMenu3" role="button" data-bs-toggle="dropdown" aria-expanded="false">SCVT Exams</a>
        <ul class="dropdown-menu" aria-labelledby="StateMenu3">
            <li><a href="${pageContext.request.contextPath}/scvt/exam-initialization" class="dropdown-item">SCVT Exam Initialization</a></li>
        </ul>
    </li>
    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link">Logout</a></li>
    
</ul>
    </div>
  </div>
</nav>
<div class="role-welcome-strip"><c:if test="${not empty sessionScope.username}">
        <c:set var="adminDisplay" value="${not empty sessionScope.fullName ? sessionScope.fullName : (not empty sessionScope.username ? sessionScope.username : 'State Directorate')}" />
        <div class="role-welcome-content">
            <div class="welcome-badge">
                <i class="fas fa-user-shield"></i>
                <span>Welcome <strong>Admin</strong>,</span>
                <span class="welcome-highlight">${adminDisplay}</span>
            </div>
        </div>
    </c:if></div>
