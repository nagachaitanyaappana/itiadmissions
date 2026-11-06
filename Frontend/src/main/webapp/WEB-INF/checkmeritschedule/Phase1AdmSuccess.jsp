<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
</head>
    <body class="legacy-success-page">
        <jsp:include page="/WEB-INF/reports/header.jsp" />
        <center>
            <c:set var="admNo" value="${empty adm_num ? sessionScope.adm_num : adm_num}" />
            Candiate Admitted with Admission Number:${admNo}<br><br>
            <c:choose>
                <c:when test="${not empty admNo}">
                    <a href="${pageContext.request.contextPath}/admissions/print-admission-slip?admissionNumber=${admNo}" target="_blank">Click here to PRINT ADMISSION SLIP</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/admissions/print-admission-slip" target="_blank">Click here to PRINT ADMISSION SLIP</a>
                </c:otherwise>
            </c:choose>
            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <a href="${pageContext.request.contextPath}/AdmissionPhase">Click here to TAKE ANOTHER ADMISSION </a>
        </center>
    </body>
</html>
