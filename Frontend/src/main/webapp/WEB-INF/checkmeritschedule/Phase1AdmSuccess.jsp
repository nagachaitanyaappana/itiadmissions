<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<%@include file='/WEB-INF/legacy/header.jsp' %>
<%@include file='/WEB-INF/legacy/banner.jsp' %>
<%@include file='/WEB-INF/legacy/nav-login2.jsp' %>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <center>
            Candiate Admitted with Admission Number:${adm_num}<br><br>
            <a href="${pageContext.request.contextPath}/admissions/print-admission-slip" target="_blank;">Click here to PRINT ADMISSION SLIP</a>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <a href="${pageContext.request.contextPath}/AdmissionPhase">Click here to TAKE ANOTHER ADMISSION </a>
        </center>
    </body>
</html>
