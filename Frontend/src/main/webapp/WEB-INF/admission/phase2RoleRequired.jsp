<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8" />
<title>:: ITI :: Admission Process</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<style>
  .notice { max-width: 620px; margin: 48px auto; padding: 20px; border: 1px solid #7a7a7a; text-align: center; }
  .notice h2 { color: #0E4878; }
</style>
</head>
<body>
<%@ include file="/WEB-INF/reports/header.jsp" %>
<div class="notice">
  <h2>Phase 2 Admission</h2>
  <p><c:out value="${phase2RoleMessage}" /></p>
</div>
</body>
</html>
