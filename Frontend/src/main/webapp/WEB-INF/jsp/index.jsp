<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <!DOCTYPE html>
    <html>

    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
        <title>AP ITI ADMISSIONS - 2026</title>
    </head>

    <body>
        <!-- Global Header Component (Includes banner, navbar, and marquee) -->
        <header>
            <%@ include file="header.jsp" %>
        </header>

        <!-- 5. Main Hero Section (Grid) -->
        <div class="container-fluid px-5 mt-4">
            <div class="row align-items-start">
                <!-- Column 1: Main Carousel & Profiles (div col-md-6) -->
                <div class="col-md-6">
                    <%@include file="carousel.jsp" %>

                        <!-- 6. Official Profiles Section -->
                        <div class="leader-profiles mt-4">
                            <div class="profile">
                                <img src="${pageContext.request.contextPath}/images/ap_cm.png" alt="Chief Minister"
                                    class="profile-img">
                                <h4><b>Sri Nara<br>Chandrababu Naidu</b></h4>
                                <p>Hon'ble Chief Minister</p>
                            </div>
                            <div class="profile">
                                <img src="${pageContext.request.contextPath}/images/ap_dcm.png"
                                    alt="Deputy Chief Minister" class="profile-img">
                                <h4><b>Sri Konidela<br>Pawan Kalyan</b></h4>
                                <p>Hon'ble Deputy Chief Minister</p>
                            </div>
                            <div class="profile">
                                <img src="${pageContext.request.contextPath}/images/it_min.png" alt="Minister"
                                    class="profile-img">
                                <h4><b>Sri Nara<br>Lokesh</b></h4>
                                <p>Hon'ble Minister<br>Information,Electronics & Communications</p>
                            </div>

                        </div>
                </div>

                <!-- Column 2: News & Updates (4 cols) -->
                <div class="col-md-3">
                    <div class="modern-card mb-4">
                        <div class="modern-news-header">
                            <h5><i class="fas fa-bullhorn me-2"></i>News & Updates</h5>
                        </div>
                        <div class="modern-news-body">
                            <div class="news-container">
                                <a href="${pageContext.request.contextPath}/GovtItiList" class="modern-news-item">
                                    <div class="modern-news-icon"><i class="fas fa-thumbtack"></i></div>
                                    <div class="modern-news-text">List of Government ITIs</div>
                                    <div class="modern-news-arrow"><i class="fas fa-angle-right"></i></div>
                                </a>
                                <a href="${pageContext.request.contextPath}/PrivateItiList" class="modern-news-item">
                                    <div class="modern-news-icon"><i class="fas fa-thumbtack"></i></div>
                                    <div class="modern-news-text">List of Private ITIs</div>
                                    <div class="modern-news-arrow"><i class="fas fa-angle-right"></i></div>
                                </a>
                                <a href="${pageContext.request.contextPath}/images/Apaar_guidelines.pdf" class="modern-news-item" target="_blank">
                                    <div class="modern-news-icon"><i class="fas fa-file-pdf"></i></div>
                                    <div class="modern-news-text">APAAR_ID Guidelines</div>
                                    <div class="modern-news-arrow"><i class="fas fa-angle-right"></i></div>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Column 3: Student Area -->
                <div class="col-md-3">
                    <div class="modern-card mb-4">
                        <div class="modern-student-header">
                            <div class="student-header-icon">
                                <i class="fas fa-graduation-cap"></i>
                            </div>
                            <div>
                                <div class="student-header-title">Student Area</div>
                                <div class="student-header-subtitle">Access your ITI services</div>
                            </div>
                        </div>
                        <div class="modern-student-body">
                            <a href="${pageContext.request.contextPath}/student-registration" class="modern-student-action">
                                <div class="action-icon-box icon-reg">
                                    <i class="fas fa-clipboard-list"></i>
                                </div>
                                <div class="action-text-box">
                                    <div class="action-title">Registration</div>
                                    <div class="action-desc">Create your account</div>
                                </div>
                                <div class="action-arrow"><i class="fas fa-angle-right"></i></div>
                            </a>
                            <a href="${pageContext.request.contextPath}/student-apply" class="modern-student-action">
                                <div class="action-icon-box icon-apply">
                                    <i class="fas fa-file-signature"></i>
                                </div>
                                <div class="action-text-box">
                                    <div class="action-title">Apply for ITI</div>
                                    <div class="action-desc">Submit your application</div>
                                </div>
                                <div class="action-arrow"><i class="fas fa-angle-right"></i></div>
                            </a>
                            <a href="${pageContext.request.contextPath}/student-edit-details" class="modern-student-action">
                                <div class="action-icon-box icon-edit">
                                    <i class="fas fa-pencil-alt"></i>
                                </div>
                                <div class="action-text-box">
                                    <div class="action-title">Edit Details</div>
                                    <div class="action-desc">Update your info</div>
                                </div>
                                <div class="action-arrow"><i class="fas fa-angle-right"></i></div>
                            </a>
                            <a href="${pageContext.request.contextPath}/forgot-regid" class="modern-student-action">
                                <div class="action-icon-box icon-forgot">
                                    <i class="fas fa-key"></i>
                                </div>
                                <div class="action-text-box">
                                    <div class="action-title">Forgot ID</div>
                                    <div class="action-desc">Recover your ID</div>
                                </div>
                                <div class="action-arrow"><i class="fas fa-angle-right"></i></div>
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>


        <!-- 7. Bottom Sections / Analytics (Optional for now) -->

        <!-- Global Footer Component -->
        <footer>
            <%@ include file="footer.jsp" %>
        </footer>
    </body>

    </html>