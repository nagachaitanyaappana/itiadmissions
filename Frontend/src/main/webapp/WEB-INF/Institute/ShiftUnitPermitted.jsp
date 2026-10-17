<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <title>Shift & Unit Permitted Configuration</title>
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
        .summary-label {
            font-size: 0.72rem;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: #17549e;
            margin-bottom: 6px;
        }
        .detail-label {
            font-weight: 600;
            color: #334155;
            font-size: 0.9rem;
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
        .form-control-sm, .form-select-sm {
            border: 1px solid #cbd5e1;
            border-radius: 6px;
            font-size: 13px;
        }
        .form-control-sm:focus, .form-select-sm:focus {
            border-color: #2f6fc0 !important;
            box-shadow: 0 0 0 0.2rem rgba(47, 111, 192, 0.15) !important;
        }
        .form-select option:hover {
            background-color: #2f6fc0 !important;
            color: #ffffff !important;
        }
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
        .success-message {
            text-align: center;
            padding: 12px;
            color: #15803d;
            background-color: #f0fdf4;
            border: 1px solid #bbf7d0;
            border-radius: 8px;
            margin-bottom: 16px;
            font-size: 0.9rem;
        }
        .validation-error {
            color: #dc2626;
            font-size: 13px;
            margin-top: 5px;
            font-weight: 600;
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
        .btn-danger-custom {
            background-color: #dc2626;
            border: none;
            color: #ffffff;
            font-weight: 600;
            font-size: 0.875rem;
            border-radius: 6px;
            transition: background-color 0.15s;
        }
        .btn-danger-custom:hover {
            background-color: #b91c1c;
            color: #ffffff;
        }
        .btn-save {
            min-width: 160px;
        }
        .btn-back {
            min-width: 160px;
            border-radius: 8px;
            font-weight: 600;
            background-color: #ffffff;
            border: 1px solid #cbd5e1;
            color: #334155;
        }
        .btn-back:hover {
            background-color: #f1f5f9;
            border-color: #cbd5e1;
            color: #1f2937;
        }
        #addEntryBtn {
            padding: 7px 16px;
            font-size: 0.85rem;
        }
        .remove-entry-btn {
            background-color: #dc2626;
            border: none;
            border-radius: 6px;
            font-size: 0.8rem;
            font-weight: 600;
        }
        .remove-entry-btn:hover { background-color: #b91c1c; }
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
            <h2>Shift &amp; Unit Permitted Configuration</h2>
            <div class="breadcrumb-text">Home / ITI Trade Selection / Shift &amp; Unit Permitted</div>
        </div>
    </div>

    <div class="container-fluid px-5 mb-5 page-canvas" style="min-height: 50vh;">
        <!-- Missing ITI/Trade Message -->
        <div id="missingInfoMessage" class="error-message" style="display: none;">
            <i class="fas fa-exclamation-triangle me-2"></i>
            <span id="missingInfoText"></span>
            <br><br>
            <a href="${pageContext.request.contextPath}/iti-trade-selection" class="btn btn-success-custom">
                <i class="fas fa-arrow-left me-2"></i>Back to Trade Selection
            </a>
        </div>

        <!-- Main Content -->
        <div id="mainContent" style="display: none;">
        <!-- Selection Summary Card -->
        <div class="card form-card">
            <div class="card-header-primary">
                <i class="fas fa-clipboard-check"></i> Selection Summary
            </div>
            <div class="card-body-custom">
                <div class="row g-4">
                    <div class="col-md-6">
                        <div class="summary-label">ITI</div>
                        <p class="mb-1"><strong>Code:</strong> <span id="selectedItiCode"></span></p>
                        <p class="mb-0"><strong>Name:</strong> <span id="selectedItiName"></span></p>
                    </div>
                    <div class="col-md-6">
                        <div class="summary-label">Trade</div>
                        <p class="mb-1"><strong>Code:</strong> <span id="selectedTradeCode"></span></p>
                        <p class="mb-0"><strong>Name:</strong> <span id="selectedTradeShort"></span></p>
                    </div>
                </div>
            </div>
        </div>

            <!-- Configuration Section -->
            <div class="card form-card">
            <div class="card-header-primary">
                <span class="step-badge">3</span><i class="fas fa-cogs"></i> Shift &amp; Unit Configuration
            </div>
                <div class="card-body-custom">
                    <!-- Entries Table -->
                    <div class="d-flex justify-content-between align-items-center mb-3">
                        <h5 class="mb-0" style="color: #1f2937; font-size: 0.95rem;">Shift &amp; Unit Entries</h5>
                        <button class="btn btn-success-custom" id="addEntryBtn">
                            <i class="fas fa-plus me-2"></i>Add Entry
                        </button>
                    </div>

                    <div class="table-responsive">
                        <table class="table table-bordered table-striped" id="entriesTable">
                            <thead>
                                <tr>
                                    <th>Strength</th>
                                    <th>Shift</th>
                                    <th>Unit</th>
                                    <th>Strength Vacant</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody id="entriesTableBody">
                                <tr id="emptyRow">
                                    <td colspan="5" class="text-center">No entries configured. Click "Add Entry" to add one.</td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <div id="entriesValidationError" class="validation-error" style="display: none;"></div>
                </div>
            </div>

            <!-- Action Buttons -->
            <div class="d-flex justify-content-between mt-4">
                <a href="${pageContext.request.contextPath}/iti-trade-selection" class="btn btn-secondary btn-back">
                    <i class="fas fa-arrow-left me-2"></i>Back to Trade Selection
                </a>
                <button class="btn btn-success-custom btn-save" id="saveBtn">
                    <i class="fas fa-save me-2"></i>Save Configuration
                </button>
            </div>

            <!-- Success Message -->
            <div id="successMessage" class="success-message" style="display: none;">
                <i class="fas fa-check-circle me-2"></i>
                <span id="successText"></span>
            </div>

            <!-- Loading Message -->
            <div id="loadingMessage" class="loading-message" style="display: none;">
                <i class="fas fa-spinner fa-spin me-2"></i> <span id="loadingText">Loading configuration...</span>
            </div>

            <!-- Error Message -->
            <div id="errorMessage" class="error-message" style="display: none;">
                <i class="fas fa-exclamation-triangle me-2"></i>
                <span id="errorText"></span>
            </div>
        </div>
    </div>

    <!-- Global Footer -->
    <%@ include file="../footer.jsp" %>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            const apiUrl = "${shiftUnitApiUrl}";

            // URL parameters
            const urlParams = new URLSearchParams(window.location.search);
            const itiCode = urlParams.get("itiCode");
            const tradeCode = urlParams.get("tradeCode");
            const itiName = urlParams.get("itiName");
            const tradeShort = urlParams.get("tradeShort");

            // DOM elements
            const missingInfoMessage = document.getElementById("missingInfoMessage");
            const missingInfoText = document.getElementById("missingInfoText");
            const mainContent = document.getElementById("mainContent");
            const selectedItiCode = document.getElementById("selectedItiCode");
            const selectedItiName = document.getElementById("selectedItiName");
            const selectedTradeCode = document.getElementById("selectedTradeCode");
            const selectedTradeShort = document.getElementById("selectedTradeShort");
            const entriesTableBody = document.getElementById("entriesTableBody");
            const emptyRow = document.getElementById("emptyRow");
            const addEntryBtn = document.getElementById("addEntryBtn");
            const saveBtn = document.getElementById("saveBtn");
            const successMessage = document.getElementById("successMessage");
            const successText = document.getElementById("successText");
            const loadingMessage = document.getElementById("loadingMessage");
            const loadingText = document.getElementById("loadingText");
            const errorMessage = document.getElementById("errorMessage");
            const errorText = document.getElementById("errorText");
            const entriesValidationError = document.getElementById("entriesValidationError");

            let entries = [];
            let isSaving = false;
            let hadExistingConfig = false;

            // Initialize page
            initializePage();

            function initializePage() {
                // Validate required parameters
                if (!itiCode || !tradeCode) {
                    if (!itiCode) {
                        missingInfoText.textContent = "ITI information is missing. Please return to ITI Trade Selection.";
                    } else if (!tradeCode) {
                        missingInfoText.textContent = "Trade information is missing. Please return to ITI Trade Selection.";
                    }
                    missingInfoMessage.style.display = "block";
                    mainContent.style.display = "none";
                    return;
                }

                // Display selected ITI and Trade
                selectedItiCode.textContent = escapeHtml(itiCode);
                selectedItiName.textContent = escapeHtml(itiName || 'N/A');
                selectedTradeCode.textContent = escapeHtml(tradeCode);
                selectedTradeShort.textContent = escapeHtml(tradeShort || 'N/A');

                missingInfoMessage.style.display = "none";
                mainContent.style.display = "block";

                // Load existing configuration
                loadExistingConfiguration();

                // Add event listeners
                addEntryBtn.addEventListener("click", addEntry);
                saveBtn.addEventListener("click", saveConfiguration);
            }

            function loadExistingConfiguration() {
                showLoading(true, "Loading configuration...");
                hideMessages();

                const url = apiUrl + '?itiCode=' + encodeURIComponent(itiCode) + '&tradeCode=' + encodeURIComponent(tradeCode);

                fetch(url)
                    .then(response => {
                        if (!response.ok) {
                            if (response.status === 404) {
                                // No existing configuration, start fresh
                                return null;
                            }
                            throw new Error("HTTP error! status: " + response.status);
                        }
                        return response.json();
                    })
                    .then(data => {
                        if (data && data.entries) {
                            // Populate existing configuration
                            hadExistingConfig = data.entries.length > 0;
                            entries = data.entries.map(entry => ({
                                strength: entry.strength,
                                shiftAllowed: entry.shiftAllowed,
                                unitAllowed: entry.unitAllowed,
                                strengthVacant: entry.strengthVacant
                            }));
                            renderEntries();
                        } else {
                            // Start with empty configuration
                            entries = [];
                            renderEntries();
                        }
                        showLoading(false);
                    })
                    .catch(error => {
                        console.error("Error loading configuration:", error);
                        showError("Unable to load configuration. Please try again.");
                        showLoading(false);
                        entries = [];
                        renderEntries();
                    });
            }

            function renderEntries() {
                entriesTableBody.innerHTML = "";

                if (entries.length === 0) {
                    const emptyRowClone = document.createElement("tr");
                    emptyRowClone.id = "emptyRow";
                    emptyRowClone.innerHTML = '<td colspan="5" class="text-center">No entries configured. Click "Add Entry" to add one.</td>';
                    entriesTableBody.appendChild(emptyRowClone);
                    return;
                }

                entries.forEach((entry, index) => {
                    const strengthValue = (entry.strength != null ? entry.strength : '');
                    const row = document.createElement("tr");
                    row.innerHTML = `
                        <td>
                            <input type="number" class="form-control form-control-sm strength-input" data-index="\${index}" value="\${strengthValue}" min="1" style="width: 100px;">
                        </td>
                        <td>
                            <select class="form-select form-select-sm shift-select" data-index="\${index}">
                                <option value="1" \${entry.shiftAllowed === 1 ? 'selected' : ''}>1</option>
                                <option value="2" \${entry.shiftAllowed === 2 ? 'selected' : ''}>2</option>
                                <option value="3" \${entry.shiftAllowed === 3 ? 'selected' : ''}>3</option>
                            </select>
                        </td>
                        <td>
                            <select class="form-select form-select-sm unit-select" data-index="\${index}">
                                \${generateUnitOptions(entry.unitAllowed)}
                            </select>
                        </td>
                        <td>
                            <input type="number" class="form-control form-control-sm strength-vacant-input" 
                                   data-index="\${index}" value="\${entry.strengthVacant != null ? entry.strengthVacant : ''}" min="0" style="width: 100px;" placeholder="= strength">
                        </td>
                        <td>
                            <button class="btn btn-danger btn-sm remove-entry-btn" data-index="\${index}">
                                <i class="fas fa-trash"></i> Remove
                            </button>
                        </td>
                    `;
                    entriesTableBody.appendChild(row);
                });

                // Add event listeners
                document.querySelectorAll('.remove-entry-btn').forEach(btn => {
                    btn.addEventListener('click', function() {
                        const index = parseInt(this.getAttribute('data-index'));
                        removeEntry(index);
                    });
                });
            }

            function generateUnitOptions(selectedValue) {
                let options = '';
                for (let i = 1; i <= 12; i++) {
                    options += `<option value="\${i}" \${i === selectedValue ? 'selected' : ''}>\${i}</option>`;
                }
                return options;
            }

            function addEntry() {
                entries.push({
                    strength: '',
                    shiftAllowed: 1,
                    unitAllowed: 1,
                    strengthVacant: ''
                });
                renderEntries();
                hideMessages();
            }

            function removeEntry(index) {
                entries.splice(index, 1);
                renderEntries();
                hideMessages();
            }

            function validateEntries() {
                const errors = [];

                // Get current values from DOM
                const strengthInputs = document.querySelectorAll('.strength-input');
                const shiftSelects = document.querySelectorAll('.shift-select');
                const unitSelects = document.querySelectorAll('.unit-select');
                const vacantInputs = document.querySelectorAll('.strength-vacant-input');

                // Check at least one entry exists
                if (strengthInputs.length === 0) {
                    errors.push("At least one shift and unit entry is required.");
                    return errors;
                }

                // Validate each entry
                const shiftUnitMap = new Map();

                for (let i = 0; i < strengthInputs.length; i++) {
                    const strength = parseInt(strengthInputs[i].value);
                    const shift = parseInt(shiftSelects[i].value);
                    const unit = parseInt(unitSelects[i].value);
                    const vacant = parseInt(vacantInputs[i].value) || 0;

                    // Template literals are backslash-escaped (\${) so JSP EL
                    // leaves them for the browser: without the escape the
                    // server evaluates ${i + 1} to 1 and ${shift}/${unit} to
                    // empty, mislabelling every duplicate as "Entry 1" and
                    // colliding every row on the same empty key.
                    // Strength is entered here (permitted capacity for the shift/unit).
                    if (!(strength > 0)) {
                        errors.push(`Entry \${i + 1}: Strength is required and must be greater than 0.`);
                    }

                    // Validate shift
                    if (shift < 1 || shift > 3) {
                        errors.push(`Entry \${i + 1}: Shift must be between 1 and 3.`);
                    }

                    // Validate unit
                    if (unit < 1 || unit > 12) {
                        errors.push(`Entry \${i + 1}: Unit must be between 1 and 12.`);
                    }

                    // Validate strength vacant
                    if (vacant < 0) {
                        errors.push(`Entry \${i + 1}: Strength vacant cannot be negative.`);
                    }

                    // Check for duplicate shift + unit combinations
                    const shiftUnitKey = `\${shift}-\${unit}`;
                    if (shiftUnitMap.has(shiftUnitKey)) {
                        errors.push(`Entry \${i + 1}: Shift \${shift} and Unit \${unit} are already configured.`);
                    } else {
                        shiftUnitMap.set(shiftUnitKey, true);
                    }
                }

                return errors;
            }

            function buildPayload() {
                // Read current values from DOM
                const updatedEntries = [];
                const strengthInputs = document.querySelectorAll('.strength-input');
                const shiftSelects = document.querySelectorAll('.shift-select');
                const unitSelects = document.querySelectorAll('.unit-select');
                const vacantInputs = document.querySelectorAll('.strength-vacant-input');

                for (let i = 0; i < entries.length; i++) {
                    const vacantRaw = vacantInputs[i].value;
                    updatedEntries.push({
                        strength: parseInt(strengthInputs[i].value),
                        shiftAllowed: parseInt(shiftSelects[i].value),
                        unitAllowed: parseInt(unitSelects[i].value),
                        // Blank means "not specified": let the backend default it to the strength.
                        strengthVacant: vacantRaw === '' ? null : parseInt(vacantRaw)
                    });
                }

                return {
                    itiCode: String(itiCode),
                    tradeCode: String(tradeCode),
                    entries: updatedEntries
                };
            }

            function saveConfiguration() {
                if (isSaving) {
                    return;
                }

                hideMessages();

                // Validate entries
                const errors = validateEntries();
                if (errors.length > 0) {
                    entriesValidationError.textContent = errors.join(" ");
                    entriesValidationError.style.display = "block";
                    return;
                }

                // Saving replaces ALL existing rows for this ITI + trade, which
                // resets the per-entry strength and vacant counts. Warn before
                // wiping already-consumed seat data.
                if (hadExistingConfig && !window.confirm(
                        "This will wipe the existing seat data (strength, filled, vacant). " +
                        "Are you sure you want to resave the shift unit?")) {
                    return;
                }

                // Build payload
                const payload = buildPayload();

                // Send PUT request
                isSaving = true;
                saveBtn.disabled = true;
                showLoading(true, "Saving...");
              console.log("========== SAVE CONFIGURATION ==========");
console.log("API URL:", apiUrl);
console.log("Payload:", payload);
console.log("========================================");
                fetch(apiUrl, {
                    method: "PUT",
                    headers: {
                        "Content-Type": "application/json"
                    },
                    body: JSON.stringify(payload)
                })
                .then(response => {
                    if (!response.ok) {
                        return response.json().then(data => {
                            throw { status: response.status, data: data };
                        }).catch(() => {
                            throw { status: response.status, data: null };
                        });
                    }
                    return response.json();
                })
                .then(data => {
                    showSuccess("Shift and unit configuration saved successfully.");
                    showLoading(false);
                    isSaving = false;
                    saveBtn.disabled = false;
                })
                .catch(error => {
                    console.error("Error saving configuration:", error);
                    showLoading(false);
                    isSaving = false;
                    saveBtn.disabled = false;

                    if (error.status) {
                        if (error.status === 400) {
                            showError("Invalid data provided. Please check your entries.");
                        } else if (error.status === 409) {
                            showError("Duplicate shift and unit combination detected.");
                        } else if (error.status === 404) {
                            showError("Resource not found. Please try again.");
                        } else if (error.status === 500) {
                            showError("Server error. Please try again later.");
                        } else {
                            showError("Failed to save configuration. Please try again.");
                        }
                    } else {
                        showError("Unable to connect to the server. Please check whether the backend is running.");
                    }
                });
            }

            function showLoading(show, text) {
                loadingMessage.style.display = show ? "block" : "none";
                if (text) {
                    loadingText.textContent = text;
                }
                if (show) {
                    mainContent.style.opacity = "0.6";
                    mainContent.style.pointerEvents = "none";
                } else {
                    mainContent.style.opacity = "1";
                    mainContent.style.pointerEvents = "auto";
                }
            }

            function showSuccess(message) {
                successText.textContent = message;
                successMessage.style.display = "block";
                setTimeout(() => {
                    successMessage.style.display = "none";
                }, 5000);
            }

            function showError(message) {
                errorText.textContent = message;
                errorMessage.style.display = "block";
            }

            function hideMessages() {
                errorMessage.style.display = "none";
                successMessage.style.display = "none";
                entriesValidationError.style.display = "none";
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