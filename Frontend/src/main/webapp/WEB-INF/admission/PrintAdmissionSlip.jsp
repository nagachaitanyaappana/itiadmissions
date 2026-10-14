<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Admission Memo</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<style>
  .page-title { text-align:center; font-family:Verdana,Arial,sans-serif; font-size:22px; margin:18px 0 12px; color:#000; }
  .call-box { width:520px; max-width:94%; margin:0 auto 60px; border:1px solid #7a7a7a; background:#fff; }
  .call-box table { width:100%; border-collapse:collapse; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .call-box td { border:1px solid #7a7a7a; padding:6px 8px; }
  .call-box td.label { width:42%; background:#f2f2f2; font-weight:bold; }
  .call-box input[type=text] { width:96%; padding:4px; font-size:13px; }
  .call-box .btn-row td { text-align:center; background:#fff; }
  .submit-btn { background-color:#4CAF50; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; }
  .submit-btn:disabled { opacity:.55; cursor:default; }
  .reset-btn { background-color:#c0392b; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; margin-left:8px; }
  .print-btn { background-color:#0E4878; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; margin-left:8px; }
  .err { color:red; font-size:12px; display:block; }
  .act-row { text-align:center; margin:12px 0; }
  .msg-err { color:red; text-align:center; }
  #footer { position:fixed; bottom:0; width:100%; padding:8px; text-align:center; background:#0E4878; font-size:12px; color:#fff; font-family:arial,verdana; }
  #footer a { color:#fff; }

  /* ---- admission memo ---- */
  .memo-wrap { width:96%; max-width:980px; margin:0 auto 60px; font-family:Verdana,Arial,sans-serif; color:#000; }
  .memo-title { text-align:center; font-size:20px; font-weight:bold; margin:14px 0; }
  .memo-table { clear:both; width:100%; border-collapse:collapse; font-size:14px; }
  .memo-table th { text-align:left; padding:8px 10px; vertical-align:top; width:38%; }
  .memo-table td { padding:8px 10px; vertical-align:top; }
  .photo-cell { float:right; width:130px; text-align:center; margin:0 0 8px 12px; }
  .photo-cell img { max-width:120px; max-height:150px; border:1px solid #7a7a7a; }
  .fee-head { font-weight:bold; padding:10px 10px 4px; }
  .fee-line td { padding:3px 10px 3px 30px; }
  .sign-row td { text-align:left; padding:26px 12px 8px; }
  .sign-row .pr { text-align:right; font-weight:bold; }
  .convener { text-align:right; font-weight:bold; padding:8px 12px 18px; }
  @media print {
    #screen1, #footer, .act-row, .no-print { display:none !important; }
    #screen2 { display:block !important; }
    body { -webkit-print-color-adjust:exact; print-color-adjust:exact; }
    .memo-wrap { width:100%; max-width:none; }
  }
</style>
</head>
<body>
<br/>
<c:choose>
  <c:when test="${not empty sessionScope.roleId}"><%@ include file="/WEB-INF/reports/header.jsp" %></c:when>
  <c:otherwise><%@ include file="/WEB-INF/bannernew.jsp" %><%@ include file="/WEB-INF/navbars/openNavbar.jsp" %></c:otherwise>
</c:choose>
<div id="screen1">
  <div class="page-title">ITI Admissions Memo Interface</div>
  <div class="call-box">
    <table>
      <tr>
        <td class="label">Admission Number :</td>
        <td><input type="text" id="admissionNumber" placeholder="Enter Admission Number" /><span class="err" id="admissionNumberError"></span></td>
      </tr>
      <tr class="btn-row"><td colspan="2">
        <input type="button" class="submit-btn" id="goBtn" value="Submit" onclick="getAdmissionSlip();" />
        <input type="button" class="reset-btn" value="Reset" onclick="resetForm();" />
      </td></tr>
    </table>
  </div>
</div>
<div id="screen2" style="display:none;">
  <div class="memo-wrap" id="resultArea"></div>
  <div class="act-row no-print">
    <input type="button" class="print-btn" id="printBtn" value="Print" onclick="window.print();" style="display:none;" />
    <input type="button" class="reset-btn" value="Back to Search" onclick="backToSearch();" />
  </div>
</div>
<div id="footer">2013 @ All Rights Reserved&nbsp;&nbsp; Designed by&nbsp;&nbsp; National Informatics Center <a href="http://www.ap.nic.in">National Informatics Center</a>&nbsp;&nbsp;&nbsp;&nbsp; <a href="#">Disclaimer</a></div>
<script>
var CTX = '${pageContext.request.contextPath}';
var API_BASE = "${backendBaseUrl}";
function esc(v){ if(v===null||v===undefined) return ""; return String(v).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"); }
function val(id){ return document.getElementById(id).value.trim(); }
function setErr(id,msg){ document.getElementById(id).innerHTML = msg ? esc(msg) : ""; }
function txt(v){ if(v===null||v===undefined) return "N/A"; var s=String(v).trim(); return s==="" ? "N/A" : s; }
function fmtDate(v){ if(!v) return "N/A"; try { var d=new Date(v); if(isNaN(d.getTime())) return String(v); var dd=("0"+d.getDate()).slice(-2),mm=("0"+(d.getMonth()+1)).slice(-2); return dd+"/"+mm+"/"+d.getFullYear(); } catch(e){ return String(v); } }
function pick(o){ if(!o) return null; if(o.data && typeof o.data==="object" && !Array.isArray(o.data)) return o.data; return o; }
function row(n,v){ return "<tr><th>"+n+"</th><td>: "+esc(v||"")+"</td></tr>"; }

function resetForm(){
  document.getElementById("admissionNumber").value = "";
  setErr("admissionNumberError","");
  document.getElementById("resultArea").innerHTML = "";
  document.getElementById("printBtn").style.display = "none";
  document.getElementById("screen2").style.display = "none";
  document.getElementById("screen1").style.display = "block";
}

function backToSearch(){ resetForm(); }

function getAdmissionSlip(){
  var a = val("admissionNumber");
  if(!a){ setErr("admissionNumberError", "Please enter Admission Number."); return; }
  setErr("admissionNumberError","");
  var btn = document.getElementById("goBtn");
  btn.disabled = true; btn.value = "Loading...";
  document.getElementById("printBtn").style.display = "none";
  document.getElementById("screen1").style.display = "none";
  document.getElementById("screen2").style.display = "block";
  document.getElementById("resultArea").innerHTML = "<p style='text-align:center;'>Loading admission memo...</p>";
  var url = CTX + "/admissions/print-admission-slip/api/admission-slip?admissionNumber=" + encodeURIComponent(a);
  fetch(url)
    .then(function(resp){ return resp.json().then(function(b){ return {s: resp.status, b: b}; }); })
    .then(function(x){ renderSlip(x, a); })
    .catch(function(){ document.getElementById("resultArea").innerHTML = '<p class="msg-err">Unable to connect to the server. Please make sure the backend is running.</p>'; })
    .finally(function(){ btn.disabled = false; btn.value = "Submit"; });
}

function renderSlip(x, a){
  var area = document.getElementById("resultArea");
  if(x.s === 400){ backToSearch(); setErr("admissionNumberError", (x.b && x.b.error) ? x.b.error : "Please enter a valid Admission Number."); return; }
  if(x.s === 404){ area.innerHTML = '<p class="msg-err">Admission number not found.</p>'; return; }
  if(x.s >= 400){
    var em = (x.b && (x.b.error || x.b.message)) ? (x.b.error || x.b.message) : ("HTTP " + x.s);
    area.innerHTML = '<p class="msg-err">' + esc(em) + '</p>';
    return;
  }
  var d = pick(x.b);
  if(!d || (d.admissionNumber===null && d.admissionNumber===undefined)){ area.innerHTML = '<p class="msg-err">Admission number not found.</p>'; return; }

  var merit = txt(d.rank) === "N/A" ? ("" + esc(txt(d.registrationNumber))) : (esc(d.rank) + "/" + esc(txt(d.registrationNumber)));
  var itiText = esc(txt(d.itiCode)) + "/" + esc(txt(d.itiName));
  var tradeText = esc(txt(d.tradeName));
  var commCat = esc(txt(d.caste)) + "/" + esc(txt(d.reservationCategory));

  var h = "<div class='memo-title'>ITI Admission Memo For Phase " + esc(d.phase===null||d.phase===undefined?"":d.phase) + ", " + esc(txt(d.year)) + "</div>";
  h += "<div class='photo-cell'><img id='candPhoto' alt='No photo' /></div>";
  h += "<table class='memo-table'>";
  h += row("1. Name", txt(d.name));
  h += row("2. Father Name", txt(d.fname));
  h += row("3. Date of Birth", fmtDate(d.dob));
  h += "<tr><th>4. Merit/Registration Number</th><td>: " + merit + "</td></tr>";
  h += "<tr><th>5. Community/Reservation Category</th><td>: " + commCat + "</td></tr>";
  h += row("6. Date of Admission", fmtDate(d.dateOfAdmission));
  h += "<tr><th>7. Admitted In The Institute</th><td>: " + itiText + "</td></tr>";
  h += "<tr><th>8. Trade Allotted</th><td>: " + tradeText + "</td></tr>";
  h += row("9. Admission Number", txt(d.admissionNumber));
  h += "<tr><th colspan='2'>10. Tuition Fees for PVT ITI Admitted Candidate</th></tr>";
  h += "<tr class='fee-line'><td>Fee for Engineering Trades in Urban Areas</td><td>Rs." + esc(txt(d.feeUrbanEngg)) + "</td></tr>";
  h += "<tr class='fee-line'><td>Fee for Non Engineering Trades in Urban Areas</td><td>Rs." + esc(txt(d.feeUrbanNonEngg)) + "</td></tr>";
  h += "<tr class='fee-line'><td>Fee for Engineering Trades in Rural Areas</td><td>Rs." + esc(txt(d.feeRuralEngg)) + "</td></tr>";
  h += "<tr class='fee-line'><td>Fee for Non Engineering Trades in Rural Areas</td><td>Rs." + esc(txt(d.feeRuralNonEngg)) + "</td></tr>";
  h += "<tr><th colspan='2'>11. Submit Your Medical Fitness Certificate</th></tr>";
  h += "<tr class='sign-row'><td>Candidate Signature</td><td class='pr'>PRINCIPAL</td></tr>";
  h += "<tr><td colspan='2' class='convener'>District Convinor &amp; Principal, " + esc(txt(d.districtName)) + "</td></tr>";
  h += "</table>";

  area.innerHTML = h;
  loadCandidatePhoto(d.registrationNumber || d.registrationId);
  document.getElementById("printBtn").style.display = "";
}

function loadCandidatePhoto(regid){
  if(!regid || !API_BASE) return;
  var img = document.getElementById("candPhoto");
  if(!img) return;
  fetch(API_BASE + "/api/student/photo/" + encodeURIComponent(regid), { credentials:"include" })
    .then(function(r){ return r.json(); })
    .then(function(res){ if(res && res.photo){ img.src = "data:image/jpeg;base64," + res.photo; } })
    .catch(function(){});
}
document.getElementById("admissionNumber").addEventListener("keydown", function(e){ if(e.key === "Enter"){ e.preventDefault(); getAdmissionSlip(); } });
(function(){
  var p = new URLSearchParams(window.location.search).get("admissionNumber");
  if(p){ document.getElementById("admissionNumber").value = p; getAdmissionSlip(); }
})();
</script>
</body>
</html>
