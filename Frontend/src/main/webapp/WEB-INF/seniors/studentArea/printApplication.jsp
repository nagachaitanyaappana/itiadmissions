<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html>
<head>
    <title>Print Application | ITI Admission Portal</title>
    <style>
        @page {
            size: A4;
            margin: 10mm;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f0f2f5;
            color: #333;
            line-height: 1.3;
        }
        .no-print-zone {
            background: #2563eb;
            color: white;
            padding: 15px;
            text-align: center;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .btn-print {
            background: white;
            color: #2563eb;
            border: none;
            padding: 10px 25px;
            font-weight: bold;
            border-radius: 5px;
            cursor: pointer;
            font-size: 1rem;
            transition: all 0.2s;
        }
        .btn-print:hover {
            background: #f8fafc;
            transform: scale(1.05);
        }
        
        .print-wrapper {
            background: white;
            width: 210mm;
            min-height: 297mm;
            margin: 20px auto;
            padding: 15mm;
            box-shadow: 0 0 20px rgba(0,0,0,0.1);
            box-sizing: border-box;
            position: relative;
        }

        /* Watermark or border if needed */
        .print-wrapper::after {
            content: "";
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            border: 1px solid #ddd;
            pointer-events: none;
        }

        /* Header Layout */
        .official-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            border-bottom: 2px solid #1e3a8a;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
        .logo-box img {
            height: 85px;
            width: auto;
        }
        .header-center {
            text-align: center;
            flex-grow: 1;
        }
        .header-center h1 {
            font-size: 1.3rem;
            margin: 0;
            color: #000;
            text-transform: uppercase;
            font-weight: 800;
        }
        .header-center h2 {
            font-size: 1.1rem;
            margin: 2px 0;
            color: #000;
            text-transform: uppercase;
            font-weight: 700;
        }
        .header-center h3 {
            font-size: 1rem;
            margin: 2px 0;
            color: #000;
            text-transform: uppercase;
            font-weight: 700;
        }

        .ack-banner {
            text-align: center;
            font-size: 0.85rem;
            color: #333;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .reg-id-display {
            text-align: left;
            font-size: 1.5rem;
            font-weight: 800;
            color: #000;
            margin-bottom: 10px;
            border-bottom: 1px solid #000;
            padding-bottom: 5px;
        }

        /* Sections */
        .section-header {
            font-size: 0.85rem;
            font-weight: 700;
            text-decoration: underline;
            text-transform: uppercase;
            margin: 15px 0 8px 0;
            color: #1e3a8a;
        }
        .section-header.center { text-align: center; }

        /* Qualification Area */
        .qual-container {
            display: flex;
            justify-content: space-between;
            margin-bottom: 20px;
        }
        .qual-data {
            flex: 1;
            font-size: 0.85rem;
        }
        .qual-data table { width: 100%; border-collapse: collapse; }
        .qual-data td { padding: 3px 0; vertical-align: top; }
        .label-col { width: 120px; font-weight: 600; color: #475569; }
        .value-col { font-weight: 700; color: #0f172a; }

        .photo-box {
            width: 110px;
            height: 130px;
            border: 1px solid #cbd5e1;
            padding: 2px;
            background: #f8fafc;
        }
        .photo-box img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        /* Tables */
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 15px;
            font-size: 0.82rem;
        }
        .data-table th, .data-table td {
            border: 1px solid #cbd5e1;
            padding: 6px 10px;
            text-align: left;
        }
        .data-table .label-cell {
            background-color: #f8fafc;
            width: 30%;
            font-weight: 600;
            color: #475569;
        }
        .data-table .value-cell {
            width: 70%;
            font-weight: 700;
            color: #0f172a;
            text-transform: uppercase;
        }

        /* Marks Table */
        .marks-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 5px;
        }
        .marks-table th {
            background-color: #f1f5f9;
            font-size: 0.8rem;
            padding: 6px;
            border: 1px solid #cbd5e1;
        }
        .marks-table td {
            padding: 5px;
            border: 1px solid #cbd5e1;
            text-align: center;
            font-weight: 700;
            font-size: 0.85rem;
        }

        /* Applied Districts List (Phase-1) */
        .phase-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 5px;
        }
        .phase-table th {
            background-color: #f1f5f9;
            font-size: 0.8rem;
            padding: 6px;
            border: 1px solid #cbd5e1;
        }
        .phase-table td {
            padding: 5px;
            border: 1px solid #cbd5e1;
            font-size: 0.85rem;
        }

        /* Fee & Notes */
        .info-section {
            font-size: 0.75rem;
            color: #334155;
            margin-top: 20px;
        }
        .info-section p { margin: 4px 0; }
        .fee-table {
            width: 60%;
            border-collapse: collapse;
            margin: 10px 0;
            font-size: 0.75rem;
        }
        .fee-table th, .fee-table td {
            border: 1px solid #94a3b8;
            padding: 4px;
            text-align: center;
        }

        .footer-sig {
            margin-top: 40px;
            display: flex;
            justify-content: flex-end;
        }
        .sig-box {
            text-align: center;
            font-size: 0.85rem;
            font-weight: 600;
            width: 200px;
        }
        .sig-line {
            border-top: 1px solid #333;
            margin-top: 30px;
            padding-top: 5px;
        }

        @media print {
            .no-print-zone { display: none; }
            body { background: white; padding: 0; }
            .print-wrapper { 
                margin: 0; 
                padding: 10mm; 
                box-shadow: none; 
                width: 100%;
                border: none;
            }
            .print-wrapper::after { border: none; }
        }
    </style>
