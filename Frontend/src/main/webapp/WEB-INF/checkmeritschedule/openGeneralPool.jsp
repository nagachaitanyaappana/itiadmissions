<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Open General Pool - AP ITI</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/all.min.css">
    <style>
        /* ---- Index / portal palette (mirrors ScheduleEntry.jsp) ---- */
        .page-header-custom {
            background-color: #e4eeb9;
            color: #000000;
            padding: 20px 0;
            margin-top: 15px;
            margin-bottom: 30px;
            border-bottom: 4px solid #b9c46d;
            box-shadow: 0 2px 4px rgba(0,0,0,0.05);
        }
        .form-card {
            border: 1px solid #b9c46d;
            border-radius: 20px;
            box-shadow: 0 8px 24px rgba(0,0,0,0.06);
            overflow: hidden;
            margin-bottom: 30px;
            background: #fff;
        }
        .card-header-primary {
            background-color: #e4eeb9;
            color: #000000;
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
            padding: 40px 30px;
            background-color: #fff;
            font-size: 1.15rem;
            font-weight: 600;
            color: #660000;
        }
        /* Footer colour - pale yellow-green (#e4eeb9) */
        .lower-footer {
            background-color: #e4eeb9 !important;
            color: #000000 !important;
        }
    </style>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/iti-portal.css">
</head>
<body>

    <jsp:include page="/WEB-INF/reports/header.jsp" />

    <div class="page-header-custom text-center">
        <div class="container">
            <h2 class="mb-0"><i class="fas fa-unlock-alt me-2"></i> General Pool</h2>
        </div>
    </div>

    <div class="container mb-5">
        <div class="row justify-content-center">
            <div class="col-lg-6">
                <div class="card form-card">
                    <div class="card-header-primary">
                        <i class="fas fa-info-circle"></i> General Pool
                    </div>
                    <div class="card-body card-body-custom text-center">
                        Please Open General Pool
                    </div>
                </div>
            </div>
        </div>
    </div>

<%@ include file="../footer.jsp" %>
</body>
</html>
