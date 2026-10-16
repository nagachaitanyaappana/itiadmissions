<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<%@include file='/WEB-INF/legacy/header.jsp' %>
<%@include file='/WEB-INF/legacy/banner.jsp' %>
<%@include file='/WEB-INF/legacy/nav-login2.jsp' %>

<html>
    <head>
        <script language="javascript" type="text/javascript">
            function checkRange() {
                //var rank='';
                var min = document.getElementById("min").value * 1;
                var max = document.getElementById("max").value * 1;
                val = document.getElementById("rank").value * 1;
                if (val < min || val > max) {
                    alert("Please Enter valid Rank and It should between '" + min + "' and '" + max + "'");
                    document.getElementById("rank").value = "";
                    document.getElementById("rank").focus();
                    return false;
                }
                return true;
            }
            function NumericsOnly(evt)
            {
                var charCode = (evt.which) ? evt.which : event.keyCode

                if ((charCode > 31 && (charCode < 48 || charCode > 57)))
                {
                    alert("Please Enter Numaric Values");
                    return false;
                }


                return true;
            }
        </script>
    </head>
    <body>
        <form action="districtAdmissionProcessOptimise" method="post" onsubmit="return err(this); ">

        <center><h1>Admission Counseling</h1><font color="red">${errorMsg}</font></center>
        <table width="400" border="0" align="center" >
            <tr>
                <th width="333">Date:  ${currentDate}</th>
                <th width="500">Ranks for counseling : ${merit_from} to ${merit_to} </th>
            </tr>
            <tr>
                <th width="333">Caste ${caste_perform}</th>
                <th width="331">Qualification ${qual_perform}</th>
            </tr>
            <tr>
                <th width="333" colspan="2">Call Time ${adm_perform}</th>
            </tr>
        </table><br/>

        <input type="hidden" name="currentDate" value="${currentDate}" />
        <input type="hidden" name="merit_from" id="min" value="${merit_from}" />
        <input type="hidden" name="merit_to" id="max" value="${merit_to}" />
        <input type="hidden" name="caste_perform" value="${caste_perform}" />
        <input type="hidden" name="qual_perform" value="${qual_perform}" />
        <input type="hidden" name="adm_perform" value="${adm_perform}" />
        <table width="276" border="1"  align="center" bgcolor="">
            <tr>
                <td width="87">Enter Rank </td>
                <td width="173"><input type="text"  name="rank" id="rank" size="20" maxlength="5" autofocus="true" onkeypress="return NumericsOnly(event);"/></td>
            </tr>

            <tr>
                <td colspan="2"> <span id="messg">&nbsp;</span></td>
            </tr>
            <tr>
                <td width="87" colspan="2" align="center" ><input type="submit" value="submit" onclick=" return checkRange();" /></td>
            </tr>
        </table>

    </form>
</body>
</html>
