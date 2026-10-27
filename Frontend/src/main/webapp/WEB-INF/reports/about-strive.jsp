<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>:: STRIVE ::</title>
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
        /* STRIVE content text */
        .text1{font-size:20px;padding-left:65px;}
        .text1 p:before{content:'\25BA ';}
        p:before{content:'\25BA ';}
    </style>
    <script type="text/javascript" src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
<body>
    <header>
        <%@ include file="../jsp/header.jsp" %>
    </header>

    <div class="container my-4">
        <h4 class="text-primary text-center mb-4">Skills Strengthening of Industrial Value Enhancement (STRIVE) Project</h4>

        <div class="card shadow-sm">
            <div class="card-body">
                <h5 class="card-title text-center fw-bold text-primary">
                    Skills Strengthening of Industrial Value Enhancement (STRIVE) Project in State of Andhra Pradesh
                </h5>
                <div class="text1">
                    <p>Objective of the scheme is to improve the relevance and efficiency of skills Training provided through Industrial Training Institutes (ITIs) and Apprenticeships, duly upgrading the infrastructure, equipment and machinery.</p>
                    <p>STRIVE is a Central Sector Scheme with no State Contribution, assisted by World Bank.</p>
                    <p>It is a 5 Year Project, closing by November 2022.</p>
                    <p>STRIVE Scheme has four result areas.</p>
                    <p>Result Area 1 - Improved Performance of ITIs</p>
                    <p>Result Area 2 - Increased Capacities of State Governments to support ITIs and Apprenticeship Training</p>
                    <p>Result Area 3 - Improved Teaching and Learning</p>
                    <p>Result Area 4 - Improved and Broadened Apprenticeship Training.</p>
                    <p>15 Govt. ITIs have been selected under the scheme and Institute Management Committees are also constituted in these ITIs.</p>
                    <p>Govt. of A.P have made an Agreement (Performance Based Fund Agreement) with Govt. of India in Feb 2019 accepting terms and Conditions of the Project.</p>
                </div>
            </div>
        </div>
    </div>

    <script>
    // Show popup on page load
    window.onload = function () {
        var popup = document.getElementById("airforcePopup");
        if (popup) {
            popup.style.display = "block";
            setTimeout(function () {
                popup.style.display = "none";
            }, 10000);
        }
    };

    function closeAirforcePopup() {
        var popup = document.getElementById("airforcePopup");
        if (popup) {
            popup.style.display = "none";
        }
    }
    </script>

    <%@ include file="../footer.jsp" %>
</body>
</html>
