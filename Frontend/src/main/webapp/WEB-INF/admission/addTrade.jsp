<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html;charset=utf-8" />
<title>:: ITI :: Add Trade</title>
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css" />
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/legacy-form.css" />
<script type="text/javascript" src="${pageContext.request.contextPath}/js/jquery.min.js"></script>
<style>
  .page-title { font-family:"Courier New",Courier,monospace; font-size:24px; margin:16px 0 6px; text-align:center; color:blue; text-decoration:underline; font-weight:bold; }
  .req-note { font-family:Verdana,Arial,sans-serif; font-size:12px; color:#c0392b; text-align:center; margin:0 0 6px; }
  .seat-box { width:50%; min-width:560px; margin:0 auto 18px; border:2px solid #000; background:#e4eeb9; padding:0 0 12px 0; }
  .seat-box table { width:100%; border-collapse:collapse; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .seat-box td { padding:8px; font-weight:bold; }
  .seat-box td.label { width:26%; font-weight:bold; }
  .seat-box select, .seat-box input[type=text] { width:96%; padding:4px; font-size:13px; }
  .submit-btn { background-color:greenyellow; border:none; color:#000; padding:4px 10px; font-size:13px; font-weight:bolder; border-radius:4px; cursor:pointer; }
  .submit-btn:disabled { opacity:.55; cursor:default; }
  .err { color:red; font-size:12px; }
  .ok { color:green; font-size:12px; }
  .result-wrap { width:96%; margin:10px auto 60px; font-family:Verdana,Arial,sans-serif; }
  .vac-head { text-align:center; color:#330033; font-size:24px; font-weight:bold; margin:14px 0 2px; }
  .vac-sub { text-align:center; font-size:14px; font-weight:bold; margin:0 0 10px; }
  .vac-sub span { color:blue; }
  .sub-head { text-align:center; color:brown; font-size:22px; font-weight:bold; text-decoration:underline; margin:8px 0; }
  .freeze-warn { text-align:center; color:#FF0000; font-weight:bold; font-size:18px; margin:6px 0; }
  .res-table { border-collapse:collapse; margin:10px auto; font-size:13px; background:#ffffcc; border:1px solid #000; }
  .res-table th, .res-table td { border:1px solid #000; padding:5px 10px; text-align:center; font-family:"Courier New",Courier,monospace; font-size:18px; }
  .res-table th { background:green; color:#fff; font-weight:bold; }
  .trade-table { width:788px; max-width:96%; margin:10px auto; border-collapse:collapse; background:#E9E7FE; border:1px solid #000; }
  .trade-table th, .trade-table td { border:1px solid #000; padding:4px 6px; font-family:"Courier New",Courier,monospace; font-size:18px; text-align:left; vertical-align:top; }
  .trade-table th { font-weight:bold; }
  .trade-table a { color:#000099; }
  .big-link { font-family:"Courier New",Courier,monospace; font-size:24px; font-weight:bold; color:#000099; cursor:pointer; }
  .big-link:hover { color:#FF0000; }
  .add-form { border-collapse:collapse; margin:10px auto; background:#e4eeb9; border:2px solid #000; font-family:Verdana,Arial,sans-serif; font-size:13px; }
  .add-form td { padding:6px 10px; }
  .add-form select, .add-form input[type=text] { padding:3px; font-size:13px; }
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
var CURRENT_ITI = '';
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

function getTrades(onDone){
  var iti = document.getElementById('itiSel').value;
  setErr('itiError', iti ? '' : 'ITI is required.');
  if(!iti) return;
  var btn = document.getElementById('goBtn');
  var area = document.getElementById('resultArea');
  btn.disabled = true; btn.value = 'Loading...';
  area.innerHTML = '<p style="text-align:center;">Loading trades...</p>';
  fetch(CTX + '/AddTrade/api/iti/' + encodeURIComponent(iti) + '/available-trades')
    .then(function(r){ return r.json(); })
    .then(function(resp){ render(resp, iti); if(onDone) onDone(); })
    .catch(function(){ area.innerHTML = '<p style="color:red;text-align:center;">Backend unavailable. Please try again later.</p>'; })
    .finally(function(){ btn.disabled = false; btn.value = 'Submit'; });
}

function render(resp, iti){
  CURRENT_ITI = iti;
  var area = document.getElementById('resultArea');
  if(!resp || (!resp.addableTrades && !resp.existingTrades)){
    area.innerHTML = '<p style="color:red;text-align:center;">No data for ITI=' + esc(iti) + '.</p>'; return;
  }
  var year = resp.year ? esc(resp.year) : '';
  var h = '<div class="vac-head">Trades for ITI ' + esc(iti) + ' - ' + esc(resp.itiName || '') + '</div>'
        + '<div class="freeze-warn">when the Trades are frozen , its not possible to edit</div>';

  var existing = resp.existingTrades || [];
  h += '<table class="trade-table"><thead><tr>'
     + '<th>Trade Code</th><th>Trade</th><th>Strength</th>'
     + '<th>Avail able for year ' + year + '</th>'
     + '<th>Seat Matrix</th><th>Edit</th><th>Reservation Entry</th>'
     + '</tr></thead><tbody>';
  if(existing.length === 0){
    h += '<tr><td colspan="7" style="text-align:center;">No trades attached to this ITI.</td></tr>';
  }
  existing.forEach(function(t){
    var frozen = num(t.tradeFreeze) === 1;
    var editCell = frozen ? ''
        : '<a href="javascript:void(0)" onclick="openEdit(' + "'" + esc(iti) + "'" + ',' + num(t.tradeCode) + ');">Edit</a>';
    var resCell = frozen ? '<a href="' + CTX + '/ReservationEntry">Reservation Entry</a>' : '';
    h += '<tr><td>' + esc(t.tradeCode) + '</td>'
       + '<td>' + esc(t.tradeShort) + ' - ' + esc(t.tradeName) + '</td>'
       + '<td>' + num(t.strength) + '</td>'
       + '<td>' + (String(t.availableForYear) === '1' ? 'Yes' : 'No') + '</td>'
       + '<td>' + esc(t.seatMatrix || '') + '</td>'
       + '<td>' + editCell + '</td>'
       + '<td>' + resCell + '</td></tr>';
  });
  h += '</tbody></table>';

  h += '<div class="act-row">';
  if(existing.length > 0){
    h += '<input type="button" id="apprBtn" class="lg-linkbtn" value="Approve All" onclick="approveGo();" />';
  }
  if(!resp.approvedExists){
    h += ' <span class="big-link" id="addTradeLink" onclick="toggleAddTrade();">Add Trade</span>';
  }
  h += '<div style="margin-top:6px;"><span class="ok" id="actOk"></span> <span class="err" id="actErr"></span></div>'
     + '</div>';

  if(resp.approvedExists){
    h += '<div class="block-note">Trades for this ITI are already approved. '
       + 'No further trades can be added.</div>';
  } else {
    var addable = resp.addableTrades || [];
    h += '<div id="addTradeForm" style="display:none;">'
       + '<div class="sub-head" style="color:#330066;">Add a new Trade for the ITI ' + esc(resp.itiName || '') + '</div>'
       + '<table class="add-form" style="width:60%;"><tbody>'
       + '<tr><td style="text-align:right;font-weight:bold;">Trade Code :</td><td style="text-align:left;">'
       + '<select id="tradeSel">' + opt('','-----select-----')
       + addable.map(function(t){ return opt(t.tradeCode, t.tradeShort + ' - ' + t.tradeName); }).join('')
       + '</select></td></tr>'
       + '<tr><td style="text-align:right;font-weight:bold;">strength :</td><td style="text-align:left;">'
       + '<input type="text" id="strengthInput" onkeypress="return numerics(event);" /></td></tr>'
       + '<tr><td style="text-align:right;font-weight:bold;">available :</td><td style="text-align:left;">'
       + '<label><input type="radio" name="avail" value="1" checked="checked" /> Yes</label>&nbsp;&nbsp;'
       + '<label><input type="radio" name="avail" value="0" /> No</label></td></tr>'
       + '<tr><td colspan="2" style="text-align:center;">'
       + '<input type="button" id="addBtn" class="submit-btn" value="Submit" onclick="addTradeGo();" /></td></tr>'
       + '</tbody></table>'
       + '</div>';
    if(addable.length === 0){
      h += '<div class="note">All master trades are already attached to this ITI.</div>';
    }
  }
  area.innerHTML = h;
}

function toggleAddTrade(){
  var f = document.getElementById('addTradeForm');
  if(f){ f.style.display = (f.style.display === 'none' || !f.style.display) ? 'block' : 'none'; }
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
      getTrades(function(){ setMsg('actOk', x.b.message || 'Approved.'); });
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

var EDIT = null;
function openEdit(iti, tradeCode){
  var area = document.getElementById('resultArea');
  area.innerHTML = '<p style="text-align:center;">Loading trade...</p>';
  fetch(CTX + '/AddTrade/api/iti/' + encodeURIComponent(iti) + '/trade/' + encodeURIComponent(tradeCode))
  .then(function(r){ return r.json().then(function(b){ return {s:r.status,b:b}; }); })
  .then(function(x){
    if(x.s >= 400 || !x.b || x.b.tradeCode === undefined){
      area.innerHTML = '<p style="color:red;text-align:center;">' + esc((x.b && (x.b.message || x.b.error)) || 'Trade not found.') + '</p>'; return;
    }
    renderEdit(x.b);
  }).catch(function(){ area.innerHTML = '<p style="color:red;text-align:center;">Unable to load trade.</p>'; });
}

function renderEdit(d){
  EDIT = d;
  var h = '<div class="vac-head">Edit Trade ' + esc(d.tradeShort || '') + ' - ' + esc(d.tradeName || '') + '</div>'
        + '<div class="vac-sub">ITI ' + esc(d.itiCode) + ' - ' + esc(d.itiName || '') + '</div>'
        + '<table class="add-form" style="width:60%;"><tbody>'
        + '<tr><td style="text-align:right;font-weight:bold;">Strength * :</td><td style="text-align:left;">'
        + '<input type="text" id="edStrength" value="' + num(d.strength) + '" onkeypress="return numerics(event);" /></td></tr>'
        + '<tr><td style="text-align:right;font-weight:bold;">Available for year :</td><td style="text-align:left;">'
        + '<label><input type="radio" name="edAvail" value="1"' + (String(d.availableForYear) === '1' ? ' checked="checked"' : '') + ' /> Yes</label>&nbsp;&nbsp;'
        + '<label><input type="radio" name="edAvail" value="0"' + (String(d.availableForYear) === '0' ? ' checked="checked"' : '') + ' /> No</label></td></tr>'
        + '</tbody></table>';
  var units = d.shiftUnits || [];
  if(units.length){
    h += '<div class="sub-head">Shift / Unit</div>'
       + '<table class="res-table"><thead><tr><th>Select</th><th>Shift</th><th>Unit</th><th>Strength</th></tr></thead><tbody>';
    units.forEach(function(u, i){
      h += '<tr><td><input type="checkbox" class="ed-unit" data-i="' + i + '"'
         + (u.availableYear ? ' checked="checked"' : '') + ' onchange="updateTradeStrength();" /></td>'
         + '<td>' + esc(u.shiftAllowed) + '</td><td>' + esc(u.unitAllowed) + '</td><td>' + num(u.strength) + '</td></tr>';
    });
    h += '</tbody></table>';
  }
  h += '<div class="act-row">'
     + '<input type="button" class="submit-btn" value="Update Above Details" onclick="saveEdit();" />'
     + '&nbsp;<input type="button" class="lg-linkbtn" value="Cancel" onclick="getTrades();" />'
     + '<div style="margin-top:6px;"><span class="err" id="editErr"></span> <span class="ok" id="editOk"></span></div>'
     + '</div>';
  document.getElementById('resultArea').innerHTML = h;
}

function updateTradeStrength(){
  if(!EDIT){ return; }
  var total = 0;
  document.querySelectorAll('.ed-unit').forEach(function(cb){
    if(cb.checked){
      var i = parseInt(cb.getAttribute('data-i'), 10);
      var u = (EDIT.shiftUnits || [])[i];
      if(u){ total += num(u.strength); }
    }
  });
  var el = document.getElementById('edStrength');
  if(el){ el.value = total; }
}

function saveEdit(){
  if(!EDIT){ return; }
  setMsg('editErr',''); setMsg('editOk','');
  var strength = num(document.getElementById('edStrength').value);
  var availEl = document.querySelector('input[name=edAvail]:checked');
  var available = availEl ? availEl.value : '1';
  var units = [];
  document.querySelectorAll('.ed-unit').forEach(function(cb){
    var i = parseInt(cb.getAttribute('data-i'), 10);
    var u = (EDIT.shiftUnits || [])[i];
    if(u){ units.push({ shiftAllowed: u.shiftAllowed, unitAllowed: u.unitAllowed, available: cb.checked }); }
  });
  var btn = event && event.target ? event.target : null;
  if(btn){ btn.disabled = true; }
  fetch(CTX + '/AddTrade/api/iti/' + encodeURIComponent(EDIT.itiCode) + '/trade/' + encodeURIComponent(EDIT.tradeCode), {
    method: 'PUT', headers: {'Content-Type':'application/json'},
    body: JSON.stringify({ strength: strength, available: available, shiftUnits: units })
  })
  .then(function(r){ return r.json().then(function(b){ return {s:r.status,b:b}; }); })
  .then(function(x){
    if(x.b && x.b.tradeCode !== undefined){
      setMsg('editOk', 'Trade updated successfully.');
      setTimeout(function(){ getTrades(); }, 600);
    } else {
      setMsg('editErr', (x.b && (x.b.message || x.b.error)) ? (x.b.message || x.b.error) : ('HTTP ' + x.s));
      if(btn){ btn.disabled = false; }
    }
  }).catch(function(){ setMsg('editErr','Backend unavailable. Update not completed.'); if(btn){ btn.disabled = false; } });
}

loadItis();
</script>
</body>
</html>
