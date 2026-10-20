const API_BASE_URL = window.API_BASE_URL;

let jwtToken = null;
let insCode = null;
let roleId = null;

$(document).ready(function() {

	jwtToken = localStorage.getItem('jwtToken');
	insCode = localStorage.getItem('insCode');
	roleId = localStorage.getItem('roleId');

	if(jwtToken == null || jwtToken == "") {
		$("#navbaropen").show(); 
		$("#errorMsg").append('<h3 class="h3 text-danger">YOU DONT HAVE AUTHORIZE TO ACCESS THIS PAGE</h3>');
	} else {
		$("#navbaropen").hide(); 
		$("#navbar").show(); 
	}
	  
});

function showError(msg) {
	$("#rankErr").text(msg).css("color", "red");
	setTimeout(function() { $("#rankErr").text(""); }, 5000);
}

function showSuccess(msg) {
	$("#rankErr").text(msg).css("color", "green");
}

function lookupRank() {
	var rank = $("#rank").val().trim();
	if (!rank) {
		showError("Please enter a rank");
		return;
	}
	if (!/^\d+$/.test(rank)) {
		showError("Rank must be numeric");
		return;
	}

	$("#studentDetails").hide();
	$("#admissionForm").hide();
	$("#adm_shift").val("");
	$("#adm_unit").empty().append('<option value="">--Select--</option>');
	showSuccess("Looking up rank...");

	$.ajax({
		url: API_BASE_URL + "/admission-process/rank-lookup",
		type: "POST",
		contentType: "application/json",
		data: JSON.stringify({ rank: rank }),
		headers: {
			"X-Role-Id": roleId,
			"X-Ins-Code": insCode,
			"Authorization": "Bearer " + jwtToken
		},
		success: function(response) {
			if (response.success && response.data) {
				var student = response.data;
				populateStudentDetails(student);
			} else {
				$("#studentDetails").hide();
				$("#admissionForm").hide();
				showError(response.message || "No candidate found for this rank");
			}
		},
		error: function(xhr) {
			var msg = "Lookup failed";
			if (xhr.responseJSON && xhr.responseJSON.message) msg = xhr.responseJSON.message;
			else if (xhr.responseText) msg = xhr.responseText;
			showError(msg);
			$("#studentDetails").hide();
			$("#admissionForm").hide();
		}
	});
}

function populateStudentDetails(student) {
	$("#d_regid").text(student.regid || "");
	$("#d_name").text(student.name || "");
	$("#d_fname").text(student.fname || "");
	$("#d_caste").text(student.caste || "");
	$("#d_gender").text(student.gender || "");
	$("#d_dob").text(student.dob || "");
	$("#d_rank").text(student.rank || "");
	$("#d_phc").text(student.phc ? "Yes" : "No");
	$("#d_exservice").text(student.exservice ? "Yes" : "No");
	$("#d_ssc_regno").text(student.ssc_regno || "");
	$("#d_ssc_year").text(student.ssc_year || "");

	if (student.photo_base64) {
		$("#d_photo").attr("src", "data:image/jpeg;base64," + student.photo_base64);
		$("#photoRow").show();
	} else {
		$("#photoRow").hide();
	}

	if (student.is_admitted) {
		$("#alreadyAdmittedMsg").text("This candidate is already admitted.").show();
		if (student.admission_details) {
			$("#ad_adm_num").text(student.admission_details.adm_num || "");
			$("#ad_iti_name").text(student.admission_details.iti_name || "");
			$("#ad_iti_code").text(student.admission_details.iti_code || "");
			$("#ad_trade_name").text(student.admission_details.trade_name || "");
			$("#ad_trade_code").text(student.admission_details.trade_code || "");
			$("#ad_date").text(student.admission_details.date_of_admission || "");
			$("#admissionDetailsRow").show();
		}
		$("#admissionForm").hide();
	} else {
		$("#alreadyAdmittedMsg").hide();
		$("#admissionDetailsRow").hide();
		$("#admissionForm").show();
		loadShiftUnits(student.regid);
	}

	$("#studentDetails").show();
}

function loadShiftUnits(regid) {
	$.ajax({
		url: API_BASE_URL + "/admission-process/shift-unit",
		type: "GET",
		data: { itiCode: $("#adm_itiCode").val(), tradeCode: $("#adm_tradeCode").val() },
		headers: {
			"X-Role-Id": roleId,
			"X-Ins-Code": insCode,
			"Authorization": "Bearer " + jwtToken
		},
		success: function(response) {
			if (response.success && response.shifts) {
				var unitSelect = $("#adm_unit");
				unitSelect.empty().append('<option value="">--Select--</option>');
				response.shifts.forEach(function(s) {
					unitSelect.append('<option value="' + s.unit_allowed + '">Shift ' + s.shift_allowed + ' - Unit ' + s.unit_allowed + ' (Str: ' + s.strength + ', Vac: ' + s.strength_vacant + ')</option>');
				});
			}
		}
	});
}

function takeAdmission() {
	var regid = $("#d_regid").text();
	var itiCode = $("#adm_itiCode").val().trim();
	var tradeCode = $("#adm_tradeCode").val().trim();
	var typeAdmission = $("#adm_typeAdmission").val();
	var shift = $("#adm_shift").val();
	var unit = $("#adm_unit").val();

	if (!regid || !itiCode || !tradeCode || !typeAdmission || !shift || !unit) {
		alert("Please fill all required fields");
		return;
	}

	$.ajax({
		url: API_BASE_URL + "/admission-process/take-admission",
		type: "POST",
		contentType: "application/json",
		data: JSON.stringify({
			regid: regid,
			itiCode: itiCode,
			tradeCode: tradeCode,
			typeAdmission: typeAdmission,
			shift: shift,
			unit: unit
		}),
		headers: {
			"X-Role-Id": roleId,
			"X-Ins-Code": insCode,
			"Authorization": "Bearer " + jwtToken
		},
		success: function(response) {
			if (response.success) {
				alert("Admission confirmed! Admission No: " + response.adm_num);
				$("#admissionForm").hide();
				lookupRank();
			} else {
				alert("Admission failed: " + (response.message || "Unknown error"));
			}
		},
		error: function(xhr) {
			var msg = "Admission request failed";
			if (xhr.responseJSON && xhr.responseJSON.message) msg = xhr.responseJSON.message;
			else if (xhr.responseText) msg = xhr.responseText;
			alert(msg);
		}
	});
}