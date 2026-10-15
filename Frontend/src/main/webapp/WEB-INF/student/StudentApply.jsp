<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="en-GB">
    <head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
<title>:: ITI  ::</title>
<link rel="shortcut icon" type="image/ico" href="${pageContext.request.contextPath}/iti.png" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/expe1011.css">
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>

<style>
    #menu-bar {
  width: 100%;
  margin: 0px 0px 0px 0px;
  padding: 0px 0px 0px 0px;
  height: 30px;
  line-height: 100%;
  border-radius: 0px;
  -webkit-border-radius: 24px;
  -moz-border-radius: 24px;
  box-shadow: 2px 2px 2px #666666;
  -webkit-box-shadow: 2px 2px 2px #666666;
  -moz-box-shadow: 2px 2px 2px #666666;
  background: #e4eeb9;
  position:relative;
  z-index:999;
}
#menu-bar li {
  margin: 0px 0px 6px 0px;
  padding: 0px 6px 0px 6px;
  float: left;
  position: relative;
  list-style: none;
}
#menu-bar a {
  font-weight: bold;
  font-family: verdana;
  font-size: 14px;
  color: #000000;
    background: #e4eeb9;
  text-decoration: none;
  display: block;
  padding: 6px 20px 6px 20px;
  margin: 0;
  margin-bottom: 6px;
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
}
#menu-bar li ul li a {
  margin: 0;
}
#menu-bar .active a, #menu-bar li:hover > a {
  background:blue;
  background: lightblue;
 background: -ms-linear-gradient(top,  #EB4954,  #A19197);
  background: -webkit-gradient(linear, left top, left bottom, from(#EB4954), to(#A19197));
  background: -moz-linear-gradient(top,  #EB4954,  #A19197);
  color: white;
  -webkit-box-shadow: 0 1px 1px rgba(0, 0, 0, .2);
  -moz-box-shadow: 0 1px 1px rgba(0, 0, 0, .2);
  box-shadow: 0 1px 1px rgba(0, 0, 0, .2);
}
#menu-bar ul li:hover a, #menu-bar li:hover li a {
  background: lightgoldenrodyellow;
  color: #000000;
}
#menu-bar ul a:hover {
  background: lightblue!important;
  color: black !important;
  border-radius: 0;
  -webkit-border-radius: 0;
  -moz-border-radius: 0;
}
#menu-bar li:hover > ul {
  display: block;
}
#menu-bar ul {
  background: block;
  background: linear-gradient(top,  #FFD21C,  #CF7688);
  background: -ms-linear-gradient(top,  #FFD21C,  #CF7688);
  background: -webkit-gradient(linear, left top, left bottom, from(#FFD21C), to(#CF7688));
  background: -moz-linear-gradient(top,  #FFD21C,  #CF7688);
  display: none;
  margin: 0;
  padding: 0;
  width: 300px;
  position: absolute;
  top: 30px;
  left: 0;
  border-radius: 0px;
  -webkit-border-radius: 10px;
  -moz-border-radius: 10px;
  -webkit-box-shadow: 2px 2px 3px #222222;
  -moz-box-shadow: 2px 2px 3px #222222;
  box-shadow: 2px 2px 3px #222222;
}
#menu-bar ul li {
  float: none;
  margin: 0;
  padding: 0;
}
#menu-bar ul a {
  padding:10px 0px 10px 15px;
   background: gold;
  color:grey;
  font-size:13px;
  font-style:normal;
  font-family:verdana;
  font-weight: normal;
  text-shadow: 2px 2px 3px #FFFFFF;
}
#menu-bar ul li:first-child > a {
  border-top-left-radius: 10px;
  -webkit-border-top-left-radius: 10px;
  -moz-border-radius-topleft: 10px;
  border-top-right-radius: 10px;
  -webkit-border-top-right-radius: 10px;
  -moz-border-radius-topright: 10px;
}
#menu-bar ul li:last-child > a {
  border-bottom-left-radius: 10px;
  -webkit-border-bottom-left-radius: 10px;
  -moz-border-radius-bottomleft: 10px;
  border-bottom-right-radius: 10px;
  -webkit-border-bottom-right-radius: 10px;
  -moz-border-radius-bottomright: 10px;
}
#menu-bar:after {
  content: ".";
  display: block;
  clear: both;
  visibility: hidden;
  line-height: 0;
  height: 0;
}
#menu-bar {
  display: inline-block;
}
  html[xmlns] #menu-bar {
  display: block;
}
* html #menu-bar {
  height: 1%;
} 
</style>

            <script type="text/javascript">

                function NumericsOnly(evt)
                {
                    var charCode = (evt.which) ? evt.which : event.keyCode

                    if ((charCode > 31 && (charCode < 48 || charCode > 57)))
                    {
                        alert("Enter Numbers");
                        return false;
                    }


                    return true;
                }

                function validate() {
                    var captcha = document.getElementById("captcha").value;
                    if (captcha === "" || captcha === null) {
                        document.getElementById("captcha").focus();
                        alert("Captcha is required");
                        return false;
                    }
                    var ssc_regno = document.getElementById("ssc_regno").value;
                    if (ssc_regno === "" || ssc_regno === null) {
                        document.getElementById("ssc_regno").focus();
                        alert("SSC HallTicket Number is required");
                        return false;
                    }
                    var dob = document.getElementById("dob").value;
                    if (dob === "" || dob === null) {
                        document.getElementById("dob").focus();
                        alert("Date of Birth is required");
                        return false;
                    }
                    var regid = document.getElementById("regid").value;
                    if (regid === "" || regid === null) {
                        document.getElementById("regid").focus();
                        alert("Registration Id is required");
                        return false;
                    }
                    return true;
                }

                function refreshCaptcha() {
                    var img = document.getElementById("captchaImage");
                    if (img) { img.src = '${pageContext.request.contextPath}/captcha?ts=' + (new Date()).getTime(); }
                }

            </script>
            <script type="text/javascript">
                var CURRENT_REGID = null;
                var CURRENT_SSC_TYPE = null;
                var CURRENT_YEAR = '';
                var CURRENT_PHASE = '';

                // Gate submit: verify captcha, fetch the registration record and open the application form
                function fetchApplication() {
                    if (!validate()) return false;
                    document.getElementById("gateErrors").innerHTML = "";
                    var enteredCaptcha = document.getElementById("captcha").value.trim().toUpperCase();
                    $.get('${pageContext.request.contextPath}/captcha/text', function (serverCaptcha) {
                        if (enteredCaptcha !== String(serverCaptcha).trim().toUpperCase()) {
                            alert("Captcha does not match. Please try again.");
                            refreshCaptcha();
                            document.getElementById("captcha").value = "";
                            document.getElementById("captcha").focus();
                            return;
                        }
                        loadApplication();
                    });
                    return false;
                }

                function loadApplication() {
                    var regid = document.getElementById("regid").value.trim();
                    var ssc_regno = document.getElementById("ssc_regno").value.trim();
                    var dob = document.getElementById("dob").value;

                    $.get('${backendBaseUrl}/api/student/apply-gate', {
                        regid: regid, dob: dob, ssc_regno: ssc_regno
                    }, function (res) {
                        var status = res && res.status;
                        if (status === 'expired') {
                            gateError('Date has Expired');
                            return;
                        }
                        if (status === 'admitted') {
                            gateError('Already Admitted');
                            return;
                        }
                        if (status === 'norecords' || !res.record) {
                            gateError('No Records Found');
                            return;
                        }
                        var s = res.record;
                        CURRENT_REGID = s.regid;
                        CURRENT_SSC_TYPE = s.sscType;
                        document.getElementById("gateDiv").style.display = "none";
                        renderRegistrationDetails(s);
                        $.get('${backendBaseUrl}/api/student/marks/' + s.regid, function (m) {
                            renderMarksDetails(s, m);
                        }).fail(function () { renderMarksDetails(s, null); });
                        initSelectionStep();
                        window.scrollTo(0, 0);
                    }).fail(function () {
                        gateError('No Records Found');
                    });
                }

                function gateError(message) {
                    document.getElementById("gateDiv").style.display = "";
                    document.getElementById("selectDiv").style.display = "none";
                    var box = document.getElementById("gateErrors");
                    box.innerHTML = '<center><h1 style="color:red;">' + message + '</h1></center>';
                }

                $(document).ready(function () {
                    $("#captchaRef").click(refreshCaptcha);
                    // Current session year/phase come from admissions.admission_phase (current = true),
                    // mirroring itiap_new's open_Application_Interface_Student.jsp lookup.
                    $.get('${backendBaseUrl}/api/reports/current-admission-phase', function (data) {
                        if (data && data.year) {
                            CURRENT_YEAR = String(data.year);
                            CURRENT_PHASE = data.phase;
                            $('.sessionYearPhase').text(CURRENT_YEAR + '(Phase-' + CURRENT_PHASE + ')');
                        }
                    });
                });
            </script>
            <script type="text/javascript">
                // ================= Step 3: selection =================
                // Writes student_trade_sel through /admission/student-trade-selection.
                // Phase 1 selects districts only (legacy student_trade_sel2025phase1 rows have
                // iti_code=''); phase 2+ selects district + ITI.
                var MAX_CHOICES = 60;
                var DISTRICT_OPTIONS = null;

                // ---- read-only registration details shown before the selection step ----
                function aplEsc(v) {
                    if (v === null || v === undefined) { return ''; }
                    return String(v).replace(/[&<>"]/g, function (c) {
                        return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[c];
                    });
                }
                function aplVal(v) {
                    if (v === null || v === undefined || String(v).trim() === '') { return '&nbsp;'; }
                    return aplEsc(v);
                }
                function aplPair(l1, v1, l2, v2) {
                    return '<tr><td class="lbl">' + l1 + '</td><td>' + aplVal(v1)
                        + '</td><td class="lbl">' + l2 + '</td><td>' + aplVal(v2) + '</td></tr>';
                }
                function renderRegistrationDetails(s) {
                    var dob = s.dob ? String(s.dob).substring(0, 10) : '';
                    var board = s.sscBoard;
                    var gender = s.gender ? (s.gender.charAt(0).toUpperCase() + s.gender.slice(1)) : '';
                    var localVal = s.local === 'NonLocal' ? 'Non-Local' : (s.local || '');
                    var monthMap = { '03': 'March', '04': 'Supplymentary' };
                    var month = monthMap[String(s.sscMonth)] || s.sscMonth || '';
                    var pwdMap = { '1': 'Blind', '2': 'Deaf', '3': 'Motor Disability', '4': 'Mental Disability' };
                    var pwd = (s.pwdCategory && s.pwdCategory !== 'N' && String(s.pwdCategory).trim() !== '')
                        ? (pwdMap[String(s.pwdCategory)] || s.pwdCategory)
                        : 'None';
                    var qual = (s.sscPassed === true) ? 'SSC Passed' : (s.sscPassed === false ? '8th Passed' : '');

                    var h = '<table class="apply-details">'
                        + aplPair('Hall Ticket Number', s.sscRegNo, 'Board', board)
                        + aplPair('Year of Pass', s.sscYear, 'Month of Pass', month)
                        + aplPair("Applicant's Name", s.name, 'Mobile Number', s.phno)
                        + aplPair('Date of Birth', dob, 'Aadhaar Number', s.adarno)
                        + aplPair("Father's Name", s.fname, 'Gender', gender)
                        + aplPair("Mother's Name", s.mname, 'Physically Challenged', s.phc ? 'Yes' : 'No')
                        + aplPair('Address', s.addr, 'PWD Category', pwd)
                        + aplPair('Ex-Service Man', s.exservice ? 'Yes' : 'No', 'Qualification', qual)
                        + aplPair('Pincode', s.pincode, 'Email', s.email)
                        + aplPair('Caste', s.caste, 'Local / Non-Local', localVal)
                        + '<tr><td class="lbl">Economic Weaker Section</td><td colspan="3">'
                            + (s.economicWeakerSection ? 'Yes' : 'No') + '</td></tr>'
                        + '</table>';

                    var box = document.getElementById("applyDetails");
                    box.innerHTML = h;
                    box.style.display = "";
                }

                // SSC marks/GPA entered at registration (cand_marks), shown alongside the
                // personal details so the whole registration record is visible here.
                function renderMarksDetails(s, m) {
                    var box = document.getElementById("applyMarks");
                    if (!m) { box.innerHTML = ''; box.style.display = "none"; return; }
                    var gpa = (s.sscType !== 'sscm');
                    var suffix = gpa ? 'GPA' : 'Marks';
                    var second = gpa ? m.sscSecondLangGpa : m.sscSecondLangMarks;
                    var numLang = (second !== null && second !== undefined && String(second).trim() !== '') ? 'Three' : 'Two';
                    var rows = gpa
                        ? [['First Language', m.sscFirstLangGpa], ['Second Language', m.sscSecondLangGpa],
                           ['Third Language - English', m.sscEngGpa], ['Mathematics', m.sscMathGpa],
                           ['General Science', m.sscSciGpa], ['Social Studies', m.sscSocialGpa], ['Total', m.sscTotGpa]]
                        : [['First Language', m.sscFirstLangMarks], ['Second Language', m.sscSecondLangMarks],
                           ['Third Language - English', m.sscEngMarks], ['Mathematics', m.sscMathMarks],
                           ['General Science', m.sscSciMarks], ['Social Studies', m.sscSocialMarks], ['Total', m.sscTotMarks]];
                    var h = '<h4 align="center"><b>SSC Details (read-only) &mdash; Number of Languages: ' + numLang + '</b></h4>'
                        + '<table class="apply-details">'
                        + '<tr class="hdr"><td colspan="3">Subject-wise ' + suffix + '</td></tr>'
                        + '<tr><td class="lbl">S.No</td><td class="lbl">Subject</td><td class="lbl">' + suffix + '</td></tr>';
                    for (var i = 0; i < rows.length; i++) {
                        h += '<tr><td>' + (i + 1) + '</td><td>' + rows[i][0] + '</td><td>'
                            + aplVal(rows[i][1]) + '</td></tr>';
                    }
                    box.innerHTML = h + '</table>';
                    box.style.display = "";
                }

                function isPhaseOne() { return String(CURRENT_PHASE) === '1'; }

                function loadDistrictOptions(after) {
                    if (DISTRICT_OPTIONS) { after(); return; }
                    $.get('${backendBaseUrl}/api/districts', function (list) {
                        DISTRICT_OPTIONS = list || [];
                        after();
                    }).fail(function () {
                        alert("Could not load the district list. Please retry.");
                    });
                }

                // Reveals the selection step and re-renders anything already saved for this candidate.
                function initSelectionStep() {
                    document.getElementById("selectDiv").style.display = "";
                    var phaseOne = isPhaseOne();
                    document.getElementById("selectHeading").innerHTML = phaseOne
                        ? 'Selection of Districts (Step 2)'
                        : 'Selection of ITIs (Step 2)';
                    document.getElementById("selectInstruction").innerHTML = phaseOne
                        ? 'Phase 1: select the districts you want to be considered for (maximum 60). '
                          + '<b>Save the list</b> &mdash; a merit list is prepared only for candidates who have selected at least one district.'
                        : 'Phase ' + CURRENT_PHASE + ': select the district and ITI combinations you want to be considered for '
                          + '(maximum 60). <b>Save the list</b> &mdash; a merit list is prepared only for candidates who have selected at least one ITI.';
                    document.getElementById("itiColHead").style.display = phaseOne ? "none" : "";
                    document.getElementById("govtColHead").style.display = phaseOne ? "none" : "";
                    document.getElementById("addRowBtn").value = phaseOne ? "Add District" : "Add ITI";
                    document.getElementById("saveSelBtn").value = phaseOne ? "Save District Selections" : "Save ITI Selections";
                    loadDistrictOptions(function () {
                        if (document.getElementById("locDeptBody").rows.length === 0) { addSelectRow(); }
                        loadSavedSelections();
                    });
                }

                function addSelectRow(distCode, itiCode) {
                    var phaseOne = isPhaseOne();
                    var body = document.getElementById("locDeptBody");
                    if (body.rows.length >= MAX_CHOICES) {
                        alert("A maximum of " + MAX_CHOICES + " selections can be made.");
                        return;
                    }
                    var row = body.insertRow(-1);
                    var cSno = row.insertCell(0);
                    var cDist = row.insertCell(1);
                    var cGov = row.insertCell(2);
                    var cIti = row.insertCell(3);
                    var cDel = row.insertCell(4);
                    cGov.className = "selGovt";
                    cGov.align = "center";

                    var districtSelect = document.createElement("select");
                    districtSelect.className = "selDistrict";
                    districtSelect.style.width = "180px";
                    districtSelect.innerHTML = '<option value="">--Select District--</option>';
                    DISTRICT_OPTIONS.forEach(function (d) {
                        var o = document.createElement("option");
                        o.value = d.code;
                        o.textContent = d.name;
                        districtSelect.appendChild(o);
                    });
                    districtSelect.onchange = function () {
                        if (phaseOne && isDuplicateDistrict(this)) {
                            alert("you have already Applied for this District");
                            this.value = "";
                            return;
                        }
                        if (!phaseOne) { loadItisForRow(this); }
                    };
                    cDist.appendChild(districtSelect);

                    if (phaseOne) {
                        cGov.style.display = "none";
                        cIti.style.display = "none";
                    } else {
                        var itiSelect = document.createElement("select");
                        itiSelect.className = "selIti";
                        itiSelect.style.width = "320px";
                        itiSelect.innerHTML = '<option value="">--Select ITI--</option>';
                        itiSelect.onchange = function () {
                            updateGovtCell(this);
                            showTrades(this.value);
                        };
                        cIti.appendChild(itiSelect);
                    }

                    var remove = document.createElement("input");
                    remove.type = "button";
                    remove.value = "Delete";
                    remove.onclick = function () {
                        body.deleteRow(row.rowIndex);
                        renumberRows();
                    };
                    cDel.appendChild(remove);

                    if (distCode) { districtSelect.value = distCode; }
                    renumberRows();
                    if (distCode && !phaseOne) { loadItisForRow(districtSelect, itiCode); }
                }

                function renumberRows() {
                    var rows = document.getElementById("locDeptBody").rows;
                    for (var i = 0; i < rows.length; i++) { rows[i].cells[0].innerHTML = (i + 1); }
                }

                // Reuses GET /admission/eligible-itis/{distCode}. That lookup returns one row per
                // trade, so the ITI list is de-duplicated on iti_code before it is shown.
                function loadItisForRow(districtSelect, preselectIti) {
                    var itiSelect = districtSelect.closest("tr").querySelector(".selIti");
                    var distCode = districtSelect.value;
                    itiSelect.innerHTML = '<option value="">--Select ITI--</option>';
                    if (!distCode) { return; }
                    $.get('${backendBaseUrl}/admission/eligible-itis/' + encodeURIComponent(distCode),
                        function (list) {
                            var seen = {};
                            (list || []).forEach(function (i) {
                                if (seen[i.itiCode]) { return; }
                                seen[i.itiCode] = true;
                                var o = document.createElement("option");
                                o.value = i.itiCode;
                                o.textContent = i.itiName + ' (' + i.ncvtCode + ')';
                                o.dataset.govt = i.govt;
                                itiSelect.appendChild(o);
                            });
                            if (preselectIti) { itiSelect.value = preselectIti; updateGovtCell(itiSelect); }
                        });
                }

                // Government/Private, shown next to the selected ITI (legacy getitibydist.jsp:87-100).
                function updateGovtCell(itiSelect) {
                    var cell = itiSelect.closest("tr").querySelector(".selGovt");
                    if (!cell) { return; }
                    var opt = itiSelect.options[itiSelect.selectedIndex];
                    var govt = opt ? opt.dataset.govt : "";
                    cell.innerHTML = (govt === 'G') ? 'Government' : (govt === 'P' ? 'Private' : (govt || ''));
                }

                // Inline duplicate-district guard (legacy Editviewpage.jsp:772-789 getcollegesdist).
                function isDuplicateDistrict(select) {
                    var value = select.value;
                    if (!value) { return false; }
                    var all = document.querySelectorAll(".selDistrict");
                    for (var i = 0; i < all.length; i++) {
                        if (all[i] !== select && all[i].value === value) { return true; }
                    }
                    return false;
                }
                // Same information the legacy getTrade_info.jsp showed for the chosen ITI.
                function showTrades(itiCode) {
                    var box = document.getElementById("itiInfo");
                    if (!itiCode) { box.innerHTML = ""; return; }
                    $.get('${backendBaseUrl}/admission/iti/' + encodeURIComponent(itiCode) + '/info',
                        function (info) { renderTrades(itiCode, box, info); })
                     .fail(function () { renderTrades(itiCode, box, null); });
                }

                function renderTrades(itiCode, box, info) {
                    var head = '';
                    if (info) {
                        head = '<table align="center">'
                            + '<tr><td align="center"><font color="blue">'
                            + (info.itiName == null ? '' : info.itiName) + '(' + itiCode + ')</font></td></tr>'
                            + '<tr><td align="center"><font color="red">'
                            + (info.address == null ? '' : info.address) + ' '
                            + (info.pinCode == null ? '' : info.pinCode) + '</font></td></tr>'
                            + (info.website ? '<tr><td align="center"><font color="red"><a href="'
                                + info.website + '" target="_blank">' + info.website + '</a></font></td></tr>' : '')
                            + '</table>';
                    }
                    $.get('${backendBaseUrl}/admission/iti/' + encodeURIComponent(itiCode) + '/trades',
                        function (list) {
                            var html = head + '<p>Listed are the Trades and Seats Available </p>'
                                + '<table border="1" align="center" style="margin:4px auto;">'
                                + '<tr><th>Trade Name</th><th>Number of Seats</th></tr>';
                            (list || []).forEach(function (t) {
                                html += '<tr><td>' + (t.tradeName || t.tradeShort) + '</td><td>'
                                    + (t.strength == null ? 0 : t.strength) + '</td></tr>';
                            });
                            box.innerHTML = html + '</table>';
                        }).fail(function () { box.innerHTML = head; });
                }

                function collectChoices() {
                    var phaseOne = isPhaseOne();
                    var rows = document.getElementById("locDeptBody").rows;
                    var choices = [];
                    for (var i = 0; i < rows.length; i++) {
                        var distCode = rows[i].querySelector(".selDistrict").value;
                        if (phaseOne) {
                            if (!distCode) { continue; }
                            choices.push({ distCode: distCode });
                        } else {
                            var itiEl = rows[i].querySelector(".selIti");
                            var itiCode = itiEl ? itiEl.value : "";
                            if (!itiCode) { continue; }
                            choices.push({ distCode: distCode, itiCode: itiCode });
                        }
                    }
                    return choices;
                }

                function saveSelections() {
                    if (!CURRENT_REGID) { alert("Load your application first."); return false; }
                    if (!$("#consent").prop("checked")) { alert("Consent is required"); $('#consent').focus(); return false; }
                    var phaseOne = isPhaseOne();
                    var choices = collectChoices();
                    if (choices.length === 0) { alert(phaseOne ? "Please select at least one district." : "Please select at least one ITI."); return false; }
                    $.ajax({
                        url: '${backendBaseUrl}/admission/student-trade-selection/' + CURRENT_REGID,
                        type: 'POST', contentType: 'application/json',
                        data: JSON.stringify({ regid: CURRENT_REGID, choices: choices }),
                        success: function (r) {
                            var what = (r && r.districtOnly) ? 'district' : 'ITI';
                            showSelectMessage(true, 'Saved ' + r.saved + ' ' + what + ' selection(s) for year '
                                + r.year + ' (phase ' + r.phase + ').');
                            showApplicationSuccess(CURRENT_REGID);
                            loadSavedSelections();
                        },
                        error: function (xhr) {
                            var msg = "Could not save your selections.";
                            if (xhr.responseJSON && xhr.responseJSON.error) { msg = xhr.responseJSON.error; }
                            showSelectMessage(false, msg);
                        }
                    });
                    return false;
                }

                function loadSavedSelections() {
                    if (!CURRENT_REGID) { return; }
                    var phaseOne = isPhaseOne();
                    $.get('${backendBaseUrl}/admission/student-trade-selection/' + CURRENT_REGID,
                        function (list) {
                            var box = document.getElementById("savedSelections");
                            if (!list || list.length === 0) {
                                box.innerHTML = '<p align="center">' + (phaseOne ? 'No district selection saved yet.' : 'No ITI selection saved yet.') + '</p>';
                                return;
                            }
                            var html = '<b>Saved ' + (phaseOne ? 'district' : 'ITI') + ' selections (' + list.length + ')</b>'
                                + '<table border="1" align="center" style="margin:6px auto;">'
                                + '<tr><th>S.No</th><th>District Name</th>'
                                + (phaseOne ? '' : '<th>Government/Private</th><th>College Name</th>') + '</tr>';
                            list.forEach(function (r, idx) {
                                html += '<tr><td align="center">' + (idx + 1) + '</td><td>'
                                    + (r.distName || r.distCode) + '</td>';
                                if (!phaseOne) {
                                    var govt = (r.govt === 'G') ? 'Government' : (r.govt === 'P' ? 'Private' : '');
                                    html += '<td>' + govt + '</td><td>' + (r.itiName || r.itiCode) + '</td>';
                                }
                                html += '</tr>';
                            });
                            box.innerHTML = html + '</table>';
                        });
                }

                function showSelectMessage(ok, msg) {
                    document.getElementById("selectResult").innerHTML =
                        '<div style="border:2px solid ' + (ok ? '#28a745' : '#dc3545')
                        + ';background-color:' + (ok ? '#d4edda' : '#f8d7da')
                        + ';padding:10px;width:70%;margin:10px auto;">' + msg + '</div>';
                }

                // Success banner shown after the application is submitted, with the link
                // to the printable acknowledgement (Application_printdist).
                function showApplicationSuccess(regid) {
                    var box = document.getElementById("applySuccess");
                    box.innerHTML = '<div class="apply-success">'
                        + 'You have successfully applied for the ITI with Registration Id <b>' + regid + '</b>. '
                        + '<a href="${pageContext.request.contextPath}/print-application?regid=' + regid
                        + '" target="_blank">Click here to download the application</a>.'
                        + '</div>';
                    box.style.display = "";
                }
            </script>

    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/legacy-form.css">
    <%@ include file="_windowGate.jsp" %>
    </head>
    <body class="lg-page">
        
