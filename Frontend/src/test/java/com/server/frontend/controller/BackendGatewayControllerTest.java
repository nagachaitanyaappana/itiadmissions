package com.server.frontend.controller;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class BackendGatewayControllerTest {

    @Test
    void requiresCsrfForStateChangingMethodsOnly() {
        assertTrue(BackendGatewayController.requiresCsrf("POST"));
        assertTrue(BackendGatewayController.requiresCsrf("PUT"));
        assertTrue(BackendGatewayController.requiresCsrf("PATCH"));
        assertTrue(BackendGatewayController.requiresCsrf("DELETE"));
        assertFalse(BackendGatewayController.requiresCsrf("GET"));
        assertFalse(BackendGatewayController.requiresCsrf("HEAD"));
        assertFalse(BackendGatewayController.requiresCsrf("OPTIONS"));
    }

    @Test
    void validatesCsrfTokensWithoutAcceptingMissingOrMismatchedValues() {
        assertTrue(BackendGatewayController.validCsrfToken("session-token", "session-token"));
        assertFalse(BackendGatewayController.validCsrfToken("session-token", "attacker-token"));
        assertFalse(BackendGatewayController.validCsrfToken("session-token", null));
        assertFalse(BackendGatewayController.validCsrfToken(null, "session-token"));
        assertFalse(BackendGatewayController.validCsrfToken("", ""));
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
        assertFalse(BackendGatewayController.safePath("/api/districts\\r\\nX-Test: yes"));
    }
}
