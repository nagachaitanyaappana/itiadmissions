package com.server.backend.config;

import jakarta.servlet.FilterChain;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import static org.junit.jupiter.api.Assertions.*;

class InternalServiceAuthenticationFilterTest {

    private static final String SECRET = "test-only-internal-service-secret-32";

    @Test
    void rejectsMissingCredentialOnLoginEndpoint() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("POST", "/api/auth/login");
        var response = new MockHttpServletResponse();
        filter.doFilter(request, response,
                (req, res) -> fail("Unauthenticated login request must not reach the controller"));
        assertEquals(401, response.getStatus());
    }

    @Test
    void acceptsMatchingCredentialOnLoginEndpoint() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("POST", "/api/auth/login");
        request.addHeader(InternalServiceAuthenticationFilter.HEADER_NAME, SECRET);
        var response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
        assertEquals(Boolean.TRUE, request.getAttribute(
                InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE));
    }

    @Test
    void rejectsBrowserOriginApiRequestsWithoutServiceCredential() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("GET", "/api/student/all");
        request.addHeader("Origin", "https://portal.example.gov.in");
        var response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Direct browser-to-Backend request must be blocked"));

        assertEquals(401, response.getStatus());
    }

    @Test
    void acceptsGatewayCredentialOnBrowserOriginApiRequests() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("GET", "/api/student/all");
        request.addHeader("Origin", "https://portal.example.gov.in");
        request.addHeader(InternalServiceAuthenticationFilter.HEADER_NAME, SECRET);
        var response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
        assertEquals(Boolean.TRUE, request.getAttribute(
                InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE));
    }

    @Test
    void rejectsLegacyServerToServerCallsWithoutServiceCredential() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("GET", "/admission-timings/entry");
        request.setRequestURI("/admission-timings/entry");
        var response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Every application endpoint must require the service credential"));

        assertEquals(401, response.getStatus());
    }

    @Test
    void acceptsCredentialOnLegacyBackendPathAndExemptsOnlyDocsAndHealth() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("GET", "/admission-timings/entry");
        request.setRequestURI("/admission-timings/entry");
        request.addHeader(InternalServiceAuthenticationFilter.HEADER_NAME, SECRET);
        var response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
        assertEquals(Boolean.TRUE, request.getAttribute(
                InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE));

        var swagger = new MockHttpServletRequest("GET", "/swagger");
        swagger.setRequestURI("/swagger");
        var swaggerResponse = new MockHttpServletResponse();
        filter.doFilter(swagger, swaggerResponse,
                (req, res) -> fail("Backend documentation must require the internal service credential"));
        assertEquals(401, swaggerResponse.getStatus());
        assertFalse(filter.shouldNotFilter(swagger));

        var health = new MockHttpServletRequest("GET", "/actuator/health");
        health.setRequestURI("/actuator/health");
        assertTrue(filter.shouldNotFilter(health));
    }

    @Test
    void rejectsInvalidCredentialEvenWhenRequestComesFromTrustedFrontendOrigin() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("POST", "/api/dv/approve");
        request.addHeader("Origin", "https://portal.example.gov.in");
        request.addHeader(InternalServiceAuthenticationFilter.HEADER_NAME, "wrong-secret");
        var response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Invalid service credential must not reach the controller"));

        assertEquals(401, response.getStatus());
    }

    @Test
    void failsClosedWhenSecretIsNotConfiguredForGatewayRequests() throws Exception {
        var filter = new InternalServiceAuthenticationFilter("");
        var request = new MockHttpServletRequest("POST", "/api/auth/login");
        var response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) -> fail("Unconfigured auth must fail closed"));

        assertEquals(503, response.getStatus());
    }
}
