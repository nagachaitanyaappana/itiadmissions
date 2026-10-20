<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <title>Select ITIs | ITI Admission Portal</title>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
        <script type="text/javascript" src="${pageContext.request.contextPath}/js/siteScript.js"></script>
        <script type="text/javascript"
            src="${pageContext.request.contextPath}/js/customJs/applyForITIPhase2Js.js?v=2.2"></script>

        <style>
            body {
                background-color: #f7f9fc;
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            }

            .apply-container {
                max-width: 1200px;
                margin: 20px auto;
                background: white;
                border: 1px solid #cbd5e1;
                border-radius: 4px;
                overflow: hidden;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            }

            .section-header {
                background-color: #195695;
                color: white;
                padding: 10px;
                text-align: center;
                font-weight: 700;
                font-size: 1.05rem;
                letter-spacing: 0.5px;
            }

            .inner-header {
                background-color: #eef4fa;
                color: #195695;
                padding: 8px;
                font-weight: 700;
                text-align: center;
                border-top: 2px solid #195695;
                border-bottom: 1px solid #cbd5e1;
                font-size: 0.95rem;
            }

            .district-selection-box {
                background-color: #f8fbff;
                padding: 8px 15px;
                border-bottom: 1px solid #cbd5e1;
                text-align: center;
            }

            .district-select {
                width: 300px;
                display: inline-block;
                border-radius: 6px;
                padding: 5px 10px;
                border: 1.5px solid #bfdbfe;
                font-size: 0.85rem;
                background-color: white;
            }

            .add-btn {
                background-color: #2563eb;
                color: white;
                border: none;
                padding: 5px 18px;
                border-radius: 4px;
                font-weight: 700;
                margin-left: 8px;
                font-size: 0.85rem;
                transition: 0.2s;
            }

            .summary-table {
                width: 100%;
                border-collapse: collapse;
            }

            .summary-table td {
                border: 1px solid #cbd5e1;
                padding: 8px 12px;
                font-size: 0.82rem;
                vertical-align: middle;
            }

            .label-cell {
                background-color: #f1f5f9;
                color: #1e3a8a;
                font-weight: 700;
                width: 20%;
                position: relative;
            }

            .label-cell::after {
                content: "* :";
                position: absolute;
                right: 5px;
                color: #ef4444;
            }

            .value-cell {
                width: 30%;
                color: #334155;
                font-weight: 600;
                background-color: white;
            }

            .marks-table {
                width: 500px;
                margin: 20px auto;
                border: 1px solid #cbd5e1;
                font-size: 0.82rem;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.03);
            }

            .marks-table th {
                background-color: #195695;
                color: white;
                padding: 8px;
                text-align: center;
                font-weight: 700;
            }

            .marks-table td {
                padding: 6px 15px;
                border: 1px solid #cbd5e1;
            }

            .marks-table .subject-col {
                background-color: #f1f5f9;
                font-weight: 700;
                color: #1e3a8a;
                width: 60%;
            }

            .marks-table .score-col {
                text-align: center;
                width: 40%;
                font-weight: 700;
                color: #334155;
            }

            .total-row {
                background-color: #eef4fa;
                font-weight: 800;
                border-top: 2px solid #195695;
            }

            .consent-box {
                background-color: #fff;
                padding: 15px;
                text-align: center;
                border-top: 1px solid #cbd5e1;
            }

            .choice-list {
                max-width: 600px;
                margin: 10px auto;
                font-size: 0.8rem;
                text-align: left;
            }
        </style>
    </head>

    <body>

        <header>
            <%@include file="/WEB-INF/seniors/header.jsp" %>
        </header>

        <main>
            <div class="container py-4">
                <div class="apply-container">
                    <div class="section-header">Selected ITIs for Admission (Phase ${activePhase != null ? activePhase :
                        'Inactive'})</div>

                    <!-- Section: Selected ITIs Table (Top) -->
                    <div class="mb-4 px-3">
                        <div
                            style="background: #dcfce7; color: #166534; font-weight: 700; padding: 10px; border: 1px solid #bbf7d0; border-bottom: none; text-align: center; border-radius: 8px 8px 0 0;">
                            Selected ITI Preferences
                        </div>
                        <div id="selectedList"
                            style="border: 1px solid #bbf7d0; background: white; min-height: 50px; border-radius: 0 0 8px 8px;">
                            <table class="table table-sm table-bordered mb-0" style="font-size: 0.85rem;">
                                <thead style="background: #f0fdf4;">
                                    <tr style="text-align: center;">
                                        <th width="10%">S.No</th>
                                        <th>ITI Name</th>
                                        <th width="15%">Action</th>
                                    </tr>
                                </thead>
                                <tbody id="selectedTableBody">
                                    <tr>
                                        <td colspan="3"
                                            style="text-align:center; padding: 15px; color: #94a3b8; font-style: italic;">
                                            No ITIs selected yet.</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>

                    <!-- Section: Please Select ITIs (Bottom) -->
                    <div class="district-selection-box mb-5"
                        style="background: #f1f5f9; border: 1px solid #cbd5e1; padding: 25px; border-radius: 12px;">
                        <div class="fw-bold mb-4 text-center"
                            style="font-size: 1.1rem; color: #1e3a8a; text-transform: uppercase; letter-spacing: 1px;">
                            Please Select ITI's here :
                        </div>

                        <div class="row g-3 align-items-end justify-content-center">
                            <div class="col-md-3 text-start">
                                <label class="form-label fw-bold text-dark mb-1" style="font-size: 0.8rem;">District
                                    Name</label>
                                <select id="districtSelect" class="form-select form-select-sm" onchange="filterITIs()">
                                    <option value="">--Select District--</option>
                                </select>
                            </div>
                            <div class="col-md-3 text-start">
                                <label class="form-label fw-bold text-dark mb-1"
                                    style="font-size: 0.8rem;">Government/Private</label>
                                <select id="typeSelect" class="form-select form-select-sm" onchange="filterITIs()">
                                    <option value="">--All--</option>
                                    <option value="G">Government</option>
                                    <option value="P">Private</option>
                                </select>
                            </div>
                            <div class="col-md-4 text-start">
                                <label class="form-label fw-bold text-dark mb-1" style="font-size: 0.8rem;">ITI
                                    Name</label>
                                <select id="itiSelect" class="form-select form-select-sm">
                                    <option value="">--Select ITI--</option>
                                </select>
                            </div>
                            <div class="col-md-2">
                                <button class="btn btn-primary btn-sm w-100 fw-bold py-2 shadow-sm"
                                    onclick="addITIFromDropdown()">
                                    Add Choice <i class="fas fa-plus-circle ms-1"></i>
                                </button>
                            </div>
                        </div>
                    </div>


                    <div class="inner-header">Student Application Summary</div>

                    <table class="summary-table">
                        <tr>
                            <td class="label-cell">Hall Ticket Number</td>
                            <td class="value-cell" id="lbl_ssc_regno">-</td>
                            <td class="label-cell">Board</td>
                            <td class="value-cell" id="lbl_board">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Year of Pass</td>
                            <td class="value-cell" id="lbl_year">-</td>
                            <td class="label-cell">Month of Pass</td>
                            <td class="value-cell" id="lbl_month">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Applicant's Name</td>
                            <td class="value-cell" id="lbl_name">-</td>
                            <td class="label-cell">Mobile Number</td>
                            <td class="value-cell" id="lbl_phno">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Date of Birth</td>
                            <td class="value-cell" id="lbl_dob">-</td>
                            <td class="label-cell">Aadhar Card Number</td>
                            <td class="value-cell" id="lbl_aadhar">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Father/Husband Name</td>
                            <td class="value-cell" id="lbl_fname">-</td>
                            <td class="label-cell">Gender</td>
                            <td class="value-cell" id="lbl_gender">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Mother's Name</td>
                            <td class="value-cell" id="lbl_mname">-</td>
                            <td class="label-cell">Physically Challenged</td>
                            <td class="value-cell" id="lbl_phys">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Address</td>
                            <td class="value-cell" id="lbl_addr">-</td>
                            <td class="label-cell">PWD Category</td>
                            <td class="value-cell" id="lbl_pwd">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Ex-Servicemen</td>
                            <td class="value-cell" id="lbl_exserv">-</td>
                            <td class="label-cell">Qualification</td>
                            <td class="value-cell" id="lbl_qual">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Pincode</td>
                            <td class="value-cell" id="lbl_pincode">-</td>
                            <td class="label-cell">Email</td>
                            <td class="value-cell" id="lbl_email">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Category</td>
                            <td class="value-cell" id="lbl_category">-</td>
                            <td class="label-cell">Local/Non Local</td>
                            <td class="value-cell" id="lbl_local">-</td>
                        </tr>
                        <tr>
                            <td class="label-cell">Economic Weaker Section</td>
                            <td colspan="3" class="value-cell" id="lbl_ews">-</td>
                        </tr>
                    </table>

                    <table class="marks-table">
                        <thead>
                            <tr>
                                <th>SNO</th>
                                <th>Subject</th>
                                <th>Marks</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td style="text-align:center">1</td>
                                <td class="subject-col">First Language</td>
                                <td class="score-col" id="lbl_m1">-</td>
                            </tr>
                            <tr>
                                <td style="text-align:center">2</td>
                                <td class="subject-col">Second Language</td>
                                <td class="score-col" id="lbl_m2">-</td>
                            </tr>
                            <tr>
                                <td style="text-align:center">3</td>
                                <td class="subject-col">Third Language- English</td>
                                <td class="score-col" id="lbl_m3">-</td>
                            </tr>
                            <tr>
                                <td style="text-align:center">4</td>
                                <td class="subject-col">Mathematics</td>
                                <td class="score-col" id="lbl_m4">-</td>
                            </tr>
                            <tr>
                                <td style="text-align:center">5</td>
                                <td class="subject-col">General Science</td>
                                <td class="score-col" id="lbl_m5">-</td>
                            </tr>
                            <tr>
                                <td style="text-align:center">6</td>
                                <td class="subject-col">Social Studies</td>
                                <td class="score-col" id="lbl_m6">-</td>
                            </tr>
                            <tr class="total-row">
                                <td colspan="2" style="text-align:right; color: #1e3a8a;">Total :</td>
                                <td class="score-col" id="lbl_mtot">-</td>
                            </tr>
                        </tbody>
                    </table>

                    <div class="consent-box">
                        <div class="d-flex align-items-center justify-content-center gap-2 mb-4"
                            style="font-size: 0.85rem; color: #1e3a8a; font-weight: 600;">
                            <input type="checkbox" id="consent" style="width: 18px; height: 18px;">
                            <label for="consent">I hereby consent to the use of Aadhaar Numbers provided in the
                                application to carryout Identity Validation for ITI college admission process (Phase
                                ${activePhase != null ? activePhase : 'Inactive'}).</label>
                        </div>

                        <button type="button" class="btn btn-success fw-bold px-4 py-2" onclick="submitApplication()"
                            style="font-size: 1.1rem; box-shadow: 0 4px 6px rgba(40,167,69,0.3);">
                            APPLY NOW <i class="fas fa-paper-plane ms-2"></i>
                        </button>
                    </div>

                    <div style="background-color: #2563eb; height: 15px; width: 100%;"></div>
                </div>
            </div>
        </main>

        <footer>
            <%@include file="/WEB-INF/seniors/footer.jsp" %>
        </footer>

    </body>

    </html>