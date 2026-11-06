package com.server.backend.service.Auth;

import io.jsonwebtoken.JwtException;
import org.junit.jupiter.api.Test;

import java.util.Base64;

import static org.junit.jupiter.api.Assertions.*;

class JwtTokenServiceTest {
    private static final String SECRET = Base64.getEncoder().encodeToString(new byte[32]);

    @Test
    void issuesSignedTokenWithOfficialIdentityClaims() {
        JwtTokenService service = new JwtTokenService(SECRET, "itiadmissions");
        var issued = service.issue("official-user", 4, "ITI-001");

        var claims = service.verify(issued.value());
        assertEquals("official-user", claims.getSubject());
        assertEquals("itiadmissions", claims.getIssuer());
        assertEquals(4, claims.get("roleId", Integer.class));
        assertEquals("ITI-001", claims.get("insCode", String.class));
        assertTrue(issued.expiresAt().isAfter(java.time.Instant.now()));
    }

    @Test
    void rejectsTokenSignedByAnotherKey() {
        JwtTokenService issuer = new JwtTokenService(SECRET, "itiadmissions");
        JwtTokenService verifier = new JwtTokenService(
                Base64.getEncoder().encodeToString(new byte[32].clone().length == 0
                        ? new byte[32] : new byte[]{1, 2, 3, 4, 5, 6, 7, 8,
                        9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24,
                        25, 26, 27, 28, 29, 30, 31, 32}), "itiadmissions");
        String token = issuer.issue("official-user", 4, "ITI-001").value();
        assertThrows(JwtException.class, () -> verifier.verify(token));
    }

    @Test
    void refusesMissingOrWeakSigningKey() {
        assertThrows(IllegalStateException.class, () -> new JwtTokenService("", "itiadmissions"));
        assertThrows(IllegalStateException.class, () -> new JwtTokenService(
                Base64.getEncoder().encodeToString(new byte[16]), "itiadmissions"));
    }
}
