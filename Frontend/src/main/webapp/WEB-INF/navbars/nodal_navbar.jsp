<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     NODAL dashboard navbar (roleId 10, matching itiap_new).
     =================================================================== --%>
<ul id="menu-bar">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>

    <li><a href="#">Administration</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change Particular User Password</a></li>
            <li><a href="${pageContext.request.contextPath}/services/registration">Add ITI Master</a></li>
            <li><a href="#">Trade Deletion</a></li>
        </ul>
    </li>

    <li><a href="#">Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-state">Api Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/phase-wise-admissions-details">Phase Wise Admissions Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/today-schedule-itis">Today Schedule ITIs</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/trade-wise-report">Trade Wise Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-report-dist-wise">Applicant Report District Wise</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/student-reg-details">STUDENT DETAILS</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/duration-wise-trade-seats-abstract">Duration Wise Trade Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/govt-or-pvt-dist-wise-seats-abstract">Govt or Pvt Dist Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dist-iti-trade-wise-seats-abstract">District/ITI/Trade Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admission-report">Admissions Report</a></li>
        </ul>
    </li>

    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/jsp/permitted_shift_unit_nodal_report.jsp">DGT Permitted Shifts Units Report</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/reprint-verified-application">Reprint Verified Application</a></li>
            <li><a href="#">Update DGT Permitted Shifts Units</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verification Report - Dist wise</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/application-reprint">Application Reprint</a></li>
            <li><a href="${pageContext.request.contextPath}/DeleteScheduleEntry">Delete Admission Timings</a></li>
        </ul>
    </li>

    <li><a href="#">Placements</a>
        <ul>
            <li><a href="#">Placements Schedlewise Data</a></li>
            <li><a href="#">Placement Year Wise Count Report</a></li>
            <li><a href="#">Placement State Report</a></li>
        </ul>
    </li>

    <li><a href="${pageContext.request.contextPath}/logout">Logout</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change Password</a></li>
        </ul>
    </li>

    <c:if test="${not empty sessionScope.username}">
        <li class="welcome-tag">Welcome, ${fullName}<br>Nodal Officer</li>
    </c:if>
</ul>
