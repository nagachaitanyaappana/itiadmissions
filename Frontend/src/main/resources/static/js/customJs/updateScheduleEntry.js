/**
 * Update Schedule Entry Timings page (WEB-INF/checkmeritschedule/updateScheduleEntry.jsp).
 *
 * The page has no production route yet (open it through the /dev tool), so nothing here
 * may depend on a deep-path-relative asset: everything is loaded from the context root.
 *
 * Re-pointed off the legacy gate (localStorage 'jwtToken', which nothing sets) and the
 * commented-out /api/checklist/schedule-entry call (no such endpoint exists). The real,
 * already-implemented API is AdmissionTimingController:
 *
 *   GET  /admission-timings/districts?govt=G|P   - district dropdown
 *   GET  /admission-timings/itis?distCode&govt   - ITI dropdown of the district
 *   POST /admission-timings/search               - schedule rows for the running phase/year
 */
const API_BASE_URL = window.API_BASE_URL;

/* Cached dropdown backing data. */
let districts = [];
let itis = [];

function getReady() {
	if (typeof SESSION_ROLE_ID === 'undefined' || SESSION_ROLE_ID === null || SESSION_ROLE_ID === '') {
		$("#navbar").hide();
		$("#404Msg").append('<h3 class="h3 text-danger">YOU DONT HAVE AUTHORIZE TO THIS PAGE</h3>');
		$("#404Msg").show();
		return;
	}
	$("#404Msg").hide();

	loadCurrentPhase();
	loadDistricts();
}

/* The running phase/year for the header, same source deleteScheduleEntry.jsp uses. */
function loadCurrentPhase() {
	$.ajax({
		type: 'POST',
		url: API_BASE_URL + '/api/status',
		cache: false,
		success: function (resp) {
			if (resp && resp.phase != null) {
				$("#currentphase").text('Running phase for ' + resp.year + ': Phase - ' + resp.phase);
			}
		}
	});
}

/* District dropdown for the delete/update schedule page (optional govt filter). */
function loadDistricts() {
	$.ajax({
		type: 'GET',
		url: API_BASE_URL + '/admission-timings/districts',
		cache: false,
		success: function (resp) {
			districts = Array.isArray(resp) ? resp : [];
			Street_name();
		},
		error: function (xhr, status, error) {
			console.error('Failed to load districts:', status, error);
		}
	});
}

/* Populates #addrs_state_p from the cached districts (same name the page always used). */
function Street_name() {
	var selectElement = document.getElementById('addrs_state_p');
	if (!selectElement) { return false; }
	selectElement.innerHTML = '<option value="all">--SELECT--</option>';
	for (var i = 0; i < districts.length; i++) {
		var option = document.createElement('option');
		option.value = districts[i].distCode;
		option.textContent = districts[i].distName;
		selectElement.appendChild(option);
	}
	return false;
}

/* ITIs of the selected district for the selected Government/Private type. */
function getColleges() {
	var dist = document.getElementById('addrs_state_p').value;
	var govt = document.getElementById('addrs_district_p').value;
	var selectElement = document.getElementById('addrs_mandal_p');
	selectElement.innerHTML = '<option value="all">--ALL--</option>';
	if (dist === 'all' || govt === 'all') { return false; }
	$.ajax({
		type: 'GET',
		url: API_BASE_URL + '/admission-timings/itis?distCode=' + encodeURIComponent(dist)
			+ '&govt=' + encodeURIComponent(govt),
		cache: false,
		success: function (resp) {
			itis = Array.isArray(resp) ? resp : [];
			for (var i = 0; i < itis.length; i++) {
				var option = document.createElement('option');
				option.value = itis[i].itiCode;
				option.textContent = itis[i].itiName;
				selectElement.appendChild(option);
			}
		},
		error: function (xhr, status, error) {
			console.error('Failed to load ITI list:', status, error);
		}
	});
	return false;
}

/* Lists the schedule entries of the running phase/year for the selected filters. */
function getScheduleEntryByDistAndIti() {
	$("#entryList").empty();
	$.ajax({
		type: 'POST',
		url: API_BASE_URL + '/admission-timings/search',
		contentType: "application/json",
		data: JSON.stringify({
			distCode: document.getElementById('addrs_state_p').value || 'all',
			itiCode: document.getElementById('addrs_mandal_p').value || 'all',
			itiType: document.getElementById('addrs_district_p').value || ''
		}),
		cache: false,
		timeout: 600000,
		success: function (resp) {
			var rows = (resp && Array.isArray(resp.data)) ? resp.data : [];
			$("#successMsg").html(rows.length === 0
				? '<span class="text-danger fw-bolder">No schedule entries found for the selected filters.</span>'
				: '<span class="text-success fw-bolder">' + rows.length + ' schedule entr' + (rows.length === 1 ? 'y' : 'ies')
					+ ' found for the running phase.</span>');
			for (var i = 0; i < rows.length; i++) {
				var bean = rows[i];
				$("#entryList").append('<tr>'
					+ '<td>' + (i + 1) + '</td>'
					+ '<td>' + (bean.distName || bean.distCode || '-') + '</td>'
					+ '<td>' + (bean.itiName || bean.itiCode || '-') + '</td>'
					+ '<td>' + (bean.meritFrom == null ? '-' : bean.meritFrom) + '</td>'
					+ '<td>' + (bean.meritTo == null ? '-' : bean.meritTo) + '</td>'
					+ '<td>' + (bean.calDate || '-') + '</td>'
					+ '<td>' + (bean.calTime || '-') + '</td>'
					+ '</tr>');
			}
		},
		error: function (resp) {
			alert('Error fetching schedule entries: HTTP ' + resp.status);
		}
	});
}

function validate() {
	var hasError = false;

	var districtName = document.getElementById('addrs_state_p').value;
	if (districtName === 'all') {
		$("#districtError").text('Please select a district.').css({ "color": "red" });
		hasError = true;
	} else {
		$("#districtError").text('');
	}

	var govtPrivateSelect = document.getElementById('addrs_district_p').value;
	if (govtPrivateSelect === 'all') {
		$("#adddistrictError").text('Please select Government or Private.').css({ "color": "red" });
		hasError = true;
	} else {
		$("#adddistrictError").text('');
	}

	// ITI name stays optional: "--ALL--" lists every schedule entry of the district,
	// which is how the district-level (ITI-less) rows of phase 1 are reached.

	var txtInput = $("#txtInput").val();
	var mainCaptcha = $("#mainCaptcha").val();
	if (txtInput == "" || txtInput == null) {
		$("#captchaErr").text('Captcha is required.').css({ "color": "red" });
		$("#txtInput").val(''); $("#txtInput").focus();
		return false;
	}
	if (txtInput !== mainCaptcha) {
		$("#captchaErr").text('Given captcha is not matched.').css({ "color": "red" });
		$("#txtInput").val(''); $("#txtInput").focus();
		return false;
	}

	if (hasError) { return false; }

	getScheduleEntryByDistAndIti();
	return true;
}

function checkValue(a) {
	document.getElementById(a).innerHTML = '';
}
