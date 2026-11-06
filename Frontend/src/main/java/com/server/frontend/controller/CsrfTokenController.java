package com.server.frontend.controller;

import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** Issues a stateless HMAC-signed double-submit CSRF token for the same-origin gateway. */
@RestController
public class CsrfTokenController {
    private static final SecureRandom RANDOM = new SecureRandom();
    private final String secret;
    private final boolean secureCookie;

    public CsrfTokenController(@Value("${app.internal-auth.secret:}") String secret,
                               @Value("${server.servlet.session.cookie.secure:false}") boolean secureCookie) {
        this.secret = secret == null ? "" : secret;
        this.secureCookie = secureCookie;
    }

    @GetMapping("/api/csrf")
    public ResponseEntity<Map<String, String>> token() {
        if (secret.length() < 32) return ResponseEntity.status(503).build();
        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String nonce = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        String signature = Base64.getUrlEncoder().withoutPadding().encodeToString(sign(nonce));
        String token = nonce + "." + signature;
        ResponseCookie cookie = ResponseCookie.from("ITIAP_CSRF_TOKEN", token)
                .httpOnly(false).secure(secureCookie).sameSite("Lax").path("/").maxAge(1800).build();
        return ResponseEntity.ok().header(HttpHeaders.SET_COOKIE, cookie.toString())
                .cacheControl(CacheControl.noStore()).body(Map.of("token", token));
    }

    private byte[] sign(String value) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            return mac.doFinal(value.getBytes(StandardCharsets.UTF_8));
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to sign CSRF token", ex);
        }
    }
}