<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>:: List of Private ITIs ::</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <style>
        .table-blue { background: #fff; }
        .table-blue th {
            background-color: #2f6fa5 !important;
            color: #ffffff !important;
            border-color: #000000 !important;
            vertical-align: middle;
            font-weight: 600;
        }
        .table-blue td, .table-blue th { border-color: #000000 !important; }
        .table-bordered {
            border: 1px solid #000000 !important;
            border-color: #000000 !important;
        }
        .table-bordered th,
        .table-bordered td,
        .table-bordered > :not(caption) > * > * {
            border-color: #000000 !important;
        }
    </style>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>
    <div class="container my-4">
        <h4 class="text-primary text-center mb-4">List of Private ITIs</h4>
        <div id="loader" class="text-center mb-3" style="display:none; font-weight:bold; color:blue;">Loading Private ITI data...</div>
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
    </div>
    <script>
let itiDataCache = [];
const GOVT_TYPE = 'P';
function loadItiList() {
    const loader = document.getElementById('loader');
    const wrap = document.getElementById('itiListTableWrap');
    const tbody = document.getElementById('itiTableBody');
    loader.style.display = 'block';
    wrap.style.display = 'none';
    tbody.innerHTML = '';
    let url = '${backendApiUrl}/trade-display/iti-list?type=' + encodeURIComponent(GOVT_TYPE);
    fetch(url, { method: 'GET' })
        .then(response => response.json())
        .then(data => {
            loader.style.display = 'none';
            if (!data.data || data.data.length === 0) {
                itiDataCache = [];
                tbody.innerHTML = '<tr><td colspan="5" class="text-center fw-bold">No Private ITIs found.</td></tr>';
                wrap.style.display = 'block';
                return;
            }
            itiDataCache = data.data;
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
            tbody.innerHTML = '<tr><td colspan="5" class="text-center fw-bold text-danger">Error loading Private ITI data. Please try again.</td></tr>';
            wrap.style.display = 'block';
            console.error('Error:', error);
        });
}
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
               escape(item.itiName) + '\n';
    });
    const blob = new Blob([csv], { type: 'application/vnd.ms-excel;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'Private_ITI_List.xls';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
document.addEventListener('DOMContentLoaded', function() {
    loadItiList();
});
</script>
    <%@ include file="../footer.jsp" %>
</body>
</html>