<center>
    <img src="${pageContext.request.contextPath}/images/gen.jpg" id="banner-id" width="100%">
</center>

<!-- ============ GATE: LOOK UP THE REGISTRATION ============ -->
<div id="gateDiv">
        <form name="EditForm_phase2" method="post" action="#" onsubmit="return fetchApplication()">
            <h2 style="background-color: lightgreen" align="center"  class="style4" >Application Form for Admission into the Industrial Training Institute for the session <span class="sessionYearPhase"></span> </h2>

            <div align="center"><b><font color="red">Note:: Applicant has to register his/her details first by clicking <a href="${pageContext.request.contextPath}/student-registration">Student Registration</a> note your registration number, then click &quot;Apply for ITI&quot;<br><br></br> </font></b>
            </div> <br>

                <table width="50%" height="30%" align="center" bgcolor="#cbd6b2" style="border:2px solid black;">
                    <tr bgcolor="#4ab131">
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td></td>
                        <td><u>Student Apply For ITI Form</u></td>
                    </tr>
                    <tr>
                        <td>SSC HallTicket Number</td>
                        <td><input type="text" name="ssc_regno" value="" id="ssc_regno"></td>
                    </tr> 
                    <tr>
                        <td>Date of Birth</td>
                        <td> <input type="date" name="dob" value="" id="dob">
                        </td>      
                    </tr>
                    <tr>
                        <td>Registration Id<font color="red">*</font></td>
                        <td><input type="text" name="regid" maxlength="10" value="" onkeypress="return NumericsOnly(event);" id="regid"></td>
                    </tr>  
                    <tr>
                        <td><b><label for="captcha">Captcha<font color="red">*</font></label></b></td>
                        <td><input type="text" name="captcha" value="" id="captcha" autocomplete="off"></td>
                    </tr>
                    <tr>
                        <td></td>
                        <td>
                            <input type="button" id="captchaRef" value="&#8635; New Captcha">
                            <img src="${pageContext.request.contextPath}/captcha" id="captchaImage" border="0" width="135" height="30">
                        </td>
                    </tr>
                    <tr colspan="4">
                        <td style="text-align: center" > 
                            <a href="${pageContext.request.contextPath}/"> <input type="button" name="back" id="submit" Style="width:100px;" value="Back to Home"/></a>
                            <input type="submit" value="Submit"></td>

                    </tr>
                    <tr bgcolor="#4ab131">
                        <td colspan="2">&nbsp;</td>
                    </tr>
                </table>
                <div id="gateErrors" align="center"></div>
            </form>
