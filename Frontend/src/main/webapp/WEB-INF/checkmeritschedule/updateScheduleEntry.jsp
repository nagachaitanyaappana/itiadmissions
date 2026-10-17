<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isELIgnored="true" %>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title> Update Schedule Entry</title>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/bootstrap.min.css">
<script src="<%= request.getContextPath() %>/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/all.min.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
<link rel="stylesheet" href="<%= request.getContextPath() %>/css/iti-portal.css">
<script type="text/javascript" src="<%= request.getContextPath() %>/js/jquery.min.js"></script>
<jsp:include page="/WEB-INF/jsp/_api_base_url.jsp"/>
<%-- Session role/institution scope. The old gate read localStorage 'jwtToken', which
     nothing in this application sets, so every visitor fell into the "not authorized"
     branch; the other checkmeritschedule pages read the HTTP session instead. --%>
<%
    Object sessionRoleId = session.getAttribute("roleId");
    String jsRoleId = sessionRoleId == null ? "" : String.valueOf(sessionRoleId).replace("'", "\\'");
%>
<script type="text/javascript">
    const SESSION_ROLE_ID = '<%= jsRoleId %>';
</script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/siteScript.js"></script>
<script type="text/javascript" src="<%= request.getContextPath() %>/js/customJs/updateScheduleEntry.js"></script>
</head>
<body onload="generateCaptcha(),getReady();">
	<div id="404Msg" align="center" style="display:none;">
				<img src="<%= request.getContextPath() %>/images/gen.jpg" class="img-fluid" />
				<%@include file="../navbars/openNavbar.jsp"%>
	</div>
	<div id="navbar">
		<%@include file="/WEB-INF/bannernew.jsp"%>
		<%@include file="/WEB-INF/checkmeritschedule/authNavbar.jsp"%>
	</div>

	<br>
	<div class="row m-1">
			<div class="col-12 text-center" id="currentphase" >
			</div>
		</div>

	  <div align="center">

            <div class="container mt-2 mb-4 border font-weight-bolder  shadow-lg"
                 style="background-color: #e6ffff; border-radius: 20px;">


                    <div class="row align-items-center m-2">
                        <div class="col-12">
                            <h6 class="h6 font-weight-bolder text-primary ">Update Schedule Entry Timings</h6>
                        </div>
                    </div>

                    <div class="row align-items-center m-2">
                        <div class="col-2">
                            <label for="monthYear" class="col-form-label float-right">District Name:</label>
                        </div>

                        <div class="col-4">
                            <select name="addrs_state_p"
                                    class="stateclass form-control"
                                    id="addrs_state_p" onchange="return getColleges();">
                                <option value="all">--SELECT--</option>

                            </select>
                             <span id="districtError" class="text-danger"></span>
                        </div>
                    </div>
                    <div class="row align-items-center m-2">
                        <div class="col-2">
                            <label for="monthYear" class="col-form-label float-right">Government/Private Type</label>
                        </div>

                        <div class="col-4">
                            <select name="addrs_district_p" class="distclass form-control" id="addrs_district_p"
                                    onchange="return getColleges();">
                                <option value="all">--SELECT--</option>
                                <option value="G">Government</option>
                                <option value="P">Private</option>
                            </select>
                            <span id="adddistrictError" class="text-danger"></span>
                        </div>
                        <div class="col-6">
                            <span style="color: red;">Govt or Private anyone is mandatory for getting data.</span>
                        </div>
                    </div>
                    <div class="row align-items-center m-2">
                        <div class="col-2">
                            <label for="monthYear" class="col-form-label float-right">ITI Name:</label>
                        </div>

                        <div class="col-4">
                            <select class="mandalsclass form-control" name="addrs_mandal_p" id="addrs_mandal_p">
                                <option value="all">--ALL--</option>
                            </select>
                             <span id="itiError" class="text-danger"></span>
                        </div>
                    </div>


		<div class="row align-items-center m-2">
			<div class="col-2">
				<label class="form-label float-md-right">Captcha&nbsp;&nbsp;</label>
			</div>
			<div class="col-4">
				<input type="text" id="txtInput" class="form-control" maxlength="4"
					autocomplete="off" onchange="return checkValue('captchaErr')" />

			</div>
			<div class="col-2">
				<input type="text" id="mainCaptcha" readonly="readonly"
					class="form-control"
					style='letter-spacing: 10px; font-weight: bolder; color: white; background-color: black;' />
					<span id="captchaErr"></span>
			</div>
			<div class="col-1">
  					<i class="fas fa-sync fa-2x pt-1" onclick="generateCaptcha();"></i>
			</div>
		</div>

		<div class="row m-1" align="center">
			<div class="col-md-12">

				<input type="submit" value="Submit" id="submitBtn"class="btn btn-success"
					onclick="return validate();" />

			</div>
                    </div>

            </div>


                            <div id='response'></div>
        </div>
	<br>

		<div align="center" id="successMsg">

		</div>
	<div>
		<div class="table-responsive">
			<table border="1" class="table table-striped" id="table">
				<thead class="table-dark">
					<tr>
						<th class="text-white">Sl No</th>
						<th class="text-white">District Name</th>
						<th class="text-white">ITI Name</th>
						<th class="text-white">Merit From</th>
						<th class="text-white">Merit To</th>
						<th class="text-white">Call Date (YYYY-MM-DD)</th>
						<th class="text-white">Call Time</th>
					</tr>
				</thead>
				<tbody id="entryList">

				</tbody>
			</table>
		</div>
	</div>

	<br>
	<br>
	<br>
	<br>
	<%@include file="/WEB-INF/footer.jsp"%>
</body>
</html>
