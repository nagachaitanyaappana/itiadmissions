<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Schedule Entry - AP ITI</title>
        <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/all.min.css">
    <style>
        /* ---- Index / portal palette (mirrors index.jsp) ---- */
        .page-header-custom {
            background-color: #e4eeb9;
            color: #000000;
            padding: 20px 0;
            margin-top: 15px;    /* small gap between the navbar and the portal heading */
            margin-bottom: 30px;
            border-bottom: 4px solid #b9c46d;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .form-card {
            border: 1px solid #b9c46d;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            overflow: hidden;
            margin-bottom: 30px;
            background: #fff;
        }
        .card-header-primary {
            background-color: #e4eeb9;
            color: #000000;
            font-weight: 700;
            padding: 15px 25px;
            text-transform: uppercase;
            letter-spacing: 1px;
            display: flex;
            align-items: center;
            gap: 10px;
            border: none;
        }
        /* Step-2 header keeps the action green from the index palette */
        .card-header-primary.bg-success {
            background-color: #b9c46d !important;
            color: #ffffff !important;
        }
        .card-body-custom {
            padding: 30px;
            background-color: #fff;
        }
        .form-label-custom {
            font-weight: 600;
            color: #660000;
            margin-bottom: 8px;
            font-size: 0.95rem;
        }
        .form-control-custom {
            border: 1.5px solid #fff;
            border-radius: 8px;
            padding: 10px 15px;
            font-weight: 500;
            transition: all 0.3s;
        }
        .form-control-custom:focus {
            border-color: #b9c46d;
            box-shadow: 0 0 0 4px rgba(76,175,80,0.15);
        }
        .btn-success-custom {
            background-color: #1aab1f;
            border: none;
            color: white;
            font-weight: 700;
            padding: 10px 30px;
            border-radius: 50px;
            transition: all 0.3s;
        }
        .btn-success-custom:hover {
            background-color: #3d8b40;
            transform: translateY(-1px);
        }
        .btn-danger-custom {
            background-color: #c41818;
            border: none;
            color: #000000;
            font-weight: 700;
            padding: 10px 30px;
            border-radius: 50px;
            transition: all 0.3s;
        }
        .btn-danger-custom:hover {
            background-color: #cb342c;
            transform: translateY(-1px);
        }
        .info-text-custom {
            font-size: 0.9rem;
            color: #6c757d;
            font-style: italic;
        }
        #timingContainer {
            display: none;
            animation: slideUp 0.5s ease;
        }
        @keyframes slideUp {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        .read-only-box {
            background-color: #fff;
            border: 1px solid #b9c46d;
            padding: 12px 15px;
            border-radius: 8px;
            font-weight: 600;
            color: #660000;
        }
                /* Align the Bootstrap success borders/overrides with the index palette */
        .form-card.border-success {
            border-color: #b9c46d !important;
        }

        /* Navbar dropdown items: replace legacy blue hover (#2f6fa5) with the
           index palette so ScheduleEntry's navbar matches MeritList. */
        body .dropdown-menu .dropdown-item:hover {
            background-color: #b9c46d !important;
            color: #000000 !important;
            padding-left: 25px;
        }

        /* ---- Native <select> dropdowns (Category / Qualification) ----
           Replace the blue OS highlight that appears on hovered <option>
           items, and the blue Bootstrap focus ring, with the index palette. */
        .form-control-custom option:hover,
        .form-select option:hover {
            background-color: #b9c46d !important;
            color: #000000 !important;
        }
        .form-control-custom:focus,
        .form-select:focus {
            border-color: #4CAF50 !important;
            box-shadow: 0 0 0 0.25rem rgba(76, 175, 80, 0.25) !important;
        }

        /* Footer colour - pale yellow-green (#e4eeb9) */
        .lower-footer {
            background-color: #e4eeb9 !important;
            color: #000000 !important;
        }
    </style>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/iti-portal.css">
</head>
<body>

    <jsp:include page="/WEB-INF/reports/header.jsp" />

    <div class="page-header-custom text-center">
        <div class="container">
            <h2 class="mb-0"><i class="fas fa-calendar-alt me-2"></i> Admission Schedule Portal</h2>
        </div>
    </div>

    <div class="container mb-5">
        <div class="row justify-content-center">
            
            <!-- Step 1: Initial Parameters (Medium size) -->
            <div class="col-lg-7" id="initContainer">
                <div class="card form-card">
                    <div class="card-header-primary d-flex justify-content-between align-items-center">
                        <span><i class="fas fa-cog"></i> Schedule Initialization</span>
                        <span class="badge bg-light text-dark p-2" style="font-size: 0.85rem;">Phase: <span id="headerPhase">...</span></span>
                    </div>
                    <div class="card-body card-body-custom">
                        <div class="row g-4">
                            <div class="col-md-6">
                                <label class="form-label-custom">Reservation:</label>
                                <select id="casteSelect" class="form-select form-control-custom">
                                    <option value="all" selected>General</option>
                                    <option value="w">Women</option>
                                </select>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-custom">Qualification:</label>
                                <select id="qualSelect" class="form-select form-control-custom">
                                    <option value="all">-All-</option>
                                </select>
                            </div>
                            <div class="col-12 text-center mt-4 border-top pt-4">
                                <button class="btn btn-success-custom me-2" onclick="initializeSchedule()">
                                    <i class="fas fa-check-circle me-1"></i> SUBMIT
                                </button>
                                <button class="btn btn-danger-custom" onclick="resetInitForm()">
                                    <i class="fas fa-undo me-1"></i> Reset 
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Step 2: Assignments (Medium size) -->
            <div class="col-lg-8" id="timingContainer">
                <div class="card form-card border-success">
                    <div class="card-header-primary bg-success">
                        <i class="fas fa-clock"></i> Assign Timing & Merit Ranges
                    </div>
                    <div class="card-body card-body-custom">
                        <div class="row g-4">
                            <!-- Read Only Information -->
                            <div class="col-md-12">
                                <div class="row text-center mb-2">
                                    <div class="col-md-3">
                                        <label class="form-label-custom d-block">District/ITI name:</label>
                                        <div id="dispEntity" class="read-only-box">-</div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label-custom d-block">Qualification:</label>
                                        <div id="dispQual" class="read-only-box">-</div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label-custom d-block">Reservation:</label>
                                        <div id="dispCaste" class="read-only-box">-</div>
                                    </div>
                                    <div class="col-md-3">
                                        <label class="form-label-custom d-block">Current Phase:</label>
                                        <div id="dispPhase" class="read-only-box">-</div>
                                    </div>
                                </div>
                            </div>

                            <hr class="mt-4">

                            <!-- Inputs -->
                            <div class="col-md-6">
                                <label class="form-label-custom">Merit Rank From (auto):</label>
                                <input type="number" id="meritFrom" class="form-control form-control-custom" readonly>
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-custom">Merit Rank To:</label>
                                <input type="number" id="meritTo" class="form-control form-control-custom" placeholder="e.g. 500" min="1">
                            </div>

                            <div class="col-md-6">
                                <label class="form-label-custom">Call Date:</label>
                                <input type="date" id="calDate" class="form-control form-control-custom">
                            </div>
                            <div class="col-md-6">
                                <label class="form-label-custom">Call Time (08:00 - 18:00):</label>
                                <input type="text" id="calTime" class="form-control form-control-custom" placeholder="HH:MM (24-hour)" maxlength="5" oninput="this.value = this.value.replace(/[^0-9:]/g, ''); if(this.value.length === 2 && !this.value.includes(':')) this.value += ':';">
                                <p class="info-text-custom mt-1"><i class="fas fa-info-circle me-1"></i> Office timings are strictly 8 AM to 6 PM.</p>
                            </div>

                            <div class="col-12 text-center mt-4 border-top pt-4">
                                <button class="btn btn-success-custom me-2" onclick="saveTimings()">
                                    <i class="fas fa-save me-1"></i> Save Schedule
                                </button>
                                <button class="btn btn-danger-custom" onclick="clearTimingForm()">
                                    <i class="fas fa-trash me-1"></i> Clear All
                                </button>
                                <div id="feedbackArea" class="mt-3 fw-bold"></div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Already scheduled for the following ranks (legacy admission.jsp) -->
                <div class="card form-card">
                    <div class="card-header-primary">
                        <i class="fas fa-list-ol"></i> Already scheduled for the following ranks
                    </div>
                    <div class="card-body card-body-custom">
                        <div class="table-responsive">
                            <table class="table table-bordered align-middle mb-0">
                                <thead>
                                    <tr>
                                        <th>Sl Number</th>
                                        <th>Merit From</th>
                                        <th>Merit To</th>
                                        <th>Call Date</th>
                                        <th>Call Time</th>
                                        <th>District Code</th>
                                        <th>Caste</th>
                                    </tr>
                                </thead>
                                <tbody id="scheduledRows">
                                    <tr><td colspan="7" class="text-center text-muted">No schedules yet.</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

        <%-- API base URL sourced from application.properties (backend.api.base-url) via
         _api_base_url.jsp. <jsp:include> is a separate translation unit, so
         ${backendBaseUrl} resolves here even though this page is EL-ignored --%>
    <jsp:include page="/WEB-INF/jsp/_api_base_url.jsp" />
    <%-- Session institution scope. login_users keeps a single ins_code column holding a district
         code for district logins (roleId 3) and an ITI code for ITI logins (roleId 4), so the role
         and that one code are sent together and the backend decides which to use. This page is
         isELIgnored="true", so EL cannot read the session here; a scriptlet is used instead. --%>
    <%
        Object sessionRoleId = session.getAttribute("roleId");
        Object sessionInsCode = session.getAttribute("insCode");
        String jsRoleId = sessionRoleId == null ? "" : String.valueOf(sessionRoleId).replace("'", "\\'");
        String jsInsCode = sessionInsCode == null ? "" : String.valueOf(sessionInsCode).replace("'", "\\'");
    %>
    <script>
        const API_BASE = window.API_BASE_URL + '/admission-timings';
        const NODE_API_BASE = window.API_BASE_URL;
        const SESSION_ROLE_ID = '<%= jsRoleId %>';
        const SESSION_INS_CODE = '<%= jsInsCode %>';

        // Schedule creation/updating is scoped by these two headers. Without them the backend
        // cannot tell which district/ITI the schedule belongs to and rejects the request.
        function scopeHeaders(extra) {
            return Object.assign({
                'X-Role-Id': SESSION_ROLE_ID,
                'X-Ins-Code': SESSION_INS_CODE
            }, extra || {});
        }
        let currentInitData = null;

        // Load the running phase for the header. The reservation list is the fixed legacy pair
        // (General / Women -> all / w), so no caste lookup is made.
        async function initPage() {
            try {
                const statusResp = await fetch(`${NODE_API_BASE}/api/status`, { 
                    credentials: 'include',
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' }
                });
                const statusRes = await statusResp.json();
                if (statusRes.success) {
                    document.getElementById('headerPhase').innerText = statusRes.phase;
                }
            } catch (err) {
                console.error("Initialization error:", err);
            }
        }

        // Initialize Schedule (Step 1)
        async function initializeSchedule() {
            const caste = document.getElementById('casteSelect').value;
            const qual = document.getElementById('qualSelect').value;

            const payload = { reservation: caste, minqul: qual };

            try {
                const response = await fetch(API_BASE + '/entry', {
                    credentials: 'include',
                    method: 'POST',
                    headers: scopeHeaders({ 'Content-Type': 'application/json' }),
                    body: JSON.stringify(payload)
                });

                const result = await response.json();
                if (result.success) {
                    // Handle placeholder response - build data from payload if not provided
                    const responseData = result.data || {
                        dist_name: localStorage.getItem('displayName') || 'Unknown',
                        iti_name: localStorage.getItem('displayName') || 'Unknown',
                        reservation: payload.reservation,
                        minqul: payload.minqul,
                        phase: document.getElementById('headerPhase').innerText
                    };
                    currentInitData = responseData;
                    showTimingForm(responseData);
                } else {
                    alert("Initialization Failed: " + (result.error || result.message || "Unknown error"));
                }
            } catch (err) {
                console.error("Submit Error:", err);
            }
        }

        function showTimingForm(data) {
            // Populate display fields: Priority to Backend Data, Fallback to Session displayName
            const sessionName = localStorage.getItem('displayName') || 'Unknown';
            document.getElementById('dispEntity').innerText = data.dist_name || data.iti_name || sessionName;
            document.getElementById('dispQual').innerText = data.minqul || '-';
            document.getElementById('dispCaste').innerText = data.reservation || '-';
            document.getElementById('dispPhase').innerText = data.phase || document.getElementById('headerPhase').innerText || '-';

            // merit_from is derived server-side (legacy admission.jsp: max(merit_to)+1); shown read-only.
            document.getElementById('meritFrom').value = data.meritFrom != null ? data.meritFrom : 1;

            // Show container
            document.getElementById('timingContainer').style.display = 'block';
            loadScheduledRanges(data);
            window.scrollTo({ top: document.body.scrollHeight, behavior: 'smooth' });
        }

        // Save Timings (Step 2)
        async function saveTimings() {
            const feedback = document.getElementById('feedbackArea');
            feedback.innerText = "";
            feedback.className = "mt-3 fw-bold";

            const payload = {
                ...currentInitData,
                meritFrom:parseInt(document.getElementById('meritFrom').value),
                meritTo: parseInt(document.getElementById('meritTo').value),
                calDate: document.getElementById('calDate').value,
                calTime: document.getElementById('calTime').value
            };

            // Basic Validation. meritFrom is auto-derived server-side, so only the fields the user
            // actually supplies are checked here.
            if(Number.isNaN(payload.meritTo) || !payload.calDate || !payload.calTime) {
                setFeedback("Please fill all timing fields.", "text-danger");
                return;
            }
            if(payload.meritTo <= 0 ){
                setFeedback("Error: 'Merit Rank To' must be greater than 0.", "text-danger");
                return;
            }
            if(!Number.isNaN(payload.meritFrom) && payload.meritFrom > 0 && payload.meritFrom > payload.meritTo) {
                setFeedback("Error: 'Merit Rank To' must be greater than 'Merit Rank From'.", "text-danger");
                return;
            }
            // Time Validation (08:00 to 18:00)
            const [hours, minutes] = payload.calTime.split(':').map(Number);
            if (hours < 8 || hours > 18 || (hours === 18 && minutes > 0)) {
                setFeedback("Error: Time must be between 08:00 and 18:00 (Office Timings).", "text-danger");
                return;
            }

            try {
                const response = await fetch(API_BASE + '/timings', {
                    credentials: 'include',
                    method: 'PUT',
                    headers: scopeHeaders({ 'Content-Type': 'application/json' }),
                    body: JSON.stringify(payload)
                });

                const result = await response.json();
                if (response.ok&&result.success) {
                    setFeedback("Schedule entered successfully!", "text-success");
                    if (result.data) { currentInitData = result.data; }
                    loadScheduledRanges(currentInitData);
                } else {
                    setFeedback("Error: " + (result.error || result.message || "Unknown error"), "text-danger");
                }
            } catch (err) {
                setFeedback("Submission error occurred.", "text-danger");
            }
        }

        // Lists the merit ranges already scheduled for this scope/phase/category (legacy admission.jsp
        // "Already scheduled for the following ranks"). The backend scopes the rows to the caller and
        // to the selected reservation/qualification.
        async function loadScheduledRanges(data) {
            const tbody = document.getElementById('scheduledRows');
            if (!tbody) { return; }
            try {
                const response = await fetch(API_BASE + '/view', {
                    credentials: 'include',
                    method: 'POST',
                    headers: scopeHeaders({ 'Content-Type': 'application/json' }),
                    body: JSON.stringify({
                        caste: (data && data.reservation) || 'all',
                        minqul: (data && data.minqul) || 'all'
                    })
                });
                const result = await response.json();
                const rows = (result && result.data) ? result.data : [];
                const distCode = (data && data.distCode) ? data.distCode : '';
                if (!rows.length) {
                    tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted">No schedules yet.</td></tr>';
                    return;
                }
                tbody.innerHTML = rows.map(function (r, i) {
                    const parts = String(r.meritRange || '').split('-');
                    const from = parts[0] || '';
                    const to = parts.length > 1 ? parts[1] : '';
                    return '<tr><td>' + (i + 1) + '</td><td>' + from + '</td><td>' + to + '</td><td>'
                        + (r.date || '') + '</td><td>' + (r.calTime || '') + '</td><td>' + distCode + '</td><td>'
                        + (r.caste || '') + '</td></tr>';
                }).join('');
            } catch (err) {
                console.error("Load scheduled ranges error:", err);
            }
        }

        function setFeedback(msg, className) {
            const feedback = document.getElementById('feedbackArea');
            feedback.innerText = msg;
            feedback.className = "mt-3 fw-bold " + className;
        }

        function resetInitForm() {
            document.getElementById('casteSelect').value = 'all';
            document.getElementById('qualSelect').value = 'all';
            document.getElementById('timingContainer').style.display = 'none';
        }

        function clearTimingForm() {
            document.getElementById('meritFrom').value = "";
            document.getElementById('meritTo').value = "";
            document.getElementById('calDate').value = "";
            document.getElementById('calTime').value = "";
            document.getElementById('feedbackArea').innerText = "";
        }

        // Start
        window.onload = initPage;
    </script>
<%@ include file="../footer.jsp" %>
</body>
</html>
