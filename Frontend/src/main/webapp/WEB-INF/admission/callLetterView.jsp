<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Call Letter</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<style>
  .page-title { text-align:center; font-family:Verdana,Arial,sans-serif; font-size:22px; margin:18px 0 12px; color:#000; }
  .call-box { width:560px; max-width:94%; margin:0 auto 60px; border:1px solid #7a7a7a; background:#fff; }
  .call-box table { width:100%; border-collapse:collapse; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .call-box td { border:1px solid #7a7a7a; padding:6px 8px; }
  .call-box td.label { width:42%; background:#f2f2f2; font-weight:bold; }
  .call-box select, .call-box input[type=text] { width:96%; padding:4px; font-size:13px; }
  .call-box .btn-row td { text-align:center; background:#fff; }
  .mode-row td { background:#e4eeb9; font-weight:bold; }
  .mode-row label { margin-right:18px; font-weight:normal; }
  .submit-btn { background-color:#4CAF50; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; }
  .submit-btn:disabled { opacity:.55; cursor:default; }
  .reset-btn { background-color:#c0392b; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; margin-left:8px; }
  .print-btn { background-color:#0E4878; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; margin-left:8px; }
  .err { color:red; font-size:12px; display:block; }
  .msg { text-align:center; color:#c0392b; font-weight:bold; margin:14px 0; }
  .act-row { text-align:center; margin:12px 0; }
  #footer { position:fixed; bottom:0; width:100%; padding:8px; text-align:center; background:#0E4878; font-size:12px; color:#fff; font-family:arial,verdana; }
  #footer a { color:#fff; }

  /* ---- printable call letter ---- */
  .cl-wrap { width:92%; max-width:820px; margin:0 auto 60px; font-family:"Times New Roman",Georgia,serif; color:#000; }
  .cl-letter { padding:18px 26px 30px; margin-bottom:18px; background:#fff; border:1px solid #bbb; font-size:14px; }
  .cl-letter p { margin:6px 0; line-height:1.5; }
  .cl-letter .center { text-align:center; }
  .cl-letter .right { text-align:right; }
  .cl-letter .just { text-align:justify; }
  .cl-letter .h-gov { font-size:16px; font-weight:bold; }
  .cl-letter .h-dept { font-size:15px; font-weight:bold; }
  .cl-letter .sub { font-size:15px; font-weight:bold; margin:10px 0; }
  .cl-letter ol { margin:8px 0 8px 22px; padding:0; }
  .cl-letter ol li { margin:4px 0; text-align:justify; }
  .cl-letter .fee { margin:4px 0 4px 18px; }
  .cl-letter .sign { margin-top:16px; }
  @media print {
    #screen1, #footer, .act-row, .no-print { display:none !important; }
    #screen2 { display:block !important; }
    .cl-wrap { width:100%; max-width:none; margin:0; }
    .cl-letter { border:none; margin:0; padding:0 10px; page-break-after:always; }
    .cl-letter:last-child { page-break-after:auto; }
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
  <div class="page-title">CALL LETTER GENERATION</div>
  <div class="call-box">
    <table>
      <tr class="mode-row">
        <td colspan="2">
          Mode:
          <label><input type="radio" name="mode" value="bulk" checked="checked" onclick="switchMode()" /> By Merit Rank Range</label>
          <label><input type="radio" name="mode" value="single" onclick="switchMode()" /> By Register Number</label>
        </td>
      </tr>
      <tr class="bulk-row">
        <td class="label">From Rank :</td>
        <td><input type="text" id="fromRank" maxlength="6" /><span class="err" id="fromRankError"></span></td>
      </tr>
      <tr class="bulk-row">
        <td class="label">To Rank :</td>
        <td><input type="text" id="toRank" maxlength="6" /><span class="err" id="toRankError"></span></td>
      </tr>
      <tr class="bulk-row">
        <td class="label">Caste :</td>
        <td><select id="casteSel"><option value="all">All</option><option value="w">Women</option></select><span class="err" id="casteError"></span></td>
      </tr>
      <tr class="single-row" style="display:none;">
        <td class="label">Register Number :</td>
        <td><input type="text" id="regid" maxlength="15" /><span class="err" id="regidError"></span></td>
      </tr>
      <tr class="btn-row"><td colspan="2"><input type="button" class="submit-btn" id="goBtn" value="Submit" onclick="getCallLetter();" /><input type="button" class="reset-btn" value="Reset" onclick="resetCallLetter();" /></td></tr>
    </table>
  </div>
</div>
<div id="screen2" style="display:none;">
  <div class="act-row no-print">
    <input type="button" class="print-btn" id="printBtn" value="Print" onclick="window.print();" />
    <input type="button" class="reset-btn" value="Back to Search" onclick="resetCallLetter();" />
  </div>
  <div class="cl-wrap" id="resultArea"></div>
</div>
<div id="footer">2013 @ All Rights Reserved&nbsp;&nbsp;Designed by&nbsp;&nbsp;National Informatics Center</div>
<script>
var CTX = "${pageContext.request.contextPath}";
var API_BASE = "${backendBaseUrl}";
var DIST = "${sessionScope.insCode}";
if(!DIST){ DIST = localStorage.getItem('insCode') || ''; }

function esc(v){ if(v===null||v===undefined) return ""; return String(v).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;"); }
function val(id){ return document.getElementById(id).value.trim(); }
function setErr(id,msg){ document.getElementById(id).innerHTML = msg ? esc(msg) : ""; }
function today(){ var d=new Date(); return d.getDate()+"/"+(d.getMonth()+1)+"/"+d.getFullYear(); }
function currentMode(){ var el=document.querySelector('input[name=mode]:checked'); return el ? el.value : 'bulk'; }

function switchMode(){
  var bulk = currentMode()==='bulk';
  document.querySelectorAll('.bulk-row').forEach(function(r){ r.style.display = bulk ? '' : 'none'; });
  document.querySelectorAll('.single-row').forEach(function(r){ r.style.display = bulk ? 'none' : ''; });
  setErr('fromRankError',''); setErr('toRankError',''); setErr('casteError',''); setErr('regidError','');
}

function loadCastes(){
  var sel = document.getElementById('casteSel');
  if(!API_BASE) return;
  fetch(API_BASE + '/api/dsc/caste-list', { credentials:'include' })
    .then(function(r){ return r.json(); })
    .then(function(res){
      var list = (res && res.data) ? res.data : [];
      var seen = {};
      list.forEach(function(item){
        var code = item.casteCode || item.caste_code;
        if(!code || seen[code]) return;
        seen[code] = true;
        var opt = document.createElement('option');
        opt.value = code; opt.textContent = code;
        sel.appendChild(opt);
      });
    })
    .catch(function(){});
}

function getCallLetter(){
  var mode = currentMode();
  if(!DIST){ alert('District not found in session. Please log in as a district user.'); return; }
  var fromErr="", toErr="", regErr="";
  if(mode==='single'){
    var reg = val('regid');
    if(!reg) regErr = 'Register Number is required.';
    else if(!/^\d+$/.test(reg)) regErr = 'Register Number must be numeric.';
    setErr('regidError', regErr);
    setErr('fromRankError',''); setErr('toRankError',''); setErr('casteError','');
    if(regErr) return;
  } else {
    var f = val('fromRank'), t = val('toRank');
    if(!f) fromErr = 'From Rank is required.';
    else if(!/^\d+$/.test(f)) fromErr = 'From Rank must be a valid numeric rank.';
    if(!t) toErr = 'To Rank is required.';
    else if(!/^\d+$/.test(t)) toErr = 'To Rank must be a valid numeric rank.';
    if(!fromErr && !toErr && parseInt(f,10) > parseInt(t,10)) toErr = 'From Rank must not be greater than To Rank.';
    if(!fromErr && !toErr && (parseInt(t,10) - parseInt(f,10)) > 500) toErr = 'Ranks difference should be less than 500.';
    setErr('fromRankError', fromErr); setErr('toRankError', toErr); setErr('casteError',''); setErr('regidError','');
    if(fromErr || toErr) return;
  }

  var btn = document.getElementById('goBtn');
  var area = document.getElementById('resultArea');
  btn.disabled = true; btn.value = 'Loading...';
  document.getElementById('screen1').style.display = 'none';
  document.getElementById('screen2').style.display = 'block';
  area.innerHTML = "<p class='msg'>Loading call letter records...</p>";

  var url;
  if(mode==='single'){
    url = CTX + '/CallLetterView/api/call-letter/print?distCode=' + encodeURIComponent(DIST)
        + '&regid=' + encodeURIComponent(val('regid'));
  } else {
    url = CTX + '/CallLetterView/api/call-letter/print?distCode=' + encodeURIComponent(DIST)
        + '&fromRank=' + encodeURIComponent(val('fromRank'))
        + '&toRank=' + encodeURIComponent(val('toRank'))
        + '&caste=' + encodeURIComponent(val('casteSel'));
  }
  fetch(url)
    .then(function(r){ return r.json().then(function(b){ return {s:r.status, b:b}; }); })
    .then(function(x){ renderResult(x); })
    .catch(function(){ area.innerHTML = "<p class='msg'>Backend unavailable. Please try again later.</p>"; })
    .finally(function(){ btn.disabled = false; btn.value = 'Submit'; });
}

function renderResult(x){
  var area = document.getElementById('resultArea');
  if(x.s >= 400){
    var em = (x.b && (x.b.error || x.b.message)) ? (x.b.error || x.b.message) : ("HTTP " + x.s);
    area.innerHTML = "<p class='msg'>Error: " + esc(em) + "</p>";
    return;
  }
  var d = x.b || {};
  var letters = Array.isArray(d.letters) ? d.letters : [];
  if(letters.length === 0){
    area.innerHTML = "<p class='msg'>No candidates found for the selected " + (currentMode()==='single' ? 'register number' : 'rank range and caste') + ".</p>";
    return;
  }
  var h = "";
  letters.forEach(function(L){ h += renderLetter(d, L); });
  area.innerHTML = h;
}

function renderLetter(d, L){
  var district = esc(d.district || '');
  var heading = esc(d.heading || 'ANDHRA PRADESH');
  var headingShort = esc(d.headingShort || 'A.P');
  var dirComm = esc(d.dirComm || 'COMMISSIONER');
  var stateCode = d.stateCode || '';

  var feeHtml;
  if(stateCode === '02' && d.feeUrbanEngg){
    feeHtml = '<li>Tuition Fees for PVT ITI Admitted Candidate'
      + '<div class="fee">i) Fee for Engineering Trades in Urban Areas &nbsp; Rs.' + esc(d.feeUrbanEngg) + '</div>'
      + '<div class="fee">ii) Fee for Non Engineering Trades in Urban Areas &nbsp; Rs.' + esc(d.feeUrbanNonEngg) + '</div>'
      + '<div class="fee">iii) Fee for Engineering Trades in Rural Areas &nbsp; Rs.' + esc(d.feeRuralEngg) + '</div>'
      + '<div class="fee">iv) Fee for Non Engineering Trades in Rural Areas &nbsp; Rs.' + esc(d.feeRuralNonEngg) + '</div>'
      + '</li>';
  } else {
    feeHtml = '<li>Tuition Fees for PVT ITI Admitted Candidate : 7700 (Per Year)</li>';
  }

  return '<div class="cl-letter">'
    + '<p class="center h-gov">GOVERNMENT OF ' + heading + '</p>'
    + '<p class="center h-dept">' + dirComm + ' OF EMPLOYMENT AND TRAINING, ' + headingShort + '., VIJAYAWADA</p>'
    + '<p>Office of the Principal,<br/><b>' + district + '</b></p>'
    + '<p class="right">Dated: <b>' + esc(today()) + '</b></p>'
    + '<p class="center sub">counseling FOR GOVT. I.T.Is/PRIVATE I.T.Is.</p>'
    + '<p>Merit Order No: <b>' + esc(L.rank) + '</b> in <b>' + district + '</b> with Register Number: <b>' + esc(L.regid) + '</b></p>'
    + '<p>Sri/Kum <b>' + esc(L.name) + '</b> S/o. D/o <b>' + esc(L.fname) + '</b></p>'
    + '<p class="just">is advised to report at this Industrial Training Institute on <b>' + esc(L.calDate || '-') + '</b> at <b>' + esc(L.calTime || '-') + '</b> sharp for '
    + 'counseling and selection. If he/she fails to attend the counseling on the scheduled date and time his/her admission into ITI will not be considered. '
    + 'Such of these candidates who do not report for counseling at the scheduled time they will be counselinged before the closure of the session of the day. '
    + 'But they will be eligible only into such trades and such institutions where seats are vacant at that point of time. Selection will be made on '
    + 'Merit-cum-Reservation as per admission rules inforce for Trade/Place (i.e. institute) choice of the applicant will be as per availability of seats at '
    + 'the time of counseling in the trade/Institute.</p>'
    + '<p class="just">This call letter is only for an counseling and does not give any right or guarantee or admission in ITI.</p>'
    + '<p class="just">He/she is allowed to bring parent/guardian at the time of counseling for his/her guidance in selection of Trade/place (Institute).</p>'
    + '<p class="just">Selection is made according to availability of seats in I.T.I.</p>'
    + '<p class="just">No T.A &amp; D.A is admissible for attending the above counseling.</p>'
    + '<ol>'
    + '<li>(a) Selections are made to such of these Trades/Units affiliated to NCVT in the I.T.Is. '
    + '(b) Selections are made under State Council for Vocational Training for I.T.Is./Units which are permitted by the State Director of Employment &amp; Training '
    + 'Department which are not covered by (NCVT) National Council for Vocational Training.</li>'
    + '<li>He/she should attend the counseling with all certificates in original T.C. The T.C. in original to be produced after selection within a week. '
    + 'The original certificates of selected candidates will be retained in the institute till the completion of the training. Hence the candidate is advised to '
    + 'keep sufficient number of true copies before submitting the original certificates.</li>'
    + '<li>Admission are subject to medical fines by the medical Officer of the Institute.</li>'
    + '<li>In case of S.C., S.T. and B.C Caste Certificates issued by the M.R.O should be submitted.</li>'
    + '<li><b>CAUTION MONEY:</b> Candidates selected for admission into Govt. and Private I.T.I should pay Rs. 60/- and Rs. 100/- respectively towards the '
    + 'Caution Money Deposit immediately after selection. SC/ST candidates are exempted from payment of Caution Money Deposit.</li>'
    + feeHtml
    + '<li>The children of Ex-Servicemen should submit the certificates issued by the Secretary, Dist. Sainik Board in original.</li>'
    + '</ol>'
    + '<p class="sign">Name: <b>' + esc(L.name) + '</b><br/>Father Name: <b>' + esc(L.fname) + '</b><br/>Address: ' + esc(L.address || '') + '</p>'
    + '</div>';
}

function resetCallLetter(){
  document.getElementById('fromRank').value = "";
  document.getElementById('toRank').value = "";
  document.getElementById('regid').value = "";
  document.getElementById('casteSel').value = "all";
  setErr('fromRankError',''); setErr('toRankError',''); setErr('casteError',''); setErr('regidError','');
  document.getElementById('resultArea').innerHTML = "";
  document.getElementById('screen2').style.display = 'none';
  document.getElementById('screen1').style.display = 'block';
}

switchMode();
loadCastes();
</script>
</body>
</html>
