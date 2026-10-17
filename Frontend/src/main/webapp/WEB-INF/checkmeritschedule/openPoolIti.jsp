<%@ page contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<%@include file='/WEB-INF/legacy/header.jsp' %>
<html>
    <head>
        <title>Open General Pool - ITI</title>
    </head>
    <body>
        <jsp:include page="/WEB-INF/reports/header.jsp" />

        <form action="" id="poolForm" onsubmit="openPool(); return false;">
            <table align="center" bgcolor="#ffffcc">
                <tr bgcolor="green">
                    <td colspan="2">&nbsp;</td>
                </tr>

                <tr>
                    <td>Open For</td>
                    <td>
                        <select name="caste" id="casteSelect">
                        </select>
                    </td>
                </tr>

                <tr bgcolor="green">
                    <td colspan="2">&nbsp;</td>
                </tr>
                <tr>
                    <td colspan="2">
                        <input type="submit" name="submit" value="Open reservation for selected Category"/>
                    </td>
                </tr>

            </table>
        </form>

        <div id="resultArea" align="center"></div>

        <%-- API base URL sourced from application.properties (backend.api.base-url) --%>
        <jsp:include page="/WEB-INF/jsp/_api_base_url.jsp" />
        <%
            Object sessionRoleId = session.getAttribute("roleId");
            Object sessionInsCode = session.getAttribute("insCode");
            String jsRoleId = sessionRoleId == null ? "" : String.valueOf(sessionRoleId).replace("'", "\\'");
            String jsInsCode = sessionInsCode == null ? "" : String.valueOf(sessionInsCode).replace("'", "\\'");
        %>
        <script>
            const API_BASE = window.API_BASE_URL;
            const SESSION_ROLE_ID = '<%= jsRoleId %>';
            const SESSION_INS_CODE = '<%= jsInsCode %>';

            // The same caste_master list the legacy page rendered with
            // beans.MyUtil.putOptions("caste_master", "caste_code", "caste_name", con).
            // NOTE: string concatenation, not template literals — EL is active on this page
            // and would swallow ${API_BASE} before the browser ever saw it.
            async function loadCastes() {
                try {
                    const resp = await fetch(API_BASE + '/api/dsc/caste-list', { credentials: 'include' });
                    const result = await resp.json();
                    const select = document.getElementById('casteSelect');
                    if (result.success && result.data) {
                        result.data.forEach(item => {
                            const opt = document.createElement('option');
                            opt.value = item.casteCode;
                            opt.textContent = item.casteName;
                            select.appendChild(opt);
                        });
                    }
                } catch (err) {
                    console.error("Caste list error:", err);
                }
            }

            // Ported from WEB-INF/open_pool_iti_level.jsp: ITI code comes from the session
            // ins_code (district derived from its first two digits); the backend resolves year
            // from iti_params code 7 and phase from admissions.admission_phase, then
            // updates/inserts the general-pool row keyed by the ITI.
            async function openPool() {
                const select = document.getElementById('casteSelect');
                const caste = select.value;
                const area = document.getElementById('resultArea');
                try {
                    const resp = await fetch(API_BASE + '/api/admission/general-pool/iti', {
                        method: 'POST',
                        credentials: 'include',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-Role-Id': SESSION_ROLE_ID,
                            'X-Ins-Code': SESSION_INS_CODE
                        },
                        body: JSON.stringify({ caste: caste })
                    });
                    const result = await resp.json();
                    if (result.success) {
                        area.innerHTML = '<h2>General Pool is Opened for the caste' + caste
                                + '</h2><br><br><a href="<%= request.getContextPath() %>/authHome">Back</a>';
                    } else {
                        area.innerHTML = '<h2 style="color:red">' + (result.error || 'Unable to open general pool') + '</h2>';
                    }
                } catch (err) {
                    area.innerHTML = '<h2 style="color:red">' + err + '</h2>';
                }
                return false;
            }

            loadCastes();
        </script>

        <%@include file='/WEB-INF/legacy/footer.jsp' %>
    </body>
</html>
