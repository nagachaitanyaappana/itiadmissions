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
        FilterChain chain = (req, res) -> fail("Unauthenticated request must not reach the controller");

        filter.doFilter(request, response, chain);

        assertEquals(401, response.getStatus());
    }

    @Test
    void acceptsMatchingCredentialOnLoginEndpoint() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("POST", "/api/auth/login");
        request.addHeader(InternalServiceAuthenticationFilter.HEADER_NAME, SECRET);
        var response = new MockHttpServletResponse();
        boolean[] reached = {false};
        FilterChain chain = (req, res) -> reached[0] = true;

        filter.doFilter(request, response, chain);

        assertTrue(reached[0]);
    }

    @Test
    void failsClosedWhenSecretIsNotConfigured() throws Exception {
        var filter = new InternalServiceAuthenticationFilter("");
        var request = new MockHttpServletRequest("POST", "/api/auth/login");
        var response = new MockHttpServletResponse();

        filter.doFilter(request, response, (req, res) -> fail("Unconfigured auth must fail closed"));

        assertEquals(503, response.getStatus());
    }

    @Test
    void doesNotInterceptOtherEndpointsDuringGatewayMigration() throws Exception {
        var filter = new InternalServiceAuthenticationFilter(SECRET);
        var request = new MockHttpServletRequest("GET", "/api/student/status");
        var response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
    }
}
