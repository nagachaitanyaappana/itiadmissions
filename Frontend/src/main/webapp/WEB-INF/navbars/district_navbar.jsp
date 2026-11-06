<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     DISTRICT dashboard navbar (roleId 3).
     Exact navigation menu matching itiadmissions project.
     UI/design styled via #menu-bar in style.css / iti-portal.css.
     =================================================================== --%>
<ul id="menu-bar" class="no-print">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>
    <li><a href="#">ITI Services</a><ul></ul></li>
    <li><a href="#">ITI Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-address-with-mobile">Applicant Address With Mobile</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-district">API Dashboard (District)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verification Report</a></li>
        </ul>
    </li>
    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase">ADMISSIONS PHASE 1</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/SeatMatrix">seatmatrix</a></li>
            <li><a href="${pageContext.request.contextPath}/CallLetterView">Call Letter</a></li>
            <li><a href="${pageContext.request.contextPath}/iti-trade-selection">DGT Permitted Shifts Units</a></li>
            <li><a href="${pageContext.request.contextPath}/AddTrade">Add Trade</a></li>
            <li><a href="${pageContext.request.contextPath}/ReservationEntry">Reservation Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/SeatCorrection">Seat Correction</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report">DGT Permitted Shifts Units Report</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/discharge">Discharge Admission</a></li>
            <li><a href="${pageContext.request.contextPath}/ScheduleEntry">Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/DeleteScheduleEntry">Delete Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/VerifyApplication">Verification For Online Application</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-verify">Shift &amp; Unit Verification</a></li>
            <li><a href="${pageContext.request.contextPath}/MeritList">Generate Merit List</a></li>
            <li><a href="${pageContext.request.contextPath}/OpenPoolDistrict">Open General Pool</a></li>
        </ul>
    </li>
    <li><a href="#">SCVT Exams</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/scvt/exam-verification">SCVT Exam Verification</a></li>
            <li><a href="${pageContext.request.contextPath}/scvt/certificate">SCVT Certificate</a></li>
        </ul>
    </li>
    <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
    <c:if test="${not empty sessionScope.username}">
        <c:set var="districtDisplay" value="${not empty sessionScope.distName ? sessionScope.distName : (not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username)}" />
        <li class="welcome-tag">
            <div class="welcome-badge">
                <i class="fas fa-city"></i>
                <span>Welcome <strong>District</strong>,</span>
                <span class="welcome-highlight">${districtDisplay}</span>
            </div>
        </li>
    </c:if>
</ul>
