<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<%@page import="java.util.List"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
	String jwtToken = (String) session.getAttribute("jwtToken");
System.out.println("jwtToken=>" + jwtToken);

String roleId = (String) session.getAttribute("roleId");
System.out.println("roleId=>" + roleId);

String insCode = (String) session.getAttribute("insCode");
System.out.println("insCode=>" + insCode);

String username = (String) session.getAttribute("username");
System.out.println("username=>" + username);

String insName = (String) session.getAttribute("insName");
System.out.println("insName=>" + insName);

%>
<!DOCTYPE html>
<html>
<head>
<title>ITI Login Success</title>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<script>
	$(document).ready(function(){
		   //alert("ready");
		   var jwtToken = '<%=jwtToken%>';
		   var roleId = '<%=roleId%>';
		   var insCode = '<%=insCode%>';
		   var username = '<%=username%>';
		   var insName = '<%=insName%>';
		//alert("jwtToken=>"+jwtToken);

		// Storing a variable in localStorage
		localStorage.setItem('jwtToken', jwtToken);
		localStorage.setItem('roleId', roleId);
		localStorage.setItem('insCode', insCode);
		localStorage.setItem('username', username);
		localStorage.setItem('insName', insName);

	});
</script>
</head>
<body>
<%-- 	<%@include file="/WEB-INF/seniors/bannernew.jsp"%> --%>
	<%@include file="/WEB-INF/seniors/bannernew.jsp"%>
	<%@include file="/WEB-INF/seniors/openNavbar.jsp"%>




<%@include file="/WEB-INF/seniors/footer.jsp"%>
</body>
</html>