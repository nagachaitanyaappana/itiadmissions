<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Add Trade</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<style>
  .page-title { font-family:Verdana,Arial,sans-serif; font-size:20px; margin:16px 0 2px 12px; color:#000; }
  .req-note { font-family:Verdana,Arial,sans-serif; font-size:12px; color:#c0392b; text-align:center; margin:0 0 6px; }
  .seat-box { width:62%; min-width:560px; margin:0 auto 18px 12px; border:1px solid #7a7a7a; background:#fff; }
  .seat-box table { width:100%; border-collapse:collapse; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .seat-box td { border-top:1px solid #ddd; border-bottom:1px solid #ddd; padding:8px; }
  .seat-box td.label { width:26%; font-weight:bold; }
  .seat-box select, .seat-box input[type=text] { width:96%; padding:4px; font-size:13px; }
  .submit-btn { background-color:#4CAF50; border:none; color:#fff; padding:6px 30px; font-size:15px; font-weight:bold; cursor:pointer; }
  .submit-btn:disabled { opacity:.55; cursor:default; }
  .err { color:red; font-size:12px; }
  .ok { color:green; font-size:12px; }
  .result-wrap { width:96%; margin:10px auto 60px; font-family:Verdana,Arial,sans-serif; }
  .vac-head { text-align:center; color:blue; font-size:18px; font-weight:bold; margin:14px 0 2px; }
  .vac-sub { text-align:center; font-size:14px; font-weight:bold; margin:0 0 10px; }
  .vac-sub span { color:blue; }
  .res-table { border-collapse:collapse; margin:10px auto; font-size:13px; background:#fff; }
  .res-table th, .res-table td { border:1px solid #7a7a7a; padding:5px 10px; text-align:center; }
  .res-table th { background:#E8F3FF; }
  .block-note { width:60%; margin:10px auto; padding:10px; text-align:center; font-weight:bold;
                color:#a00; background:#fdecea; border:1px solid #e74c3c; }
  .act-row { text-align:center; margin:14px 0; }
  .note { width:70%; margin:12px auto; font-size:12px; color:#333; background:#fef9e7; border:1px solid #d4ac0d; padding:8px 10px; }
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
<div class="page-title">Add Trade and Reservation Matrix in selected ITI</div>
<div class="req-note">* Denotes Required Field</div>
<div class="seat-box">
  <table>
    <tr>
      <td class="label">Select ITI * :</td>
      <td><select id="itiSel"><option value="">--select--</option></select><span class="err" id="itiError"></span></td>
    </tr>
    <tr>
      <td colspan="2" style="text-align:center;"><input type="button" id="goBtn" class="submit-btn" value="Submit" onclick="getTrades();" /></td>
    </tr>
  </table>
</div>
<div class="result-wrap" id="resultArea"></div>
<div id="footer">National Informatics Centre</div>
<script>
var CTX = '${pageContext.request.contextPath}';
var DIST = '${sessionScope.insCode}';
function esc(s){ if(s===null||s===undefined) return ''; return String(s).replace(/[&<>"]/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); }
function setErr(id,m){ document.getElementById(id).innerHTML = esc(m); }
function setMsg(id,m){ var e = document.getElementById(id); if(e) e.innerHTML = esc(m); }
function num(v){ v = parseInt(v,10); return isNaN(v) ? 0 : v; }
function opt(v,t){ return '<option value="' + esc(v) + '">' + esc(t) + '</option>'; }

function loadItis(){
  if(!DIST){ DIST = localStorage.getItem('insCode') || ''; }
  var sel = document.getElementById('itiSel');
  if(!DIST){ setErr('itiError', 'District not found in session.'); return; }
  fetch(CTX + '/AddTrade/api/district/' + encodeURIComponent(DIST) + '/itis')
    .then(function(r){ return r.json(); })
    .then(function(list){
      var h = opt('','--select--');
      (Array.isArray(list)?list:[]).forEach(function(x){ h += opt(x.itiCode, x.itiCode + ' - ' + x.itiName); });
      sel.innerHTML = h;
    }).catch(function(){
      fetch(CTX + '/AddTrade/api/itis/' + encodeURIComponent(DIST)).then(function(r){ return r.json(); }).then(function(nm){
        var h = opt('','--select--');
        (Array.isArray(nm)?nm:[]).forEach(function(n){ h += opt(n,n); });
        sel.innerHTML = h;
      }).catch(function(){});
    });
}

function getTrades(){
  var iti = document.getElementById('itiSel').value;
  setErr('itiError', iti ? '' : 'ITI is required.');
  if(!iti) return;
  var btn = document.getElementById('goBtn');
  var area = document.getElementById('resultArea');
  btn.disabled = true; btn.value = 'Loading...';
  area.innerHTML = '<p style="text-align:center;">Loading trades...</p>';
  fetch(CTX + '/AddTrade/api/iti/' + encodeURIComponent(iti) + '/available-trades')
    .then(function(r){ return r.json(); })
    .then(function(resp){ render(resp, iti); })
    .catch(function(){ area.innerHTML = '<p style="color:red;text-align:center;">Backend unavailable. Please try again later.</p>'; })
    .finally(function(){ btn.disabled = false; btn.value = 'Submit'; });
}

function render(resp, iti){
  var area = document.getElementById('resultArea');
  if(!resp || (!resp.addableTrades && !resp.existingTrades)){
    area.innerHTML = '<p style="color:red;text-align:center;">No data for ITI=' + esc(iti) + '.</p>'; return;
  }
  var h = '<div class="vac-head">Trades for ITI ' + esc(iti) + ' - ' + esc(resp.itiName || '') + '</div>';

  var existing = resp.existingTrades || [];
  h += '<table class="res-table"><thead><tr><th>Trade Code</th><th>Trade</th><th>Strength</th><th>Filled</th>'
     + '<th>Vacant</th><th>Available for year</th><th>Approved</th></tr></thead><tbody>';
  if(existing.length === 0){
    h += '<tr><td colspan="7">No trades added yet.</td></tr>';
  }
  existing.forEach(function(t){
    h += '<tr><td>' + esc(t.tradeShort) + '</td><td>' + esc(t.tradeName) + '</td>'
      + '<td>' + num(t.strength) + '</td><td>' + num(t.strengthFill) + '</td><td>' + num(t.strengthVacant) + '</td>'
      + '<td>' + (String(t.availableForYear) === '1' ? 'Yes' : 'No') + '</td>'
      + '<td>' + (num(t.convApproval) === 1 ? 'Yes' : 'No') + '</td></tr>';
  });
  h += '</tbody></table>';

  if(resp.approvedExists){
    h += '<div class="block-note">Trades for this ITI are already approved. '
       + 'No further trades can be added.</div>';
  } else {
    var addable = resp.addableTrades || [];
    h += '<table class="res-table" style="width:60%;"><tbody>'
      + '<tr><td class="label" style="text-align:right;font-weight:bold;">Trade * :</td><td style="text-align:left;">'
      + '<select id="tradeSel">' + opt('','--select--')
      + addable.map(function(t){ return opt(t.tradeCode, t.tradeShort + ' - ' + t.tradeName); }).join('')
      + '</select></td></tr>'
      + '<tr><td style="text-align:right;font-weight:bold;">Strength * :</td><td style="text-align:left;">'
      + '<input type="text" id="strengthInput" onkeypress="return numerics(event);" /></td></tr>'
      + '<tr><td style="text-align:right;font-weight:bold;">Available :</td><td style="text-align:left;">'
      + '<label><input type="radio" name="avail" value="1" checked="checked" /> Yes</label>&nbsp;&nbsp;'
      + '<label><input type="radio" name="avail" value="0" /> No</label></td></tr>'
      + '<tr><td colspan="2" style="text-align:center;">'
      + '<input type="button" id="addBtn" class="submit-btn" value="Add Trade" onclick="addTradeGo();" />'
      + '&nbsp;<input type="button" id="apprBtn" class="submit-btn" value="Approve All" onclick="approveGo();" />'
      + '<div style="margin-top:8px;"><span class="err" id="actErr"></span> <span class="ok" id="actOk"></span></div>'
      + '</td></tr></tbody></table>';
    if(addable.length === 0){
      h += '<div class="note">All master trades are already attached to this ITI.</div>';
    }
  }
  area.innerHTML = h;
}

function addTradeGo(){
  var iti = document.getElementById('itiSel').value;
  var tradeCode = num(document.getElementById('tradeSel').value);
  var strength = num(document.getElementById('strengthInput').value);
  var availEl = document.querySelector('input[name=avail]:checked');
  var available = availEl ? num(availEl.value) : 1;
  setMsg('actErr',''); setMsg('actOk','');
  if(!tradeCode){ setMsg('actErr','Please select a trade.'); return; }
  var btn = document.getElementById('addBtn');
  btn.disabled = true; btn.value = 'Adding...';
  fetch(CTX + '/AddTrade/api/iti/' + encodeURIComponent(iti) + '/trades', {
    method: 'POST', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ tradeCode: tradeCode, strength: strength, available: available })
  }).then(function(r){ return r.json().then(function(b){ return {s: r.status, b: b}; }); })
  .then(function(x){
    if(x.b && (x.b.approvedExists !== undefined) && Array.isArray(x.b.existingTrades)){
      render(x.b, iti); setMsg('actOk', 'Trade added successfully.');
    } else {
      setMsg('actErr', 'Add Trade not completed: ' + ((x.b && (x.b.error || x.b.message)) ? (x.b.error || x.b.message) : ('HTTP ' + x.s)));
    }
  }).catch(function(){ setMsg('actErr','Backend unavailable. Add Trade not completed.'); })
  .finally(function(){ btn.disabled = false; btn.value = 'Add Trade'; });
}

function approveGo(){
  var iti = document.getElementById('itiSel').value;
  setMsg('actErr',''); setMsg('actOk','');
  var btn = document.getElementById('apprBtn');
  btn.disabled = true; btn.value = 'Approving...';
  fetch(CTX + '/AddTrade/api/iti/' + encodeURIComponent(iti) + '/approve-all', {method: 'PUT'})
  .then(function(r){ return r.json().then(function(b){ return {s: r.status, b: b}; }); })
  .then(function(x){
    if(x.b && x.b.success){
      getTrades();
      setMsg('actOk', x.b.message || 'Approved.');
    } else {
      setMsg('actErr', 'Approve All not completed: ' + ((x.b && (x.b.error || x.b.message)) ? (x.b.error || x.b.message) : ('HTTP ' + x.s)));
    }
  }).catch(function(){ setMsg('actErr','Backend unavailable. Approve All not completed.'); })
  .finally(function(){ btn.disabled = false; btn.value = 'Approve All'; });
}

function numerics(evt){
  var charCode = (evt.which) ? evt.which : evt.keyCode;
  if(charCode > 31 && (charCode < 48 || charCode > 57)){ return false; }
  return true;
}

loadItis();
</script>
</body>
</html>
