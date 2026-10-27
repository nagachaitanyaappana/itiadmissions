<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>:: ITI List ::</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <style>
        .form-select,.form-control{border-color:#007bff !important}
        .form-select:focus,.form-control:focus{border-color:#007bff !important;box-shadow:0 0 0 0.2rem rgba(0,123,255,.25)}
        .table-blue{background:#fff}
        .table-blue th{background:#007bff;color:#fff}
        .table-blue td,.table-blue th{border-color:#007bff}
        /* Make all borders blue */
        .card{border-color:#007bff !important}
        .table{border-color:#007bff !important}
        .table-bordered{border-color:#007bff !important}
        .table-bordered td,.table-bordered th{border-color:#007bff !important}
        .btn{border-color:#007bff !important}
        .btn-primary{border-color:#007bff !important}
        .btn-success{border-color:#007bff !important}
    </style>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <div class="container my-4">
        <h4 class="text-primary text-center mb-4">List of Government and Private ITIs</h4>

        <form id="itiListForm">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Select ITI Type</label>
                            <select id="govtType" class="form-select">
                                <option value="">-- Select --</option>
                                <option value="A" selected>All</option>
                                <option value="G">Government</option>
                                <option value="P">Private</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">&nbsp;</label>
                            <button type="button" class="btn btn-primary w-100" onclick="loadItiList()">Proceed</button>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label fw-bold">&nbsp;</label>
                            <div class="d-grid">
                                <button type="button" class="btn btn-success w-100" onclick="exportToExcel()" disabled id="btnDownload">Download Excel</button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <div id="loader" class="text-center mb-3" style="display:none; font-weight:bold; color:blue;">Loading ITI data...</div>

            <div id="itiListTableWrap" class="mt-4" style="display:none;">
                <div class="table-responsive">
                    <table class="table table-bordered table-striped align-middle" id="itiListTable" style="min-width:650px;">
                        <thead class="table-blue">
                            <tr>
                                <th class="text-center">SL.No</th>
                                <th class="text-center">District Name</th>
                                <th class="text-center">NIC ITI Code</th>
                                <th class="text-center">NCVT Code</th>
                                <th class="text-center">ITI Name</th>
                            </tr>
                        </thead>
                        <tbody id="itiTableBody"></tbody>
                    </table>
                </div>
            </div>
        </form>
    </div>

    <script>
let itiDataCache = [];

function loadItiList() {
    const govtType = document.getElementById('govtType').value;
    const loader = document.getElementById('loader');
    const wrap = document.getElementById('itiListTableWrap');
    const tbody = document.getElementById('itiTableBody');
    const btnDownload = document.getElementById('btnDownload');

    loader.style.display = 'block';
    wrap.style.display = 'none';
    tbody.innerHTML = '';
    btnDownload.disabled = true;

    let url = '${backendApiUrl}/trade-display/iti-list';
    if (govtType && govtType !== '') {
        url += '?type=' + encodeURIComponent(govtType);
    }

    fetch(url, { method: 'GET' })
        .then(response => response.json())
        .then(data => {
            loader.style.display = 'none';

            if (!data.data || data.data.length === 0) {
                itiDataCache = [];
                tbody.innerHTML = '<tr><td colspan="5" class="text-center fw-bold">No ITIs found.</td></tr>';
                wrap.style.display = 'block';
                return;
            }

            itiDataCache = data.data;
            btnDownload.disabled = false;
            let rows = '';
            data.data.forEach((item, index) => {
                rows += '<tr>' +
                               '<td>' + (index + 1) + '</td>' +
                               '<td>' + (item.districtName || '') + '</td>' +
                               '<td>' + (item.nicItiCode || '') + '</td>' +
                               '<td>' + (item.ncvtCode || '') + '</td>' +
                               '<td>' + (item.itiName || '') + '</td>' +
                               '</tr>';
            });

            tbody.innerHTML = rows;
            wrap.style.display = 'block';
        })
        .catch(error => {
            loader.style.display = 'none';
            itiDataCache = [];
            tbody.innerHTML = '<tr><td colspan="5" class="text-center fw-bold text-danger">Error loading ITI data. Please try again.</td></tr>';
            wrap.style.display = 'block';
            console.error('Error:', error);
        });
}

// Export the currently-loaded data as an Excel (.xls HTML table) file
function exportToExcel() {
    if (!itiDataCache || itiDataCache.length === 0) {
        alert('No data available to download. Please load the ITI list first.');
        return;
    }

    let csv = '\\ufeffSL.No,District Name,NIC ITI Code,NCVT Code,ITI Name\\n';
    itiDataCache.forEach((item, index) => {
        const escape = (val) => {
            const s = (val || '').toString();
            return '"' + s.replace(/"/g, '""') + '"';
        };
        csv += (index + 1) + ',' +
               escape(item.districtName) + ',' +
               escape(item.nicItiCode) + ',' +
               escape(item.ncvtCode) + ',' +
               escape(item.itiName) + '\\n';
    });

    const blob = new Blob([csv], { type: 'application/vnd.ms-excel;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'ITI_List.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
</script>

    <%@ include file="../footer.jsp" %>
</body>
</html>
