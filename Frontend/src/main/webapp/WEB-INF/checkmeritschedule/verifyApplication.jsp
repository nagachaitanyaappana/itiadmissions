<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <title>Verification For Online Application</title>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <jsp:include page="/WEB-INF/jsp/_api_base_url.jsp"/>
    <script type="text/javascript">
        const SESSION_ROLE_ID = '${sessionScope.roleId}';
        const SESSION_INS_CODE = '${sessionScope.insCode}';
        const SESSION_USERNAME = '${sessionScope.username}';
        const SESSION_DIST_NAME = '${sessionScope.distName}';
    </script>
    <style>
        body { margin: 0; font-family: Verdana, Arial, sans-serif; background: #fff; }
        #footer {
            position: fixed; bottom: 0px; width: 100%; height: 25px;
            padding-top: 8px; text-align: center;
            background-color: #0E4878; border-top: 1px #000000 solid;
            font-size: 12px; font-family: arial, verdana; color: #ffffff;
        }
        #footer a { color: white; }

        #verifyForm {
            border: black 2px solid;
            max-width: 480px; width: 90%;
            text-align: center; margin: 2% auto 3%;
            padding-bottom: 3%; background-color: #e4eeb9;
            border-radius: 8px;
        }
        #verifyForm h2 { color: blue; text-decoration: underline; margin: 1.5rem 0; }
        #verifyForm input { display: inline-block; width: 70%; padding: 8px; }
        #verifyForm .btn-submit {
            background: #a8d942; color: #fff; border: 1px solid #8abf2e;
            padding: 10px 20px; border-radius: 4px; font-weight: bold; cursor: pointer;
        }
        #verifyForm .btn-submit:hover { background: #95c930; }
        .msg-box { margin-top: 1rem; font-weight: bold; text-align: center; }

        /* Result Section */
        #resultSection { display: none; max-width: 1000px; margin: 2% auto; }
        #resultCard { border: 1px solid #ccc; border-radius: 8px; background: #fff; box-shadow: 0 2px 6px rgba(0,0,0,0.1); }
        #resultHeader { background: #f5f5f5; border-bottom: 1px solid #ddd; padding: 12px 16px; display: flex; justify-content: space-between; align-items: center; border-radius: 8px 8px 0 0; }
        #resultHeader h5 { margin: 0; font-size: 16px; }
        #statusBadge { padding: 4px 10px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        #resultBody { padding: 16px; }
        #verifyMsg { margin-bottom: 16px; }

        /* Photo */
        #photoWrapper { display: flex; gap: 16px; margin-bottom: 16px; flex-wrap: wrap; }
        #photoBox { flex: 0 0 130px; text-align: center; }
        #studentPhoto { display: none; max-width: 120px; max-height: 150px; border: 1px solid #ddd; border-radius: 4px; }
        #noPhotoPlaceholder { color: #666; font-size: 12px; }

        /* Details Table */
        .detail-table { width: 100%; border-collapse: collapse; font-size: 13px; margin-bottom: 16px; }
        .detail-table th { width: 180px; text-align: left; padding: 4px; border-bottom: 1px solid #eee; font-weight: bold; }
        .detail-table td { padding: 4px; border-bottom: 1px solid #eee; }

        /* Section Header */
        .section-hdr { color: #0056b3; border-bottom: 1px solid #ddd; padding-bottom: 4px; margin: 16px 0 8px; font-size: 14px; font-weight: bold; }

        /* Marks Table */
        #marksTable { width: 100%; border-collapse: collapse; font-size: 13px; }
        #marksTable th { background: #f5f5f5; text-align: left; padding: 6px; border: 1px solid #ddd; }
        #marksTable td { padding: 6px; border: 1px solid #ddd; }
        #marksTable .text-center { text-align: center; }
        #marksTable .text-right { text-align: right; }
        #marksTable tfoot tr { background: #f5f5f5; font-weight: bold; }

        /* Trades Table */
        #tradesTable { width: 100%; border-collapse: collapse; font-size: 13px; min-width: 400px; }
        #tradesTable th { background: #f5f5f5; padding: 6px; border: 1px solid #ddd; text-align: center; }
        #tradesTable td { padding: 6px; border: 1px solid #ddd; text-align: center; }
        #tradesTable td:nth-child(3) { text-align: left; }

        /* Document Verification Table */
        #docTable { width: 100%; border-collapse: collapse; font-size: 13px; margin-top: 8px; }
        #docTable th { background: #f5f5f5; padding: 6px; border: 1px solid #ddd; text-align: left; width: 40%; }
        #docTable th:nth-child(2) { width: 20%; text-align: center; }
        #docTable th:nth-child(3) { width: 20%; text-align: center; }
        #docTable th:nth-child(4) { width: 20%; text-align: center; }
        #docTable td { padding: 6px; border: 1px solid #ddd; }
        #docTable td label { display: inline-flex; align-items: center; gap: 4px; cursor: pointer; }

        /* Action Buttons */
        .btn-group { text-align: center; margin-top: 16px; }
        .btn-group button { padding: 10px 24px; border-radius: 4px; font-weight: bold; cursor: pointer; margin: 0 8px; border: 1px solid; }
        .btn-approve { background: #28a745; color: #fff; border-color: #1e7e34; }
        .btn-reject { background: #dc3545; color: #fff; border-color: #bd2130; }
        .btn-reject:disabled, .btn-approve:disabled { opacity: 0.6; cursor: not-allowed; }
        .btn-cancel { background: #6c757d; color: #fff; border-color: #545b62; }

        /* Reject Reason */
        #rejectReasonDiv { display: none; margin-top: 16px; }
        #rejectReasonDiv label { font-weight: bold; display: block; margin-bottom: 4px; }
        #rejectReasonDiv textarea { width: 100%; padding: 8px; border: 1px solid #ccc; border-radius: 4px; font-family: inherit; box-sizing: border-box; }
        #rejectReasonDiv .btn-row { margin-top: 8px; }

        /* Toast */
        #verifyMsg { margin-bottom: 16px; }
        .toast { padding: 10px; border-radius: 4px; margin-bottom: 12px; }
        .toast-success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .toast-danger { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .toast-warning { background: #fff3cd; border: 1px solid #ffeeba; color: #856404; }
        .toast-info { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; }

        /* Modal */
        .modal { display: none; position: fixed; z-index: 1000; left: 0; top: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); }
        .modal-content { background: #fff; margin: 10% auto; padding: 20px; border: 1px solid #888; width: 50%; max-width: 500px; border-radius: 8px; box-shadow: 0 4px 8px rgba(0,0,0,0.2); }
        .modal-header { background: #28a745; color: #fff; padding: 10px 16px; border-radius: 8px 8px 0 0; margin: -20px -20px 16px; font-weight: bold; }
        .modal-close { float: right; font-size: 24px; cursor: pointer; }
        .modal-body { margin: 16px 0; }
        .modal-footer { text-align: right; }
        .modal-footer button { padding: 8px 16px; border-radius: 4px; font-weight: bold; cursor: pointer; margin-left: 8px; border: 1px solid; }
        .modal-btn-confirm { background: #28a745; color: #fff; border-color: #1e7e34; }
        .modal-btn-cancel { background: #6c757d; color: #fff; border-color: #545b62; }

        /* Message boxes */
        .alert { padding: 10px; border-radius: 4px; margin-bottom: 12px; }
        .alert-success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
        .alert-danger { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
        .alert-warning { background: #fff3cd; border: 1px solid #ffeeba; color: #856404; }
        .alert-info { background: #d1ecf1; border: 1px solid #bee5eb; color: #0c5460; }

        /* Form elements */
        .form-control { width: 100%; padding: 6px 8px; border: 1px solid #ccc; border-radius: 4px; font-family: inherit; box-sizing: border-box; }
        select.form-control { height: 34px; }
        textarea.form-control { min-height: 60px; resize: vertical; }
        .radio-group { display: inline-flex; gap: 16px; align-items: center; }
        .radio-group label { display: inline-flex; align-items: center; gap: 4px; cursor: pointer; font-weight: normal; }
        .readonly { background: #f5f5f5; }
    </style>
</head>
<body onload="initPage()">
    <jsp:include page="/WEB-INF/reports/header.jsp" />

    <!-- Search Form -->
    <div id="verifyForm">
        <h2>Verification for Online Application</h2>
        <form id="searchForm" onsubmit="return validate(event);">
            Registration Id:
            <input type="text" id="regid" name="regid" maxlength="15" onkeypress="return NumericsOnly(event);" autocomplete="off" />
            <br/><br/>
            <button type="submit" class="btn-submit">Search</button>
        </form>
        <div id="msgBox" class="msg-box"></div>
    </div>

    <!-- Result Section -->
    <div id="resultSection" style="display:none; max-width: 1000px; margin: 2% auto;">
        <div id="resultCard">
            <div id="resultHeader">
                <h5 style="margin:0;"><strong>Application Details</strong></h5>
                <span id="statusBadge"></span>
            </div>
            <div style="padding: 16px;">
                <div id="verifyMsg"></div>

                <!-- Photo + Basic Info -->
                <div style="display: flex; gap: 16px; margin-bottom: 16px; flex-wrap: wrap;">
                    <div style="flex: 0 0 130px; text-align: center;">
                        <img id="studentPhoto" src="" alt="Student Photo" style="display:none; max-width: 120px; max-height: 150px; border: 1px solid #ddd; border-radius: 4px;" />
                        <div id="noPhotoPlaceholder" style="color: #666; font-size: 12px;">No Photo</div>
                    </div>
                    <div style="flex: 1; min-width: 300px;">
                        <table class="detail-table">
                            <tbody>
                                <tr><th>Registration ID</th><td id="d_regid"></td></tr>
                                <tr><th>SSC Reg No</th><td id="d_ssc_regno"></td></tr>
                                <tr><th>Name</th><td id="d_name"></td></tr>
                                <tr><th>Father Name</th><td id="d_fname"></td></tr>
                                <tr><th>Mother Name</th><td id="d_mname"></td></tr>
                                <tr><th>Date of Birth</th><td id="d_dob"></td></tr>
                                <tr><th>Gender</th><td id="d_gender"></td></tr>
                                <tr><th>Caste</th><td id="d_caste"></td></tr>
                                <tr><th>Mobile</th><td id="d_phno"></td></tr>
                                <tr><th>Aadhaar</th><td id="d_adarno"></td></tr>
                                <tr><th>Address</th><td id="d_addr"></td></tr>
                                <tr><th>Local/Non-Local</th><td id="d_local"></td></tr>
                                <tr><th>SSC Board</th><td id="d_ssc_board"></td></tr>
                                <tr><th>SSC Year</th><td id="d_ssc_year"></td></tr>
                                <tr><th>SSC Month</th><td id="d_ssc_month"></td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Marks Summary -->
                <h6 class="section-hdr">Marks Summary</h6>
                <table id="marksTable">
                    <thead>
                        <tr style="background: #f5f5f5;">
                            <th>Subject</th>
                            <th style="text-align: center;">Score</th>
                        </tr>
                    </thead>
                    <tbody id="marksBody">
                        <tr><td colspan="2" style="text-align:center;color:#666;padding:12px;">No marks data</td></tr>
                    </tbody>
                    <tfoot>
                        <tr style="background: #f5f5f5; font-weight: bold;">
                            <th style="text-align:left;padding:6px;border:1px solid #ddd;">Total</th>
                            <th style="text-align:center;padding:6px;border:1px solid #ddd;" id="totalScore">-</th>
                        </tr>
                    </tfoot>
                </table>

                <!-- Selected ITIs -->
                <h6 class="section-hdr">Selected ITIs (in your district)</h6>
                <div style="overflow-x: auto;">
                    <table id="tradesTable">
                        <thead>
                            <tr style="background: #f5f5f5;">
                                <th style="width: 50px;">S.No</th>
                                <th>ITI Code</th>
                                <th>ITI Name</th>
                            </tr>
                        </thead>
                        <tbody id="tradesBody">
                            <tr><td colspan="3" style="text-align:center;color:#666;padding:12px;">No trade selections in your district</td></tr>
                        </tbody>
                    </table>
                </div>
                <div id="districtScopeMsg"></div>

                <!-- Document Verification -->
                <h6 class="section-hdr">Document Verification</h6>
                <table id="docTable">
                    <thead>
                        <tr style="background: #f5f5f5;">
                            <th>Document</th>
                            <th style="text-align:center;">Yes</th>
                            <th style="text-align:center;">No</th>
                            <th style="text-align:center;">N/A</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>SSC Equivalent Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_ssc_eq" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_ssc_eq" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_ssc_eq" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Transfer Certificate (TC)</td>
                            <td style="text-align:center;"><input type="radio" name="doc_tc" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_tc" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_tc" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Caste Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_cc" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_cc" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_cc" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Physically Challenged Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_pc" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_pc" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_pc" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Ex-Servicemen Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_exsv" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_exsv" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_exsv" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Study Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_sc" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_sc" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_sc" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Nativity Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_nc" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_nc" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_nc" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>UID/Aadhaar Verification</td>
                            <td style="text-align:center;"><input type="radio" name="doc_uidv" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_uidv" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_uidv" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>EWS Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_ewsv" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_ewsv" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_ewsv" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Age 21 Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_age21" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_age21" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_age21" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Experience Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_exp" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_exp" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_exp" value="N/A" class="doc-radio" checked></td>
                        </tr>
                        <tr>
                            <td>Establishment Certificate</td>
                            <td style="text-align:center;"><input type="radio" name="doc_est" value="Yes" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_est" value="No" class="doc-radio"></td>
                            <td style="text-align:center;"><input type="radio" name="doc_est" value="N/A" class="doc-radio" checked></td>
                        </tr>
                    </tbody>
                </table>

                <!-- Photo Preview -->
                <div style="margin-top: 16px; text-align: center;">
                    <strong>Candidate Photo:</strong><br/>
                    <img id="studentPhotoLarge" src="" alt="Candidate Photo" style="display:none; max-width: 200px; max-height: 250px; border: 1px solid #ddd; border-radius: 4px;" />
                    <div id="noPhotoLarge" style="color: #666; font-size: 12px;">No Photo Uploaded</div>
                </div>

                <div id="rejectReasonDiv" style="display:none; margin-top: 16px;">
                    <label for="rejectReason"><strong>Rejection Reason <span style="color:#dc3545;">*</span></strong></label>
                    <textarea id="rejectReason" class="form-control" rows="3" placeholder="Enter reason for rejection..."></textarea>
                    <div style="margin-top: 8px;">
                        <button type="button" onclick="confirmReject()" style="background:#dc3545;color:#fff;border:1px solid #bd2130;padding:8px 16px;border-radius:4px;font-weight:bold;cursor:pointer;margin-right:8px;">Confirm Reject</button>
                        <button type="button" onclick="hideRejectReason()" class="btn-cancel">Cancel</button>
                    </div>
                </div>

                <div class="btn-group" style="margin-top: 20px;">
                    <button type="button" id="btnApprove" class="btn-approve" onclick="submitDecision('Approve')" disabled>Approve (A)</button>
                    <button type="button" id="btnReject" class="btn-reject" onclick="showRejectReason()" disabled>Reject (R)</button>
                </div>

                <div id="verifyMsg" style="margin-top: 16px;"></div>
            </div>
        </div>
    </div>

    <!-- Confirm Modal -->
    <div id="confirmModal" class="modal">
        <div class="modal-content">
            <div class="modal-header">
                <span class="modal-close" onclick="closeModal()">&times;</span>
                <span id="modalTitle">Confirm</span>
            </div>
            <div class="modal-body">
                <p id="modalMsg"></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="modal-btn-cancel" onclick="closeModal()">Cancel</button>
                <button type="button" id="modalConfirmBtn" class="modal-btn-confirm">Confirm</button>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/footer.jsp" />
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/verifyApplication.js"></script>
</body>
</html>