<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link href="${pageContext.request.contextPath}/css/bootstrap.min.css" rel="stylesheet">
<script src="${pageContext.request.contextPath}/js/bootstrap.bundle.min.js"></script>
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<script>
	$(document).ready(function(){
		
		var roleId = localStorage.getItem('roleId');
		var insCode = localStorage.getItem('insCode');
		var username = localStorage.getItem('username');
		var insName = localStorage.getItem('insName');
		//alert("jwtToken=>"+jwtToken);
		
                 if(roleId == '4'){
                	 //alert("roleId=>4");
                	    const listItem1 = document.createElement("li");
                	    listItem1.setAttribute("class", "nav-item");
                	    const link1 = document.createElement("a");
                	    link1.setAttribute("class", "nav-link active");
                	    
                	    link1.href = "./plcmtEntryForm";  
                	    link1.textContent = "Placement Entry";  
                	    listItem1.appendChild(link1);
                	    const navbarList = document.getElementById("placements");
                	    navbarList.appendChild(listItem1);

                	    const listItem2 = document.createElement("li");
                	    listItem2.setAttribute("class", "nav-item");
                	    const link2 = document.createElement("a");
                	    link2.setAttribute("class", "nav-link active");
                	    
                	    link2.href = "./plcmtITIReport";  
                	    link2.textContent = "Placement ITI Report";  
                	    listItem2.appendChild(link2);
                	    navbarList.appendChild(listItem2);
                 }
                 if(roleId == "3"){
                	 //alert("3")
                	const listItem1 = document.createElement("li");
                	listItem1.setAttribute("class", "dropdown-item");
             	    const link1 = document.createElement("a");
             	    link1.href = "./placementScheduleEntry";  
             	    link1.textContent = "Placement Schedule Entry";  
             	    listItem1.appendChild(link1);
             	    const navbarList = document.getElementById("placements");
             	   	navbarList.appendChild(listItem1);
                	 
                	const listItem2 = document.createElement("li");
                	listItem2.setAttribute("class", "dropdown-item");
             	    const link2 = document.createElement("a");
             	   	link2.href = "./plcmtDistReport";  
             	  	link2.textContent = "Placement Dist Report";  
             	    listItem2.appendChild(link2);
             	    const navbarList2 = document.getElementById("placements");
             	   	navbarList2.appendChild(listItem2);
             	   	
                	const distVerificationli = document.createElement("li");
                	distVerificationli.setAttribute("class", "dropdown-item");
             	    const distVerificationa = document.createElement("a");
             	    distVerificationa.href = "./distVerification";  
             	    distVerificationa.textContent = "Application Verification";  
             	    distVerificationli.appendChild(distVerificationa);
             	    const distVerificationList = document.getElementById("admissions");
             	   distVerificationList.appendChild(distVerificationli);
             	   	
                	const meritListli = document.createElement("li");
                	meritListli.setAttribute("class", "dropdown-item");
             	    const meritLista = document.createElement("a");
             	   meritLista.href = "./meritListPhaseOne";  
             	  meritLista.textContent = "Merit List-Phase1";  
             	 meritListli.appendChild(meritLista);
             	    const meritListList = document.getElementById("admissions");
             	   meritListList.appendChild(meritListli);
             	   	
                	const scheduleEntryli = document.createElement("li");
                	scheduleEntryli.setAttribute("class", "dropdown-item");
             	    const scheduleEntrya = document.createElement("a");
             	   scheduleEntrya.href = "./scheduleEntry";  
             	  scheduleEntrya.textContent = "Schedule Entry-Phase1";  
             	 scheduleEntryli.appendChild(scheduleEntrya);
             	    const scheduleEntryList = document.getElementById("admissions");
             	   scheduleEntryList.appendChild(scheduleEntryli);
             	   
                	const admissionPhaseli = document.createElement("li");
                	admissionPhaseli.setAttribute("class", "dropdown-item");
             	    const admissionPhasea = document.createElement("a");
             	   admissionPhasea.href = "./admissionPhase1";  
             	  admissionPhasea.textContent = "ADMISSIONS PHASE 1";  
             	 admissionPhaseli.appendChild(admissionPhasea);
             	    const admissionPhaseList = document.getElementById("admissions");
             	   admissionPhaseList.appendChild(admissionPhaseli);
             	   
             	   
                	const addTradeli = document.createElement("li");
                	addTradeli.setAttribute("class", "dropdown-item");
             	    const addTradea = document.createElement("a");
             	   addTradea.href = "./addTrade";  
             	  addTradea.textContent = "Add Trade";  
             	 addTradeli.appendChild(addTradea);
             	    const addTradeList = document.getElementById("admissions");
             	   addTradeList.appendChild(addTradeli);
             	   
             	   
             	   	
     
             	   	
                	 
                 }
                 if(roleId == "10"){
                	const admissionIntializationli = document.createElement("li");
                	admissionIntializationli.setAttribute("class", "dropdown-item");
              	    const admissionIntializationa = document.createElement("a");
              	  	admissionIntializationa.href = "./admissionIntialization";  
              		admissionIntializationa.textContent = "Admission Intialization";  
              		admissionIntializationli.appendChild(admissionIntializationa);
              	    const navbarList = document.getElementById("admissions");
              	   	navbarList.appendChild(admissionIntializationli);
              	   	
              	   	
              	   	
                   	const UpdateScheduleEntryli = document.createElement("li");
                	UpdateScheduleEntryli.setAttribute("class", "dropdown-item");
             	    const UpdateScheduleEntrya = document.createElement("a");
             	   UpdateScheduleEntrya.href = "./deleteScheduleEntry";  
             	  UpdateScheduleEntrya.textContent = "Delete Schedule Entry ";  
             	 UpdateScheduleEntryli.appendChild(UpdateScheduleEntrya);
             	    const UpdateScheduleEntryList = document.getElementById("admissions");
             	   UpdateScheduleEntryList.appendChild(UpdateScheduleEntryli);
             	   	
              	   	
              	   	
                 }
                 if(roleId == "10" || roleId == "2"){
                	 //alert("3")
                	const listItem1 = document.createElement("li");
                	listItem1.setAttribute("class", "dropdown-item");
             	    const link1 = document.createElement("a");
             	    link1.href = "./plcmtStateReport";  
             	    link1.textContent = "Placement State Report";  
             	    listItem1.appendChild(link1);
             	    const navbarList = document.getElementById("placements");
             	   	navbarList.appendChild(listItem1);
                	 
                	const listItem2 = document.createElement("li");
                	listItem2.setAttribute("class", "dropdown-item");
             	    const link2 = document.createElement("a");
             	   	link2.href = "./plcmtYearWiseCountReport";  
             	  	link2.textContent = "Placement Year Wise Report";  
             	    listItem2.appendChild(link2);
             	    const navbarList2 = document.getElementById("placements");
             	   	navbarList2.appendChild(listItem2);
                	 
             	   	
                 }
                 $("#loginId").append('Welcome, '+username+'<br>'+insName+', '+insCode);
	});
	</script>
