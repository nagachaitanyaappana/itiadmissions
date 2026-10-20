<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>ATC ITI PHONE NUMBERS</title>
    <style>
        .page-title {
            color: #333;
            font-size: 28px;
            font-weight: 600;
        }
        .breadcrumb-text {
            color: #888;
            font-size: 14px;
        }
        .table th {
            background-color: #212529 !important;
            color: white !important;
            padding: 12px;
            font-weight: bold;
        }
        .table td {
            padding: 12px;
            vertical-align: middle;
        }
        .table-striped tbody tr:nth-of-type(odd) {
            background-color: #f8f9fa;
        }
        .table-striped tbody tr:nth-of-type(even) {
            background-color: #ffffff;
        }
        .search-area {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .search-box {
            display: flex;
            width: 100%;
            max-width: 400px;
        }
        .toggle-switch {
            display: flex;
            align-items: center;
            gap: 10px;
            color: #555;
            font-size: 14px;
        }
        .form-switch .form-check-input {
            width: 3em;
            height: 1.5em;
            background-color: #fff;
            border: 1px solid #ccc;
        }
        .form-switch .form-check-input:checked {
            background-color: #198754;
            border-color: #198754;
        }
    </style>
</head>

<body>
    <!-- Global Header -->
    <header>
        <%@ include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <div class="container-fluid px-5 mt-4 mb-5" style="min-height: 50vh;">
        <!-- Page Header & Breadcrumbs -->
        <div class="d-flex justify-content-between align-items-center mb-5">
            <h2 class="page-title text-uppercase">ATC ITI PHONE NUMBERS</h2>
            <div class="breadcrumb-text">Home / ATC ITI Phone Numbers</div>
        </div>

        <div style="background-color: #fff; padding-top: 10px;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 style="color: #444; font-size: 26px;">ATC ITI Phone Numbers</h3>
                <div class="text-muted" id="entries-info" style="font-size: 14px;">Showing 0 to 0 of 0 entries</div>
            </div>

            <!-- Controls -->
            <div class="search-area flex-column flex-md-row gap-3">
                <div class="search-box input-group">
                    <input type="text" id="searchInput" class="form-control" placeholder="Search by district, ITI name, code, or phone...">
                    <button class="btn btn-primary px-4" id="searchBtn">Search</button>
                </div>
                <div class="toggle-switch">
                    <span>Live Search:</span>
                    <div class="form-check form-switch m-0 p-0 d-flex align-items-center position-relative" style="padding-left: 3.5em !important; height: 100%;">
                        <input class="form-check-input m-0" type="checkbox" role="switch" id="liveSearchToggle" checked>
                    </div>
                    <span class="text-success ms-2" style="font-size: 13px;">Enable real-time filtering</span>
                </div>
            </div>

            <!-- Table -->
            <div class="table-responsive mt-3">
                <table class="table table-bordered table-striped" id="itiPhoneTable">
                    <thead>
                        <tr>
                            <th>Sl.<br>No.</th>
                            <th>District</th>
                            <th>ITI Type</th>
                            <th>ITI Code</th>
                            <th>NCVT Code</th>
                            <th>ITI Name</th>
                            <th>Contact<br>Number</th>
                            <th>ITI Email ID</th>
                        </tr>
                    </thead>
                    <tbody id="tableBody">
                        <tr>
                            <td colspan="8" class="text-center">Loading data...</td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- Global Footer -->
    <footer>
        <%@ include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            let allData = [];
            const tableBody = document.getElementById("tableBody");
            const searchInput = document.getElementById("searchInput");
            const searchBtn = document.getElementById("searchBtn");
            const liveSearchToggle = document.getElementById("liveSearchToggle");
            const entriesInfo = document.getElementById("entries-info");

            // Fetch Data from API
            fetch("${pageContext.request.contextPath}/api/atc-iti-phones", {
                method: "POST",
                headers: { "Content-Type": "application/json" }
            })
                .then(response => response.json())
                .then(data => {
                    console.log("ATC Phone Data Received:", data);
                    allData = data;
                    renderTable(allData);
                })
                .catch(error => {
                    console.error("Error fetching data: ", error);
                    tableBody.innerHTML = "<tr><td colspan='8' class='text-center text-danger'>Failed to load data.</td></tr>";
                });

            // Render Table
            function renderTable(dataToRender) {
                tableBody.innerHTML = "";
                if (dataToRender.length === 0) {
                    tableBody.innerHTML = "<tr><td colspan='8' class='text-center'>No matching records found</td></tr>";
                    entriesInfo.textContent = "Showing 0 entries";
                    return;
                }

                dataToRender.forEach((item, index) => {
                    const tr = document.createElement("tr");
                    tr.innerHTML = `
                        <td>\${index + 1}</td>
                        <td>\${item.district || ''}</td>
                        <td>\${item.itiType || ''}</td>
                        <td style="color: #2563eb; font-weight: bold;">\${item.itiCode || ''}</td>
                        <td style="color: #059669; font-weight: bold;">\${item.ncvtCode || ''}</td>
                        <td style="font-weight: 600;">\${item.itiName || ''}</td>
                        <td>\${item.contactNumber || ''}</td>
                        <td>\${item.itiEmailId || ''}</td>
                    `;
                    tableBody.appendChild(tr);
                });
                
                entriesInfo.textContent = `Showing 1 to \${dataToRender.length} of \${allData.length} entries`;
            }

            // Filter logic
            function applyFilter() {
                const term = searchInput.value.toLowerCase();
                const filtered = allData.filter(item => 
                    (item.district && item.district.toLowerCase().includes(term)) ||
                    (item.itiName && item.itiName.toLowerCase().includes(term)) ||
                    (item.itiCode && item.itiCode.toLowerCase().includes(term)) ||
                    (item.contactNumber && item.contactNumber.toLowerCase().includes(term)) ||
                    (item.itiEmailId && item.itiEmailId.toLowerCase().includes(term))
                );
                renderTable(filtered);
            }

            // Event Listeners
            searchBtn.addEventListener("click", applyFilter);
            
            searchInput.addEventListener("keyup", function(e) {
                if (liveSearchToggle.checked) {
                    applyFilter();
                } else if (e.key === "Enter") {
                    applyFilter();
                }
            });
            
            liveSearchToggle.addEventListener("change", function() {
                if (this.checked) {
                    applyFilter();
                }
            });
        });
    </script>
</body>

</html>
