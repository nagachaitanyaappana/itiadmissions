<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Open General Pool - District</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/all.min.css">
    <style>
        /* ---- Index / portal palette (mirrors ScheduleEntry.jsp) ---- */
        .page-header-custom {
            background-color: #e4eeb9;
            color: #000000;
            padding: 20px 0;
            margin-top: 15px;
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
            color: #ffffff;
        }
        .pool-result {
            display: none;
            border: 1px solid #b9c46d;
            border-radius: 12px;
            background-color: #f4f7e4;
            color: #32601c;
            font-weight: 700;
            padding: 16px 20px;
            margin-top: 20px;
        }
        .pool-result.error {
            border-color: #c41818;
            background-color: #fdecec;
            color: #8b1010;
        }
        /* Native <select> dropdown highlight in the index palette */
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
            <h2 class="mb-0"><i class="fas fa-unlock-alt me-2"></i> Open General Pool</h2>
        </div>
    </div>

    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-6">
                <div class="card form-card">
                    <div class="card-header-primary">
                        <i class="fas fa-users"></i> Open Reservation
                    </div>
                    <div class="card-body card-body-custom">
                        <form action="" id="poolForm" onsubmit="openPool(); return false;">
                            <div class="mb-2">
                                <label class="form-label-custom" for="casteSelect">Open For:</label>
                                <select name="caste" id="casteSelect" class="form-select form-control-custom">
                                </select>
                            </div>
                            <div class="text-center mt-4 border-top pt-4">
                                <button type="submit" name="submit" class="btn btn-success-custom">
                                    <i class="fas fa-check-circle me-1"></i> Open reservation for selected Category
                                </button>
                            </div>
                        </form>
                        <div id="resultArea" class="pool-result text-center"></div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <%-- API base URL sourced from application.properties (backend.api.base-url) --%>
    <jsp:include page="/WEB-INF/jsp/_api_base_url.jsp" />
    <%
        Object sessionRoleId = session.getAttribute("roleId");
        Object sessionInsCode = session.getAttribute("insCode");
        String jsRoleId = sessionRoleId == null ? "" : String.valueOf(sessionRoleId).replace("'", "\\'");
        String jsInsCode = sessionInsCode == null ? "" : String.valueOf(sessionInsCode).replace("'", "\\'");
    %>
    <script>
        const API_BASE = window.API_BASE_URL;
        const SESSION_ROLE_ID = '<%= jsRoleId %>';
        const SESSION_INS_CODE = '<%= jsInsCode %>';

        // The same caste_master list the legacy page rendered with
        // beans.MyUtil.putOptions("caste_master", "caste_code", "caste_name", con).
        // NOTE: string concatenation, not template literals — EL is active on this page
        // and would swallow ${API_BASE} before the browser ever saw it.
        async function loadCastes() {
            try {
                const resp = await fetch(API_BASE + '/api/dsc/caste-list', { credentials: 'include' });
                const result = await resp.json();
                const select = document.getElementById('casteSelect');
                if (result.success && result.data) {
                    result.data.forEach(item => {
                        const opt = document.createElement('option');
                        opt.value = item.casteCode;
                        opt.textContent = item.casteName;
                        select.appendChild(opt);
                    });
                }
            } catch (err) {
                console.error("Caste list error:", err);
            }
        }

        // Ported from open_pool_dist_level.jsp: district code comes from the session ins_code;
        // the backend resolves year from iti_params code 7 and phase from the current
        // admissions.admission_phase row, then updates/inserts the open_general_pool row.
        async function openPool() {
            const select = document.getElementById('casteSelect');
            const caste = select.value;
            const area = document.getElementById('resultArea');
            try {
                const resp = await fetch(API_BASE + '/api/admission/general-pool/district', {
                    method: 'POST',
                    credentials: 'include',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-Role-Id': SESSION_ROLE_ID,
                        'X-Ins-Code': SESSION_INS_CODE
                    },
                    body: JSON.stringify({ caste: caste })
                });
                const result = await resp.json();
                if (result.success) {
                    area.className = 'pool-result text-center';
                    area.innerHTML = 'General Pool is Opened for the caste' + caste;
                } else {
                    area.className = 'pool-result error text-center';
                    area.innerHTML = result.error || 'Unable to open general pool';
                }
            } catch (err) {
                area.className = 'pool-result error text-center';
                area.innerHTML = err;
            }
            area.style.display = 'block';
            return false;
        }

        loadCastes();
    </script>

<%@ include file="../footer.jsp" %>
</body>
</html>
