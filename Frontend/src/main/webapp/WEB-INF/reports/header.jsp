<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal-theme.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal-pages.css">
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
    <%@ include file="../jsp/bannernew.jsp" %>
    <c:choose>
        <%-- logged-in: show the dashboard navbar matching the session role (same as authHome_*.jsp) --%>
        <c:when test="${not empty sessionScope.roleId}">
            <c:choose>
                <c:when test="${sessionScope.roleId eq 4 or sessionScope.roleId eq '4'}">
                    <%@ include file="../navbars/iti_navbar.jsp" %>
                </c:when>
                <c:when test="${sessionScope.roleId eq 3 or sessionScope.roleId eq '3'}">
                    <%@ include file="../navbars/district_navbar.jsp" %>
                </c:when>
                <c:when test="${sessionScope.roleId eq 10 or sessionScope.roleId eq '10'}">
                    <%@ include file="../navbars/nodal_navbar.jsp" %>
                </c:when>
                <%-- roleId 2 = Admin/State, and any other role falls back here --%>
                <c:otherwise>
                    <%@ include file="../navbars/state_navbar.jsp" %>
                </c:otherwise>
            </c:choose>
            <div class="news-marquee">
                <div class="marquee-content">
                    <img src="${pageContext.request.contextPath}/images/new.gif" alt="new" style="height: 20px;">
                    <span class="text-white">Welcome to AP ITI Admission Portal</span>
                    <span class="mx-3 text-white">|</span>
                    <img src="${pageContext.request.contextPath}/images/new.gif" alt="new" style="height: 20px;">
                    <span class="text-white">AP ITI అడ్మిషన్ పోర్టల్ కు స్వాగతం..</span>
                </div>
            </div>
        </c:when>
        <%-- anonymous visitors receive the same public navbar and welcome marquee as the homepage. --%>
        <c:otherwise>
            <c:if test="${empty hideNavbar or hideNavbar.toString() == 'false' or hideNavbar.toString() == '0'}">
                <%@ include file="../navbars/openNavbar.jsp" %>
                <div class="news-marquee">
                    <div class="marquee-content">
                        <img src="${pageContext.request.contextPath}/images/new.gif" alt="new" style="height: 20px;">
                        <span class="text-white">Welcome to AP ITI Admission Portal</span>
                        <span class="mx-3 text-white">|</span>
                        <img src="${pageContext.request.contextPath}/images/new.gif" alt="new" style="height: 20px;">
                        <span class="text-white">AP ITI అడ్మిషన్ పోర్టల్ కు స్వాగతం..</span>
                    </div>
                </div>
            </c:if>
        </c:otherwise>
    </c:choose>
