package com.server.frontend.controller;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import java.util.Map;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

/** Issues a stateless signed double-submit token bound to the current access-token cookie. */
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
    public ResponseEntity<Map<String, String>> token(HttpServletRequest request) {
        String accessToken = cookie(request, "ITIAP_ACCESS_TOKEN");
        if (accessToken == null || accessToken.isBlank() || accessToken.length() > 8192)
            return ResponseEntity.status(401).build();
        if (secret.length() < 32) return ResponseEntity.status(503).build();

        byte[] bytes = new byte[32];
        RANDOM.nextBytes(bytes);
        String nonce = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        String signature = Base64.getUrlEncoder().withoutPadding()
                .encodeToString(sign(accessToken, nonce));
        String token = nonce + "." + signature;
        ResponseCookie cookie = ResponseCookie.from("ITIAP_CSRF_TOKEN", token)
                .httpOnly(false).secure(secureCookie).sameSite("Lax").path("/").maxAge(900).build();
        return ResponseEntity.ok().header(HttpHeaders.SET_COOKIE, cookie.toString())
                .cacheControl(CacheControl.noStore()).body(Map.of("token", token));
    }

    static boolean valid(String accessToken, String token, String secret) {
        if (accessToken == null || accessToken.isBlank() || token == null || secret == null
                || secret.length() < 32) return false;
        int separator = token.lastIndexOf('.');
        if (separator <= 0 || separator == token.length() - 1) return false;
        try {
            byte[] expected = sign(secret, accessToken, token.substring(0, separator));
            byte[] actual = Base64.getUrlDecoder().decode(token.substring(separator + 1));
            return MessageDigest.isEqual(expected, actual);
        } catch (RuntimeException ex) {
            return false;
        }
    }

    private byte[] sign(String accessToken, String nonce) {
        return sign(secret, accessToken, nonce);
    }

    private static byte[] sign(String secret, String accessToken, String nonce) {
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            // Length-prefix both values to avoid ambiguous concatenation and bind the CSRF
            // token to this exact short-lived authenticated access token.
            byte[] context = accessToken.getBytes(StandardCharsets.UTF_8);
            byte[] random = nonce.getBytes(StandardCharsets.UTF_8);
            mac.update((byte) (context.length >>> 24));
            mac.update((byte) (context.length >>> 16));
            mac.update((byte) (context.length >>> 8));
            mac.update((byte) context.length);
            mac.update(context);
            mac.update((byte) (random.length >>> 24));
            mac.update((byte) (random.length >>> 16));
            mac.update((byte) (random.length >>> 8));
            mac.update((byte) random.length);
            mac.update(random);
            return mac.doFinal();
        } catch (Exception ex) {
            throw new IllegalStateException("Unable to sign CSRF token", ex);
        }
    }

    private static String cookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) if (name.equals(cookie.getName())) return cookie.getValue();
        return null;
    }
}