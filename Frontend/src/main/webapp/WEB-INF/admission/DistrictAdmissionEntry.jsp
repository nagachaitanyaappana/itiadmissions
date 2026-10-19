<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
	<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="ISO-8859-1">
<title>Insert title here</title>
<script
	src="https://ajax.googleapis.com/ajax/libs/jquery/3.7.1/jquery.min.js"></script>
                    <jsp:include page="/WEB-INF/jsp/_api_base_url.jsp"/>
 <script type="text/javascript" src="./js/customJs/DistrictAdmissionEntryJs.js"></script>
 
</head>
<body> 

	<div id="navbaropen" align="center">
		<%@include file="/WEB-INF/banner.jsp"%>
		<%@include file="/WEB-INF/navbaropen.jsp"%>
		<span id="errorMsg"></span>
	</div>
	
	<div id="navbar">
		<%@include file="/WEB-INF/banner.jsp"%>
		<%@include file="/WEB-INF/navbar.jsp"%>
		
		<div align="center">
				<h6 class="h6 font-weight-bolder">TAKING ADMISSIONS - PHASE-1</h6>
		</div>
		
		
		<div class="container border p-2 mt-2 border font-weight-bolder shadow-lg w-50" style=" border-radius: 20px">
		
			<table class="table table-borderless">
				<fmt:parseDate pattern="yyyy-MM-dd" value="${admDate }" var="admDate" />
				<fmt:formatDate pattern="dd-MM-yyyy" value="${admDate }" var="admDatee" />
				<tr>
					<td>Date : <span style="font-weight: bolder;">${admDatee }</span></td><td>Ranks for counseling : <span style="font-weight: bolder;">${meritFrom } to ${meritTo }</span></td><td></td>
				</tr>
				<tr>
					<td>Caste : <span style="font-weight: bolder;">${castePerform }</span></td><td>Qualification : <span style="font-weight: bolder;">${qualPerform }</span></td> 
				</tr>
				<tr>
					<td>Call Time : <span style="font-weight: bolder;">${admTime }</span></td> 
				</tr>
			</table>
			
