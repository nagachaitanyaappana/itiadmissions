package com.server.frontend.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;
import java.util.Map;

@Service
public class FrontendRestClient {

    private final RestTemplate rest;
    @Value("${backend.api.base-url:http://localhost:5050}")
    private String backendBaseUrl;

    public FrontendRestClient(RestTemplate rest) {
        this.rest = rest;
    }

    /** GET .../api/XXXX and unwrap {success, count, data} envelope if present. */
    public List<Map<String, Object>> queryData(String path) {
        try {
            ResponseEntity<Object> response = rest.getForEntity(backendBaseUrl + path, Object.class);
            Object body = response.getBody();
            if (body instanceof Map) {
                Map<String, Object> map = (Map<String, Object>) body;
                if (map.containsKey("success") && map.containsKey("data")) {
                    Object data = map.get("data");
                    if (data instanceof List) {
                        return (List<Map<String, Object>>) data;
                    }
                }
            }
            // bare JSON array fallback
            if (body instanceof List) {
                return (List<Map<String, Object>>) body;
            }
        } catch (Exception e) {
            // returning empty list lets the JSP render gracefully
        }
        return java.util.Collections.emptyList();
    }

    /** GET .../api/XXXX expecting a JSON list; same envelope-unwrapping logic. */
    public List<Map<String, Object>> queryList(String path) {
        return queryData(path);
    }
}