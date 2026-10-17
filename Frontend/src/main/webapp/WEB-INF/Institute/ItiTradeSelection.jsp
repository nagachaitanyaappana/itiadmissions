<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>

    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <title>ITI TRADE SELECTION</title>
    <style>
        /* ---- Modern admin theme (blue accent, light canvas) ---- */
        .page-canvas {
            background-color: #f5f7fa;
            border: 1px solid #e8edf3;
            border-radius: 14px;
            padding-top: 20px;
            padding-bottom: 26px;
        }
        .page-header-custom {
            background: linear-gradient(135deg, #1d5aa6 0%, #164a86 100%);
            color: #ffffff;
            padding: 12px 0 14px;
            margin-top: 15px;
            margin-bottom: 20px;
            box-shadow: 0 1px 3px rgba(16,24,40,0.12);
        }
        .page-header-custom h2 {
            font-size: 1.25rem;
            font-weight: 600;
            letter-spacing: 0.2px;
            margin-bottom: 2px;
        }
        .breadcrumb-text {
            color: rgba(255,255,255,0.75);
            font-size: 12px;
        }
        .form-card {
            border: 1px solid #e4e9f0;
            border-radius: 12px;
            box-shadow: 0 1px 2px rgba(16,24,40,0.05);
            overflow: hidden;
            margin-bottom: 16px;
            background: #fff;
        }
        .card-header-primary {
            background-color: #ffffff;
            color: #1f2937;
            font-weight: 700;
            font-size: 0.78rem;
            padding: 12px 18px;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            display: flex;
            align-items: center;
            gap: 10px;
            border-bottom: 1px solid #eef2f7;
        }
        .card-header-primary i { color: #17549e; }
        .step-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 20px;
            height: 20px;
            border-radius: 50%;
            background-color: #17549e;
            color: #ffffff;
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 0;
        }
        .card-body-custom {
            padding: 20px;
            background-color: #fff;
        }
        .form-label-custom {
            font-weight: 600;
            color: #334155;
            margin-bottom: 6px;
            font-size: 0.9rem;
        }
        .form-select {
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 13px;
        }
        .form-select:focus {
            border-color: #2f6fc0 !important;
            box-shadow: 0 0 0 0.2rem rgba(47, 111, 192, 0.15) !important;
        }
        .form-select option:hover {
            background-color: #2f6fc0 !important;
            color: #ffffff !important;
        }
        .table th {
            background-color: #eef2f7 !important;
            color: #475569 !important;
            padding: 10px 12px;
            font-weight: 600;
            font-size: 11.5px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            border-bottom: 1px solid #e2e8f0 !important;
        }
        .table td {
            padding: 10px 12px;
            vertical-align: middle;
            font-size: 13px;
            color: #1f2937;
            border-bottom: 1px solid #eef2f7 !important;
        }
        .table, .table th, .table td { border-color: #eef2f7 !important; }
        .table-striped > tbody > tr:nth-child(odd) > td,
        .table-striped > tbody > tr:nth-child(odd) > th { background-color: #f8fafc !important; }
        .table-striped > tbody > tr:nth-child(even) > td,
        .table-striped > tbody > tr:nth-child(even) > th { background-color: #ffffff !important; }
        .table tbody tr:hover > td { background-color: #eef6ff !important; }
        .loading-message {
            text-align: center;
            padding: 30px;
            color: #64748b;
            font-size: 14px;
        }
        .error-message {
            text-align: center;
            padding: 30px;
            color: #dc2626;
            font-size: 14px;
        }
        .radio-cell {
            text-align: center;
            width: 60px;
        }
        .btn-success-custom {
            background-color: #17549e;
            border: none;
            color: #ffffff;
            font-weight: 600;
            font-size: 0.875rem;
            padding: 8px 20px;
            border-radius: 8px;
            transition: background-color 0.15s;
        }
        .btn-success-custom:hover {
            background-color: #123f78;
            color: #ffffff;
        }
        .btn-continue {
            min-width: 140px;
        }
        .btn-continue:disabled { opacity: .55; }
        /* Navbar dropdown items: blue palette hover */
        body .dropdown-menu .dropdown-item:hover {
            background-color: #17549e !important;
            color: #ffffff !important;
            padding-left: 25px;
        }
        /* Footer: solid navy blue with white text */
        .lower-footer {
            background-color: #0f2f5c !important;
            color: #ffffff !important;
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
</head>

<body>
    <!-- Global Header -->
    <jsp:include page="/WEB-INF/reports/header.jsp" />

    <!-- Portal page heading -->
    <div class="page-header-custom">
        <div class="container">
            <h2>ITI Trade Selection</h2>
            <div class="breadcrumb-text">Home / ITI Trade Selection</div>
        </div>
    </div>

    <div class="container-fluid px-5 mb-5 page-canvas" style="min-height: 50vh;">
        <!-- ITI Selection Area -->
        <div class="card form-card">
            <div class="card-header-primary">
                <span class="step-badge">1</span><i class="fas fa-building"></i> Select ITI
            </div>
            <div class="card-body-custom">
                <div class="row g-3">
                    <div class="col-md-6">
                        <label for="itiSelect" class="form-label-custom">ITI:</label>
                        <select class="form-select" id="itiSelect">
                            <option value="">-- Select ITI --</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>

        <!-- Selected ITI Details -->
        <div class="card form-card" id="itiDetails" style="display: none;">
            <div class="card-header-primary">
                <i class="fas fa-info-circle"></i> Selected ITI Details
            </div>
            <div class="card-body-custom">
                <div class="row">
                    <div class="col-md-6">
                        <p class="mb-1"><strong>ITI Code:</strong> <span id="selectedItiCode"></span></p>
                        <p class="mb-0"><strong>ITI Name:</strong> <span id="selectedItiName"></span></p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Trades Table Area -->
        <div class="card form-card" id="tradesArea" style="display: none;">
            <div class="card-header-primary">
                <span class="step-badge">2</span><i class="fas fa-tools"></i> Trades Available in This ITI
            </div>
            <div class="card-body-custom">
                <div class="d-flex justify-content-end mb-2">
                    <div class="text-muted" id="tradeCount">Showing 0 entries</div>
                </div>
                <div class="table-responsive">
                    <table class="table table-bordered table-striped">
                        <thead>
                            <tr>
                                <th class="radio-cell">Select</th>
                                <th>Trade Code</th>
                                <th>Trade</th>
                                <th>Strength</th>
                                <th>Duration (Months)</th>
                                <th>Available</th>
                            </tr>
                        </thead>
                        <tbody id="tradeTableBody">
                            <tr>
                                <td colspan="6" class="text-center">Please select an ITI to load trades.</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <!-- Loading Message -->
        <div id="loadingMessage" class="loading-message" style="display: none;">
            <i class="fas fa-spinner fa-spin me-2"></i> Loading trades...
        </div>

        <!-- Error Message -->
        <div id="errorMessage" class="error-message" style="display: none;">
            <i class="fas fa-exclamation-triangle me-2"></i>
            <span id="errorText"></span>
        </div>

        <!-- Empty Result Message -->
        <div id="emptyMessage" class="loading-message" style="display: none;">
            No trades are currently associated with this ITI.
        </div>

        <!-- Continue Button -->
        <div class="d-flex justify-content-end mt-4">
            <button class="btn btn-success-custom btn-continue" id="continueBtn" disabled>
                Continue <i class="fas fa-arrow-right ms-2"></i>
            </button>
        </div>
    </div>

    <!-- Global Footer -->
    <%@ include file="../footer.jsp" %>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const itiSelect = document.getElementById("itiSelect");
            const itiDetails = document.getElementById("itiDetails");
            const selectedItiCode = document.getElementById("selectedItiCode");
            const selectedItiName = document.getElementById("selectedItiName");
            const tradesArea = document.getElementById("tradesArea");
            const tradeTableBody = document.getElementById("tradeTableBody");
            const tradeCount = document.getElementById("tradeCount");
            const continueBtn = document.getElementById("continueBtn");
            const loadingMessage = document.getElementById("loadingMessage");
            const errorMessage = document.getElementById("errorMessage");
            const errorText = document.getElementById("errorText");
            const emptyMessage = document.getElementById("emptyMessage");

            const itiApiUrl = "${itiApiUrl}";
            const backendBaseUrl = "${backendApiBaseUrl}";

            let allItis = [];
            let currentTrades = [];
            let selectedTrade = null;

            // Load ITI list on page load
            fetchItiList();

            // ITI selection change handler
            itiSelect.addEventListener("change", function () {
                const itiCode = this.value;
                if (itiCode) {
                    loadTradesForIti(itiCode);
                } else {
                    resetTradeSection();
                }
            });

            // Continue button click handler
            continueBtn.addEventListener("click", function () {
                if (selectedTrade) {
                    goToShiftUnitPage(selectedTrade);
                }
            });

            function fetchItiList() {
                fetch(itiApiUrl)
                    .then(response => {
                        if (!response.ok) {
                            throw new Error("Failed to fetch ITI list");
                        }
                        return response.json();
                    })
                    .then(data => {
                        allItis = data;
                        populateItiDropdown(allItis);

                        // Check if itiCode is provided in URL
                        const urlParams = new URLSearchParams(window.location.search);
                        const urlItiCode = urlParams.get('itiCode');
                        if (urlItiCode) {
                            itiSelect.value = urlItiCode;
                            loadTradesForIti(urlItiCode);
                        }
                    })
                    .catch(error => {
                        console.error("Error loading ITI list:", error);
                        errorText.textContent = "Unable to load ITI list. Please refresh the page.";
                        errorMessage.style.display = "block";
                    });
            }

            function populateItiDropdown(itis) {
                itiSelect.innerHTML = '<option value="">-- Select ITI --</option>';
                itis.forEach(iti => {
                    const option = document.createElement("option");
                    option.value = iti.itiCode;
                    option.textContent = (iti.itiCode || '') + ' - ' + (iti.itiName || 'Unknown ITI');
                    itiSelect.appendChild(option);
                });
            }

            function loadTradesForIti(itiCode) {
                showLoading(true);
                hideMessages();

                // Per-ITI trade list (only the trades sanctioned for this ITI).
                // Served by a same-origin proxy so the page needs no CORS; the
                // proxy delegates to the backend reservation-entry trade lookup.
                const url = '${pageContext.request.contextPath}/iti-trade-selection/api/iti/'
                    + encodeURIComponent(itiCode) + '/trades';

                fetch(url, { credentials: 'include' })
                    .then(response => {
                        if (!response.ok) {
                            throw new Error("HTTP error! status: " + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        currentTrades = Array.isArray(data) ? data : [];
                        renderTrades(currentTrades);
                        updateSelectedItiDetails(itiCode);
                        showLoading(false);
                    })
                    .catch(error => {
                        console.error("Error loading trades:", error);
                        errorText.textContent = "Unable to load trades for the selected ITI. Please try again.";
                        errorMessage.style.display = "block";
                        showLoading(false);
                        resetTradeSection();
                    });
            }

            function renderTrades(trades) {
                tradeTableBody.innerHTML = "";

                if (trades.length === 0) {
                    emptyMessage.style.display = "block";
                    tradesArea.style.display = "none";
                    continueBtn.disabled = true;
                    selectedTrade = null;
                    tradeCount.textContent = "Showing 0 entries";
                    return;
                }

                emptyMessage.style.display = "none";
                tradesArea.style.display = "block";

                trades.forEach((trade, index) => {
                    const tr = document.createElement("tr");

                    const isAvailable = !(trade.tradeFreeze === 1 || trade.tradeFreeze === "1");

                   tr.innerHTML = `
    <td class="radio-cell">
        <input type="radio" name="tradeRadio" value="\${index}" class="trade-radio">
    </td>
    <td>\${escapeHtml(trade.tradeCode ?? '')}</td>
    <td><strong>\${escapeHtml(trade.tradeName || trade.tradeShort || '')}</strong></td>
    <td>\${escapeHtml(trade.strength != null ? String(trade.strength) : (trade.unitStrength != null ? String(trade.unitStrength) : '-'))}</td>
    <td>\${escapeHtml(trade.durationYrs != null ? String(trade.durationYrs) : '-')}</td>
    <td>\${isAvailable
        ? '<span class="text-success fw-bold">Yes</span>'
        : '<span class="text-danger">No</span>'}</td>
`;

tradeTableBody.appendChild(tr);
                });

                // \${...} escaped so JSP EL leaves the literal for the browser.
                tradeCount.textContent = `Showing \${trades.length} entries`;

                // Add event listeners to radio buttons
                const radioButtons = document.querySelectorAll('.trade-radio');
                radioButtons.forEach(radio => {
                    radio.addEventListener('change', handleTradeSelection);
                });
            }

            function handleTradeSelection(event) {
                const selectedIndex = parseInt(event.target.value);
                selectedTrade = currentTrades[selectedIndex];
                continueBtn.disabled = false;
            }

            function updateSelectedItiDetails(itiCode) {
                const iti = allItis.find(i => i.itiCode === itiCode);
                if (iti) {
                    selectedItiCode.textContent = iti.itiCode || '';
                    selectedItiName.textContent = iti.itiName || '';
                    itiDetails.style.display = "block";
                }
            }

           function goToShiftUnitPage(trade) {

    const itiCode = itiSelect.value;

    const iti = allItis.find(i => String(i.itiCode) === String(itiCode));

    const itiName = iti ? iti.itiName : '';

    const tradeCode = String(trade.tradeCode);
    const tradeShort = trade.tradeShort || '';

   const url =
    '${pageContext.request.contextPath}/shift-unit-permitted' +
    '?itiCode=' + encodeURIComponent(itiCode) +
    '&tradeCode=' + encodeURIComponent(tradeCode) +
    '&tradeShort=' + encodeURIComponent(tradeShort) +
    '&itiName=' + encodeURIComponent(itiName);

window.location.href = url;
}
            function showLoading(show) {
                loadingMessage.style.display = show ? "block" : "none";
                if (show) {
                    tradesArea.style.display = "none";
                    emptyMessage.style.display = "none";
                    errorMessage.style.display = "none";
                }
            }

            function hideMessages() {
                errorMessage.style.display = "none";
                emptyMessage.style.display = "none";
            }

            function resetTradeSection() {
                currentTrades = [];
                selectedTrade = null;
                tradeTableBody.innerHTML = '<tr><td colspan="6" class="text-center">Please select an ITI to load trades.</td></tr>';
                tradesArea.style.display = "none";
                itiDetails.style.display = "none";
                continueBtn.disabled = true;
                tradeCount.textContent = "Showing 0 entries";
            }

            function escapeHtml(text) {
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }
        });
    </script>
</body>

</html>