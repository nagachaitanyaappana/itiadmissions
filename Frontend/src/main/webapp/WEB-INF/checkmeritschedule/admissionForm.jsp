<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@include file='/WEB-INF/legacy/header.jsp' %>

<style>
    .admission-form-table {
        width: 100%;
        max-width: 800px;
        margin: 20px auto;
        border-collapse: collapse;
    }
    .admission-form-table th {
        background: #f0f0f0;
        padding: 10px;
        text-align: left;
        border: 1px solid #ccc;
        font-weight: bold;
    }
    .admission-form-table td {
        padding: 10px;
        border: 1px solid #ccc;
    }
    .dropdown-row {
        display: flex;
        gap: 20px;
    }
    .dropdown-col {
        flex: 1;
    }
    select {
        width: 100%;
        padding: 8px;
        font-size: 14px;
        box-sizing: border-box;
    }
    label {
        font-weight: bold;
        margin-bottom: 5px;
        display: block;
    }
</style>

<script>
    function loadTrades() {
        var itiSelect = document.getElementById("itiSelect");
        var itiCode = itiSelect.value;
        var tradeSelect = document.getElementById("tradeSelect");
        var shiftUnitDiv = document.getElementById("shiftUnitDiv");

        tradeSelect.innerHTML = '<option value="">-- Select Trade --</option>';
        shiftUnitDiv.innerHTML = '';

        if (!itiCode) return;

        fetch('/AdmissionPhase/get-trades?itiCode=' + encodeURIComponent(itiCode))
            .then(response => response.json())
            .then(data => {
                if (data.success && data.trades) {
                    data.trades.forEach(function(trade) {
                        var opt = document.createElement('option');
                        opt.value = trade.tradeCode || trade.code || trade.tradeName;
                        opt.textContent = trade.tradeName || trade.name;
                        tradeSelect.appendChild(opt);
                    });
                }
            })
            .catch(err => console.error('Error loading trades:', err));
    }

    function loadShiftsUnits() {
        var tradeSelect = document.getElementById("tradeSelect");
        var tradeCode = tradeSelect.value;
        var shiftUnitDiv = document.getElementById("shiftUnitDiv");

        shiftUnitDiv.innerHTML = '';

        if (!tradeCode) return;

        fetch('/AdmissionPhase/shift-unit?tradeCode=' + encodeURIComponent(tradeCode))
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    var html = '<table class="admission-form-table">';
                    html += '<tr><th>Shift</th><th>Unit</th></tr>';

                    if (data.shifts) {
                        data.shifts.forEach(function(shift) {
                            html += '<tr>';
                            html += '<td>' + (shift.shiftName || shift.shift) + '</td>';
                            html += '<td>';
                            if (shift.units && shift.units.length) {
                                html += '<select name="unitCode" style="width:100%;padding:8px;">';
                                html += '<option value="">-- Select Unit --</option>';
                                shift.units.forEach(function(unit) {
                                    html += '<option value="' + (unit.unitCode || unit.code) + '">' + (unit.unitName || unit.name) + '</option>';
                                });
                                html += '</select>';
                            } else {
                                html += '<em>No units available</em>';
                            }
                            html += '</td>';
                            html += '</tr>';
                        });
                    }
                    html += '</table>';
                    shiftUnitDiv.innerHTML = html;
                }
            })
            .catch(err => console.error('Error loading shifts/units:', err));
    }
</script>

<table class="admission-form-table">
    <tr>
        <th colspan="2">Phase 1 – District Level Admission</th>
    </tr>
    <tr>
        <td class="dropdown-col">
            <label>Select ITI</label>
            <select id="itiSelect" name="itiCode" onchange="loadTrades()">
                <option value="">-- Select ITI --</option>
                <c:forEach items="${itiList}" var="iti">
                    <option value="${iti.itiCode}">${iti.itiName}</option>
                </c:forEach>
            </select>
        </td>
        <td class="dropdown-col">
            <label>Trades Available</label>
            <select id="tradeSelect" name="tradeCode" onchange="loadShiftsUnits()">
                <option value="">-- Select Trade --</option>
            </select>
        </td>
    </tr>
    <tr>
        <td>
            <div id="shiftUnitDiv"></div>
        </td>
    </tr>
    <tr>
        <td colspan="2" style="text-align:center; padding-top: 15px;">
            <button type="submit" class="btn btn-primary" onclick="return validateForm();">Submit Admission</button>
        </td>
    </tr>
</table>

<script>
    function validateForm() {
        var iti = document.getElementById("itiSelect").value;
        var trade = document.getElementById("tradeSelect").value;
        if (!iti) {
            alert("Please select an ITI");
            return false;
        }
        if (!trade) {
            alert("Please select a Trade");
            return false;
        }
        return true;
    }
</script>