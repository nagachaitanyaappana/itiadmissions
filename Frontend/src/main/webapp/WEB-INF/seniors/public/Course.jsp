<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>Course Information - AP ITI Admissions</title>
    <style>
        .course-card {
            background-color: #fff;
            border: 1px solid #e0e0e0;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0,0,0,0.05);
            padding: 24px;
            margin-bottom: 24px;
        }
        .file-meta {
            color: #6c757d;
            font-size: 0.9rem;
            margin-bottom: 20px;
        }
        .file-badge {
            background-color: #f3e8ff;
            color: #7e22ce;
            padding: 2px 8px;
            border-radius: 4px;
            font-size: 0.8rem;
            font-weight: bold;
            display: inline-block;
            margin-right: 6px;
        }
        .search-container {
            background-color: #f8f9fa;
            border: 1px solid #e9ecef;
            border-radius: 6px;
            padding: 16px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }
        .table th {
            color: #495057;
            font-weight: 600;
            border-bottom-width: 2px;
        }
        .table td, .table th {
            vertical-align: middle;
            padding: 12px;
        }
    </style>
</head>

<body class="d-flex flex-column min-vh-100 bg-light">

    <!-- Global Header Component -->
    <header>
        <%@ include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <!-- Main Content -->
    <div class="container-fluid px-5 my-4 flex-grow-1">

        <!-- Page Title -->
        <div class="row mb-3">
            <div class="col-12">
                <h2 class="fw-bold" style="font-size: 1.8rem; color: #555;">Course Information</h2>
            </div>
        </div>

        <!-- Content -->
        <div class="row">
            <div class="col-12">
                <div class="course-card">
                    <h3 class="fw-bold mb-2">Course Details.</h3>
                    <div class="file-meta">
                        <span class="file-badge">XLSX</span> &middot; 10.8 KB &middot; Uploaded Aug 29, 2025
                    </div>

                    <!-- Search Section -->
                    <div class="search-container">
                        <input type="text" id="searchInput" class="form-control" placeholder="Search course data..." style="max-width: 400px;">
                        <button class="btn btn-success px-4" onclick="searchTable()">Search</button>
                        <button class="btn btn-secondary px-4" onclick="clearSearch()">Clear</button>
                    </div>

                    <div class="mb-3 text-muted">
                        Showing <strong id="rowCount">4</strong> rows
                    </div>

                    <div class="table-responsive">
                        <table class="table table-striped table-hover border" id="courseTable">
                            <thead class="table-light">
                                <tr>
                                    <th>Sl. No.</th>
                                    <th>Trade Code</th>
                                    <th>Trade</th>
                                    <th>Duration</th>
                                    <th>Trade Type</th>
                                    <th>Entry Qualification</th>
                                    <th>Minimum Age</th>
                                </tr>
                            </thead>
                            <tbody id="courseTableBody">
                                <!-- Data will be populated here via JavaScript API call -->
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </div>

    <!-- Global Footer Component -->
    <footer style="margin-top: auto;">
        <%@ include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

    <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
    <script>
        let allCourses = [];

        document.addEventListener('DOMContentLoaded', function() {
            fetchCourses();
        });

        function fetchCourses() {
            fetch("${pageContext.request.contextPath}/api/courses", {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' }
            })
                .then(response => response.json())
                .then(data => {
                    allCourses = data;
                    renderTable(allCourses);
                })
                .catch(error => console.error('Error fetching courses:', error));
        }

        function renderTable(courses) {
            const tbody = document.getElementById('courseTableBody');
            tbody.innerHTML = ''; // Clear previous data
            
            courses.forEach((course, index) => {
                const tr = document.createElement('tr');
                tr.innerHTML = `
                    <td>\${index + 1}</td>
                    <td>\${course.tradeCode || ''}</td>
                    <td>\${course.tradeName || ''}</td>
                    <td>\${course.duration || ''}</td>
                    <td>\${course.tradeType || ''}</td>
                    <td>\${course.entryQualification || ''}</td>
                    <td>\${course.minimumAge || ''}</td>
                `;
                tbody.appendChild(tr);
            });
            document.getElementById('rowCount').innerText = courses.length;
        }

        function searchTable() {
            const searchInput = document.getElementById('searchInput').value.toUpperCase();
            const filteredCourses = allCourses.filter(course => {
                return (course.tradeCode && course.tradeCode.toUpperCase().includes(searchInput)) ||
                       (course.tradeName && course.tradeName.toUpperCase().includes(searchInput)) ||
                       (course.duration && course.duration.toUpperCase().includes(searchInput)) ||
                       (course.tradeType && course.tradeType.toUpperCase().includes(searchInput)) ||
                       (course.entryQualification && course.entryQualification.toUpperCase().includes(searchInput)) ||
                       (course.minimumAge && course.minimumAge.toUpperCase().includes(searchInput));
            });
            renderTable(filteredCourses);
        }

        function clearSearch() {
            document.getElementById('searchInput').value = '';
            renderTable(allCourses);
        }

        document.getElementById('searchInput').addEventListener('keypress', function(event) {
            if (event.key === 'Enter') {
                event.preventDefault();
                searchTable();
            }
        });
    </script>
</body>

</html>
