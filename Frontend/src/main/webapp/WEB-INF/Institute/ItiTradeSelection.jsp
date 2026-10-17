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
        /* ---- Vibrant royal-blue palette (solid, modern portal look) ---- */
        .page-header-custom {
            background: linear-gradient(135deg, #2a65b8 0%, #1b4f9c 100%);
            color: #ffffff;
            padding: 20px 0;
            margin-top: 15px;
            margin-bottom: 30px;
            border-bottom: 4px solid #123a75;
            box-shadow: 0 2px 6px rgba(0,0,0,0.12);
        }
        .page-header-custom h2 {
            font-weight: 700;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        .breadcrumb-text {
            color: #cfe2f7;
            font-size: 14px;
        }
        .form-card {
            border: 1px solid #bcd3ee;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 30px;
            background: #fff;
        }
        .card-header-primary {
            background: linear-gradient(135deg, #2a65b8 0%, #1b4f9c 100%);
            color: #ffffff;
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
            color: #123a75;
            margin-bottom: 8px;
            font-size: 0.95rem;
        }
        .form-select {
            border: 1.5px solid #a9c6e8;
            border-radius: 8px;
        }
        .form-select:focus {
            border-color: #2a65b8 !important;
            box-shadow: 0 0 0 0.25rem rgba(42, 101, 184, 0.25) !important;
        }
        .form-select option:hover {
            background-color: #2a65b8 !important;
            color: #ffffff !important;
        }
        .table th {
            background-color: #1b4f9c !important;
            color: white !important;
            padding: 12px;
            font-weight: bold;
            font-size: 13px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .table td {
            padding: 10px;
            vertical-align: middle;
            font-size: 13px;
        }
        .table, .table th, .table td { border: 1px solid #bcd3ee !important; }
        .table-striped > tbody > tr:nth-child(odd) > td,
        .table-striped > tbody > tr:nth-child(odd) > th { background-color: #f2f7fc !important; }
        .table-striped > tbody > tr:nth-child(even) > td,
        .table-striped > tbody > tr:nth-child(even) > th { background-color: #ffffff !important; }
        .loading-message {
            text-align: center;
            padding: 40px;
            color: #666;
            font-size: 16px;
        }
        .error-message {
            text-align: center;
            padding: 40px;
            color: #dc3545;
            font-size: 16px;
        }
        .radio-cell {
            text-align: center;
            width: 60px;
        }
        .btn-success-custom {
            background-color: #1b4f9c;
            border: none;
            color: white;
            font-weight: 700;
            padding: 10px 30px;
            border-radius: 50px;
            transition: all 0.3s;
        }
        .btn-success-custom:hover {
            background-color: #16417f;
            transform: translateY(-1px);
            color: #fff;
        }
        .btn-continue {
            min-width: 150px;
        }
        .btn-continue:disabled { opacity: .55; }
        /* Navbar dropdown items: royal-blue palette hover */
        body .dropdown-menu .dropdown-item:hover {
            background-color: #2a65b8 !important;
            color: #ffffff !important;
            padding-left: 25px;
        }
        /* Footer: solid navy blue with white text */
        .lower-footer {
            background-color: #123a75 !important;
            color: #ffffff !important;
        }
    </style>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
</head>

<body>
    <!-- Global Header -->
    <jsp:include page="/WEB-INF/reports/header.jsp" />

    <!-- Portal page heading -->
    <div class="page-header-custom text-center">
        <div class="container">
            <h2 class="text-uppercase">ITI Trade Selection</h2>
            <div class="breadcrumb-text">Home / ITI Trade Selection</div>
        </div>
    </div>

    <div class="container-fluid px-5 mb-5" style="min-height: 50vh;">
        <!-- ITI Selection Area -->
        <div class="card form-card">
            <div class="card-header-primary">
                <i class="fas fa-building"></i> Select ITI
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
                <i class="fas fa-tools"></i> Trades Available in This ITI
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