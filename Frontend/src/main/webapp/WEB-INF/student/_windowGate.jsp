<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%--
    Legacy beans.MyUtil.LastDate() gate, ported for the student pages.
    If admissions.admission_phase.application_to_date (+1 second) is in the past,
    the page is replaced by the legacy "Date has Expired" screen.
    Included by: StudentRegistration.jsp, StudentApply.jsp, StudentEditDetails.jsp, ForgotRegId.jsp
--%>
<script type="text/javascript">
    (function () {
        function showWindowMessage(message) {
            document.body.innerHTML =
                '<h1 style="text-align:center;font-family:verdana;color:#000;margin-top:60px;">' + message + '</h1>'
                + '<center style="margin-top:20px;"><a href="${pageContext.request.contextPath}/">Back to Home Page</a></center>';
        }
        function checkWindow() {
            var xhr = new XMLHttpRequest();
            xhr.open('GET', '${backendBaseUrl}/api/reports/current-admission-phase', true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === 4) {
                    var data = null;
                    try { data = JSON.parse(xhr.responseText); } catch (e) { data = null; }
                    if (xhr.status === 200 && data && data.open === false) {
                        showWindowMessage('Date has Expired');
                    } else if (xhr.status !== 200 || !data) {
                        showWindowMessage('Unable to verify the configured application date window.');
                    }
                }
            };
            try {
                xhr.send();
            } catch (e) {
                showWindowMessage('Unable to verify the configured application date window.');
            }
        }
        if (document.readyState === 'loading') {
            document.addEventListener('DOMContentLoaded', checkWindow);
        } else {
            checkWindow();
        }
    })();
</script>
