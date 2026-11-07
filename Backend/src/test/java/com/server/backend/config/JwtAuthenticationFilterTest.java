package com.server.backend.config;

import com.server.backend.service.Auth.JwtTokenService;
import com.server.backend.service.Student.StudentObjectAuthorizationService;
import jakarta.servlet.FilterChain;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;

import java.util.Base64;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class JwtAuthenticationFilterTest {

    private static final String SECRET = Base64.getEncoder().encodeToString(new byte[32]);
    private JwtTokenService tokens;
    private StudentObjectAuthorizationService studentObjects;
    private JwtAuthenticationFilter filter;

    @BeforeEach
    void setUp() {
        tokens = new JwtTokenService(SECRET, "itiadmissions");
        studentObjects = mock(StudentObjectAuthorizationService.class);
        filter = new JwtAuthenticationFilter(tokens, studentObjects);
    }

    @Test
    void requiresOfficialTokenForProtectedGatewayRoutes() throws Exception {
        MockHttpServletRequest request = gatewayRequest("POST", "/api/dv/approve");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Protected route must not run without a token"));

        assertEquals(401, response.getStatus());
    }

    @Test
    void allowsExplicitPublicCandidateReferenceRoutesWithoutOfficialToken() throws Exception {
        MockHttpServletRequest request = gatewayRequest("GET", "/api/student/castes");
        MockHttpServletResponse response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
    }

    @Test
    void allowsCandidateRecordOnlyWhenGatewaySuppliesMatchingVerifiedRegid() throws Exception {
        MockHttpServletRequest request = gatewayRequest("GET", "/api/student/12345");
        request.addHeader("X-Candidate-Regid", "12345");
        MockHttpServletResponse response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
    }

    @Test
    void rejectsCandidateRecordWhenGatewaySessionScopeDoesNotMatch() throws Exception {
        MockHttpServletRequest request = gatewayRequest("GET", "/api/student/12345");
        request.addHeader("X-Candidate-Regid", "54321");
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Mismatched candidate scope must not reach the controller"));

        assertEquals(401, response.getStatus());
    }

    @Test
    void rejectsDistrictVerificationMutationFromAnItiRole() throws Exception {
        MockHttpServletRequest request = gatewayRequest("POST", "/api/dv/approve");
        request.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "1234").value());
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("ITI role must not approve district-level verification"));

        assertEquals(403, response.getStatus());
    }

    @Test
    void derivesTrustedIdentityHeadersFromSignedClaims() throws Exception {
        MockHttpServletRequest request = gatewayRequest("POST", "/api/dv/approve");
        request.addHeader("Authorization", "Bearer " + tokens.issue("district-user", 3, "07").value());
        request.addHeader("X-Role-Id", "2");
        request.addHeader("X-Ins-Code", "99");
        MockHttpServletResponse response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> {
            reached[0] = true;
            HttpServletRequest servletRequest = (HttpServletRequest) req;
            assertEquals("3", servletRequest.getHeader("X-Role-Id"));
            assertEquals("07", servletRequest.getHeader("X-Ins-Code"));
            assertEquals("07", servletRequest.getHeader("X-Dist-Code"));
            assertNull(servletRequest.getHeader("X-Iti-Code"));
        });

        assertTrue(reached[0]);
    }

    @Test
    void appliesObjectLevelDistrictAndItiChecksToStudentRecords() throws Exception {
        MockHttpServletRequest request = gatewayRequest("GET", "/api/student/12345");
        request.addHeader("Authorization", "Bearer " + tokens.issue("district-user", 3, "07").value());
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Out-of-scope candidate must not be returned"));

        assertEquals(403, response.getStatus());
    }

    private static MockHttpServletRequest gatewayRequest(String method, String path) {
        MockHttpServletRequest request = new MockHttpServletRequest(method, path);
        request.setRequestURI(path);
        request.setAttribute(InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE, Boolean.TRUE);
        return request;
    }
}
