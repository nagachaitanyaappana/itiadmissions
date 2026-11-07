package com.server.frontend.controller;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpSession;

import static org.junit.jupiter.api.Assertions.*;

class CaptchaControllerTest {

    @Test
    void validatesAndConsumesCaptchaWithoutExposingItsAnswer() {
        CaptchaController controller = new CaptchaController();
        MockHttpServletRequest request = sameOriginRequest();
        request.getSession(true).setAttribute("CAPTCHA_TEXT", "A7K2");

        var response = controller.verify("a7k2", request);

        assertEquals(HttpStatus.NO_CONTENT, response.getStatusCode());
        assertNull(request.getSession(false).getAttribute("CAPTCHA_TEXT"));
        assertNotNull(request.getSession(false).getAttribute(CaptchaController.VERIFIED_AT_KEY));
        assertEquals(2, request.getSession(false).getAttribute(CaptchaController.VERIFIED_USES_KEY));
    }

    @Test
    void rejectsCrossOriginCaptchaVerification() {
        CaptchaController controller = new CaptchaController();
        MockHttpServletRequest request = sameOriginRequest();
        request.removeHeader("Origin");
        request.addHeader("Origin", "https://attacker.example");
        request.getSession(true).setAttribute("CAPTCHA_TEXT", "A7K2");

        var response = controller.verify("A7K2", request);

        assertEquals(HttpStatus.FORBIDDEN, response.getStatusCode());
        assertEquals("A7K2", request.getSession(false).getAttribute("CAPTCHA_TEXT"));
    }

    @Test
    void limitsCaptchaAttemptsPerSession() {
        CaptchaController controller = new CaptchaController();
        MockHttpServletRequest request = sameOriginRequest();
        request.getSession(true).setAttribute("CAPTCHA_TEXT", "A7K2");

        for (int i = 0; i < 5; i++) {
            assertEquals(HttpStatus.BAD_REQUEST, controller.verify("WRONG", request).getStatusCode());
        }
        assertNull(request.getSession(false).getAttribute("CAPTCHA_TEXT"));
        assertEquals(429, controller.verify("A7K2", request).getStatusCode());
    }

    @Test
    void consumesCorrectLoginCaptchaOnlyOnce() {
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("CAPTCHA_TEXT", "1234");
        session.setAttribute("CAPTCHA_ATTEMPTS", 0);
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setSession(session);

        assertTrue(CaptchaController.consumeForLogin(request, "1234"));
        assertNull(session.getAttribute("CAPTCHA_TEXT"));
        assertNull(session.getAttribute("CAPTCHA_ATTEMPTS"));
        assertFalse(CaptchaController.consumeForLogin(request, "1234"));
    }

    @Test
    void expiresLoginCaptchaAfterFiveIncorrectAttempts() {
        MockHttpSession session = new MockHttpSession();
        session.setAttribute("CAPTCHA_TEXT", "1234");
        session.setAttribute("CAPTCHA_ATTEMPTS", 0);
        MockHttpServletRequest request = new MockHttpServletRequest();
        request.setSession(session);

        for (int i = 0; i < 5; i++) {
            assertFalse(CaptchaController.consumeForLogin(request, "9999"));
        }

        assertEquals(5, session.getAttribute("CAPTCHA_ATTEMPTS"));
        assertNull(session.getAttribute("CAPTCHA_TEXT"));
        assertFalse(CaptchaController.consumeForLogin(request, "1234"));
    }

    private static MockHttpServletRequest sameOriginRequest() {
        MockHttpServletRequest request = new MockHttpServletRequest("POST", "/captcha/verify");
        request.setScheme("http");
        request.setServerName("localhost");
        request.setServerPort(80);
        request.addHeader("Origin", "http://localhost");
        return request;
    }
}
