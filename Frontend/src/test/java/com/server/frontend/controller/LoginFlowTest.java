package com.server.frontend.controller;

import jakarta.servlet.http.HttpSession;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpSession;
import org.springframework.test.web.client.MockRestServiceServer;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.web.client.RestTemplate;

import static org.junit.jupiter.api.Assertions.*;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.header;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.method;
import static org.springframework.test.web.client.match.MockRestRequestMatchers.requestTo;
import static org.springframework.test.web.client.response.MockRestResponseCreators.withSuccess;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@SpringBootTest
@AutoConfigureMockMvc
class LoginFlowTest {

    // Generated at test runtime so no secret-shaped literal is committed or scanned.
    private static final String TEST_SERVICE_KEY =
            "test-" + java.util.UUID.randomUUID().toString().replace("-", "");

    @DynamicPropertySource
    static void registerTestProperties(DynamicPropertyRegistry registry) {
        registry.add("app.internal-auth.secret", () -> TEST_SERVICE_KEY);
        registry.add("backend.api.base-url", () -> "http://localhost:5050");
    }

    @Autowired
    private org.springframework.test.web.servlet.MockMvc mvc;

    @Autowired
    private RestTemplate restTemplate;

    private MockRestServiceServer backend;

    @BeforeEach
    void setUpBackendStub() {
        backend = MockRestServiceServer.bindTo(restTemplate).build();
    }

    @AfterEach
    void verifyBackendStub() {
        backend.verify();
    }

    private MockHttpSession sessionWithCaptcha() throws Exception {
        MockHttpSession session = new MockHttpSession();
        mvc.perform(get("/captcha").session(session)).andExpect(status().isOk());
        return session;
    }

    private String captchaText(HttpSession session) {
        return (String) session.getAttribute("CAPTCHA_TEXT");
    }

    private void respondToLogin(String json) {
        backend.expect(requestTo("http://localhost:5050/api/auth/login"))
                .andExpect(method(HttpMethod.POST))
                .andExpect(header("X-Internal-Service-Key", TEST_SERVICE_KEY))
                .andRespond(withSuccess(json, MediaType.APPLICATION_JSON));
    }

    @Test
    void wrongCaptchaRedirectsHomeWithoutCallingBackend() throws Exception {
        MockHttpSession session = sessionWithCaptcha();
        String wrong = "zzzzz".equals(captchaText(session)) ? "aaaaa" : "zzzzz";
        mvc.perform(post("/iti/login.do")
                        .header("Origin", "http://localhost")
                        .param("uname", "test-user")
                        .param("pwd", "not-a-real-password")
                        .param("captcha", wrong)
                        .session(session))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/?error=captcha"));
    }

    @Test
    void correctCaptchaButRejectedCredentialsRedirectWithInvalid() throws Exception {
        respondToLogin("""
                {"success":false,"message":"Invalid credentials"}
                """);
        MockHttpSession session = sessionWithCaptcha();
        mvc.perform(post("/iti/login.do")
                        .header("Origin", "http://localhost")
                        .param("uname", "test-user")
                        .param("pwd", "not-a-real-password")
                        .param("captcha", captchaText(session))
                        .session(session))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/?error=invalid"));
    }

    @Test
    void successfulLoginStoresOnlySafeUserDataAndIssuesHttpOnlyAccessCookie() throws Exception {
        respondToLogin("""
                {
                  "success":true,
                  "message":"Login successful",
                  "username":"test-user",
                  "roleId":4,
                  "insCode":"TEST-ITI",
                  "fullName":"Test Official",
                  "itiName":"Test ITI",
                  "distName":"",
                  "loginCount":1,
                  "lastLogins":[],
                  "accessToken":"test.signed.access-token",
                  "expiresAt":"2030-01-01T00:15:00Z",
                  "tokenType":"Bearer"
                }
                """);
        MockHttpSession session = sessionWithCaptcha();
        mvc.perform(post("/iti/login.do")
                        .header("Origin", "http://localhost")
                        .param("uname", "test-user")
                        .param("pwd", "test-password")
                        .param("captcha", captchaText(session))
                        .session(session))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/authHome"))
                .andExpect(cookie().httpOnly("ITIAP_ACCESS_TOKEN", true));

        assertEquals(4, ((Number) session.getAttribute("roleId")).intValue());
        assertEquals("test-user", session.getAttribute("username"));
        @SuppressWarnings("unchecked")
        java.util.Map<String, Object> safeUser =
                (java.util.Map<String, Object>) session.getAttribute("sessionUser");
        assertNotNull(safeUser);
        assertFalse(safeUser.containsKey("accessToken"));
        assertFalse(safeUser.containsKey("expiresAt"));
        assertFalse(safeUser.containsKey("tokenType"));

        mvc.perform(get("/authHome").session(session))
                .andExpect(status().isOk());
    }

