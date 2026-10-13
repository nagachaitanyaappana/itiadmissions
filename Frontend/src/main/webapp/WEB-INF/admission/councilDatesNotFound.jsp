<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Council Dates Not Found</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<style>
  .page-title { text-align:center; font-family:Verdana,Arial,sans-serif; font-size:22px; margin:18px 0 12px; color:#000; }
  .notice-box { width:600px; margin:0 auto 60px; border:1px solid #7a7a7a; background:#fff; }
  .notice-box table { width:100%; border-collapse:collapse; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .notice-box td { border:1px solid #7a7a7a; padding:14px 16px; }
  .notice-head { background:#e4eeb9; font-weight:bold; text-align:center; font-size:15px; }
  .notice-msg { color:#a00; font-weight:bold; text-align:center; }
  #footer { position:fixed; bottom:0; width:100%; padding:8px; text-align:center; background:#0E4878; font-size:12px; color:#fff; font-family:arial,verdana; }
  #footer a { color:#fff; }
</style>
</head>
<body>
<br/>
<c:choose>
  <c:when test="${not empty sessionScope.roleId}"><%@ include file="/WEB-INF/reports/header.jsp" %></c:when>
  <c:otherwise><%@ include file="/WEB-INF/bannernew.jsp" %><%@ include file="/WEB-INF/navbars/openNavbar.jsp" %></c:otherwise>
</c:choose>

<div class="page-title">Start Admission Process</div>

<div class="notice-box">
  <table>
    <tr><td class="notice-head">Council Dates Not Found</td></tr>
    <tr><td class="notice-msg">No counselling schedule is available for today.</td></tr>
    <tr><td style="text-align:center;">
      Admission cannot be processed until the district publishes a schedule entry for the current date.
      Please create a Schedule Entry for today and try again.
    </td></tr>
    <tr><td style="text-align:center;">
      <a href="${pageContext.request.contextPath}/AdmissionCounseling/Start">&laquo; Back to Start Admission Process</a>
    </td></tr>
  </table>
</div>

<div id="footer">2013 @ All Rights Reserved&nbsp;&nbsp; Designed by&nbsp;&nbsp; National Informatics Center <a href="http://www.ap.nic.in">National Informatics Center</a>&nbsp;&nbsp;&nbsp;&nbsp; <a href="#">Disclaimer</a></div>
</body>
</html>
