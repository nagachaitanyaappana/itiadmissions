package com.server.frontend.controller;

import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpSession;

import static org.junit.jupiter.api.Assertions.*;

class BackendGatewayControllerTest {

    @Test
    void requiresSameOriginProtectionForStateChangingMethodsOnly() {
        assertTrue(BackendGatewayController.requiresCsrf("POST"));
        assertTrue(BackendGatewayController.requiresCsrf("PUT"));
        assertTrue(BackendGatewayController.requiresCsrf("PATCH"));
        assertTrue(BackendGatewayController.requiresCsrf("DELETE"));
        assertFalse(BackendGatewayController.requiresCsrf("GET"));
        assertFalse(BackendGatewayController.requiresCsrf("HEAD"));
        assertFalse(BackendGatewayController.requiresCsrf("OPTIONS"));
    }

    @Test
    void acceptsOnlyTheExactRequestOriginForWrites() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setScheme("https");
        request.setServerName("portal.example.gov.in");
        request.setServerPort(443);
        request.addHeader("Origin", "https://portal.example.gov.in");
        assertTrue(BackendGatewayController.sameOrigin(request));

        request.removeHeader("Origin");
        request.addHeader("Origin", "https://attacker.example");
        assertFalse(BackendGatewayController.sameOrigin(request));
    }

    @Test
    void requiresFetchMetadataWhenOriginHeaderIsAbsent() {
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setScheme("http");
        request.setServerName("localhost");
        request.setServerPort(5051);
        assertFalse(BackendGatewayController.sameOrigin(request));

        request.addHeader("Sec-Fetch-Site", "same-origin");
        assertTrue(BackendGatewayController.sameOrigin(request));

        request.removeHeader("Sec-Fetch-Site");
        request.addHeader("Sec-Fetch-Site", "cross-site");
        assertFalse(BackendGatewayController.sameOrigin(request));
    }

    @Test
    void allowsOnlyExplicitPublicCandidateRoutes() {
        assertTrue(BackendGatewayController.isPublicCandidateRequest("GET", "/api/student/apply-gate"));
        assertTrue(BackendGatewayController.isPublicCandidateRequest("GET", "/api/student/lookup-regid"));
        assertTrue(BackendGatewayController.isPublicCandidateRequest("GET", "/api/student/castes"));
        assertTrue(BackendGatewayController.isPublicCandidateRequest("GET", "/api/student/subcastes/BC-A"));
        assertTrue(BackendGatewayController.isPublicCandidateRequest("GET", "/api/reports/current-admission-phase"));
        assertTrue(BackendGatewayController.isPublicCandidateRequest("POST", "/api/student/register"));
        assertFalse(BackendGatewayController.isPublicCandidateRequest("GET", "/api/student/all"));
        assertFalse(BackendGatewayController.isPublicCandidateRequest("GET", "/api/student/12345"));
        assertFalse(BackendGatewayController.isPublicCandidateRequest("POST", "/api/dv/approve"));
    }

    @Test
    void bindsCandidateDataRoutesToARegistrationId() {
        assertEquals("12345", BackendGatewayController.candidateRegid("GET", "/api/student/12345"));
        assertEquals("12345", BackendGatewayController.candidateRegid("GET", "/api/student/photo/12345"));
        assertEquals("12345", BackendGatewayController.candidateRegid("POST", "/api/student/photo/12345"));
        assertEquals("12345", BackendGatewayController.candidateRegid("GET", "/api/student/marks/12345"));
        assertEquals("12345", BackendGatewayController.candidateRegid("PUT", "/api/student/update/12345"));
        assertEquals("12345", BackendGatewayController.candidateRegid("POST", "/admission/student-trade-selection/12345"));
        assertEquals("12345", BackendGatewayController.candidateRegid("DELETE", "/admission/student-trade-selection/12345/ITI-001"));
        assertEquals("12345", BackendGatewayController.candidateRegid("DELETE", "/admission/student-trade-selection/12345/dist/07"));
        assertNull(BackendGatewayController.candidateRegid("GET", "/api/student/all"));
    }

    @Test
    void consumesCaptchaProofForTwoRegistrationWritesThenExpiresIt() {
        MockHttpSession session = new MockHttpSession();
        session.setAttribute(CaptchaController.VERIFIED_AT_KEY, 1_000L);
        session.setAttribute(CaptchaController.VERIFIED_USES_KEY, 2);

        assertTrue(BackendGatewayController.consumeCaptchaProof(session, false, 1_001L));
        assertEquals(1, session.getAttribute(CaptchaController.VERIFIED_USES_KEY));
        assertTrue(BackendGatewayController.consumeCaptchaProof(session, false, 1_002L));
        assertNull(session.getAttribute(CaptchaController.VERIFIED_AT_KEY));
        assertNull(session.getAttribute(CaptchaController.VERIFIED_USES_KEY));
        assertFalse(BackendGatewayController.consumeCaptchaProof(session, false, 1_003L));
    }

    @Test
    void consumesCaptchaProofCompletelyForIdentityChecks() {
        MockHttpSession session = new MockHttpSession();
        session.setAttribute(CaptchaController.VERIFIED_AT_KEY, 1_000L);
        session.setAttribute(CaptchaController.VERIFIED_USES_KEY, 2);

        assertTrue(BackendGatewayController.consumeCaptchaProof(session, true, 1_001L));
        assertNull(session.getAttribute(CaptchaController.VERIFIED_AT_KEY));
        assertNull(session.getAttribute(CaptchaController.VERIFIED_USES_KEY));
    }

    @Test
    void rejectsExpiredCaptchaProof() {
        MockHttpSession session = new MockHttpSession();
        session.setAttribute(CaptchaController.VERIFIED_AT_KEY, 1_000L);
        session.setAttribute(CaptchaController.VERIFIED_USES_KEY, 2);

        assertFalse(BackendGatewayController.consumeCaptchaProof(session, false, 301_001L));
        assertNull(session.getAttribute(CaptchaController.VERIFIED_AT_KEY));
        assertNull(session.getAttribute(CaptchaController.VERIFIED_USES_KEY));
    }

    @Test
    void acceptsNormalBackendApiPaths() {
        assertTrue(BackendGatewayController.safePath("/api/districts"));
        assertTrue(BackendGatewayController.safePath("/api/student/12345"));
        assertTrue(BackendGatewayController.safePath("/admission/student-trade-selection/1"));
    }

    @Test
    void rejectsTraversalAndEncodedSeparators() {
        assertFalse(BackendGatewayController.safePath("/api/../actuator"));
        assertFalse(BackendGatewayController.safePath("/api/%2e%2e/actuator"));
        assertFalse(BackendGatewayController.safePath("/api%2factuator"));
        assertFalse(BackendGatewayController.safePath("/api/%5cactuator"));
        assertFalse(BackendGatewayController.safePath("/api/%252e%252e"));
        assertFalse(BackendGatewayController.safePath("/api\\actuator"));
    }

    @Test
    void rejectsAdministrativeAndDocumentationEndpoints() {
        assertFalse(BackendGatewayController.safePath("/actuator/health"));
        assertFalse(BackendGatewayController.safePath("/swagger-ui/index.html"));
        assertFalse(BackendGatewayController.safePath("/v3/api-docs"));
        assertFalse(BackendGatewayController.safePath("/api/auth/login"));
    }

    @Test
    void rejectsMalformedAndControlCharacterPaths() {
        assertFalse(BackendGatewayController.safePath(null));
        assertFalse(BackendGatewayController.safePath("api/districts"));
        assertFalse(BackendGatewayController.safePath("//evil.example/path"));
        assertFalse(BackendGatewayController.safePath("/api/districts\r\nX-Test: yes"));
    }
}
