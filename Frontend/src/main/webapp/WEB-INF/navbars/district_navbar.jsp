<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     DISTRICT dashboard navbar (roleId 3, matching itiap_new).
     =================================================================== --%>
<ul id="menu-bar">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>

    <li><a href="#">Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/trade-display1">Update ITI</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-report">Applicant Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-address-with-mobile">Applicant Address with Mobile</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-district">API Dashboard</a></li>
        </ul>
    </li>

    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/VerifyApplication">Verification for Online Applications</a></li>
            <li><a href="${pageContext.request.contextPath}/VerifyApplication">Re-Verification for Online Applications</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report">DGT Permitted Shifts Units Report</a></li>
            <li><a href="${pageContext.request.contextPath}/iti-trade-selection">DGT Permitted Shifts Units</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-verify">Shift-Unit Verify</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/reprint-verified-application">Reprint Verified Application</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verification Report - Dist wise</a></li>
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase">ADMISSIONS PHASE 1</a></li>
            <li><a href="${pageContext.request.contextPath}/SeatMatrix">seatmatrix</a></li>
            <li><a href="${pageContext.request.contextPath}/AddTrade">Add Trade</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/application-reprint">Application Reprint</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/MeritList">Merit List with GPA</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/print-admission-slip">Print Admission Slip</a></li>
            <li><a href="${pageContext.request.contextPath}/ScheduleEntry">Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/CallLetterView">CALL LETTER</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/discharge">DISCHARGE ADMISSION</a></li>
        </ul>
    </li>

    <li><a href="#">Exams and Sem</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Exam Apply</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">DOWNLOAD EXAM MASTER DATA</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Semester Hallticket Download</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">HT Download Nonsem</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">HT Approval/Nominal Rolls</a></li>
        </ul>
    </li>

    <li><a href="#">HRMS</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Employee ID Edit</a></li>
        </ul>
    </li>

    <li><a href="#">Placements</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Placement Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Placement Dist Report</a></li>
        </ul>
    </li>

    <li><a href="#">Achievements</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">ITI WISE REPORT</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">ACHIEVEMENT ENTRY</a></li>
        </ul>
    </li>

    <li><a href="#">Abstracts</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Caste wise year wise abstract</a></li>
        </ul>
    </li>

    <li><a href="#">SCVT Exams</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/scvt/exam-verification">SCVT Exam Verification</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">SCVT MARKS ENTRY</a></li>
            <li><a href="${pageContext.request.contextPath}/scvt/certificate">SCVT Certificate</a></li>
        </ul>
    </li>

    <li><a href="${pageContext.request.contextPath}/logout">Logout</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change Password</a></li>
        </ul>
    </li>

    <c:if test="${not empty sessionScope.username}">
        <li class="welcome-tag">Welcome, ${fullName}<br>District</li>
    </c:if>
</ul>
