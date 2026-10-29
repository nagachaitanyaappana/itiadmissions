<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Admission Counseling</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<style>
body{font-family:Verdana,Arial,sans-serif;background:#fff;padding-bottom:120px;}
.page-title{text-align:center;font-size:20px;margin:16px 0 4px;font-weight:bold;}
.sub-line{text-align:center;font-size:12px;margin-bottom:10px;}
.box{width:96%;margin:0 auto 14px;border:1px solid #7a7a7a;background:#fff;}
.box table{width:100%;border-collapse:collapse;font-size:12px;}
.box td,.box th{border:1px solid #7a7a7a;padding:5px 6px;}
.box th{background:#e4eeb9;}
.rank-box{width:460px;margin:0 auto 24px;border:1px solid #7a7a7a;}
.rank-box table{width:100%;border-collapse:collapse;font-size:13px;}
.rank-box td{border:1px solid #7a7a7a;padding:6px 8px;}
.rank-box td.label{width:38%;background:#f2f2f2;font-weight:bold;}
.rank-box input[type=text]{width:94%;padding:4px;}
.btn-row td{text-align:center;}
.submit-btn{background-color:#4CAF50;border:none;color:#fff;padding:6px 40px;font-size:15px;font-weight:bold;cursor:pointer;}
.submit-btn:disabled{opacity:.55;cursor:default;}
.prn-btn{background-color:#0E4878;border:none;color:#fff;padding:6px 40px;font-size:15px;font-weight:bold;cursor:pointer;margin-left:8px;}
.err{color:red;font-size:12px;}
.ok{color:green;font-weight:bold;}
.notice{background:#fff3cd;border:1px solid #d9a600;padding:8px 10px;margin:8px 0;font-size:13px;}
.cand-head{background:#e4eeb9;font-weight:bold;text-align:center;font-size:14px;}
.matrix-wrap{overflow-x:auto;}
.matrix-wrap table{min-width:900px;}
.matrix-wrap th,.matrix-wrap td{text-align:center;font-size:11px;}
.tfv-f{background:#e8f5a8;font-weight:bold;}
.vacant-cell{background:#BCE954;font-weight:bold;}
.student-photo{display:block;width:100px;height:130px;object-fit:cover;margin:0 auto 4px;}
#admissionSection{margin-bottom:90px;}
#admForm{margin-bottom:50px;}
.memo{border:1px solid #7a7a7a;width:60%;margin:10px auto 100px;font-size:13px;border-collapse:collapse;}
.memo td{border:1px solid #7a7a7a;padding:6px 8px;}
.inline-input{padding:3px;font-size:12px;}
#footer{position:fixed;bottom:0;left:0;width:100%;padding:8px;text-align:center;background:#0E4878;font-size:12px;color:#fff;z-index:999;}
#footer a{color:#fff;}
@media print{#footer,.no-print{display:none;}}
</style>
</head>
<body>
<br/>
<c:choose><c:when test="${not empty sessionScope.roleId}"><%@ include file="/WEB-INF/reports/header.jsp" %></c:when><c:otherwise><%@ include file="/WEB-INF/bannernew.jsp" %><%@ include file="/WEB-INF/navbars/openNavbar.jsp" %></c:otherwise></c:choose>
<div class="page-title">Admission Counseling</div>
<div class="sub-line no-print">Enter the merit rank for the running phase. Candidate and seat matrix are resolved from the live admission database.</div>
<c:if test="${not admissionWindowOpen}"><div class="notice no-print">Admission Date is Expired or no admission window is configured.</div></c:if>
<div class="rank-box no-print" ${not admissionWindowOpen ? 'style="display:none;"' : ''}><table>
<tr><td class="cand-head" colspan="2">Enter Rank for process counseling</td></tr>
<tr><td class="label">Enter Rank :</td><td><input type="text" id="rank" value="${param.rank}" maxlength="6" /></td></tr>
<tr><td class="label">Phase :</td><td><input type="text" id="phase" value="${currentPhase}" maxlength="2" readonly="readonly" /></td></tr>
<tr><td class="label">Year :</td><td><input type="text" id="year" value="${currentYear}" maxlength="4" readonly="readonly" /></td></tr>
<tr class="btn-row"><td colspan="2"><input type="button" class="submit-btn" value="Submit" onclick="lookupRank();" /> <span class="err" id="rankError"></span></td></tr>
</table></div>
<div id="resultArea" style="width:96%;margin:0 auto;"></div>

<div class="box no-print" id="candBox" style="display:none;">
<table><tr><td class="cand-head" colspan="4">ITI Admissions For AUGUST, <span id="admYear"></span></td></tr><tr id="candRow"></tr></table>
<table id="admNotice" style="display:none;"><tr><td class="notice" id="admNoticeText"></td></tr>
<tr><td class="btn-row"><input type="button" class="prn-btn" value="Print Admission Memo" onclick="openMemo();" /></td></tr></table>
</div>

<div class="box no-print" id="admissionSection" style="display:none;">
<table><tr><td class="cand-head">Select ITI / Trade</td></tr></table>
<div class="matrix-wrap"><table>
<thead><tr><th rowspan="2">ITI Name</th><th rowspan="2">Trade Name</th><th rowspan="2">Total</th><th colspan="3">General</th><th colspan="3">IM</th><th colspan="3">PH</th><th colspan="3">EX-S</th><th rowspan="2">Sel</th></tr>
<tr><th>T</th><th>F</th><th>V</th><th>T</th><th>F</th><th>V</th><th>T</th><th>F</th><th>V</th><th>T</th><th>F</th><th>V</th></tr></thead>
<tbody id="matrixBody"></tbody>
</table></div>

<div class="box" id="shiftUnitBox" style="display:none;">
<table><tr><td class="cand-head">Shift / Unit</td></tr></table>
<div class="matrix-wrap"><table>
<thead><tr><th>Select</th><th>Shift</th><th>Unit</th><th>Strength</th><th>Strength Vacant</th></tr></thead>
<tbody id="shiftUnitBody"></tbody>
</table></div>
<div class="err" id="shiftUnitEmpty" style="display:none;padding:6px;">No shift/unit is permitted for this ITI and trade.</div>
</div>

<table id="admForm">
<tr><td class="cand-head" colspan="4">Admission Details</td></tr>
<tr><td>Id marks 1: <input type="text" id="idm1" class="inline-input" size="20" /></td><td>Id marks 2: <input type="text" id="idm2" class="inline-input" size="20" /></td></tr>
<tr><tr><td>SSC Reg No: <input type="text" id="sscReg" class="inline-input" size="14" /></td><td>SSC Year: <input type="text" id="sscYear" class="inline-input" size="8" /></td></tr>
<tr><td>SSC Board: <span id="sscBoardText"></span><input type="hidden" id="sscBoard" /></td>
<td>Type of Admission: <select id="admissionBoard"><option value="">Select Board</option></select></td></tr>
<tr><td>SSC Month: <select id="sscMonth" class="inline-input"><option value="">Select</option><option value="03">March</option><option value="04">Supplementary</option></select></td></tr>
<tr><td colspan="2" class="btn-row" style="padding:15px 0 25px;"><input type="button" class="submit-btn" id="takeBtn" value="Take Admission" onclick="takeAdmission();" /> <span class="err" id="takeErr"></span></td></tr>
</table>
<div style="height:50px;"></div>
</div>

<table class="memo" id="memoBox" style="display:none;">
<tr><td class="cand-head" colspan="2">Admission Memo</td></tr>
<tr><td>Admission Number</td><td class="ok" id="mAdmNo"></td></tr>
<tr><td>Candidate</td><td id="mCand"></td></tr>
<tr><td>Allotted ITI / Trade</td><td id="mIti"></td></tr>
<tr><td class="btn-row no-print" colspan="2"><input type="button" class="prn-btn" value="Print Admission Memo" onclick="openMemo();" /></td></tr>
</table>
<div id="footer">2013 @ All Rights Reserved Designed by National Informatics Center <a href="http://www.ap.nic.in">National Informatics Center</a></div>
<script>
var CTX='${pageContext.request.contextPath}';
var cur=null, sel=null, seatMatrix=[], shiftUnitOptions=[], lastAdmNum=null;
function esc(s){s=(s==null)?'':String(s);return s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');}
function txt(v){if(v==null)return 'N/A';var s=String(v).trim();return s===''?'N/A':s;}
function num(v){return (v==null||v==='')?0:parseInt(v,10)||0;}

function lookupRank(){
  var rank=document.getElementById('rank').value.trim();
  var phase=document.getElementById('phase').value.trim();
  var year=document.getElementById('year').value.trim();
  document.getElementById('rankError').innerHTML='';
  document.getElementById('admissionSection').style.display='none';
  document.getElementById('shiftUnitBox').style.display='none';
  document.getElementById('memoBox').style.display='none';
  document.getElementById('candBox').style.display='none';
  if(!rank){document.getElementById('rankError').innerHTML='Rank should not be empty.';return;}
  if(!phase){document.getElementById('rankError').innerHTML='Phase should not be empty.';return;}
  if(!/^\d{4}$/.test(year)){document.getElementById('rankError').innerHTML='Enter valid year e.g.2026';return;}
  document.getElementById('resultArea').innerHTML='<div class="box"><table><tr><td class="cand-head">Loading candidate...</td></tr></table></div>';
  fetch(CTX+'/AdmissionCounseling/api/candidate-resolve?rank='+encodeURIComponent(rank)+'&phase='+encodeURIComponent(phase)+'&year='+encodeURIComponent(year))
  .then(function(r){return r.json();})
  .then(function(resp){showCand(resp,rank,phase,year);})
  .catch(function(){document.getElementById('resultArea').innerHTML='<span class="err">Could not reach backend API.</span>';});
}

function showCand(resp,rank,phase,year){
  document.getElementById('resultArea').innerHTML='';
  var c=(resp&&resp.candidate)?resp.candidate:null;
  if(!c){
    document.getElementById('candBox').style.display='none';
    var src=(resp&&resp.source)?' (source: '+esc(resp.source)+')':'';
    document.getElementById('resultArea').innerHTML='<div class="box"><table><tr><td class="cand-head">No candidate found for Rank='+esc(rank)+', Phase='+esc(phase)+', Year='+esc(year)+src+'. Check the rank and the running phase.</td></tr></table></div>';
    return;
  }
  cur=c;
  sel=null;
  document.getElementById('sscReg').value=c.ssc_regno||'';
  document.getElementById('sscYear').value=c.ssc_year||'';
  document.getElementById('sscBoard').value=c.ssc_board||'';
  document.getElementById('sscBoardText').textContent=c.ssc_board||'N/A';
  document.getElementById('sscMonth').value=c.ssc_month_option||'';
  document.getElementById('idm1').value='';
  document.getElementById('idm2').value='';
  document.getElementById('admYear').innerHTML=esc(c.year||year);
  var photo=c.photo_base64
    ?'<img class="student-photo" src="data:image/jpeg;base64,'+esc(c.photo_base64)+'" alt="Student photo" />'
    :'<span>No photo available</span>';
  document.getElementById('candRow').innerHTML=
    '<td>'+photo+'Name:<b>'+esc(c.name||c.regid)+'</b><br/>Father Name:<b>'+esc(c.fatherName||'-')+'</b><br/>Mother Name:<b>'+esc(c.motherName||'-')+'</b><br/>Community:<b>'+esc(c.caste||'-')+'</b></td>'+
    '<td>Rank:<b>'+esc(c.rank)+'</b><br/>Reg No:<b>'+esc(c.regid)+'</b><br/>PHC/Ex-Service:<b>'+esc(c.phc||'-')+'/'+esc(c.exservice||'-')+'</b><br/>EWS/PWD:<b>'+esc(c.ews||'-')+'/'+esc(c.pwd_category||'-')+'</b></td>'+
    '<td>Dist:<b>'+esc(c.distName||c.dist_code||'-')+'</b><br/>ITI:<b>'+esc(c.iti_code||'-')+'</b><br/>Phase:<b>'+esc(c.phase||phase)+'</b></td>'+
    '<td>Gender:<b>'+esc(c.gender||'-')+'</b><br/>DOB:<b>'+esc(c.dob||'-')+'</b><br/>SSC Reg No:<b>'+esc(c.ssc_regno||'-')+'</b><br/>SSC Board/Year/Month:<b>'+esc(c.ssc_board||'-')+'/'+esc(c.ssc_year||'-')+'/'+esc(c.ssc_month||'-')+'</b><br/>Email:<b>'+esc(c.email||'-')+'</b><br/>Status:<b>'+esc(c.app_status||'-')+'</b></td>';
  document.getElementById('candBox').style.display='block';

  var admitted=!!c.is_admitted;
  var adm=c.admission_details||null;
  if(admitted&&adm){
    lastAdmNum=adm.adm_num||null;
    document.getElementById('admNotice').style.display='table';
    document.getElementById('admNoticeText').innerHTML='This candidate was already admitted in <b>'+esc(adm.iti_name||'-')+'</b> for <b>'+esc(adm.trade_name||'-')+'</b> on <b>'+esc(adm.date_of_admission||'-')+'</b> (Admission No: <b>'+esc(adm.adm_num||'-')+'</b>).';
    document.getElementById('admissionSection').style.display='none';
  }else{
    document.getElementById('admNotice').style.display='none';
    document.getElementById('admissionSection').style.display='block';
    loadBoards();
    loadMatrix(phase,year);
  }
}

function loadBoards(){
  var sel=document.getElementById('admissionBoard');
  if(sel.dataset.loaded==='1')return;
  fetch(CTX+'/AdmissionCounseling/api/iti-boards')
  .then(function(r){return r.json();})
  .then(function(res){
    var list=(res&&res.data)?res.data:[];
    list.forEach(function(b){
      var o=document.createElement('option');
      o.value=b.board_code;o.textContent=b.board_name;
      sel.appendChild(o);
    });
    sel.dataset.loaded='1';
  }).catch(function(){});
}

function loadMatrix(phase,year){
  var b=document.getElementById('matrixBody');
  b.innerHTML='<tr><td colspan="17">Loading seat matrix...</td></tr>';
  fetch(CTX+'/AdmissionCounseling/api/seat-matrix',{method:'POST'})
  .then(function(r){return r.json();})
  .then(function(res){
    seatMatrix=(res&&res.success&&res.data)?res.data:[];
    renderMatrix();
  })
  .catch(function(){b.innerHTML='<tr><td colspan="17" class="err">Unable to load the seat matrix.</td></tr>';});
}

function cat(item,k){
  var c=(item&&item.categories)?item.categories[k]:null;
  return c?c:{T:0,F:0,V:0};
}

function hasStudentReservation(item, cand){
  if(!cand || !item) return false;
  var vac = item.vacancies || {};
  var caste = (cand.caste || '').trim();
  var isFemale = cand.gender && String(cand.gender).toLowerCase().indexOf('f') === 0;
  var isPhc = (cand.phc === 'Yes' || cand.phc === 't' || cand.phc === 'true' || cand.phc === true);
  var isExs = (cand.exservice === 'Yes' || cand.exservice === 't' || cand.exservice === 'true' || cand.exservice === true);

  function vCount(catName){
    if(!catName) return 0;
    var k1 = catName.trim();
    var k2 = k1.replace(/_/g, '-');
    var k3 = k1.replace(/-/g, '_');
    return num(vac[k1] != null ? vac[k1] : (vac[k2] != null ? vac[k2] : vac[k3]));
  }

  function wCat(base){
    if(!base) return '';
    return base.indexOf('-') >= 0 ? (base + 'W') : (base + '-W');
  }

  var resVac = 0;
  // 1. Candidate's caste / reservation
  if(caste){
    resVac += vCount(caste);
    if(isFemale){
      resVac += vCount(wCat(caste));
    }
  }

  // 2. Special reservation quotas if candidate holds them
  if(isPhc){
    resVac += vCount('PH');
    if(isFemale) resVac += vCount('PH-W');
  }
  if(isExs){
    resVac += vCount('EX-S');
    if(isFemale) resVac += vCount('EX-SW');
  }

  return resVac > 0;
}

function renderMatrix(){
  var b=document.getElementById('matrixBody');
  b.innerHTML='';
  if(!seatMatrix.length){b.innerHTML='<tr><td colspan="17">No seats available in the district for this phase.</td></tr>';return;}
  seatMatrix.forEach(function(item,idx){
    var g=cat(item,'General'), im=cat(item,'IM'), ph=cat(item,'PH'), ex=cat(item,'EXS');
    function three(c){var vacant=num(c.V);return '<td>'+num(c.T)+'</td><td class="tfv-f">'+num(c.F)+'</td><td'+(vacant>0?' class="vacant-cell"':'')+'>'+vacant+'</td>';}
    var totalVacancy=num(g.V)+num(im.V)+num(ph.V)+num(ex.V)>0;
    var resAvailable=item.vacancies ? hasStudentReservation(item, cur) : totalVacancy;
    var selectable = totalVacancy && resAvailable;
    var disabledReason = !totalVacancy
      ? 'No vacant seats'
      : (!resAvailable ? ('No vacant seats for candidate reservation (' + esc(cur ? cur.caste : '') + ')') : '');
    b.insertAdjacentHTML('beforeend',
      '<tr><td>'+esc(item.iti_name)+'</td><td>'+esc(item.trade_name)+'</td><td>'+txt(item.strength_total)+'</td>'+
      three(g)+three(im)+three(ph)+three(ex)+
      '<td><input type="radio" name="seat" data-i="'+idx+'"'+(selectable?'':' disabled="disabled" title="'+disabledReason+'"')+' /></td></tr>');
  });
  var radios=b.querySelectorAll('input[name=seat]');
  radios.forEach(function(r){
    r.onclick=function(){
      var idx=parseInt(r.getAttribute('data-i'),10);
      var item=seatMatrix[idx];
      sel={iti:item.iti_code,itiName:item.iti_name,trade:item.trade_code,tradeName:item.trade_name};
      document.getElementById('takeErr').innerHTML='';
      loadShiftUnit(item.iti_code,item.trade_code);
    };
  });
}

function loadShiftUnit(itiCode,tradeCode){
  var box=document.getElementById('shiftUnitBox');
  var body=document.getElementById('shiftUnitBody');
  var empty=document.getElementById('shiftUnitEmpty');
  body.innerHTML='';shiftUnitOptions=[];
  empty.style.display='none';box.style.display='block';
  fetch(CTX+'/AdmissionCounseling/api/shift-unit?itiCode='+encodeURIComponent(itiCode)+'&tradeCode='+encodeURIComponent(tradeCode))
  .then(function(r){return r.json();})
  .then(function(res){
    var list=(res&&res.shifts)?res.shifts:[];
    shiftUnitOptions=list;
    if(!list.length){empty.style.display='block';return;}
    list.forEach(function(s){
      var shift=(s.shift_allowed!=null)?s.shift_allowed:'';
      var unit=(s.unit_allowed!=null)?s.unit_allowed:'';
      body.insertAdjacentHTML('beforeend',
        '<tr><td><input type="radio" name="shiftUnit" data-shift="'+esc(shift)+'" data-unit="'+esc(unit)+'" /></td>'+
        '<td>'+esc(shift)+'</td><td>'+esc(unit)+'</td><td>'+txt(s.strength)+'</td><td>'+txt(s.strength_vacant)+'</td></tr>');
    });
  })
  .catch(function(){empty.textContent='Unable to load shift/unit options.';empty.style.display='block';});
}

function openMemo(){
  if(!lastAdmNum){return;}
  window.open(CTX+'/admissions/print-admission-slip?admissionNumber='+encodeURIComponent(lastAdmNum),'_blank');
}

var isTakingAdmission = false;
function takeAdmission(){
  if (isTakingAdmission) return;
  var err=document.getElementById('takeErr');
  err.innerHTML='';
  if(!cur){err.innerHTML='Look up a rank first.';return;}
  if(!sel){err.innerHTML='Please choose a trade from the listed ITIs for this candidate.';return;}
  var board=document.getElementById('admissionBoard').value;
  if(!board){err.innerHTML='Please select Type of Admission (Board).';return;}
  var su=document.querySelector('input[name=shiftUnit]:checked');
  if(shiftUnitOptions.length>0&&!su){err.innerHTML='Please select a Shift and Unit option.';return;}
  isTakingAdmission = true;
  var btn=document.getElementById('takeBtn');
  btn.disabled=true;btn.value='Admitting...';
  var payload={
    regid:cur.regid,
    trade_code:sel.trade,
    iti_code:sel.iti,
    caste_name:cur.caste,
    idmarks1:document.getElementById('idm1').value,
    idmarks2:document.getElementById('idm2').value,
    ssc_regno:document.getElementById('sscReg').value,
    ssc_board:document.getElementById('sscBoard').value,
    ssc_year:document.getElementById('sscYear').value,
    ssc_month:document.getElementById('sscMonth').value,
    type_admission:board,
    shift:su?su.getAttribute('data-shift'):null,
    unit:su?su.getAttribute('data-unit'):null
  };
  fetch(CTX+'/AdmissionCounseling/api/take-admission',{
    method:'POST',
    headers:{'Content-Type':'application/json'},
    body:JSON.stringify(payload)
  })
  .then(function(r){return r.json().then(function(b){return {s:r.status,b:b};});})
  .then(function(x){
    var res=x.b||{};
    if(res.success){
      lastAdmNum=res.adm_num||null;
      document.getElementById('mAdmNo').innerHTML=esc(res.adm_num||'-');
      document.getElementById('mCand').innerHTML='Rank '+esc(cur.rank)+' / RegID '+esc(cur.regid)+' / Phase '+esc(cur.phase)+' / Year '+esc(cur.year);
      document.getElementById('mIti').innerHTML=esc(sel.itiName)+' - '+esc(sel.tradeName);
      document.getElementById('memoBox').style.display='table';
      document.getElementById('admissionSection').style.display='none';
      document.getElementById('candBox').style.display='none';
      document.getElementById('memoBox').scrollIntoView({behavior:'smooth',block:'center'});
    }else{
      err.innerHTML=esc(res.error||res.message||('Admission failed'+(x.s?' (HTTP '+x.s+')':'.')));
    }
  })
  .catch(function(){err.innerHTML='Server error during admission.';})
  .finally(function(){
    isTakingAdmission = false;
    btn.disabled = false;
    btn.value = 'Take Admission';
  });
}

(function(){if(document.getElementById('rank').value)lookupRank();})();
</script>
</body>
</html>
