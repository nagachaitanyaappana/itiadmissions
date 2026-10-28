<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     STATE / ADMIN dashboard navbar (roleId 2, matching itiap_new).
     =================================================================== --%>
<ul id="menu-bar">
    <li><a href="${pageContext.request.contextPath}/authHome">Home</a></li>

    <li><a href="#">Administration</a>
        <ul>
            <li><a href="#">Upload News And Updates</a></li>
            <li><a href="#">Scroll Update</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report">Shift Unit Report</a></li>
            <li><a href="#">Trade Name Change</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/district-schedule">District Schedule</a></li>
            <li><a href="${pageContext.request.contextPath}/services/dget-iti-code">DGET ITI CODE</a></li>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change Particular User Password</a></li>
            <li><a href="${pageContext.request.contextPath}/services/register-new-user">NEW USER CREATION</a></li>
            <li><a href="#">Login History</a></li>
            <li><a href="${pageContext.request.contextPath}/services/registration">Add ITI Master</a></li>
        </ul>
    </li>

    <li><a href="#">Reports</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/trade-dist-wise-admission-report">Trade/District Wise Admission Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-state">Api Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/tradewise-vacant-position">TradeWise Vacant Position</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/distwise-admitted-seats-abstract">DistrictWise Admitted Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admitted-seats-abstract">Admitted Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/today-schedule-itis">Today Schedule ITIs</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/trade-display1">Update ITI</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/phase-wise-admissions-details">Phase Wise Admissions Details</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract">Caste Wise Admissions Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dist-iti-trade-wise-seats-abstract">District/ITI/Trade Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/govt-or-pvt-dist-wise-seats-abstract">Govt or Pvt Dist Wise Seats Abstract</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/admission-report">Admissions Report</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/duration-wise-trade-seats-abstract">Duration Wise Trade Seats Abstract</a></li>
        </ul>
    </li>

    <li><a href="#">Admissions</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/jsp/permitted_shift_unit_nodal_report.jsp">DGT Permitted Shifts Units Report</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/status-master">Freeze or UnFreeze</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/search">Search</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/verification-report">Verification Report - Dist wise</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/dsc-list">DSC List</a></li>
            <li><a href="${pageContext.request.contextPath}/admissions/discharge-admission">DISCHARGE ADMISSION</a></li>
        </ul>
    </li>

    <li><a href="#">Exams and Sem</a>
        <ul>
            <li><a href="#">Question Paper Indent</a></li>
            <li><a href="#">SCVT Semwise Certificate</a></li>
            <li><a href="#">Candidate Details</a></li>
            <li><a href="#">Result Process</a></li>
            <li><a href="#">Dist Wise Sem Results</a></li>
            <li><a href="#">ExamCentre Allocation</a></li>
            <li><a href="#">ExamCentre Entry</a></li>
            <li><a href="#">Admission Data</a></li>
            <li><a href="#">Total Marks Process Semwise/Htno</a></li>
            <li><a href="#">Marks Entry</a></li>
            <li><a href="#">HT Approval/Nominal Rolls</a></li>
            <li><a href="#">Delete Admission Non Sem</a></li>
            <li><a href="#">Centerwise QIndent</a></li>
        </ul>
    </li>

    <li><a href="#">HRMS</a>
        <ul>
            <li><a href="#">Faculty Report</a></li>
            <li><a href="#">Hrms Instructions</a></li>
            <li><a href="#">Employee ID Edit</a></li>
            <li><a href="#">Employees Report</a></li>
            <li><a href="#">Faculty details</a></li>
        </ul>
    </li>

    <li><a href="#">Placements</a>
        <ul>
            <li><a href="#">Placement State Report</a></li>
            <li><a href="#">Placement Year Wise Count Report</a></li>
        </ul>
    </li>

    <li><a href="#">Achievements</a>
        <ul>
            <li><a href="#">ITI WISE REPORT</a></li>
        </ul>
    </li>

    <li><a href="#">Abstracts</a>
        <ul>
            <li><a href="#">Caste wise year wise abstract</a></li>
            <li><a href="#">Generate New Abstract Query</a></li>
        </ul>
    </li>

    <li><a href="#">SCVT Exams</a>
        <ul>
            <li><a href="#">Sem Certificate Printing</a></li>
            <li><a href="${pageContext.request.contextPath}/scvt/exam-initialization">SCVT Exam Initialization</a></li>
            <li><a href="#">SCVT Result Processing</a></li>
            <li><a href="${pageContext.request.contextPath}/scvt/certificate">SCVT Certificate</a></li>
        </ul>
    </li>

    <li><a href="${pageContext.request.contextPath}/logout">Logout</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/services/password-change">Change Password</a></li>
        </ul>
    </li>

    <c:if test="${not empty sessionScope.username}">
        <li class="welcome-tag">Welcome, ${fullName}<br>Admin</li>
    </c:if>
</ul>
