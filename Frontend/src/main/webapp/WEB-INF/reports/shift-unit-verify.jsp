<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html;charset=utf-8">
    <title>Shift &amp; Unit Verification</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <style>
        .verify-box { width:50%; min-width:520px; margin:10px auto; border:1px solid #7a7a7a; }
        .verify-box table { width:100%; border-collapse:collapse; font-size:13px; }
        .verify-box td { padding:8px 10px; }
        .verify-box .head { background:#4ab131; color:#fff; text-align:center; font-weight:bold; }
        .verify-box select { padding:4px; }
        .btn-go { background:green; color:#fff; font-weight:bold; border:none; padding:6px 22px; cursor:pointer; }
        .btn-reset { background:red; color:#fff; font-weight:bold; border:none; padding:6px 22px; cursor:pointer; }
        .rec-table { width:92%; margin:12px auto; border-collapse:collapse; font-size:12px; }
        .rec-table th, .rec-table td { border:1px solid #7a7a7a; padding:4px 6px; }
        .rec-table th { background:#4ab131; color:#fff; text-align:center; }
        .verifyBtn { background:red; color:#fff; font-weight:bold; border:none; padding:4px 10px; cursor:pointer; }
        .loader { text-align:center; padding:14px; color:#005073; }
        .msg { text-align:center; margin:8px auto; font-weight:bold; }
        .msg.ok { color:green; }
        .msg.err { color:red; }
        #footer { position:fixed; bottom:0; width:100%; padding:8px; text-align:center; background:#0E4878; font-size:12px; color:#fff; }
        #footer a { color:#fff; }
    </style>
    <script>
        var CTX = '${pageContext.request.contextPath}';
        var BACKEND = '${backendApiUrl}';
        var DIST = '${sessionScope.insCode}';
        var SHIFTS = ['1', '2', '3'];
        var UNITS = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'];

        function esc(v){ if(v===null||v===undefined) return ''; return String(v).replace(/[&<>"]/g, function(c){ return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]; }); }
        function setMsg(id,m,ok){ var e=document.getElementById(id); if(!e) return; e.className='msg ' + (ok?'ok':'err'); e.innerHTML=esc(m); }

        function loadItis(){
            var sel = document.getElementById('iticode');
            if(!DIST){ setMsg('pageMsg','District not found in session.', false); return; }
            fetch(BACKEND + '/shift-unit-verify/itis?distCode=' + encodeURIComponent(DIST))
            .then(function(r){ return r.json(); })
            .then(function(j){
                var list = (j && j.data) ? j.data : [];
                var h = '<option value="">--select--</option>';
                list.forEach(function(it){ h += '<option value="' + esc(it.itiCode) + '">' + esc(it.itiCode) + ' - ' + esc(it.itiName) + '</option>'; });
                sel.innerHTML = h;
            })
            .catch(function(){ setMsg('pageMsg','Unable to load ITIs.', false); });
        }

        function opts(vals, selected){
            var h = '<option value="">--select--</option>';
            vals.forEach(function(v){ h += '<option value="' + v + '"' + (String(selected) === v ? ' selected' : '') + '>' + v + '</option>'; });
            return h;
        }

        function proceed(){
            var iti = document.getElementById('iticode').value;
            setMsg('pageMsg','', true);
            document.getElementById('resultWrap').style.display = 'none';
            if(!iti){ setMsg('pageMsg','Please select an ITI.', false); return; }
            document.getElementById('loader').style.display = 'block';
            fetch(BACKEND + '/shift-unit-verify?distCode=' + encodeURIComponent(DIST) + '&itiCode=' + encodeURIComponent(iti))
            .then(function(r){ return r.json(); })
            .then(function(j){
                document.getElementById('loader').style.display = 'none';
                render(j && j.data ? j.data : [], iti);
            })
            .catch(function(){ document.getElementById('loader').style.display='none'; setMsg('pageMsg','Unable to load admissions.', false); });
        }

        function render(rows, iti){
            var body = document.getElementById('recBody');
            var title = document.getElementById('itiTitle');
            title.textContent = iti + ' - ' + (document.getElementById('iticode').selectedOptions[0] ? document.getElementById('iticode').selectedOptions[0].textContent : '');
            if(!rows.length){
                body.innerHTML = '<tr><td colspan="9" style="text-align:center;">No admission pending shift/unit verification.</td></tr>';
            } else {
                body.innerHTML = rows.map(function(r, i){
                    return '<tr>'
                        + '<td style="text-align:center;">' + (i + 1) + '</td>'
                        + '<td>' + esc(r.admNum) + '</td>'
                        + '<td>' + esc(r.name) + '</td>'
                        + '<td>' + esc(r.fname) + '</td>'
                        + '<td>' + esc(r.dob) + '</td>'
                        + '<td style="text-align:center;">' + esc(r.gender) + '</td>'
                        + '<td><select id="shift_' + esc(r.admNum) + '">' + opts(SHIFTS, r.shift) + '</select></td>'
                        + '<td><select id="unit_' + esc(r.admNum) + '">' + opts(UNITS, r.unit) + '</select></td>'
                        + '<td style="text-align:center;"><button type="button" class="verifyBtn" onclick="verifyRow(\'' + esc(r.admNum) + '\')">Verify</button></td>'
                        + '</tr>';
                }).join('');
            }
            document.getElementById('resultWrap').style.display = 'block';
            setMsg('pageMsg','', true);
        }

        function verifyRow(admNum){
            var shift = document.getElementById('shift_' + admNum).value;
            var unit = document.getElementById('unit_' + admNum).value;
            setMsg('pageMsg','', true);
            fetch(BACKEND + '/shift-unit-verify', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ admNum: admNum, shift: shift, unit: unit })
            })
            .then(function(r){ return r.json().then(function(b){ return { s: r.status, b: b }; }); })
            .then(function(x){
                if(x.b && x.b.success){
                    setMsg('pageMsg', 'Admission ' + admNum + ' verified.', true);
                    proceed();
                } else {
                    setMsg('pageMsg', (x.b && (x.b.message || x.b.error)) || ('HTTP ' + x.s), false);
                }
            })
            .catch(function(){ setMsg('pageMsg','Backend unavailable.', false); });
        }

        document.addEventListener('DOMContentLoaded', loadItis);
    </script>
</head>
<body>
    <%@ include file="header.jsp" %>
    <div class="container mt-4">
        <h3 style="text-align:center;color:#330033;">Shift &amp; Unit Verification</h3>
        <div class="verify-box">
            <table>
                <tr><td class="head" colspan="2">Shift Unit Verification</td></tr>
                <tr>
                    <td style="width:35%;font-weight:bold;">Select ITI</td>
                    <td><select id="iticode" style="width:100%;"></select></td>
                </tr>
                <tr>
                    <td colspan="2" style="text-align:center;">
                        <input type="button" class="btn-go" value="Proceed" onclick="proceed();" />
                        <input type="reset" class="btn-reset" value="Reset" onclick="document.getElementById('resultWrap').style.display='none';" />
                    </td>
                </tr>
                <tr><td class="head" colspan="2">&nbsp;</td></tr>
            </table>
        </div>
        <div id="loader" class="loader" style="display:none;">Loading...</div>
        <div class="msg" id="pageMsg"></div>
        <div id="resultWrap" style="display:none;">
            <table class="rec-table">
                <thead>
                    <tr><th colspan="9" id="itiTitle"></th></tr>
                    <tr>
                        <th>SL.No</th><th>Admission number</th><th>Name</th><th>Father Name</th>
                        <th>Date Of Birth</th><th>Gender</th><th>Shift</th><th>Unit</th><th>Verify</th>
                    </tr>
                </thead>
                <tbody id="recBody"></tbody>
            </table>
        </div>
    </div>
    <div id="footer">2013 @ All Rights Reserved&nbsp;&nbsp; Designed by&nbsp;&nbsp; National Informatics Center <a href="http://www.ap.nic.in">National Informatics Center</a></div>
    <%@ include file="../footer.jsp" %>
</body>
</html>
