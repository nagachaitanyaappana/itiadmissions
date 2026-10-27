<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>DSC List | ITI Reports</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css?v=${System.currentTimeMillis()}">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <style>
        .nodal-page-title-dashboard { text-align: center; padding: 30px 0; color: #003366; font-weight: 800; background: #f8fbff; border-bottom: 1px solid #e1ecf8; margin-bottom: 40px; }
        .nodal-page-title-dashboard h2 { margin: 0; font-size: 1.6rem; letter-spacing: 0.5px; }
        .form-label-official { font-size: 0.85rem; font-weight: 700; color: #445566; text-transform: uppercase; letter-spacing: 0.8px; display: block; }
        .form-select-official, .form-control-official { border: 1px solid #ced4da; border-radius: 6px; padding: 10px 15px; font-size: 1.05rem; color: #2d3748; background-color: #ffffff; transition: border-color 0.2s ease; width: 100%; }
        .form-select-official:focus, .form-control-official:focus { border-color: #003366; outline: none; box-shadow: 0 0 0 3px rgba(0, 51, 102, 0.1); }
        .btn-submit-official-navy { background-color: #003366; color: white; padding: 12px 30px; border-radius: 10px; font-weight: 700; letter-spacing: 0.5px; border: none; transition: all 0.2s ease; }
        .btn-submit-official-navy:hover { background-color: #002244; transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0, 34, 68, 0.2); color: white; }
        .report-table th { font-size: 12px; padding: 12px 8px; background: #0f2c4e !important; color: white !important; text-transform: uppercase; position: sticky; top: 0; z-index: 10; }
        .report-table td { font-size: 13px; padding: 10px 8px; border-bottom: 1px solid #f0f0f0; font-weight: 500; color: #1e293b; }
        .category-header { background-color: #eaf1f9; padding: 10px 14px; border-left: 5px solid #003366; font-weight: 700; color: #003366; text-align: left; }
        .loader-spinner { display: none; text-align: center; padding: 40px; color: #003366; }
        .report-meta-box { background: #f8fbff; border: 1px solid #d4e3f5; border-radius: 8px; padding: 12px 20px; margin-bottom: 20px; font-size: 0.95rem; }
        .report-meta-box span.meta-val { font-weight: 700; color: #003366; }
    </style>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal-theme.css?v=2">
</head>
<body class="nodal-body">
    <c:set var="hideNavbar" value="true" scope="request" />
    <%@ include file="header.jsp" %>
    <c:set var="activeTab" value="dsc_list" />
    <div class="nodal-page-title-dashboard"><h2>DSC List</h2></div>

    <div class="container mt-4" id="selectionView">
        <div class="nodal-report-card shadow-lg" style="max-width: 650px; margin: 0 auto; border: 1px solid #e0e0e0; border-radius: 12px;">
            <div class="nodal-card-header-dashboard" style="padding: 15px 25px;"><i class="fas fa-filter me-2"></i> Selection Criteria</div>
            <div class="p-4 bg-white rounded-bottom">
                <form id="reportForm" onsubmit="fetchReport(event)">
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label class="form-label-official">ITI Name</label>
                            <select name="iti_code" id="iti_code" class="form-select-official" required onchange="loadTradesForIti(this.value)">
                                <option value="">Select ITI</option>
                            </select>
                        </div>
                        <div class="col-md-6 mt-3 mt-md-0">
                            <label class="form-label-official">Trade</label>
                            <select name="trade_code" id="trade_code" class="form-select-official" required>
                                <option value="">Select Trade</option>
                            </select>
                        </div>
                    </div>
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label class="form-label-official">Phase</label>
                            <select name="phase" id="phase" class="form-select-official" required>
                                <option value="">-select-</option>
                                <option value="1">1</option>
                                <option value="2">2</option>
                                <option value="3">3</option>
                                <option value="4">4</option>
                                <option value="5">5</option>
                                <option value="6">6</option>
                                <option value="7">7</option>
                                <option value="All">All</option>
                            </select>
                        </div>
                        <div class="col-md-4 mt-3 mt-md-0">
                            <label class="form-label-official">Year</label>
                            <select name="year" id="year" class="form-select-official" required>
                                <option value="">-select-</option>
                                <option value="2026" selected>2026</option>
                                <option value="2025">2025</option>
                                <option value="2024">2024</option>
                                <option value="2023">2023</option>
                                <option value="2022">2022</option>
                                <option value="2021">2021</option>
                            </select>
                        </div>
                        <div class="col-md-4 mt-3 mt-md-0">
                            <label class="form-label-official">Admission Performed in Level</label>
                            <select name="level" id="level" class="form-select-official" required>
                                <option value="">-select-</option>
                                <option value="dist_code">Convener</option>
                                <option value="iti_code">ITI</option>
                            </select>
                        </div>
                    </div>
                    <div class="mt-4 text-center">
                        <button type="submit" class="btn-submit-official-navy"><i class="fas fa-search me-2"></i>VIEW REPORT</button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="loader-spinner" id="loader">
        <i class="fas fa-spinner fa-spin fa-3x"></i>
        <p class="mt-3 fw-bold">Generating DSC List...</p>
    </div>

    <div class="container-fluid px-4 py-4" id="reportView" style="display: none;">
        <div class="no-print d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
            <button class="btn btn-outline-secondary shadow-sm px-4 rounded-pill fw-bold" onclick="showSelection()">
                <i class="fas fa-arrow-left me-2"></i> BACK TO SELECTION
            </button>
            <div class="d-flex align-items-center gap-2 flex-wrap">
                <input type="text" id="reportSearch" class="form-control form-control-sm" placeholder="Search in results..." onkeyup="filterReport(this.value)" style="width: 240px;">
                <button class="btn btn-outline-secondary shadow-sm px-4 rounded-pill fw-bold btn-sm" onclick="tableToExcel('dscTable', 'DSC_List')">
                    <i class="fas fa-file-excel me-2 text-success"></i>EXCEL DOWNLOAD
                </button>
                <button class="btn text-white fw-bold shadow-sm px-4 rounded-pill btn-sm" onclick="window.print()" style="background-color: #337ab7;">
                    <i class="fas fa-print me-2"></i>PRINT REPORT
                </button>
            </div>
        </div>

        <div class="report-meta-box shadow-sm text-center py-3 mb-3" id="reportMetaCard" style="display: none; background-color: #f8fbff; border: 1px solid #d0e2f5;">
            <h4 class="fw-bold mb-1" style="color: #003366; font-size: 1.25rem;">ADMISSIONS SELECTION LIST FOR THE SESSION AUGUST - <span id="metaYear"></span></h4>
            <h5 class="fw-bold mb-2" style="color: #003366; font-size: 1.1rem;">Phase <span id="metaPhase"></span> ADMISSIONS THROUGH DIST. SELECTION COMMITTEE <span id="metaDistName"></span></h5>
            <div class="fw-bold text-dark mb-1">Name of the ITI: <span id="metaItiName"></span></div>
            <div class="fw-bold text-secondary mb-2" style="font-size: 0.95rem;">This List Indicates candidates admitted in Phase: <span id="metaPhaseSub"></span></div>
            <div class="d-flex justify-content-center gap-4 flex-wrap fw-bold mt-2 pt-2 border-top">
                <div>Trade Name : <span id="metaTradeName" class="text-primary"></span></div>
                <div>Strength : <span id="metaStrength" class="text-primary"></span></div>
                <div>Admission Level : <span id="metaLevel" class="text-primary"></span></div>
            </div>
        </div>

        <div class="shadow" style="background-color: #fff; border-radius: 8px; overflow: hidden; border: 1px solid #e0e0e0;">
            <div style="overflow-y: auto; max-height: 650px;">
                <table class="table table-bordered mb-0 table-hover text-center report-table" id="dscTable" style="min-width: 900px;">
                    <thead>
                        <tr>
                            <th>Sl NO</th>
                            <th>RANK</th>
                            <th>Admission Number</th>
                            <th>Name</th>
                            <th>Father Name</th>
                            <th>Gender</th>
                            <th>Date of Birth</th>
                            <th>caste</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody"></tbody>
                </table>
            </div>
        </div>
    </div>

    <script>
        function showSelection() {
            document.getElementById('reportView').style.display = 'none';
            document.getElementById('selectionView').style.display = 'block';
        }

        function tableToExcel(tableID, name) {
            const table = document.getElementById(tableID);
            if (!table) return;
            const html = table.outerHTML;
            const blob = new Blob(['\ufeff', html], { type: "application/vnd.ms-excel" });
            const url = URL.createObjectURL(blob);
            const a = document.createElement("a");
            a.href = url;
            a.download = (name || 'DSC_List') + '.xls';
            document.body.appendChild(a);
            a.click();
            document.body.removeChild(a);
            URL.revokeObjectURL(url);
        }

        function filterReport(query) {
            const q = (query || '').toLowerCase().trim();
            const rows = document.querySelectorAll('#tableBody tr');
            let currentHeader = null;
            let groupHasMatch = false;

            rows.forEach(row => {
                if (row.querySelector('.category-header')) {
                    if (currentHeader) {
                        currentHeader.style.display = (groupHasMatch || !q) ? '' : 'none';
                    }
                    currentHeader = row;
                    groupHasMatch = false;
                } else {
                    const text = row.textContent.toLowerCase();
                    const match = !q || text.includes(q);
                    row.style.display = match ? '' : 'none';
                    if (match) groupHasMatch = true;
                }
            });
            if (currentHeader) {
                currentHeader.style.display = (groupHasMatch || !q) ? '' : 'none';
            }
        }

        function loadOptions() {
            return fetch('${backendApiUrl}/dsc-options', { credentials: 'include' })
                .then(r => r.json())
                .then(data => {
                    const itiSelect = document.getElementById('iti_code');
                    const tradeSelect = document.getElementById('trade_code');
                    itiSelect.innerHTML = '<option value="">Select ITI</option>';
                    tradeSelect.innerHTML = '<option value="">Select Trade</option>';
                    if (data.itis && data.itis.length > 0) {
                        data.itis.forEach(iti => {
                            itiSelect.innerHTML += '<option value="' + iti.iti_code + '">' + iti.iti_name + '</option>';
                        });
                    }
                    if (data.trades && data.trades.length > 0) {
                        data.trades.forEach(trade => {
                            tradeSelect.innerHTML += '<option value="' + trade.trade_code + '">' + trade.trade_name + '</option>';
                        });
                    }
                })
                .catch(err => console.error('Failed to load options:', err));
        }

        function loadTradesForIti(itiCode) {
            const tradeSelect = document.getElementById('trade_code');
            tradeSelect.innerHTML = '<option value="">Select Trade</option>';
            if (!itiCode) {
                return;
            }
            fetch('${backendApiUrl}/dsc-options?iti_code=' + encodeURIComponent(itiCode), { credentials: 'include' })
                .then(r => r.json())
                .then(data => {
                    if (data.trades && data.trades.length > 0) {
                        data.trades.forEach(trade => {
                            tradeSelect.innerHTML += '<option value="' + trade.trade_code + '">' + trade.trade_name + '</option>';
                        });
                    }
                })
                .catch(err => console.error('Failed to load trades for ITI:', err));
        }

        function fetchReport(event) {
            event.preventDefault();
            const iti_code = document.getElementById('iti_code').value;
            const trade_code = document.getElementById('trade_code').value;
            const phase = document.getElementById('phase').value;
            const year = document.getElementById('year').value;
            const level = document.getElementById('level').value;

            if (!iti_code || !trade_code || !phase || !year || !level) {
                alert('Please select all fields');
                return;
            }

            document.getElementById('selectionView').style.display = 'none';
            document.getElementById('loader').style.display = 'block';

            const modeAdm = level === 'dist_code' ? 'CONVENER' : 'ITI';

            fetch('${backendApiUrl}/dsc-full?distCode=' + encodeURIComponent('ALL') + '&itiCode=' + encodeURIComponent(iti_code) + '&tradeCode=' + encodeURIComponent(trade_code) + '&phase=' + encodeURIComponent(phase) + '&year=' + encodeURIComponent(year) + '&modeAdm=' + encodeURIComponent(modeAdm), {
                method: 'GET'
            })
            .then(response => response.json().then(data => {
                if (!response.ok) {
                    throw new Error(data.message || data.error || ('Request failed (' + response.status + ')'));
                }
                return data;
            }))
            .then(data => {
                document.getElementById('loader').style.display = 'none';
                document.getElementById('reportView').style.display = 'block';

                // Fill Meta Summary
                const itiSel = document.getElementById('iti_code');
                const tradeSel = document.getElementById('trade_code');
                const itiName = (data.iti && data.iti.iti_name) ? data.iti.iti_name : (itiSel.options[itiSel.selectedIndex] ? itiSel.options[itiSel.selectedIndex].text : iti_code);
                const tradeName = (data.trade && data.trade.trade_name) ? data.trade.trade_name : (tradeSel.options[tradeSel.selectedIndex] ? tradeSel.options[tradeSel.selectedIndex].text : trade_code);
                const distName = (data.meta && data.meta.selection_type) ? data.meta.selection_type : '';
                const tradeStrength = (data.trade && data.trade.total_strength != null) ? data.trade.total_strength : '-';

                document.getElementById('metaDistName').textContent = distName;
                document.getElementById('metaItiName').textContent = itiName;
                document.getElementById('metaTradeName').textContent = tradeName;
                document.getElementById('metaStrength').textContent = tradeStrength;
                document.getElementById('metaPhase').textContent = phase;
                document.getElementById('metaPhaseSub').textContent = phase;
                document.getElementById('metaYear').textContent = year;
                document.getElementById('metaLevel').textContent = (level === 'dist_code' ? 'Convener' : 'ITI');
                document.getElementById('reportMetaCard').style.display = 'block';

                const searchInput = document.getElementById('reportSearch');
                if (searchInput) searchInput.value = '';

                const tbody = document.getElementById('tableBody');
                tbody.innerHTML = '';

                if (!data.categories || data.categories.length === 0) {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; padding:20px; font-weight: bold;">No records found.</td></tr>';
                    return;
                }

                let slNo = 1;
                let totalCandidates = 0;
                data.categories.forEach(cat => {
                    if (cat.candidates && cat.candidates.length > 0) {
                        const headerRow = document.createElement('tr');
                        headerRow.innerHTML = '<td colspan="8" class="category-header">Category : ' + (cat.category_code || 'Unknown') + ' Strength (' + (cat.strength || 0) + ') Strength Fill (' + (cat.filled || 0) + ') and Strength Vacant (' + (cat.vacant || 0) + ')</td>';
                        tbody.appendChild(headerRow);

                        cat.candidates.forEach(cand => {
                            if (cand.admission_number === 'VACANT' || cand.name === 'VACANT') {
                                const tr = document.createElement('tr');
                                tr.innerHTML = '<td>&nbsp;</td><td colspan="7" style="text-align: center; font-weight: bold; color: #555; letter-spacing: 2px;">-------------------------------------------VACANT----------------------------------------</td>';
                                tbody.appendChild(tr);
                            } else {
                                totalCandidates++;
                                const tr = document.createElement('tr');
                                tr.innerHTML =
                                    '<td>' + (cand.slNo != null && cand.slNo > 0 ? cand.slNo : slNo++) + '</td>' +
                                    '<td>' + (cand.rank != null && cand.rank !== '' && cand.rank !== 'null' ? cand.rank : '') + '</td>' +
                                    '<td>' + (cand.admission_number || '-') + '</td>' +
                                    '<td style="text-align: left;">' + (cand.name || '-') + '</td>' +
                                    '<td style="text-align: left;">' + (cand.father_name || '-') + '</td>' +
                                    '<td>' + (cand.gender || '-') + '</td>' +
                                    '<td>' + (cand.date_of_birth || '-') + '</td>' +
                                    '<td>' + (cand.caste || '-') + '</td>';
                                tbody.appendChild(tr);
                            }
                        });
                    }
                });

                if (totalCandidates === 0 && (!data.categories || data.categories.length === 0)) {
                    tbody.innerHTML = '<tr><td colspan="8" style="text-align:center; padding:20px; font-weight: bold;">No records found.</td></tr>';
                }
            })
            .catch(error => {
                document.getElementById('loader').style.display = 'none';
                document.getElementById('selectionView').style.display = 'block';
                alert('Error loading DSC list: ' + error.message);
                console.error('Error:', error);
            });
        }

        document.addEventListener('DOMContentLoaded', function() {
            fetch('${backendApiUrl}/current-admission-phase')
                .then(r => r.json())
                .then(config => {
                    const year = config.year || String(new Date().getFullYear());
                    const phase = config.phase || '';
                    const yearSelect = document.getElementById('year');
                    const phaseSelect = document.getElementById('phase');
                    if (yearSelect) yearSelect.value = year;
                    if (phaseSelect && phase) phaseSelect.value = String(phase);
                    return loadOptions();
                })
                .catch(err => {
                    console.error('Failed to load current phase:', err);
                    return loadOptions();
                });
        });
    </script>
<%@ include file="../footer.jsp" %>
</body>
</html>
