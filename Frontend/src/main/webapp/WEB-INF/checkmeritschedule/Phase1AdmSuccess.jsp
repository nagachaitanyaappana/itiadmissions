<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Admission Successful | AP ITI Admissions</title>
        <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
    <body class="legacy-success-page">
        <jsp:include page="/WEB-INF/reports/header.jsp" />
        <c:set var="admNo" value="${empty adm_num ? sessionScope.adm_num : adm_num}" />
        <main class="success-panel">
            <div class="text-success mb-3" style="font-size:2.5rem;" aria-hidden="true">
                <i class="fas fa-check-circle"></i>
            </div>
            <h1 class="h3 fw-bold" style="color:#003366;">Admission completed successfully</h1>
            <p class="text-muted mb-2">The candidate has been admitted successfully.</p>
            <p class="fs-5 mb-4">Admission Number: <strong>${admNo}</strong></p>
            <div class="d-flex flex-wrap justify-content-center gap-3">
                <c:choose>
                    <c:when test="${not empty admNo}">
                        <a class="btn btn-primary px-4" href="${pageContext.request.contextPath}/admissions/print-admission-slip?admissionNumber=${admNo}" target="_blank" rel="noopener">Print Admission Slip</a>
                    </c:when>
                    <c:otherwise>
                        <a class="btn btn-primary px-4" href="${pageContext.request.contextPath}/admissions/print-admission-slip" target="_blank" rel="noopener">Print Admission Slip</a>
                    </c:otherwise>
                </c:choose>
                <a class="btn btn-outline-primary px-4" href="${pageContext.request.contextPath}/AdmissionPhase">Take Another Admission</a>
            </div>
        </main>
    </body>
</html>
