<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <title>About STRIVE - AP ITI</title>
    </head>

    <body class="d-flex flex-column min-vh-100">

        <!-- Global Header Component (Includes banner, navbar, and marquee) -->
        <%@ include file="/WEB-INF/seniors/header.jsp" %>

                <!-- 4. Main Content (About STRIVE) -->
                <div class="container-fluid px-5 my-5 flex-grow-1">
                    <div class="row mb-4">
                        <div class="col-12 text-center">
                            <h5 class="fw-bold text-decoration-underline"
                                style="font-family: 'Times New Roman', Times, serif; font-size: 1.3rem; color: #000;">
                                Skills Strengthening of Industrial Value Enhancement (STRIVE) Project in State of Andhra
                                Pradesh
                            </h5>
                        </div>
                    </div>

                    <div class="row justify-content-center">
                        <div class="col-12 col-lg-10"
                            style="font-family: 'Times New Roman', Times, serif; font-size: 1.15rem; color: #000; line-height: 1.8;">
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>Objective of the scheme is to improve the relevance and efficiency of skills
                                    Training provided through Industrial Training Institutes (ITIs) and Apprenticeships,
                                    duly upgrading the infrastructure, equipment and machinery.</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>STRIVE is a Central Sector Scheme with no State Contribution, assisted by World
                                    Bank.</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>It is a 5 Year Project , closing by November 2022.</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>STRIVE Scheme has four result areas.</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>Result Area 1 - Improved Performance of ITIs</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>Result Area 2 - Increased Capacities of State Governments to support ITIs and
                                    Apprenticeship Training</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>Result Area 3 - Improved Teaching and Learning</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>Result Area 4 - Improved and Broadened Apprenticeship Training.</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>15 Govt. ITIs have been selected under the scheme and Institute Management
                                    Committees are also constituted in these ITIs.</div>
                            </div>
                            <div class="d-flex mb-3">
                                <span class="me-2">&#9658;</span>
                                <div>Govt. of A.P have made an Agreement (Performance Based Fund Agreement ) with Govt.
                                    of India in Feb 2019 accepting terms and Conditions of the Project.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Global Footer Component -->
                <%@ include file="/WEB-INF/seniors/footer.jsp" %>
    </body>

    </html>