</div>
<!-- ============ STEP 3: SELECTION (phase 1 = districts, phase 2+ = district + ITI) ============ -->
<div id="selectDiv" style="display:none;">
    <h2 id="selectHeading" style="background-color: lightgreen" align="center" class="style4">Selection (Step 2)</h2>

    <p id="selectInstruction" align="center" style="width:70%;margin:auto;">
        Select the ITIs you want to be considered for, in order of preference (maximum 60).
        <b>Save the list</b> &mdash; a merit list is prepared only for candidates who have selected at least one ITI.
    </p>

    <div id="applyDetails" style="display:none;width:70%;margin:10px auto;"></div>
    <div id="applyMarks" style="display:none;width:70%;margin:10px auto;"></div>

    <div id="applySuccess" style="display:none;"></div>

    <div id="selectResult"></div>

    <table width="70%" align="center" bgcolor="#cbd6b2" style="border:2px solid black;">
        <tr bgcolor="#4ab131" style="color:#fff;">
            <th style="width:60px;">S.No</th>
            <th style="width:200px;">District</th>
            <th id="govtColHead" style="width:120px;">Government/Private</th>
            <th id="itiColHead">ITI</th>
            <th style="width:90px;">Remove</th>
        </tr>
        <tbody id="locDeptBody"></tbody>
    </table>

    <div align="center" style="margin:10px;">
        <input type="checkbox" id="consent" name="aadhar">
        <label for="consent"> I hereby consent to the use of Aadhaar Numbers  provided in the
            application to carryout Identity Validation for ITI college admission process.</label>
    </div>

    <div align="center" style="margin:10px;">
        <input type="button" id="addRowBtn" value="Add ITI" onclick="addSelectRow();">
        <input type="button" id="saveSelBtn" value="Save Selections" onclick="saveSelections();">
    </div>

    <div id="itiInfo" align="center"></div>
    <div id="savedSelections" style="width:70%;margin:10px auto;"></div>
