<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<%@include file='/WEB-INF/legacy/header.jsp' %>
<jsp:include page="/WEB-INF/reports/header.jsp" />
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
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
