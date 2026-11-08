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
    void allowsTrustedBackendLoginWithoutBearerToken() throws Exception {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/api/auth/login");
        request.setRequestURI("/api/auth/login");
        request.setAttribute(InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE, Boolean.TRUE);
        MockHttpServletResponse response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
        assertEquals(200, response.getStatus());
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
    void allowsCandidateIdentityChecksOnlyAsPublicJsonPosts() throws Exception {
        for (String path : new String[] { "/api/student/apply-gate", "/api/student/verify-identity" }) {
            MockHttpServletRequest post = gatewayRequest("POST", path);
            MockHttpServletResponse postResponse = new MockHttpServletResponse();
            boolean[] reached = {false};
            filter.doFilter(post, postResponse, (req, res) -> reached[0] = true);
            assertTrue(reached[0], "POST identity check should be public: " + path);

            MockHttpServletRequest get = gatewayRequest("GET", path);
            MockHttpServletResponse getResponse = new MockHttpServletResponse();
            filter.doFilter(get, getResponse,
                    (req, res) -> fail("Identity checks must not expose DOB/hall-ticket in GET URLs"));
            assertEquals(401, getResponse.getStatus());
        }
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
    void allowsItiScheduleReadUpdateAndDeleteOnlyForItsOwnIti() throws Exception {
        for (String method : new String[] { "GET", "PUT", "DELETE" }) {
            MockHttpServletRequest own = gatewayRequest(method, "/admission-timings/ITI-001/1");
            own.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
            MockHttpServletResponse ownResponse = new MockHttpServletResponse();
            boolean[] reached = {false};
            filter.doFilter(own, ownResponse, (req, res) -> reached[0] = true);
            assertTrue(reached[0], method + " should be allowed for the assigned ITI");

            MockHttpServletRequest other = gatewayRequest(method, "/admission-timings/ITI-999/1");
            other.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
            MockHttpServletResponse otherResponse = new MockHttpServletResponse();
            filter.doFilter(other, otherResponse,
                    (req, res) -> fail(method + " must not be allowed for another ITI"));
            assertEquals(403, otherResponse.getStatus());
        }
    }

    @Test
    void deniesUnknownDistrictVerificationRoutesToEveryRole() throws Exception {
        for (int role : new int[] { 2, 3, 4, 10 }) {
            MockHttpServletRequest request = gatewayRequest("GET", "/api/dv/unreviewed-export");
            request.addHeader("Authorization", "Bearer " + tokens.issue("official", role, "07").value());
            MockHttpServletResponse response = new MockHttpServletResponse();
            filter.doFilter(request, response,
                    (req, res) -> fail("Unknown district verification routes must be denied"));
            assertEquals(403, response.getStatus());
        }
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

    @Test
    void allowsCandidateToRemoveOnlyTheirVerifiedTradeSelectionRoutes() throws Exception {
        MockHttpServletRequest request = gatewayRequest(
                "DELETE", "/admission/student-trade-selection/12345/dist/07");
        request.addHeader("X-Candidate-Regid", "12345");
        MockHttpServletResponse response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> reached[0] = true);

        assertTrue(reached[0]);
    }

    @Test
    void deniesUnscopedChecklistReadsToItiOfficials() throws Exception {
        MockHttpServletRequest request = gatewayRequest("GET", "/api/checklist");
        request.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("Unscoped checklist listing must be denied"));

        assertEquals(403, response.getStatus());
    }

    @Test
    void derivesItiReportDistrictFilterInsteadOfTrustingBrowserParameter() throws Exception {
        when(studentObjects.districtForIti("ITI-001")).thenReturn("07");
        MockHttpServletRequest request = gatewayRequest("GET", "/api/reports/iti-wise-status");
        request.addParameter("distCode", "99");
        request.addParameter("itiCode", "ITI-999");
        request.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
        MockHttpServletResponse response = new MockHttpServletResponse();
        boolean[] reached = {false};

        filter.doFilter(request, response, (req, res) -> {
            reached[0] = true;
            HttpServletRequest trusted = (HttpServletRequest) req;
            assertEquals("07", trusted.getParameter("distCode"));
            assertEquals("ITI-001", trusted.getParameter("itiCode"));
            assertEquals("07", trusted.getHeader("X-Dist-Code"));
            assertEquals("ITI-001", trusted.getHeader("X-Iti-Code"));
        });

        assertTrue(reached[0]);
    }

    @Test
    void allowsDetailedAdmissionsReportOnlyForTheAuthenticatedItiScope() throws Exception {
        when(studentObjects.districtForIti("ITI-001")).thenReturn("07");
        MockHttpServletRequest own = gatewayRequest("GET", "/api/reports/admission-report-iti");
        own.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
        MockHttpServletResponse ownResponse = new MockHttpServletResponse();
        boolean[] ownReached = {false};
        filter.doFilter(own, ownResponse, (req, res) -> ownReached[0] = true);
        assertTrue(ownReached[0]);

        MockHttpServletRequest district = gatewayRequest("GET", "/api/reports/admission-report-iti");
        district.addHeader("Authorization", "Bearer " + tokens.issue("district-user", 3, "07").value());
        MockHttpServletResponse districtResponse = new MockHttpServletResponse();
        filter.doFilter(district, districtResponse,
                (req, res) -> fail("District accounts must not use the ITI-only detail report"));
        assertEquals(403, districtResponse.getStatus());
    }

    @Test
    void deniesItiReportsWhenTheItiHasNoTrustedDistrictMapping() throws Exception {
        when(studentObjects.districtForIti("ITI-001")).thenReturn(null);
        MockHttpServletRequest request = gatewayRequest("GET", "/api/reports/iti-wise-status");
        request.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
        MockHttpServletResponse response = new MockHttpServletResponse();

        filter.doFilter(request, response,
                (req, res) -> fail("ITI reports require a resolvable district scope"));

        assertEquals(403, response.getStatus());
    }

    @Test
    void allowsItiOfficialsToReadOnlyTheirOwnMeritList() throws Exception {
        MockHttpServletRequest own = gatewayRequest("GET", "/api/meritlist/iti/ITI-001");
        own.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
        MockHttpServletResponse ownResponse = new MockHttpServletResponse();
        boolean[] ownReached = {false};
        filter.doFilter(own, ownResponse, (req, res) -> ownReached[0] = true);
        assertTrue(ownReached[0]);

        MockHttpServletRequest other = gatewayRequest("GET", "/api/meritlist/iti/ITI-002");
        other.addHeader("Authorization", "Bearer " + tokens.issue("iti-user", 4, "ITI-001").value());
        MockHttpServletResponse otherResponse = new MockHttpServletResponse();
        filter.doFilter(other, otherResponse,
                (req, res) -> fail("Cross-ITI merit list access must be denied"));
        assertEquals(403, otherResponse.getStatus());
    }

    private static MockHttpServletRequest gatewayRequest(String method, String path) {
        MockHttpServletRequest request = new MockHttpServletRequest(method, path);
        request.setRequestURI(path);
        request.setAttribute(InternalServiceAuthenticationFilter.AUTHENTICATED_ATTRIBUTE, Boolean.TRUE);
        return request;
    }
}
