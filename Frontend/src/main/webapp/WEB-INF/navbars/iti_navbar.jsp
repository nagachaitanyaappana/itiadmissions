<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     ITI dashboard navbar (roleId 4, matching itiap_new).
     =================================================================== --%>
<ul id="menu-bar">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>

    <li><a href="#">Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-iti">API Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-report">Applicant Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admission-report">Admission Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verified Report - ITI</a></li>
        </ul>
    </li>

    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/admissions/reprint-verified-application">Reprint Verified Application</a></li>
            <li><a href="${pageContext.request.contextPath}/VerifyApplication">Verification for Online Applications</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report">DGT Permitted Shifts Units Report</a></li>
            <li><a href="${pageContext.request.contextPath}/AdmissionCounseling/Start">Admissions - Councilling</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/search">Search</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/print-admission-slip">Print Admission Slip</a></li>
            <li><a href="${pageContext.request.contextPath}/ScheduleEntry">Schedule Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/admission-image-upload">Admission Image Upload</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/admission-update">Admission Update</a></li>
        </ul>
    </li>

    <li><a href="#">Exams and Sem</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Semester Hallticket Download</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">HT Download Nonsem</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Exam Apply</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">HT Approval/Nominal Rolls</a></li>
        </ul>
    </li>

    <li><a href="#">HRMS</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Employee ID Edit</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Faculty details</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Employees Report</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Employee Profile Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Faculty Report</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Hrms Instructions</a></li>
        </ul>
    </li>

    <li><a href="#">Placements</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/under-construction">Placement Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">Placement ITI Report</a></li>
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
            <li><a href="${pageContext.request.contextPath}/under-construction">SCVT Exam Application Details Entry</a></li>
            <li><a href="${pageContext.request.contextPath}/under-construction">SCVT HallTicket Download</a></li>
        </ul>
    </li>

    <li><a href="${pageContext.request.contextPath}/logout">Logout</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change Password</a></li>
        </ul>
    </li>

    <c:if test="${not empty sessionScope.username}">
        <li class="welcome-tag">
            Welcome, ${username}<br>
            ${itiName}
        </li>
    </c:if>
</ul>