    @Test
    void safeRedirectRejectsProtocolRelativeAndBackslashTargets() {
        assertEquals("/authHome", LoginController.safeRedirect("//attacker.example", "/authHome"));
        assertEquals("/authHome", LoginController.safeRedirect("/\\\\attacker.example", "/authHome"));
        assertEquals("/reports", LoginController.safeRedirect("/reports", "/authHome"));
        assertEquals("/authHome", LoginController.safeRedirect("https://attacker.example", "/authHome"));
    }

    @Test
    void crossOriginLogoutDoesNotInvalidateTheOfficialSession() throws Exception {
        MockHttpSession session = devSession(4);

        mvc.perform(get("/logout")
                        .header("Origin", "https://attacker.example")
                        .session(session))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/"));

        assertNotNull(session.getAttribute("sessionUser"));
    }

    @Test
    void authHomeWithoutLoginRedirectsToError() throws Exception {
        mvc.perform(get("/authHome"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/?error=session"));
    }

    // ---------- /dev login gate + per-login page access ----------

    /** Signed-in session for a given roleId, without touching the backend. */
    private MockHttpSession devSession(Object roleId) {
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("sessionUser", new java.util.HashMap<String, Object>());
        session.setAttribute("username", "devuser");
        if (roleId != null) session.setAttribute("roleId", roleId);
        return session;
    }

    @Test
    void devIndexRedirectsToDevLoginWhenSignedOut() throws Exception {
        mvc.perform(get("/dev"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/dev/login"));
    }

    @Test
    void devLoginPageRenders() throws Exception {
        mvc.perform(get("/dev/login"))
                .andExpect(status().isOk())
                .andExpect(forwardedUrl("/WEB-INF/jsp/devLogin.jsp"));
    }

    @Test
    void devLogoutSendsBackToDevLogin() throws Exception {
        mvc.perform(get("/dev/logout").header("Origin", "http://localhost").session(devSession(4)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/dev/login"));
    }

    @Test
    void devViewRedirectsToDevLoginWhenSignedOut() throws Exception {
        mvc.perform(get("/dev/view/admission/addTrade"))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/dev/login"));
    }

    @Test
    void itiLoginCanOpenItiPageButNotNodalPage() throws Exception {
        mvc.perform(get("/dev/view/reports/api-dashboard-iti").session(devSession(4)))
                .andExpect(status().isOk())
                .andExpect(forwardedUrl("/WEB-INF/reports/api-dashboard-iti.jsp"));

        mvc.perform(get("/dev/view/reports/api-dashboard-state").session(devSession(4)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/dev?error=denied&page=reports%2Fapi-dashboard-state"));
    }

    @Test
    void nodalLoginCanOpenNodalPageButNotItiOnlyPage() throws Exception {
        mvc.perform(get("/dev/view/reports/api-dashboard-state").session(devSession(10)))
                .andExpect(status().isOk())
                .andExpect(forwardedUrl("/WEB-INF/reports/api-dashboard-state.jsp"));

        mvc.perform(get("/dev/view/reports/api-dashboard-iti").session(devSession(10)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/dev?error=denied&page=reports%2Fapi-dashboard-iti"));
    }

    @Test
    void sharedPageOpensForEverySupportedOfficialRole() throws Exception {
        for (Object role : new Object[]{4, 3, 10, 2}) {
            mvc.perform(get("/dev/view/reports/dsc-list").session(devSession(role)))
                    .andExpect(status().isOk());
        }
    }

    @Test
    void adminCanOpenEveryPage() throws Exception {
        mvc.perform(get("/dev/view/reports/api-dashboard-iti").session(devSession(2)))
                .andExpect(status().isOk());
        mvc.perform(get("/dev/view/reports/api-dashboard-state").session(devSession(2)))
                .andExpect(status().isOk());
    }

    @Test
    void unroutedWipPageRequiresARecognizedOfficialRole() throws Exception {
        mvc.perform(get("/dev/view/admission/addTrade").session(devSession(4)))
                .andExpect(status().isOk());
        mvc.perform(get("/dev/view/admission/addTrade").session(devSession(10)))
                .andExpect(status().isOk());
        mvc.perform(get("/dev/view/admission/addTrade").session(devSession(null)))
                .andExpect(status().is3xxRedirection())
                .andExpect(redirectedUrl("/dev?error=denied&page=admission%2FaddTrade"));
    }
}
