    <ul id="menu-bar" style="height: 45px;">
        <li> <a href="${pageContext.request.contextPath}/authHome">Home</a> </li>

        <li>
            <a href="#">ITI Reports</a>
            <ul>
                <li><span class="top"></span><span class="bottom"></span></li>
                <li><a href="${pageContext.request.contextPath}/reports/applicant-address-with-mobile"  title="">Applicant Address With Mobile </a></li>
                <li><a href="${pageContext.request.contextPath}/reports/api-dashboard-district"  title="">API Dashboard (District) </a></li>
                <li><a href="${pageContext.request.contextPath}/reports/caste-wise-admissions-abstract"  title="">Caste Wise Admissions Abstract </a></li>
                <li><a href="${pageContext.request.contextPath}/reports/verification-report"  title="">Verification Report </a></li>
                <li><a href="${pageContext.request.contextPath}/reports/dsc-list"  title="">DSC List </a></li>
            </ul>
        </li>

        <li>
            <a href="#">Admissions</a>
            <ul>
                <li><span class="top"></span><span class="bottom"></span></li>
                <li><a href="${pageContext.request.contextPath}/AdmissionPhase"  title="">ADMISSIONS PHASE 1 </a></li>
                <li><a href="${pageContext.request.contextPath}/AdmissionPhase"  title="">Admission Counseling (Rank) </a></li>
                <li><a href="${pageContext.request.contextPath}/SeatMatrix"  title="">seatmatrix </a></li>
                <li><a href="${pageContext.request.contextPath}/CallLetterView"  title="">Call Letter </a></li>
                <li><a href="${pageContext.request.contextPath}/iti-trade-selection"  title="">DGT Permitted Shifts Units </a></li>
                <li><a href="${pageContext.request.contextPath}/AddTrade"  title="">Add Trade </a></li>
                <li><a href="${pageContext.request.contextPath}/ReservationEntry"  title="">Reservation Entry </a></li>
                <li><a href="${pageContext.request.contextPath}/SeatCorrection"  title="">Seat Correction </a></li>
                <li><a href="${pageContext.request.contextPath}/reports/shift-unit-report"  title="">DGT Permitted Shifts Units Report </a></li>
                <li><a href="${pageContext.request.contextPath}/admissions/discharge"  title="">Discharge Admission </a></li>
                <li><a href="${pageContext.request.contextPath}/ScheduleEntry"  title="">Schedule Entry </a></li>
                <li><a href="${pageContext.request.contextPath}/DeleteScheduleEntry"  title="">Delete Schedule Entry </a></li>
                <li><a href="${pageContext.request.contextPath}/VerifyApplication"  title="">Verification For Online Application </a></li>
                <li><a href="${pageContext.request.contextPath}/reports/shift-unit-verify"  title="">Shift &amp; Unit Verification </a></li>
                <li><a href="${pageContext.request.contextPath}/MeritList"  title="">Generate Merit List </a></li>
            </ul>
        </li>

        <li>
            <a href="#">SCVT Exams</a>
            <ul>
                <li><span class="top"></span><span class="bottom"></span></li>
                <li><a href="${pageContext.request.contextPath}/scvt/exam-verification"  title="">SCVT Exam Verification </a></li>
                <li><a href="${pageContext.request.contextPath}/scvt/certificate"  title="">SCVT Certificate </a></li>
            </ul>
        </li>

        <li><a href="${pageContext.request.contextPath}/logout">Logout</a>
            <ul>
                <li><span class="top"></span><span class="bottom"></span></li>
                <li><a href="${pageContext.request.contextPath}/ChangePassword_Interface"  title="">Change Password  </a></li>
            </ul>
        </li>

        <li><span style="color: blue; font-size: 10px;" >
                        Welcome, ${sessionScope.username}<br>
                         ${sessionScope.insCode}</span> </li>
    </ul>
