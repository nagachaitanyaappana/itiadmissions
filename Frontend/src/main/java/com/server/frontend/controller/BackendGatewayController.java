package com.server.frontend.controller;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.time.Duration;
import java.util.Set;
import java.util.Base64;
import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;

import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/** Same-origin gateway: browser -> Frontend -> Backend. */
@RestController
public class BackendGatewayController {
    private static final Set<String> METHODS =
            Set.of("GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS");
    private static final Set<String> REQUEST_HEADERS =
            Set.of("accept", "content-type", "if-match", "if-none-match", "range");
    private static final Set<String> RESPONSE_HEADERS =
            Set.of("content-type", "content-disposition", "cache-control", "etag",
                    "last-modified", "accept-ranges", "content-range");

    private final RestTemplate rest;
    private final String backendBaseUrl;
    @Value("${app.internal-auth.secret:}")
    private String internalApiSecret;

    public BackendGatewayController(
            @Value("${backend.api.base-url}") String backendBaseUrl,
            @Value("${backend.gateway.connect-timeout:3s}") Duration connectTimeout,
            @Value("${backend.gateway.read-timeout:30s}") Duration readTimeout) {
        this.backendBaseUrl = backendBaseUrl;
        SimpleClientHttpRequestFactory factory = new SimpleClientHttpRequestFactory();
        factory.setConnectTimeout(connectTimeout);
        factory.setReadTimeout(readTimeout);
        this.rest = new RestTemplate(factory);
    }

    @RequestMapping("/backend/**")
    public ResponseEntity<byte[]> proxy(HttpServletRequest request) throws IOException {
        String accessToken = cookie(request, "ITIAP_ACCESS_TOKEN");
        if (accessToken == null || accessToken.isBlank() || accessToken.length() > 8192)
            return ResponseEntity.status(401).build();
        String methodName = request.getMethod().toUpperCase();
        if (!METHODS.contains(methodName)) return ResponseEntity.status(405).build();
        if (internalApiSecret == null || internalApiSecret.length() < 32)
            return ResponseEntity.status(503).build();
        if (requiresCsrf(methodName) && !validCsrfToken(
                cookie(request, "ITIAP_CSRF_TOKEN"), request.getHeader("X-CSRF-TOKEN"), internalApiSecret))
            return ResponseEntity.status(403).build();

        String requestPath = request.getRequestURI().substring(request.getContextPath().length());
        if (!requestPath.startsWith("/backend/")) return ResponseEntity.badRequest().build();
        String path = requestPath.substring("/backend".length());
        if (!safePath(path)) return ResponseEntity.badRequest().build();

        HttpMethod method = HttpMethod.valueOf(methodName);
        String target = UriComponentsBuilder.fromUriString(backendBaseUrl)
                .path(path).query(request.getQueryString()).build(true).toUriString();
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Service-Key", internalApiSecret);
        headers.setBearerAuth(accessToken);
        for (String name : REQUEST_HEADERS) {
            String value = request.getHeader(name);
            if (value != null) headers.set(name, value);
        }
        byte[] body = method == HttpMethod.GET || method == HttpMethod.HEAD
                ? new byte[0] : StreamUtils.copyToByteArray(request.getInputStream());
        try {
            ResponseEntity<byte[]> upstream = rest.exchange(
                    target, method, new HttpEntity<>(body, headers), byte[].class);
            return response(upstream.getStatusCode(), upstream.getHeaders(), upstream.getBody());
        } catch (org.springframework.web.client.HttpStatusCodeException ex) {
            return response(ex.getStatusCode(), ex.getResponseHeaders(), ex.getResponseBodyAsByteArray());
        } catch (RestClientException ex) {
            return ResponseEntity.status(502).build();
        }
    }

    private static ResponseEntity<byte[]> response(
            org.springframework.http.HttpStatusCode status, HttpHeaders source, byte[] body) {
        HttpHeaders safe = new HttpHeaders();
        if (source != null) source.forEach((name, values) -> {
            if (RESPONSE_HEADERS.contains(name.toLowerCase())) safe.put(name, values);
        });
        return new ResponseEntity<>(body, safe, status);
    }

    private static String cookie(HttpServletRequest request, String name) {
        Cookie[] cookies = request.getCookies();
        if (cookies == null) return null;
        for (Cookie cookie : cookies) if (name.equals(cookie.getName())) return cookie.getValue();
        return null;
    }

    static boolean requiresCsrf(String method) {
        return !("GET".equalsIgnoreCase(method) || "HEAD".equalsIgnoreCase(method)
                || "OPTIONS".equalsIgnoreCase(method));
    }

    static boolean validCsrfToken(String cookieToken, String supplied, String secret) {
        if (cookieToken == null || supplied == null || secret == null || secret.length() < 32
                || cookieToken.isBlank() || !MessageDigest.isEqual(
                    cookieToken.getBytes(StandardCharsets.UTF_8),
                    supplied.getBytes(StandardCharsets.UTF_8))) return false;
        int separator = cookieToken.lastIndexOf('.');
        if (separator <= 0 || separator == cookieToken.length() - 1) return false;
        String nonce = cookieToken.substring(0, separator);
        try {
            Mac mac = Mac.getInstance("HmacSHA256");
            mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
            byte[] expected = mac.doFinal(nonce.getBytes(StandardCharsets.UTF_8));
            byte[] actual = Base64.getUrlDecoder().decode(cookieToken.substring(separator + 1));
            return MessageDigest.isEqual(expected, actual);
        } catch (Exception ex) {
            return false;
        }
    }

    static boolean safePath(String path) {
        if (path == null || !path.startsWith("/") || path.startsWith("//")
                || path.contains("\\") || path.contains("..") || path.indexOf(0) >= 0
                || path.indexOf('\r') >= 0 || path.indexOf('\n') >= 0
                || path.matches("(?i).*%(2f|5c|2e|25).*")) return false;
        String lower = path.toLowerCase();
        return !lower.startsWith("/actuator") && !lower.startsWith("/swagger")
                && !lower.startsWith("/v3/api-docs") && !lower.startsWith("/error")
                && !lower.startsWith("/api/auth");
    }
}