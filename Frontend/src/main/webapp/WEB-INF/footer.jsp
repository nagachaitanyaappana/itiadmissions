<div style="height: 60px;"></div>
<footer class="mt-auto" style="position: fixed; bottom: 0; left: 0; width: 100%; z-index: 1000;">
    <div class="lower-footer text-center mt-3">
        <div class="container">
            &copy; 2026 Government of Andhra Pradesh. All Rights Reserved. Developed by NIC.
        </div>
    </div>
</footer>

<%-- Scriptlet (not EL): this footer is statically included (<%@ include %>) by pages
     with isELIgnored="true" (e.g. checkmeritschedule/ScheduleEntry.jsp), where EL would
     stay literal and the browser would request /$%7BpageContext...%7D/js/... (404). --%>
<script src="<%= request.getContextPath() %>/js/jquery.min.js"></script>
<script src="<%= request.getContextPath() %>/js/bootstrap.bundle.min.js"></script>