</head>

<body>
<!-- 	<img src="${pageContext.request.contextPath}/images/gen.jpg" class="img-fluid" -->
<!-- 		style="height: 100px; width: 1300px;" /> -->

	<nav class="navbar navbar-expand-sm navbar-dark bg-primary">

		<div class="container">
			<a class="navbar-brand" href="#"></a>

			<button class="navbar-toggler" type="button"
				data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent"
				aria-controls="navbarSupportedContent" aria-expanded="false"
				aria-label="Toggle navigation">
				<span class="navbar-toggler-icon"></span>
			</button>

			<div class="collapse navbar-collapse" id="navbarSupportedContent">

				<ul class="navbar-nav ">
					<li class="nav-item"><a class="nav-link active"
						aria-current="page" href="./loginSuccess"><i
							class="fas fa-home"></i></a></li>

					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle active" href="#"
						id="navbarDropdown" role="button" data-bs-toggle="dropdown"
						aria-expanded="false"> Services </a>
						<ul class="dropdown-menu bg-white"
							aria-labelledby="navbarDropdown" id="services">
						</ul></li>
						
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle active" href="#"
						id="navbarDropdown" role="button" data-bs-toggle="dropdown"
						aria-expanded="false"> Admissions </a>
						<ul class="dropdown-menu bg-white"
							aria-labelledby="navbarDropdown" id="admissions">
						</ul></li>
						
					<li class="nav-item dropdown"><a
						class="nav-link dropdown-toggle active" href="#"
						id="navbarDropdown" role="button" data-bs-toggle="dropdown"
						aria-expanded="false"> SCVT Exams </a>
						<ul class="dropdown-menu bg-white"
							aria-labelledby="navbarDropdown" id="scvtexams">
						</ul></li>

					<li class="nav-item"><a class="nav-link active"
						aria-current="page" href="./logout">Logout</a></li>

<!-- 					<li class="nav-item" style="margin-left: 20px;"><span -->
<!-- 						id="loginId" class="text-warning"></span></li> -->

				</ul>

			</div>
		</div>
	</nav>
</body>

</html>