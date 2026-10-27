<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>:: ITI ::</title>
    <link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/images/iti.png" />
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
    <style>
        .table-blue { background: #fff; }
        .table-blue th,
        .table-blue tfoot th {
            background-color: #2f6fa5 !important;
            color: #ffffff !important;
            border-color: #000000 !important;
            vertical-align: middle;
            font-weight: 600;
        }
        .table-blue th .text-primary,
        .table-blue th .text-info {
            color: #ffffff !important;
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
        .btn-primary {
            background-color: #2f6fa5 !important;
            border-color: #2f6fa5 !important;
            color: #ffffff !important;
        }
        .btn-primary:hover,
        .btn-primary:focus,
        .btn-primary:active {
            background-color: #1e4f7a !important;
            border-color: #1e4f7a !important;
            color: #ffffff !important;
        }
    </style>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        var tableToExcel = (function() {
            var uri = 'data:application/vnd.ms-excel;base64,',
                template = '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:excel" xmlns="http://www.w3.org/REC-html40"><head><!--[if gte mso 9]><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet><x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet></x:ExcelWorksheets></x:ExcelWorkbook></xml><![endif]--></head><body><table>{table}</table></body></html>',
                base64 = function(s) {
                    return window.btoa(unescape(encodeURIComponent(s)))
                },
                format = function(s, c) {
                    return s.replace(/{(\w+)}/g, function(m, p) {
                        return c[p];
                    })
                };
            return function(table, name) {
                if (!table.nodeType)
                    table = document.getElementById(table);
                var ctx = {worksheet: name || 'Worksheet', table: table.innerHTML};
                window.location.href = uri + base64(format(template, ctx));
            }
        })();
    </script>
</head>

<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <div class="container my-4">
        <h4 class="text-primary text-center mb-4">List of ITI's with Trades & Strengths Interface</h4>

        <form name="form1" id="form1" method="POST" action="${pageContext.request.contextPath}/reports/iti-profile">
            <div class="card shadow-sm">
                <div class="card-body">
                    <div class="row g-3 align-items-end">
                        <div class="col-md-4">
                            <label class="form-label fw-bold">Select District</label>
                            <select name="dist_code" id="dist_code" class="form-select">
                                <option value="">--select--</option>
                                <option value='25' <c:if test="${param.dist_code eq '25'}">selected</c:if>>Alluri Sitaramaraju</option>
                                <option value='24' <c:if test="${param.dist_code eq '24'}">selected</c:if>>Anakapalli</option>
                                <option value='22' <c:if test="${param.dist_code eq '22'}">selected</c:if>>Anantapur</option>
                                <option value='33' <c:if test="${param.dist_code eq '33'}">selected</c:if>>Annamayya</option>
                                <option value='32' <c:if test="${param.dist_code eq '32'}">selected</c:if>>Bapatla</option>
                                <option value='23' <c:if test="${param.dist_code eq '23'}">selected</c:if>>Chittoor</option>
                                <option value='14' <c:if test="${param.dist_code eq '14'}">selected</c:if>>East Godavari</option>
                                <option value='29' <c:if test="${param.dist_code eq '29'}">selected</c:if>>Eluru</option>
                                <option value='17' <c:if test="${param.dist_code eq '17'}">selected</c:if>>Guntur</option>
                                <option value='27' <c:if test="${param.dist_code eq '27'}">selected</c:if>>Kakinada</option>
                                <option value='28' <c:if test="${param.dist_code eq '28'}">selected</c:if>>Konaseema</option>
                                <option value='16' <c:if test="${param.dist_code eq '16'}">selected</c:if>>Krishna</option>
                                <option value='21' <c:if test="${param.dist_code eq '21'}">selected</c:if>>Kurnool</option>
                                <option value='38' <c:if test="${param.dist_code eq '38'}">selected</c:if>>Markapuram</option>
                                <option value='34' <c:if test="${param.dist_code eq '34'}">selected</c:if>>Nandyal</option>
                                <option value='19' <c:if test="${param.dist_code eq '19'}">selected</c:if>>Nellore</option>
                                <option value='30' <c:if test="${param.dist_code eq '30'}">selected</c:if>>NTR</option>
                                <option value='31' <c:if test="${param.dist_code eq '31'}">selected</c:if>>Palnadu</option>
                                <option value='26' <c:if test="${param.dist_code eq '26'}">selected</c:if>>Parvathipuram-Manyam</option>
                                <option value='37' <c:if test="${param.dist_code eq '37'}">selected</c:if>>Polavaram</option>
                                <option value='18' <c:if test="${param.dist_code eq '18'}">selected</c:if>>Prakasam</option>
                                <option value='11' <c:if test="${param.dist_code eq '11'}">selected</c:if>>Srikakulam</option>
                                <option value='35' <c:if test="${param.dist_code eq '35'}">selected</c:if>>Sri Satyasai</option>
                                <option value='36' <c:if test="${param.dist_code eq '36'}">selected</c:if>>Tirupati</option>
                                <option value='13' <c:if test="${param.dist_code eq '13'}">selected</c:if>>Visakhapatnam</option>
                                <option value='12' <c:if test="${param.dist_code eq '12'}">selected</c:if>>Vizianagaram</option>
                                <option value='15' <c:if test="${param.dist_code eq '15'}">selected</c:if>>West Godavari</option>
                                <option value='20' <c:if test="${param.dist_code eq '20'}">selected</c:if>>YSR</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label fw-bold">GOVT/PVT</label>
                            <select name="gov" id="gov" class="form-select">
                                <option value="" <c:if test="${empty param.gov}">selected</c:if>>----ALL----</option>
                                <option value="G" <c:if test="${param.gov eq 'G'}">selected</c:if>>GOVERNMENT</option>
                                <option value="P" <c:if test="${param.gov eq 'P'}">selected</c:if>>PRIVATE</option>
                            </select>
                        </div>
                        <div class="col-md-3 d-grid">
                            <button type="submit" class="btn btn-primary">Submit</button>
                        </div>
                    </div>
                </div>
            </div>
        </form>

        <div id="resultsSection" class="mt-4" style="display:none;">
            <div id="loader" class="text-center mb-3" style="display:none; font-weight:bold; color:blue;">Loading ITI records...</div>

            <div class="table-responsive">
                <table class="table table-bordered table-striped align-middle" id="tabcolor" style="min-width:650px;">
                    <thead class="table-blue">
                        <tr>
                            <th colspan="2" class="text-center">
                                <div class="fw-bold text-white">List of ITI's with Trades & Strengths in <span id="distNameHeading"></span></div>
                                <div class="text-white-50 small">Click on ITI Name to view the ITI profile and staff details</div>
                            </th>
                        </tr>
                    </thead>
                    <tbody id="itiTableBody"></tbody>
                    <tfoot class="table-blue">
                        <tr><th colspan="2" class="text-center">&nbsp;</th></tr>
                    </tfoot>
                </table>
            </div>

            <div class="text-center mt-3">
                <button type="button" class="btn btn-success" onclick="tableToExcel('tabcolor', 'iti')">Download Excel Data</button>
            </div>
        </div>
    </div>

    <script>
        const BACKEND_URL = "${backendApiUrl}";
        document.addEventListener('DOMContentLoaded', function() {
            const urlParams = new URLSearchParams(window.location.search);
            const distCode = "${param.dist_code}" || urlParams.get('dist_code') || '';
            const govType = "${param.gov}" || urlParams.get('gov') || '';

            const distSelect = document.getElementById('dist_code');
            if (distCode) {
                distSelect.value = distCode;
                const distName = distSelect.options[distSelect.selectedIndex] ? distSelect.options[distSelect.selectedIndex].text : distCode;
                document.getElementById('distNameHeading').innerText = distName;
                document.getElementById('resultsSection').style.display = 'block';
                fetchItiData(distCode, govType);
            } else {
                document.getElementById('distNameHeading').innerText = 'Selected District';
                document.getElementById('itiTableBody').innerHTML = '<tr><td colspan="2" align="center" class="fw-bold">Please select a district.</td></tr>';
            }
        });

        function fetchItiData(distCode, govType) {
            document.getElementById('loader').style.display = 'block';
            let url = BACKEND_URL + '/trade-display/itis?dist=' + encodeURIComponent(distCode);
            if (govType) {
                url += '&type=' + encodeURIComponent(govType);
            }
            fetch(url)
                .then(res => res.json())
                .then(resData => {
                    document.getElementById('loader').style.display = 'none';
                    const list = (resData && resData.data) ? resData.data : [];
                    const tbody = document.getElementById('itiTableBody');
                    tbody.innerHTML = '';
                    if (list.length === 0) {
                        tbody.innerHTML = '<tr><td colspan="2" class="text-center fw-bold text-danger">No ITI records found for the selected district.</td></tr>';
                        return;
                    }
                    list.forEach(row => {
                        const tr = document.createElement('tr');
                        const code = row.code || '';
                        const name = row.itiName || '-';
                        let tradesHtml = '<ol>';
                        if (row.trades && row.trades.length > 0) {
                            row.trades.forEach(t => {
                                tradesHtml += '<li>' + (t.tradeName || '-') + ' (' + (t.strength || 0) + ')</li>';
                            });
                        } else {
                            tradesHtml += '<li>No trades listed</li>';
                        }
                        tradesHtml += '</ol>';
                        tr.innerHTML =
                            '<td>' +
                            '<a href="${pageContext.request.contextPath}/iti-details?itiCode=' + encodeURIComponent(code) + '">' +
                            code + ' :- ' + name +
                            '</a>' +
                            tradesHtml +
                            '</td>';
                        tbody.appendChild(tr);
                    });
                })
                .catch(err => {
                    document.getElementById('loader').style.display = 'none';
                    document.getElementById('itiTableBody').innerHTML = '<tr><td colspan="2" class="text-center fw-bold text-danger">Error loading data: ' + err.message + '</td></tr>';
                });
        }
    </script>

    <%@ include file="../footer.jsp" %>
</body>
</html>
