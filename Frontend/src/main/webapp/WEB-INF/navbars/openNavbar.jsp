<%@ page language="java" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- ===================================================================
     Home page & public navigation bar (Centered with mx-auto).
     =================================================================== --%>
<nav class="navbar navbar-expand-lg custom-navbar">
    <div class="container-fluid">
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#mainNav" aria-controls="mainNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="mainNav">
            <ul class="navbar-nav nav-menu mx-auto">
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/">Home</a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="itiProfileDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        ITI Profile
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="itiProfileDropdown">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/iti-profile">ITI Profile</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/iti-list">ITI LIST</a></li>
                    </ul>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" id="striveDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                        STRIVE
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="striveDropdown">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/about-strive">ABOUT STRIVE</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/reports/disclosure-management">Disclosure Management</a></li>
                    </ul>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/Login">Login</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="https://itiadmissions.ap.gov.in/placementsfe/">PLACEMENTS / IN-PLANT TRAINING</a>
                </li>
            </ul>
        </div>
    </div>
</nav>
