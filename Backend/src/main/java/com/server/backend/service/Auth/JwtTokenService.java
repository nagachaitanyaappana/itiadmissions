package com.server.backend.service.Auth;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.SecretKey;
import java.time.Instant;
import java.util.Date;

/** Issues and verifies short-lived official-user access tokens. */
@Service
public class JwtTokenService {
    private static final long ACCESS_TOKEN_SECONDS = 900;
    private final SecretKey signingKey;
    private final String issuer;

    public JwtTokenService(@Value("${app.jwt.secret:}") String encodedSecret,
                           @Value("${app.jwt.issuer:itiadmissions}") String issuer) {
        if (encodedSecret == null || encodedSecret.isBlank()) {
            throw new IllegalStateException("APP_JWT_SECRET must be configured");
        }
        byte[] keyBytes;
        try {
            keyBytes = Decoders.BASE64.decode(encodedSecret);
        } catch (RuntimeException ex) {
            throw new IllegalStateException("APP_JWT_SECRET must be Base64 encoded", ex);
        }
        if (keyBytes.length < 32) {
            throw new IllegalStateException("APP_JWT_SECRET must contain at least 32 random bytes");
        }
        this.signingKey = Keys.hmacShaKeyFor(keyBytes);
        this.issuer = issuer;
    }

    public IssuedToken issue(String username, Integer roleId, String insCode) {
        Instant now = Instant.now();
        Instant expires = now.plusSeconds(ACCESS_TOKEN_SECONDS);
        String token = Jwts.builder().issuer(issuer).subject(username)
                .issuedAt(Date.from(now)).expiration(Date.from(expires))
                .claim("roleId", roleId).claim("insCode", insCode)
                .signWith(signingKey).compact();
        return new IssuedToken(token, expires);
    }

    public Claims verify(String token) {
        return Jwts.parser().verifyWith(signingKey).requireIssuer(issuer)
                .build().parseSignedClaims(token).getPayload();
    }

    public record IssuedToken(String value, Instant expiresAt) {}
}
