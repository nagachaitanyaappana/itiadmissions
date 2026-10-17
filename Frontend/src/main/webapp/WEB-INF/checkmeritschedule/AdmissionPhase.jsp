<%@ page contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@include file='/WEB-INF/legacy/header.jsp' %>
<html>
    <body>
        <jsp:include page="/WEB-INF/reports/header.jsp" />
        <form action="${pageContext.request.contextPath}/AdmissionPhase/itiAdmissionEntry" method="post" id="startForm">
            <c:choose>
                <c:when test="${phase == '1'}">
            <p align="center">
                &nbsp;</p>
            <p align="center">
                <font size="6" color="#008000"> <b>
                        <font size="5" color="#800080" face="Segoe UI Light">To Start Admission Process Select all the following.</font></b></font></p>
            <font size="6" color="#008000">
                <table border="1" align=center width="307">
                    <tr>
                        <td width="191">
                            <font color="#800000" face="Constantia" size="4"><b>Caste
                                    :</b></font></td>
                        <td width="100">
                            <select name="caste_perform" id="caste_perform">
                                <c:forEach var="c" items="${casteOptions}">
                                    <option value="${c.casteCode}">${c.casteName}</option>
                                </c:forEach>
                                <option value="all" selected>all</option>
                                <option value="w">Women</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td width="191">
                            <font color="#800000" face="Constantia" size="4"><b>Qualification
                                    :</b></font></td>
                        <td width="100">
                            <select name="qual_perform" id="qual_perform">
                                <option value="all">all</option>
                                <option value="assc">Intermediate</option>
                            </select>
                        </td>
                    </tr>
                    <tr>
                        <td width="191">
                            <font color="#800000" face="Constantia" size="4"><b>Admission Timings
                                    :</b></font></td>
                        <td width="100">
                            <select name="adm_perform" id="adm_perform">
                                <c:forEach var="t" items="${timingOptions}">
                                    <option value="${t}">${t}</option>
                                </c:forEach>
                            </select>
                        </td>
                    </tr>
                </table>
            </font>
            <center> <input type="submit" value="Submit" />
                    <br></br><font color="red">
                        <b>${errorMsg}</b>
                    </b>
                </font></center>
                </c:when>
                <c:otherwise>
                    <center><h2>Admission Date is Expired</h2></center>
                </c:otherwise>
            </c:choose>
            </form>
        <font size="6" color="#008000">
            <div id="sub">
            </div>
            <%@include file='/WEB-INF/legacy/footer.jsp' %>
    </body>
</html>
