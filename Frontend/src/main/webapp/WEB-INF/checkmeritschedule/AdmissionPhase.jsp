<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Admission Phase 1 | AP ITI Admissions</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/iti-portal-theme.css">
    <style>
        .admission-phase-card { max-width: 760px; margin: 2rem auto; border: 1px solid #dbe4ee; border-radius: 12px; background: #fff; box-shadow: 0 8px 24px rgba(15, 45, 75, .08); overflow: hidden; }
        .admission-phase-card__heading { margin: 0; padding: 1rem 1.4rem; color: #fff; background: linear-gradient(135deg, #195695, #2f6fa5); font-size: 1.2rem; font-weight: 700; }
        .admission-phase-card__body { padding: 1.5rem; }
        .admission-phase-form { display: grid; gap: 1rem; }
        .admission-phase-field { display: grid; grid-template-columns: minmax(180px, 1fr) minmax(220px, 1.3fr); gap: 1rem; align-items: center; }
        .admission-phase-field label { margin: 0; color: #334155; font-weight: 600; }
        .admission-phase-field .form-select { min-height: 42px; }
        .admission-phase-submit { min-width: 130px; }
        .admission-phase-error { color: #b42318; font-weight: 600; }
        @media (max-width: 575.98px) { .admission-phase-card { margin: 1rem .75rem; } .admission-phase-card__body { padding: 1rem; } .admission-phase-field { grid-template-columns: 1fr; gap: .35rem; } }
    </style></head>
<body>
    <jsp:include page="/WEB-INF/reports/header.jsp" />

    <main class="container py-3">
        <section class="admission-phase-card" aria-labelledby="admissionPhaseHeading">
            <h1 class="admission-phase-card__heading" id="admissionPhaseHeading">
                <i class="fas fa-clipboard-check me-2" aria-hidden="true"></i>Admission Phase 1
            </h1>
            <div class="admission-phase-card__body">
                <c:choose>
                    <c:when test="${phase == '1' and admissionWindowOpen}">
                        <p class="text-muted mb-4">Select the required admission criteria below to start the admission process.</p>
                        <form action="${pageContext.request.contextPath}/AdmissionPhase/itiAdmissionEntry" method="post" id="startForm" class="admission-phase-form">
                            <div class="admission-phase-field">
                                <label for="caste_perform">Caste</label>
                                <select name="caste_perform" id="caste_perform" class="form-select">
                                    <c:forEach var="c" items="${casteOptions}">
                                        <option value="${c.casteCode}">${c.casteName}</option>
                                    </c:forEach>
                                    <option value="all" selected>All</option>
                                    <option value="w">Women</option>
                                </select>
                            </div>
                            <div class="admission-phase-field">
                                <label for="qual_perform">Qualification</label>
                                <select name="qual_perform" id="qual_perform" class="form-select">
                                    <option value="all">All</option>
                                    <option value="assc">Intermediate</option>
                                </select>
                            </div>
                            <div class="admission-phase-field">
                                <label for="adm_perform">Admission Timings</label>
                                <select name="adm_perform" id="adm_perform" class="form-select">
                                    <c:forEach var="t" items="${timingOptions}">
                                        <option value="${t}">${t}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="d-flex flex-wrap align-items-center gap-3 pt-2">
                                <button type="submit" class="btn btn-primary admission-phase-submit">
                                    <i class="fas fa-arrow-right me-1" aria-hidden="true"></i>Submit
                                </button>
                                <c:if test="${not empty errorMsg}">
                                    <span class="admission-phase-error" role="alert">${errorMsg}</span>
                                </c:if>
                            </div>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-warning mb-0" role="alert">
                            <i class="fas fa-exclamation-triangle me-2" aria-hidden="true"></i>
                            ${empty admissionWindowError ? 'Admission Date is Expired' : admissionWindowError}
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>

    <%@ include file="../jsp/footer.jsp" %>
</body>
</html>
