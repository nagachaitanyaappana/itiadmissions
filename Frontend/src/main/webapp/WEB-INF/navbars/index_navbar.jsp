<%@ page language="java" pageEncoding="UTF-8" %>
<%-- ===================================================================
     Shared PUBLIC navbar (the short, index-style #menu-bar).
     =================================================================== --%>
<ul id="menu-bar">
    <li><a href="${pageContext.request.contextPath}/">Home</a></li>
    <li class="dropdown">
        <a href="javascript:void(0)">ITI Profile</a>
        <div class="dropdown-content">
            <a href="${pageContext.request.contextPath}/reports/iti-profile">ITI Profile</a>
            <a href="${pageContext.request.contextPath}/reports/iti-list">ITI LIST</a>
        </div>
    </li>
    <li>
        <a href="javascript:void(0)">STRIVE</a>
        <ul>
            <li><a href="${pageContext.request.contextPath}/reports/about-strive">ABOUT STRIVE</a></li>
            <li><a href="${pageContext.request.contextPath}/reports/disclosure-management">Disclosure Management</a></li>
        </ul>
    </li>
</ul>

