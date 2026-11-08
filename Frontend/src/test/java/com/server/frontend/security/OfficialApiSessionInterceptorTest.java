package com.server.frontend.security;

import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.mock.web.MockHttpSession;

import static org.junit.jupiter.api.Assertions.*;

class OfficialApiSessionInterceptorTest {

    private final OfficialApiSessionInterceptor interceptor = new OfficialApiSessionInterceptor();

    @Test
    void rejectsCrossOriginWritesOnUnlistedFrontendEndpoints() throws Exception {
        MockHttpServletRequest request = request("POST", "/public/submit");
        request.removeHeader("Origin");
        request.addHeader("Origin", "https://attacker.example");
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertFalse(interceptor.preHandle(request, response, new Object()));
        assertEquals(403, response.getStatus());
    }

    @Test
    void allowsSameOriginWritesOnUnlistedFrontendEndpoints() throws Exception {
        MockHttpServletRequest request = request("POST", "/public/submit");
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertTrue(interceptor.preHandle(request, response, new Object()));
        assertEquals(200, response.getStatus());
    }

    @Test
    void blocksUnauthenticatedLegacyProxyRequests() throws Exception {
        MockHttpServletRequest request = request("GET", "/ReservationEntry/api/iti/123/trades");
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertFalse(interceptor.preHandle(request, response, new Object()));
        assertEquals(401, response.getStatus());
    }

    @Test
    void restrictsLegacyProxyRoutesToTheirIntendedOfficialRoles() throws Exception {
        MockHttpServletRequest request = request("GET", "/admissions/search/api/admission-search");
        HttpSession session = new MockHttpSession();
        session.setAttribute("sessionUser", java.util.Map.of("username", "district-user"));
        session.setAttribute("roleId", "3");
        request.setSession((MockHttpSession) session);
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertFalse(interceptor.preHandle(request, response, new Object()));
        assertEquals(403, response.getStatus());
    }

    @Test
    void allowsTheIntendedRoleThroughTheLegacyProxyGuard() throws Exception {
        MockHttpServletRequest request = request("GET", "/admissions/search/api/admission-search");
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("sessionUser", java.util.Map.of("username", "iti-user"));
        session.setAttribute("roleId", "4");
        request.setSession(session);
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertTrue(interceptor.preHandle(request, response, new Object()));
        assertEquals(200, response.getStatus());
    }

    @Test
    void rejectsCrossOriginLegacyProxyWrites() throws Exception {
        MockHttpServletRequest request = request("PUT", "/ReservationEntry/api/reservation-entry");
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("sessionUser", java.util.Map.of("username", "district-user"));
        session.setAttribute("roleId", "3");
        request.setSession(session);
        request.addHeader("Origin", "https://attacker.example");
        MockHttpServletResponse response = new MockHttpServletResponse();

        assertFalse(interceptor.preHandle(request, response, new Object()));
        assertEquals(403, response.getStatus());
    }

    private static MockHttpServletRequest request(String method, String path) {
        MockHttpServletRequest request = new MockHttpServletRequest(method, path);
        request.setRequestURI(path);
        request.setScheme("https");
        request.setServerName("portal.example.gov.in");
        request.setServerPort(443);
        request.addHeader("Origin", "https://portal.example.gov.in");
        return request;
    }
}
