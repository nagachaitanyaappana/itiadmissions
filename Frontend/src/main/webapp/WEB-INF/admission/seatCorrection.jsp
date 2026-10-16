<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Seat Correction</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/legacy-form.css" />
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<style>
  .page-title { font-family:Verdana,Arial,sans-serif; font-size:24px; margin:16px 0 2px; text-align:center; color:#000099; }
  .req-note { font-family:Verdana,Arial,sans-serif; font-size:12px; color:#c0392b; text-align:center; margin:0 0 6px; }
  .seat-box { width:50%; min-width:560px; margin:0 auto 18px; border:2px solid #000; background:#e4eeb9; }
  .seat-box table { width:100%; border-collapse:collapse; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .seat-box td { border-top:1px solid #b9c99a; border-bottom:1px solid #b9c99a; padding:8px; font-weight:bold; }
  .seat-box td.label { width:24%; font-weight:bold; }
  .seat-box select { width:96%; padding:4px; font-size:13px; }
  .submit-btn { background-color:green; border:none; color:#fff; padding:6px 42px; font-size:15px; font-weight:bold; cursor:pointer; }
  .submit-btn:disabled { opacity:.55; cursor:default; }
  .err { color:red; font-size:12px; display:block; }
  .ok { color:green; font-size:12px; display:block; }
  .result-wrap { width:96%; margin:10px auto 60px; font-family:Verdana,Arial,sans-serif; }
  .vac-head { text-align:center; color:#000099; font-size:24px; font-weight:normal; margin:14px 0 2px; }
  .vac-sub { text-align:center; font-size:18px; color:#660066; margin:0 0 10px; }
  .res-table { border-collapse:collapse; margin:0 auto; font-size:13px; background:#E8F3FF; border:1px solid #000; }
  .res-table th, .res-table td { border:1px solid #000; padding:5px 10px; text-align:center; }
  .res-table th { font-weight:bold; background:#E8F3FF; }
  .res-table td.name { text-align:left; }
  .res-table input.fill, .res-table input.vacant { width:60px; text-align:right; padding:3px; }
  .total-box { text-align:right; margin:10px 20% 0 auto; font-size:13px; font-weight:bold; color:#663399; }
  .total-box input { width:80px; text-align:right; font-weight:bold; }
  .act-row { text-align:center; margin:14px 0; }
  .save-purple { background:none; border:none; color:#663399; font-weight:bold; font-size:15px; cursor:pointer; }
  .save-purple:disabled { opacity:.55; cursor:default; }
  .note { width:70%; margin:12px auto; font-size:12px; color:#333; background:#fef9e7; border:1px solid #d4ac0d; padding:8px 10px; }
  .gate-banner { display:none; width:62%; min-width:560px; margin:0 auto 12px; font-family:Verdana,Arial,sans-serif; font-size:13px; padding:10px 12px; border:1px solid; }
  .gate-banner.block { display:block; background:#fdecea; border-color:#c0392b; color:#922b21; }
  .gate-banner.ok { display:block; background:#eafaf1; border-color:#27ae60; color:#1e8449; }
  .gate-banner a { color:#922b21; font-weight:bold; }
  #footer { position:fixed; bottom:0; width:100%; padding:8px; text-align:center; background:#0E4878; font-size:12px; color:#fff; }
  #footer a { color:#fff; }
</style>
</head>
<body>
<br/>
<c:choose>
  <c:when test="${not empty sessionScope.roleId}"><%@ include file="/WEB-INF/reports/header.jsp" %></c:when>
  <c:otherwise><%@ include file="/WEB-INF/bannernew.jsp" %><%@ include file="/WEB-INF/navbars/openNavbar.jsp" %></c:otherwise>
</c:choose>
<div class="lg-page">
<div class="page-title">Seat Correction</div>
<div class="req-note">* Denotes Required Field</div>
<div class="gate-banner" id="gateArea"></div>
<div class="seat-box">
  <table>
    <tr>
      <td class="label">Select ITI * :</td>
      <td><select id="itiSel"><option value="">--select--</option></select><span class="err" id="itiError"></span></td>
    </tr>
    <tr>
      <td class="label">Select Trade * :</td>
      <td><select id="tradeSel"><option value="">--select--</option></select><span class="err" id="tradeError"></span></td>
    </tr>
    <tr>
      <td colspan="2" style="text-align:center;"><input type="button" id="goBtn" class="submit-btn" value="Submit" onclick="loadCorrection();" /></td>
    </tr>
  </table>
</div>
<div class="result-wrap" id="resultArea"></div>
</div>
<div id="footer">National Informatics Centre</div>
<script>
var CTX = '${pageContext.request.contextPath}';
var DIST = '${sessionScope.insCode}';
var current = null;
function esc(s){ if(s===null||s===undefined) return ''; return String(s).replace(/[&<>"]/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); }
function setErr(id,m){ document.getElementById(id).innerHTML = esc(m); }
function num(v){ v = parseInt(v,10); return isNaN(v) ? 0 : v; }

function loadItis(){
  if(!DIST){ DIST = localStorage.getItem('insCode') || ''; }
  var sel = document.getElementById('itiSel');
  if(!DIST){ setErr('itiError', 'District not found in session.'); return; }
  fetch(CTX + '/SeatCorrection/api/district/' + encodeURIComponent(DIST) + '/itis')
    .then(function(r){ return r.json(); })
    .then(function(list){
      var h = '<option value="">--select--</option>';
      (Array.isArray(list)?list:[]).forEach(function(x){
        h += '<option value="' + esc(x.itiCode) + '">' + esc(x.itiCode) + ' - ' + esc(x.itiName) + '</option>';
      });
      sel.innerHTML = h;
    }).catch(function(){ setErr('itiError', 'Unable to load ITIs.'); });
}

function loadTrades(){
  var iti = document.getElementById('itiSel').value;
  var sel = document.getElementById('tradeSel');
  var gate = document.getElementById('gateArea');
  var goBtn = document.getElementById('goBtn');
  sel.innerHTML = '<option value="">--select--</option>';
  document.getElementById('resultArea').innerHTML = '';
  gate.className = 'gate-banner';
  gate.innerHTML = '';
  goBtn.disabled = false;
  if(!iti) return;
  // Seat Correction opens only once DGT Permitted Shifts Units AND Add Trade (Approve All) are done.
  fetch(CTX + '/SeatCorrection/api/iti/' + encodeURIComponent(iti) + '/readiness')
    .then(function(r){ return r.json(); })
    .then(function(rd){
      if(!rd || !rd.ready){
        gate.className = 'gate-banner block';
        gate.innerHTML = esc((rd && rd.message) ? rd.message : 'Seat Correction is not open for this ITI.')
          + ' <a href="' + CTX + '/iti-trade-selection">DGT Permitted Shift Units</a>'
          + ' | <a href="' + CTX + '/AddTrade">Add Trade</a>';
        sel.innerHTML = '<option value="">--select--</option>';
        goBtn.disabled = true;
        return;
      }
      gate.className = 'gate-banner ok';
      gate.innerHTML = esc(rd.message || 'Seat Correction is open.');
      loadTradesList(iti);
    })
    .catch(function(){ setErr('tradeError', 'Unable to check Seat Correction readiness.'); });
}

function loadTradesList(iti){
  var sel = document.getElementById('tradeSel');
  fetch(CTX + '/SeatCorrection/api/iti/' + encodeURIComponent(iti) + '/approved-trades')
    .then(function(r){ return r.json(); })
    .then(function(list){
      var h = '<option value="">--select--</option>';
      var n = 0;
      (Array.isArray(list)?list:[]).forEach(function(t){
        n++;
        h += '<option value="' + esc(t.tradeCode) + '">' + esc(t.tradeShort) + ' - ' + esc(t.tradeName) + '</option>';
      });
      sel.innerHTML = h;
      if(n === 0){
        var gate = document.getElementById('gateArea');
        gate.className = 'gate-banner block';
        gate.innerHTML = 'No approved trade for this ITI. Approve a trade in Add Trade first.';
        document.getElementById('goBtn').disabled = true;
      }
    }).catch(function(){ setErr('tradeError', 'Unable to load trades.'); });
}

function loadCorrection(){
  var iti = document.getElementById('itiSel').value;
  var trade = document.getElementById('tradeSel').value;
  setErr('itiError', iti ? '' : 'ITI is required.');
  setErr('tradeError', trade ? '' : 'Trade is required.');
  if(!iti || !trade) return;
  var btn = document.getElementById('goBtn');
  var area = document.getElementById('resultArea');
  btn.disabled = true; btn.value = 'Loading...';
  area.innerHTML = '<p style="text-align:center;">Loading seat correction...</p>';
  fetch(CTX + '/SeatCorrection/api/seat-correction?itiCode=' + encodeURIComponent(iti) + '&tradeCode=' + encodeURIComponent(trade))
    .then(function(r){ return r.json(); })
    .then(function(d){ render(d); })
    .catch(function(){ area.innerHTML = '<p class="err" style="text-align:center;">Unable to load seat correction.</p>'; })
    .finally(function(){ btn.disabled = false; btn.value = 'Submit'; });
}

function render(d){
  current = d;
  if(!d || !d.categories){ document.getElementById('resultArea').innerHTML = '<p class="err" style="text-align:center;">No data.</p>'; return; }
  var rows = '';
  d.categories.forEach(function(c, i){
    rows += '<tr>'
      + '<td>' + esc(c.categoryCode) + '</td>'
      + '<td class="name">' + esc(c.categoryName) + '</td>'
      + '<td>' + num(c.strength) + '<input type="hidden" id="strength_' + i + '" value="' + num(c.strength) + '" data-code="' + esc(c.categoryCode) + '"/></td>'
      + '<td><input class="fill" type="text" id="fill_' + i + '" value="' + num(c.strengthFill) + '"'
      + ' onkeypress="return numerics(event);" onkeyup="recalc();"/></td>'
      + '<td><input class="vacant" type="text" id="vac_' + i + '" value="' + num(c.strengthVacant) + '"'
      + ' onkeypress="return numerics(event);" readonly="readonly"/></td>'
      + '<td id="adm_' + i + '">' + num(c.admitted) + '</td>'
      + '</tr>';
  });
  var html = '<div class="vac-head">Reservation Breakup of Seats for ITI '
    + esc(d.itiCode) + ' - ' + esc(d.itiName || '') + ' in Trade '
    + esc(d.tradeShort || '') + ' - ' + esc(d.tradeName || '') + '</div>'
    + '<p class="vac-sub">Phase <span>' + esc(d.phase) + '</span> - Year <span>' + esc(d.year) + '</span></p>'
    + '<table class="res-table"><thead><tr>'
    + '<th>Category Code</th><th>Category Name</th><th>Strength</th><th>Already Fill</th><th>Vacant Seats</th><th>Admitted Number</th>'
    + '</tr></thead><tbody>' + rows + '</tbody></table>'
    + '<div class="total-box">Sanctioned Strength : <input type="text" id="sanctioned" value="' + num(d.totalStrength) + '" readonly="readonly"/></div>'
    + '<div class="total-box">Cumulative Total : <input type="text" id="total" value="0" readonly="readonly"/></div>'
    + '<div class="act-row"><input type="button" class="save-purple" id="saveBtn" value="Update/Insert Details" onclick="saveCorrection();"/></div>'
    + '<div class="act-row"><span class="err" id="saveError"></span><span class="ok" id="saveOk"></span></div>'
    + '<div class="note">Correct the Already Fill column against the admitted numbers, then save. '
    + 'Vacant seats are recomputed as Strength minus Already Fill; the sum of strengths must not exceed the sanctioned strength.</div>';
  document.getElementById('resultArea').innerHTML = html;
  recalc();
}

function recalc(){
  var fills = document.querySelectorAll('input.fill');
  var total = 0;
  for(var i=0;i<fills.length;i++){
    var st = num(document.getElementById('strength_' + i).value);
    var fl = num(fills[i].value);
    var vac = st - fl;
    var vacEl = document.getElementById('vac_' + i);
    if(vacEl) vacEl.value = (vac < 0 ? 0 : vac);
    fills[i].style.color = (vac < 0) ? 'red' : '';
    total += st;
  }
  var totalEl = document.getElementById('total');
  if(totalEl) totalEl.value = total;
}

function saveCorrection(){
  var iti = document.getElementById('itiSel').value;
  var trade = num(document.getElementById('tradeSel').value);
  var fills = document.querySelectorAll('input.fill');
  var entries = [];
  for(var i=0;i<fills.length;i++){
    var code = document.getElementById('strength_' + i).getAttribute('data-code');
    var st = num(document.getElementById('strength_' + i).value);
    var fl = num(fills[i].value);
    if(fl > st){ setMsg('saveError','Already fill cannot exceed strength for category ' + code + '.'); return; }
    entries.push({ categoryCode: code, strength: st, strengthFill: fl });
  }
  var sanctioned = num(document.getElementById('sanctioned').value);
  var total = num(document.getElementById('total').value);
  if(total > sanctioned){ setMsg('saveError','Total reserved strength exceeds the sanctioned strength.'); return; }
  setMsg('saveError',''); setMsg('saveOk','');
  var btn = document.getElementById('saveBtn');
  btn.disabled = true; btn.value = 'Saving...';
  fetch(CTX + '/SeatCorrection/api/seat-correction', {
    method: 'PUT', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ itiCode: iti, tradeCode: trade, entries: entries })
  }).then(function(r){ return r.json(); })
  .then(function(d){
    if(d && d.success){
      setMsg('saveOk', d.message || 'Saved successfully.');
      if(d.categories){ render(d); }
      setMsg('saveOk', d.message || 'Saved successfully.');
    } else {
      setMsg('saveError', (d && d.message) ? d.message : 'Save failed.');
    }
  }).catch(function(){ setMsg('saveError', 'Backend unavailable. Seat correction not saved.'); })
  .finally(function(){ btn.disabled = false; btn.value = 'Update/Insert Details'; });
}

function numerics(evt){
  var charCode = (evt.which) ? evt.which : evt.keyCode;
  if(charCode > 31 && (charCode < 48 || charCode > 57)){ return false; }
  return true;
}
function setMsg(id,m){ var e = document.getElementById(id); if(e) e.innerHTML = esc(m); }

document.getElementById('itiSel').addEventListener('change', loadTrades);
loadItis();
</script>
</body>
</html>
