package com.server.frontend.controller;

import org.junit.jupiter.api.Test;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import static org.junit.jupiter.api.Assertions.*;

class BackendGatewayControllerTest {
    private static final String SECRET = "01234567890123456789012345678901";

    @Test void requiresCsrfForStateChangingMethodsOnly() {
        assertTrue(BackendGatewayController.requiresCsrf("POST"));
        assertTrue(BackendGatewayController.requiresCsrf("PUT"));
        assertTrue(BackendGatewayController.requiresCsrf("PATCH"));
        assertTrue(BackendGatewayController.requiresCsrf("DELETE"));
        assertFalse(BackendGatewayController.requiresCsrf("GET"));
        assertFalse(BackendGatewayController.requiresCsrf("HEAD"));
        assertFalse(BackendGatewayController.requiresCsrf("OPTIONS"));
    }

    @Test void validatesSignedDoubleSubmitTokensWithoutSessionState() throws Exception {
        String nonce = "test-random-nonce";
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        String token = nonce + "." + Base64.getUrlEncoder().withoutPadding()
                .encodeToString(mac.doFinal(nonce.getBytes(StandardCharsets.UTF_8)));
        assertTrue(BackendGatewayController.validCsrfToken(token, token, SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(token, "attacker", SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(token, token, "short"));
        assertFalse(BackendGatewayController.validCsrfToken(nonce + ".bad", nonce + ".bad", SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(token, null, SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(null, token, SECRET));
    }

    @Test void acceptsNormalBackendApiPaths() {
        assertTrue(BackendGatewayController.safePath("/api/districts"));
        assertTrue(BackendGatewayController.safePath("/api/student/12345"));
        assertTrue(BackendGatewayController.safePath("/admission/student-trade-selection/1"));
    }

    @Test void rejectsTraversalAndEncodedSeparators() {
        assertFalse(BackendGatewayController.safePath("/api/../actuator"));
        assertFalse(BackendGatewayController.safePath("/api/%2e%2e/actuator"));
        assertFalse(BackendGatewayController.safePath("/api%2factuator"));
        assertFalse(BackendGatewayController.safePath("/api/%5cactuator"));
        assertFalse(BackendGatewayController.safePath("/api/%252e%252e"));
        assertFalse(BackendGatewayController.safePath("/api\\actuator"));
    }

    @Test void rejectsAdministrativeAndDocumentationEndpoints() {
        assertFalse(BackendGatewayController.safePath("/actuator/health"));
        assertFalse(BackendGatewayController.safePath("/swagger-ui/index.html"));
        assertFalse(BackendGatewayController.safePath("/v3/api-docs"));
        assertFalse(BackendGatewayController.safePath("/api/auth/login"));
    }

    @Test void rejectsMalformedAndControlCharacterPaths() {
        assertFalse(BackendGatewayController.safePath(null));
        assertFalse(BackendGatewayController.safePath("api/districts"));
        assertFalse(BackendGatewayController.safePath("//evil.example/path"));
        assertFalse(BackendGatewayController.safePath("/api/districts\\r\\nX-Test: yes"));
    }
}