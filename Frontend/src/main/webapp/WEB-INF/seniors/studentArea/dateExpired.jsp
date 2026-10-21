<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Registration Closed | ITI Admission Portal</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        .expired-container {
            min-height: 60vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .expired-card {
            max-width: 600px;
            width: 100%;
            padding: 40px;
            background: white;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0,0,0,0.08);
            text-align: center;
            border-top: 5px solid #ef4444;
        }
        .expired-icon {
            font-size: 4rem;
            color: #ef4444;
            margin-bottom: 20px;
            animation: bounce 2s infinite;
        }
        @keyframes bounce {
            0%, 20%, 50%, 80%, 100% {transform: translateY(0);}
            40% {transform: translateY(-10px);}
            60% {transform: translateY(-5px);}
        }
        .expired-title {
            font-size: 1.8rem;
            font-weight: 800;
            color: #1e3a8a;
            margin-bottom: 15px;
        }
        .expired-text {
            color: #64748b;
            font-size: 1.1rem;
            line-height: 1.6;
            margin-bottom: 30px;
        }
        .btn-home {
            background-color: #1e3a8a;
            color: white;
            padding: 12px 30px;
            font-weight: 700;
            border-radius: 6px;
            text-decoration: none;
            transition: 0.3s;
        }
        .btn-home:hover {
            background-color: #1e40af;
            color: white;
            transform: translateY(-2px);
        }
    </style>
</head>
<body style="background-color: #f8fafc;">

    <header>
        <%@include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <main>
        <div class="container expired-container">
            <div class="expired-card">
                <div class="expired-icon">
                    <i class="fas fa-calendar-times"></i>
                </div>
                <h1 class="expired-title">Admission Period Closed</h1>
                <p class="expired-text">
                    The online registration and application period has either expired or is not yet active for the current phase. 
                    Please keep checking the official notifications for the next admission dates.
                </p>
                <a href="${pageContext.request.contextPath}/" class="btn-home">
                    <i class="fas fa-home me-2"></i> Back to Home
                </a>
            </div>
        </div>
    </main>

    <footer>
        <%@include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

</body>
</html>
