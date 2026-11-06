<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     NODAL dashboard navbar (roleId 10).
     Exact navigation menu matching itiadmissions project.
     UI/design styled via #menu-bar in style.css / iti-portal.css.
     =================================================================== --%>
<ul id="menu-bar" class="no-print">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>
    <li><a href="#">ITI Services</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change User Password</a></li>
            <li><a href="${pageContext.request.contextPath}/services/registration">Add ITI Master</a></li>
        </ul>
    </li>
    <li><a href="#">ITI Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-state">API Dashboard (State)</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/phase-wise-admissions-details">Phase Wise Admissions Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/today-schedule-itis">Today Schedule ITIs</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/trade-wise-report">Trade Wise Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/applicant-report-dist-wise">Applicant Report Dist Wise</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dist-iti-trade-wise-seats-abstract">DIST/ITI/Trade Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/duration-wise-trade-seats-abstract">Duration Wise Trade Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/govt-or-pvt-dist-wise-seats-abstract">Govt or Pvt Dist Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/student-reg-details">Student Reg Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/students-not-admitted">Students Not Admitted</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verification Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract">Caste Wise Admissions Abstract</a></li>
        </ul>
    </li>
    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase">ADMISSIONS PHASE 1</a></li>
            <li><a href="${pageContext.request.contextPath}/AdmissionPhase">Admission Counseling (Rank)</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/reprint-verified-application">Application Reprint</a></li>
            <li><a href="${pageContext.request.contextPath}/jsp/permitted_shift_unit_nodal_report.jsp">DGT Permitted Shifts Report</a></li>
        </ul>
    </li>
    <li><a href="#">SCVT Exams</a><ul></ul></li>
    <li><a href="${pageContext.request.contextPath}/logout">Logout</a></li>
    <c:if test="${not empty sessionScope.username}">
        <c:set var="nodalDisplay" value="${not empty sessionScope.distName ? sessionScope.distName : (not empty sessionScope.fullName ? sessionScope.fullName : sessionScope.username)}" />
        <li class="welcome-tag">
            <div class="welcome-badge">
                <i class="fas fa-map-marker-alt"></i>
                <span>Welcome <strong>Nodal Officer</strong>,</span>
                <span class="welcome-highlight">${nodalDisplay}</span>
            </div>
        </li>
    </c:if>
</ul>