<div class="row align-items-center m-2">
 				<div class="col-md-4">
 					<label for="rank" class="col-form-label float-right">
 						Rank </label> 
 				</div>
 				<div class="col-md-8 w-50">
 					 <input type="text" name="rank" id="rank" class="form-control" /><span id="rankErr"></span>
 				</div>
 			</div>               
 			<div align="center">
 				<button class="btn btn-primary w-50" onclick="lookupRank();">LOOKUP RANK</button>
 			</div>

 			<!-- Student Details Section (hidden until lookup) -->
 			<div id="studentDetails" style="display: none; margin-top: 20px;">
 				<div class="card border-info">
 					<div class="card-header bg-info text-white">
 						<h6 class="mb-0">STUDENT DETAILS</h6>
 					</div>
 					<div class="card-body">
 						<div id="alreadyAdmittedMsg" class="alert alert-danger" style="display: none;"></div>
 						<div class="row">
 							<div class="col-md-6">
 								<strong>Registration ID:</strong> <span id="d_regid"></span><br>
 								<strong>Name:</strong> <span id="d_name"></span><br>
 								<strong>Father Name:</strong> <span id="d_fname"></span><br>
 								<strong>Caste:</strong> <span id="d_caste"></span><br>
 								<strong>Gender:</strong> <span id="d_gender"></span><br>
 								<strong>DOB:</strong> <span id="d_dob"></span><br>
 							</div>
 							<div class="col-md-6">
 								<strong>Rank:</strong> <span id="d_rank"></span><br>
 								<strong>PH:</strong> <span id="d_phc"></span><br>
 								<strong>Ex-Serviceman:</strong> <span id="d_exservice"></span><br>
 								<strong>SSC Reg No:</strong> <span id="d_ssc_regno"></span><br>
 								<strong>SSC Year:</strong> <span id="d_ssc_year"></span><br>
 							</div>
 						</div>
 						<div class="row mt-2" id="photoRow" style="display: none;">
 							<div class="col-md-12 text-center">
 								<strong>Photo:</strong><br>
 								<img id="d_photo" src="" alt="Photo" style="max-width: 120px; border: 1px solid #ccc;">
 							</div>
 						</div>
 						<div class="row mt-2" id="admissionDetailsRow" style="display: none;">
 							<div class="col-md-12">
 								<div class="alert alert-warning">
 									<strong>Already Admitted:</strong><br>
 									Admission No: <span id="ad_adm_num"></span><br>
 									ITI: <span id="ad_iti_name"></span> (<span id="ad_iti_code"></span>)<br>
 									Trade: <span id="ad_trade_name"></span> (<span id="ad_trade_code"></span>)<br>
 									Date: <span id="ad_date"></span>
 								</div>
 							</div>
 						</div>
 					</div>
 				</div>
 
 				<!-- Admission Form (shown only if not already admitted) -->
 				<div id="admissionForm" style="display: none; margin-top: 15px;">
 					<div class="card border-success">
 						<div class="card-header bg-success text-white">
 							<h6 class="mb-0">CONFIRM ADMISSION</h6>
 						</div>
 						<div class="card-body">
 							<div class="row mb-2">
 								<div class="col-md-4">
 									<label for="adm_itiCode" class="col-form-label">ITI Code</label>
 								</div>
 								<div class="col-md-8">
 									<input type="text" id="adm_itiCode" class="form-control" required>
 								</div>
 							</div>
 							<div class="row mb-2">
 								<div class="col-md-4">
 									<label for="adm_tradeCode" class="col-form-label">Trade Code</label>
 								</div>
 								<div class="col-md-8">
 									<input type="text" id="adm_tradeCode" class="form-control" required>
 								</div>
 							</div>
 							<div class="row mb-2">
 								<div class="col-md-4">
 									<label for="adm_typeAdmission" class="col-form-label">Type of Admission</label>
 								</div>
 								<div class="col-md-8">
 									<select id="adm_typeAdmission" class="form-control" required>
 										<option value="">--Select--</option>
 										<option value="GEN">General</option>
 										<option value="SC">SC</option>
 										<option value="ST">ST</option>
 										<option value="BC-A">BC-A</option>
 										<option value="BC-B">BC-B</option>
 										<option value="BC-C">BC-C</option>
 										<option value="BC-D">BC-D</option>
 										<option value="BC-E">BC-E</option>
 										<option value="PH">PH</option>
 										<option value="EX">Ex-Serviceman</option>
 										<option value="SP">Sports</option>
 									</select>
 								</div>
 							</div>
 							<div class="row mb-2">
 								<div class="col-md-4">
 									<label for="adm_shift" class="col-form-label">Shift</label>
 								</div>
 								<div class="col-md-8">
 									<select id="adm_shift" class="form-control" required>
 										<option value="">--Select--</option>
 										<option value="1">1</option>
 										<option value="2">2</option>
 										<option value="3">3</option>
 									</select>
 								</div>
 							</div>
 							<div class="row mb-2">
 								<div class="col-md-4">
 									<label for="adm_unit" class="col-form-label">Unit</label>
 								</div>
 								<div class="col-md-8">
 									<select id="adm_unit" class="form-control" required>
 										<option value="">--Select--</option>
 									</select>
 								</div>
 							</div>
 							<div align="center">
 								<button class="btn btn-success w-50" onclick="takeAdmission();">CONFIRM ADMISSION</button>
 							</div>
 						</div>
 					</div>
 				</div>
 			</div>
		
		</div>
		 
	</div>
	
	
	
	
	
<!-- 	<br> <br> -->
<!-- 	<br> <br> -->
	<%@include file="/WEB-INF/footer.jsp"%>
	
</body>
</html>