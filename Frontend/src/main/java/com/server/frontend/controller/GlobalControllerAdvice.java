package com.server.frontend.controller;

import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ModelAttribute;

/**
 * Browser-facing backend URLs must always resolve to the same-origin Frontend
 * gateway. The real BACKEND_URL remains a server-side property and is never
 * rendered into a JSP or static JavaScript asset.
 */
@ControllerAdvice
public class GlobalControllerAdvice {

    private static final String GATEWAY_PATH = "/backend";
    private static final String REPORTS_PATH = "/api/reports";

    @ModelAttribute("backendApiUrl")
    public String getBackendApiUrl(HttpServletRequest request) {
        return request.getContextPath() + GATEWAY_PATH + REPORTS_PATH;
    }

    @ModelAttribute("backendBaseUrl")
    public String getBackendBaseUrl(HttpServletRequest request) {
        return request.getContextPath() + GATEWAY_PATH;
    }
}
