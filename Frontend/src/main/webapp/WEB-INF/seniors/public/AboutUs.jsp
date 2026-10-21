<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>

<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <title>About Us - AP ITI Admissions</title>
</head>

<body class="d-flex flex-column min-vh-100">

    <!-- Global Header Component -->
    <header>
        <%@ include file="/WEB-INF/seniors/header.jsp" %>
    </header>

    <!-- Main Content -->
    <div class="container-fluid px-5 my-5 flex-grow-1">

        <!-- Page Title -->
        <div class="row mb-3">
            <div class="col-12">
                <h2 class="fw-bold" style="font-size: 2rem; color: #111; letter-spacing: 1px; text-transform: uppercase;">About Us</h2>
                <hr style="border-top: 2px solid #ccc; margin-top: 8px;">
            </div>
        </div>

        <!-- Content -->
        <div class="row justify-content-start">
            <div class="col-12 col-lg-11">
                <ul style="list-style-type: circle; font-family: 'Times New Roman', Times, serif; font-size: 1.1rem; color: #000; line-height: 1.9; padding-left: 20px;">

                    <li class="mb-3">
                        Government of Andhra Pradesh has accorded permission to the Department of Employment and Training, AP,
                        to conduct online admissions into all the Government ITIs, Private ITIs and other affiliated Industrial
                        Training Institutes in the State, in accordance with the Admission Calendar issued by the Directorate
                        General of Training (DGT), New Delhi under the Ministry of Skill Development and Entrepreneurship,
                        Government of India. Accordingly, the Department releases admission notifications once in a year to
                        facilitate admissions for eligible candidates into ITIs through an online system.
                    </li>

                    <li class="mb-3">
                        Further, the Government has taken initiatives to modernize Industrial Training Institutes by upgrading
                        infrastructure, introducing industry-oriented courses and enhancing skill development programs to meet
                        the requirements of present-day industries and to improve the employability of youth in the State.
                    </li>

                    <li class="mb-3">
                        The Industrial Training Institutes impart training through the Craftsman Training Scheme (CTS), which
                        was introduced in the year 1950 by the Government of India to ensure a steady flow of skilled workers
                        in different trades for the domestic industry.
                    </li>

                    <li class="mb-3">
                        The Industrial Training Institutes play a vital role in the economy of the State, especially in
                        providing skilled manpower for industries. These institutes are established to ensure a continuous
                        supply of trained workers in various trades, to enhance industrial productivity both quantitatively
                        and qualitatively, to reduce unemployment among educated youth by providing employable skills, and to
                        develop a technical and industrial attitude among the younger generation.
                    </li>

                    <li class="mb-3">
                        During the training period, about 70% of the curriculum is allotted to Trade Practical and the
                        remaining to theoretical subjects such as Trade Theory, Workshop Calculation &amp; Science,
                        Engineering Drawing and Employability Skills, ensuring a balanced development of practical and
                        theoretical knowledge among trainees.
                    </li>

                </ul>
            </div>
        </div>

    </div>

    <!-- Global Footer Component -->
    <footer>
        <%@ include file="/WEB-INF/seniors/footer.jsp" %>
    </footer>

</body>

</html>
