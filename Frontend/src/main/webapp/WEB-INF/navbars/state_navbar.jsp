<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     STATE / ADMIN dashboard navbar (roleId 2, and fallback).
     Exact navigation menu matching itiadmissions project.
     UI/design styled via #menu-bar in style.css / iti-portal.css.
     =================================================================== --%>
<ul id="menu-bar" class="no-print">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>
    <li><a href="#">ITI Services</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change User Password</a></li>
            <li><a href="${pageContext.request.contextPath}/services/dget-iti-code">DGET ITI CODE</a></li>
            <li><a href="${pageContext.request.contextPath}/services/register-new-user">New User Creation</a></li>
        </ul>
    </li>
    <li><a href="#">ITI Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/students-not-admitted">Students Not Admitted</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-state">API Dashboard (State)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/phase-wise-admissions-details">Phase Wise Admissions Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/today-schedule-itis">Today Schedule ITIs</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dist-iti-trade-wise-seats-abstract">DIST/ITI/Trade Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/duration-wise-trade-seats-abstract">Duration Wise Trade Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/govt-or-pvt-dist-wise-seats-abstract">Govt or Pvt Dist Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verification Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/district-schedule">District Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report">Shift Unit Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admitted-seats-abstract">Admitted Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/all-resource-role">All Resource Role</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/distwise-admitted-seats-abstract">DistWise Admitted Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/trade-dist-wise-admission-report">Trade/Dist Wise Admission Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/tradewise-vacant-position">TradeWise Vacant Position</a></li>
        </ul>
    </li>
    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/admissions/search">Search</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/discharge-admission">DISCHARGE ADMISSION</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/status-master">Freeze / UnFreeze</a></li>
        </ul>
    </li>
    <li><a href="#">SCVT Exams</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/scvt/exam-initialization">SCVT Exam Initialization</a></li>
        </ul>
    </li>
    <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
    <c:if test="${not empty sessionScope.username}">
        <c:set var="adminDisplay" value="${not empty sessionScope.fullName ? sessionScope.fullName : (not empty sessionScope.username ? sessionScope.username : 'State Directorate')}" />
        <li class="welcome-tag">
            <div class="welcome-badge">
                <i class="fas fa-user-shield"></i>
                <span>Welcome <strong>Admin</strong>,</span>
                <span class="welcome-highlight">${adminDisplay}</span>
            </div>
        </li>
    </c:if>
</ul>