</div>
<style>
    .apply-details{ width:100%; margin:10px auto; border-collapse:collapse; background:#cbd6b2; border:2px solid #000; }
    .apply-details td{ border:1px solid #7ba7c9; padding:6px 8px; }
    .apply-details tr.hdr td{ background:#4ab131; color:#fff; font-weight:bold; text-align:center; font-size:larger; }
    .apply-details td.lbl{ background:#b7e2f3; color:#1e43cc; font-weight:bold; width:20%; }
    .apply-success{ border:2px solid #28a745; background:#d4edda; color:#14532d; padding:14px;
        width:70%; margin:14px auto; text-align:center; font-size:15px; font-weight:bold; }
    .apply-success a{ color:#000099; font-weight:bold; }
    #footer{
        position:fixed;
        bottom:0px;
        width:100%;
        height:25px;
        padding-top: 8px;
        text-align: center;
        background-color: #0E4878;
        border-top: 1px #000000 solid;
        font-size: 12px;
        font-family: arial, verdana;
        color: #ffffff;
    }
</style>

<br><br>
<br><br>

<div id="footer">
    2013 @ All Rights Reserved &nbsp;&nbsp; Designed by &nbsp; National Informatics Center
    <font color="white"><a href="http://www.ap.nic.in" title="">National Informatics Center </a></font>
    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font color="white"><a href="${pageContext.request.contextPath}/">Disclaimer</a></font>

</div>


<%@ include file="../footer.jsp" %>
    </body>
</html>