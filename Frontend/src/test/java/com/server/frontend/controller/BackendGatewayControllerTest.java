package com.server.frontend.controller;

import org.junit.jupiter.api.Test;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import static org.junit.jupiter.api.Assertions.*;

class BackendGatewayControllerTest {
    private static final String SECRET = "01234567890123456789012345678901";
    private static final String ACCESS_TOKEN = "header.payload.signature";

    @Test void requiresCsrfForStateChangingMethodsOnly() {
        assertTrue(BackendGatewayController.requiresCsrf("POST"));
        assertTrue(BackendGatewayController.requiresCsrf("PUT"));
        assertTrue(BackendGatewayController.requiresCsrf("PATCH"));
        assertTrue(BackendGatewayController.requiresCsrf("DELETE"));
        assertFalse(BackendGatewayController.requiresCsrf("GET"));
        assertFalse(BackendGatewayController.requiresCsrf("HEAD"));
        assertFalse(BackendGatewayController.requiresCsrf("OPTIONS"));
    }

    @Test void validatesSignedDoubleSubmitTokensBoundToCurrentAccessToken() throws Exception {
        String nonce = "test-random-nonce";
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(SECRET.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] access = ACCESS_TOKEN.getBytes(StandardCharsets.UTF_8);
        byte[] random = nonce.getBytes(StandardCharsets.UTF_8);
        mac.update((byte)(access.length >>> 24)); mac.update((byte)(access.length >>> 16));
        mac.update((byte)(access.length >>> 8)); mac.update((byte)access.length); mac.update(access);
        mac.update((byte)(random.length >>> 24)); mac.update((byte)(random.length >>> 16));
        mac.update((byte)(random.length >>> 8)); mac.update((byte)random.length); mac.update(random);
        String token = nonce + "." + Base64.getUrlEncoder().withoutPadding()
                .encodeToString(mac.doFinal());

        assertTrue(BackendGatewayController.validCsrfToken(ACCESS_TOKEN, token, token, SECRET));
        assertFalse(BackendGatewayController.validCsrfToken("different-access-token", token, token, SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(ACCESS_TOKEN, token, "attacker", SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(ACCESS_TOKEN, token, token, "short"));
        assertFalse(BackendGatewayController.validCsrfToken(ACCESS_TOKEN, nonce + ".bad", nonce + ".bad", SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(ACCESS_TOKEN, token, null, SECRET));
        assertFalse(BackendGatewayController.validCsrfToken(null, token, token, SECRET));
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