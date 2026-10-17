<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">
<%@include file='/WEB-INF/legacy/header.jsp' %>
<jsp:include page="/WEB-INF/reports/header.jsp" />

<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
        <script type="text/javascript">
            // Mirrors legacy onRadioClick(): fetches the permitted shift/unit rows for the
            // chosen (iti, trade) and injects them into the hidden #shiftUnitBorder table.
            function onRadioClick(value) {
                $('#shiftUnitBorder').hide();
                var parts = value.split("+");
                var itiCode = parts[1];
                var tradeCode = parts[2];
                $.ajax({
                    type: 'get',
                    url: '${pageContext.request.contextPath}/AdmissionPhase/shift-unit',
                    data: { itiCode: itiCode, tradeCode: tradeCode },
                    success: function (response) {
                        $('#shiftUnitBorder').show();
                        $('#result').html(response);
                    },
                    error: function (xhr, status, error) {
                        console.error("Error occurred:", error);
                        alert("Error occurred while calling API.");
                    }
                });
            }

            // Mirrors legacy validateRadioSelection(): a shift/unit row must be chosen.
            function validateRadioSelection() {
                var selected = document.querySelector('input[name="selectedRadio"]:checked');
                if (!selected) {
                    alert("Please select at least one Shift Unit Option.");
                    return false;
                }
                return true;
            }
        </script>
    </head>
    <body>

    <center><h3>ITI Admissions For AUGUST, ${student.year_of_admission}</h3></center><br/>
    <center><font color="red">${errorMsg}</font></center>

    <form action="${pageContext.request.contextPath}/AdmissionPhase/take-admission" method="post"
          onsubmit="return validateRadioSelection();">

        <input type="hidden" name="regid" value="${student.regid}" />
        <input type="hidden" name="caste_name" value="${student.caste}" />

        <table align="center" width="800" border="1" bgcolor="#E3E4FA">
            <tr>
                <td colspan='2'>
                    <img src="${pageContext.request.contextPath}/AdmissionPhase/photo/${student.regid}"/>
                </td>
                <td>
                    <input type="file" name="pic"/>
                </td>
            </tr>
            <tr>
                <th align="left" width="164">Name</th>
                <td width="160">${student.name}</td>
                <th align="left" width="164">Father Name</th>
                <td width="160">${student.fname}</td>
            </tr>
            <tr>
                <th align="left">Community</th>
                <td>
                    <select name="caste_name_select" id="caste_name">
                        <option value="${student.caste}">${student.caste}</option>
                        <c:forEach var="c" items="${casteOptions}">
                            <option value="${c.casteCode}">${c.casteName}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr>
                <th align="left">Gender</th>
                <td>${student.gender}</td>
                <th align="left">DOB</th>
                <td>${student.dob}</td>
            </tr>
            <tr>
                <th align="left">Rank </th>
                <td>${student.rank}</td>
                <th align="left">Reg No </th>
                <td>${student.regid}</td>
            </tr>
            <tr>
                <th align="left">Physically Challenged </th>
                <td>${student.phc}</td>
                <th align="left">Exservice</th>
                <td>${student.exservice}</td>
            </tr>
            <tr>
                <th align="left">Academic Year</th>
                <td>${student.year_of_admission}</td>
            </tr>
            <tr>
                <th align="left">Email Id</th>
                <td>${student.email_id}</td>
            </tr>
            <tr>
                <th align="left">Economic Weaker Section</th>
                <td>${student.ews}</td>
                <th align="left">Pwd Category</th>
                <td>${student.pwd_category}</td>
            </tr>
        </table>

        <br/>

        <%-- Seat matrix: columns are driven by the backend "layout", reproducing whichever of the
             16 legacy table variants (general/reservation x male/female x phc x exservice) matches
             this candidate. The green #BCE954 highlight marks the column whose check_code equals the
             row's check (vacancy precedence). --%>
        <table width="900" border="1" align="center" bgcolor="#E3E4FA">
            <tr>
                <th width="300">ITI Name</th>
                <th width="300">Trade Name </th>
                <th width="14">&nbsp;</th>
                <th width="68">Total Strength</th>
                <c:forEach var="col" items="${layout}">
                    <th width="120">${col.label}
                        <table width="120" border="1">
                            <tr>
                                <td width="40">T</td>
                                <td width="40">F</td>
                                <td width="40">V</td>
                            </tr>
                        </table>
                    </th>
                </c:forEach>
            </tr>
            <c:forEach var="row" items="${seat_matrix}">
                <tr>
                    <c:choose>
                        <c:when test="${row.check_name == 0}">
                            <th align="left">${row.iti_name}</th>
                        </c:when>
                        <c:otherwise>
                            <th align="left">&nbsp;</th>
                        </c:otherwise>
                    </c:choose>
                    <th align="left">${row.trade_name}</th>
                    <th>
                        <c:choose>
                            <c:when test="${row.check == 0}">
                                <input type="radio" name="trade_code" disabled="true"
                                       value="${row.iti_name}+${row.iti_code}+${row.trade_code}+${row.check}" />
                            </c:when>
                            <c:otherwise>
                                <input type="radio" name="trade_code"
                                       value="${row.iti_name}+${row.iti_code}+${row.trade_code}+${row.check}"
                                       onclick="onRadioClick(this.value)" />
                            </c:otherwise>
                        </c:choose>
                    </th>
                    <th>${row.total_strength}</th>
                    <c:forEach var="col" items="${layout}">
                        <th>
                            <table width="120" border="1">
                                <tr <c:if test="${row.check == col.check_code}">bgcolor="#BCE954"</c:if>>
                                    <td width="40">${row[col.strength]}</td>
                                    <td width="40">${row[col.fill]}</td>
                                    <td width="40">${row[col.vacant]}</td>
                                </tr>
                            </table>
                        </th>
                    </c:forEach>
                </tr>
            </c:forEach>
        </table>

        <table align="center" border="1">
            <tr>
                <td><b><font color="#800080" face="Corbel">Identification marks : </font></b></td>
                <td><textarea name="idmarks1"></textarea></td>
                <td><b><font color="#800080" face="Corbel">Identification marks : </font></b></td>
                <td><textarea name="idmarks2"></textarea></td>
            </tr>
            <tr>
                <td><b><font color="#800080" face="Corbel">SSc Reg Number : </font></b></td>
                <td><input type="text" name="ssc_regno" /></td>
                <td><b><font color="#800080" face="Corbel">SSC Board : </font></b></td>
                <td>
                    <select name="ssc_board" class="style99">
                        <c:forEach var="b" items="${sscBoards}">
                            <option value="${b.board_code}">${b.board_name}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
            <tr>
                <td><b><font color="#800080" face="Corbel">SSC year of Pass : </font></b></td>
                <td>
                    <select name="ssc_year">
                        <c:forEach var="y" items="${sscYears}">
                            <option value="${y}">${y}</option>
                        </c:forEach>
                    </select>
                </td>
                <td><b><font color="#800080" face="Corbel">SSC Month of Pass : </font></b></td>
                <td>
                    <select name="ssc_month">
                        <option value="03">---Select --</option>
                        <option value="03">March</option>
                        <option value="03">Supplymentary</option>
                    </select>
                </td>
            </tr>
            <tr>
                <td><b><font color="#800080" face="Corbel">Type of Examination : </font></b></td>
                <td>
                    <select name="type_admission" class="style2" required="true">
                        <c:forEach var="bd" items="${itiBoards}">
                            <option value="${bd.board_code}">${bd.board_name}</option>
                        </c:forEach>
                    </select>
                </td>
            </tr>
        </table>

        <table border="1" id="shiftUnitBorder" style="display: none; margin: 0 auto;">
            <thead>
                <tr>
                    <th></th>
                    <th>Shift</th>
                    <th>Unit</th>
                    <th>Strength</th>
                    <th>Strength Vacant </th>
                </tr>
            </thead>
            <tbody id="result"></tbody>
        </table>
        <br/>
        <center><input type="submit" name="takeAdmission" value="Take Admission" /></center>
    </form>
    </body>
</html>