</head>
<body>

    <div class="no-print-zone">
        <button class="btn-print" onclick="window.print()">
            <i class="fas fa-print"></i> DOWNLOAD & PRINT APPLICATION
        </button>
        <p style="margin-top: 10px; font-size: 0.8rem; opacity: 0.9;">Verify all details before printing. Use A4 paper for best results.</p>
    </div>

    <div class="print-wrapper">
        <!-- Header -->
        <div class="official-header">
            <div class="logo-box">
                <img src="${pageContext.request.contextPath}/images/ap.png" onerror="this.src='https://upload.wikimedia.org/wikipedia/commons/e/e3/Emblem_of_Andhra_Pradesh.svg'">
            </div>
            <div class="header-center">
                <h1>Government of Andhra Pradesh</h1>
                <h2>Department of Employment and Training</h2>
                <h3>Industrial Training Institutes</h3>
            </div>
            <div class="logo-box">
                <img src="${pageContext.request.contextPath}/images/itilogo.png" onerror="this.src='https://e-smart.nic.in/iti_admission/images/skill_logo1.png'" style="height: 75px;">
            </div>
        </div>

        <div class="ack-banner">
            Acknowledgement of Submission of Application for Admission into ITI for the session 2025 (Phase-${activePhase != null ? activePhase : '1'})
        </div>

        <div class="reg-id-display">
            Registration ID:${app.regid}
        </div>

        <!-- Qualification Details -->
        <div class="section-header">Qualification Details</div>
        <div class="qual-container">
            <div class="qual-data">
                <table>
                    <tr><td class="label-col">Hall Ticket</td><td class="value-col">: ${app.ssc_regno}</td></tr>
                    <tr><td class="label-col">Board</td><td class="value-col">: ${app.board_name != null ? app.board_name : app.ssc_board}</td></tr>
                    <tr><td class="label-col">Year of Pass</td><td class="value-col">: ${app.ssc_year}</td></tr>
                    <tr><td class="label-col">Applied Date</td><td class="value-col">: <fmt:formatDate value="${app.entry_date}" pattern="dd-MM-yyyy HH:mm:ss" /></td></tr>
                </table>
            </div>
            <div class="photo-box">
                <c:choose>
                    <c:when test="${photo != null}">
                        <img src="data:image/jpeg;base64,${photo}" alt="Student Photo">
                    </c:when>
                    <c:otherwise>
                        <div style="height:100%; display:flex; align-items:center; justify-content:center; color:#94a3b8; font-size:0.7rem;">PHOTO NOT UPLOADED</div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- Personal Details -->
        <div class="section-header center">Personal Details</div>
        <table class="data-table">
            <tr><td class="label-cell">Name</td><td class="value-cell">${app.name}</td></tr>
            <tr><td class="label-cell">Father Name</td><td class="value-cell">${app.fname}</td></tr>
            <tr><td class="label-cell">Mother Name</td><td class="value-cell">${app.mname}</td></tr>
            <tr><td class="label-cell">D.O.B</td><td class="value-cell"><fmt:formatDate value="${app.dob}" pattern="dd-MM-yyyy" /></td></tr>
            <tr><td class="label-cell">Address</td><td class="value-cell">${app.addr}</td></tr>
            <tr><td class="label-cell">Pincode</td><td class="value-cell">${app.pincode}</td></tr>
            <tr><td class="label-cell">Email</td><td class="value-cell" style="text-transform: none;">${app.email}</td></tr>
            <tr><td class="label-cell">Economic Weaker Section</td><td class="value-cell">${app.economic_weaker_section ? 'YES' : 'NO'}</td></tr>
        </table>

        <!-- Reservation Details -->
        <div class="section-header center">Reservation Details</div>
        <table class="data-table">
            <tr>
                <td class="label-cell">Gender</td><td class="value-cell" style="width:20%;">${app.gender}</td>
                <td class="label-cell" style="width:20%;">Caste</td><td class="value-cell">${app.caste_name != null ? app.caste_name : app.caste}</td>
            </tr>
            <tr>
                <td class="label-cell">Ex-Service</td><td class="value-cell">${app.exservice ? 'YES' : 'NO'}</td>
                <td class="label-cell">Physically Handicapped</td><td class="value-cell">${app.phc ? 'YES' : 'NO'}</td>
            </tr>
            <tr>
                <td class="label-cell">Local Status</td><td class="value-cell">${app.local}</td>
                <td class="label-cell">Aadhar No</td><td class="value-cell">XXXXXXXX${fn:substring(app.adarno, fn:length(app.adarno)-4, fn:length(app.adarno))}</td>
            </tr>
            <tr>
                <td class="label-cell">Phone No</td><td class="value-cell" colspan="3">${app.phno}</td>
            </tr>
        </table>

        <!-- Marks Section -->
        <div class="section-header center">Marks/GPA</div>
        <table class="marks-table">
            <thead>
                <tr>
                    <th>First Language</th>
                    <th>Second Language</th>
                    <th>English</th>
                    <th>Mathematics</th>
                    <th>Science</th>
                    <th>Social Studies</th>
                    <th>Total</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td>${marks.ssc_first_lang_marks}</td>
                    <td>${marks.ssc_second_lang_marks}</td>
                    <td>${marks.ssc_eng_marks}</td>
                    <td>${marks.ssc_math_marks}</td>
                    <td>${marks.ssc_sci_marks}</td>
                    <td>${marks.ssc_social_marks}</td>
                    <td style="background:#f8fafc;">${marks.ssc_tot_marks}</td>
                </tr>
            </tbody>
        </table>

        <!-- Phase 1 Districts Area -->
        <c:if test="${not empty phase1Dists}">
            <div class="section-header center">Applied District List (Phase-1)</div>
            <table class="phase-table">
                <thead>
                    <tr>
                        <th width="10%">S.No</th>
                        <th>District Name</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="dist" items="${phase1Dists}" varStatus="status">
                        <tr>
                            <td align="center">${status.index + 1}</td>
                            <td>${dist.dist_name}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>

        <!-- Phase 2-5 ITIs Area -->
        <c:if test="${not empty phase2Itis}">
            <div class="section-header center">Selected ITIs (Phases 2-5)</div>
            <table class="phase-table">
                <thead>
                    <tr>
                        <th width="10%">S.No</th>
                        <th>District</th>
                        <th>ITI Name</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="iti" items="${phase2Itis}" varStatus="status">
                        <tr>
                            <td align="center">${status.index + 1}</td>
                            <td>${iti.dist_name}</td>
                            <td>${iti.iti_name}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </c:if>

        <!-- Info Section -->
        <div class="info-section">
            <p><strong>Fee Structure:</strong></p>
            <p style="margin-left: 10px;">a. Tuition Fees for Private ITIs per annum</p>
            <table class="fee-table" style="margin-left: 100px;">
                <tr><th></th><th>Urban</th><th>Rural</th></tr>
                <tr><td>Engineering Trades</td><td>16,500</td><td>15,000</td></tr>
                <tr><td>Non-Engineering Trades</td><td>13,200</td><td>12,000</td></tr>
            </table>
            <p style="margin-left: 10px;">b. Tuition fee for Government ITIs is <strong>NIL</strong> (Free education)</p>
            
            <p style="margin-top: 15px;"><strong>Note:</strong></p>
            <p>1) For Certificate Verification, Candidate can visit any nearest Government ITI.</p>
            <p>2) During Certificate Verification, Candidate should bring all his/her original certificates i.e., SSC or Equivalent Certificate, Caste, Physically Challenged (PH), Ex-Servicemen, Nativity, Study, transfer Certificate(TC), Aadhar Card and any other Certificates.</p>
            <p>3) At the time of certificate verification, furnish two sets of Xerox copies and bring this registration card to the verification center.</p>
        </div>

        <div class="footer-sig">
            <div class="sig-box">
                <div class="sig-line">Signature of the applicant</div>
            </div>
        </div>

    </div>

</body>
</html>