package com.server.frontend.controller;

import java.io.IOException;
import java.util.Set;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StreamUtils;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.client.RestClientException;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.util.UriComponentsBuilder;

/**
 * Same-origin gateway for authenticated official workflows.
 * Public candidate endpoints are intentionally not exposed here until their
 * exact route allowlist and ownership rules have been audited.
 */
@RestController
public class BackendGatewayController {
    private static final Set<String> METHODS =
            Set.of("GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS");
    private static final Set<String> REQUEST_HEADERS =
            Set.of("accept", "content-type", "if-match", "if-none-match", "range");
    private static final Set<String> RESPONSE_HEADERS =
            Set.of("content-type", "content-disposition", "cache-control", "etag",
                    "last-modified", "accept-ranges", "content-range");

    private final RestTemplate rest = new RestTemplate();

    @Value("${backend.api.base-url}")
    private String backendBaseUrl;

    @Value("${app.internal-auth.secret:}")
    private String internalApiSecret;

    @RequestMapping("/backend/**")
    public ResponseEntity<byte[]> proxy(HttpServletRequest request) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("sessionUser") == null) {
            return ResponseEntity.status(401).build();
        }
        String methodName = request.getMethod().toUpperCase();
        if (!METHODS.contains(methodName)) {
            return ResponseEntity.status(405).build();
        }
        if (internalApiSecret == null || internalApiSecret.length() < 32) {
            return ResponseEntity.status(503).build();
        }

        String path = request.getRequestURI().substring("/backend".length());
        if (!safePath(path)) {
            return ResponseEntity.badRequest().build();
        }

        HttpMethod method = HttpMethod.valueOf(methodName);
        String target = UriComponentsBuilder.fromUriString(backendBaseUrl)
                .path(path).query(request.getQueryString()).build(true).toUriString();
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Internal-Service-Key", internalApiSecret);
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

    private static boolean safePath(String path) {
        if (path == null || !path.startsWith("/") || path.startsWith("//")
                || path.contains("\\") || path.contains("..") || path.indexOf(0) >= 0) {
            return false;
        }
        String lower = path.toLowerCase();
        return !lower.startsWith("/actuator") && !lower.startsWith("/swagger")
                && !lower.startsWith("/v3/api-docs") && !lower.startsWith("/error")
                && !lower.startsWith("/api/auth");
    }
}
