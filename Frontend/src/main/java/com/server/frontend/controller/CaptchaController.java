package com.server.frontend.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.springframework.http.MediaType;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.security.SecureRandom;

import javax.imageio.ImageIO;

/**
 * Serves the login captcha image and stores the expected text in the HTTP session.
 * Replaces the legacy captcha.jsp. Supports ?ts= cache-busting refreshes.
 *
 * <p>All endpoints are served under the {@code /captcha} parent path: {@code GET /captcha}
 * (PNG image) and {@code GET /captcha/text} (plain-text variant).
 */
@Controller
@RequestMapping("/captcha")
public class CaptchaController {

    private static final String SESSION_KEY = "CAPTCHA_TEXT";
    private static final String ATTEMPTS_KEY = "CAPTCHA_ATTEMPTS";
    static final String VERIFIED_AT_KEY = "CAPTCHA_VERIFIED_AT";
    static final String VERIFIED_USES_KEY = "CAPTCHA_VERIFIED_USES";
    private static final int MAX_ATTEMPTS = 5;
    private static final String CHARS = "0123456789";
    private static final SecureRandom RANDOM = new SecureRandom();

    @GetMapping(produces = MediaType.IMAGE_PNG_VALUE)
    public void captcha(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String text = randomText(4);
        HttpSession session = request.getSession();
        session.setAttribute(SESSION_KEY, text);
        session.setAttribute(ATTEMPTS_KEY, 0);
        session.removeAttribute(VERIFIED_AT_KEY);
        session.removeAttribute(VERIFIED_USES_KEY);
        session.removeAttribute("verifiedCandidateRegid");
        response.setContentType(MediaType.IMAGE_PNG_VALUE);
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate");
        response.setDateHeader("Expires", 0);

        BufferedImage img = new BufferedImage(135, 30, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, 135, 30);

        // noise lines
        for (int i = 0; i < 5; i++) {
            g.setColor(new Color(180 + RANDOM.nextInt(60), 180 + RANDOM.nextInt(60), 180 + RANDOM.nextInt(60)));
            g.drawLine(RANDOM.nextInt(135), RANDOM.nextInt(30), RANDOM.nextInt(135), RANDOM.nextInt(30));
        }

        // characters
        int x = 12;
        for (char c : text.toCharArray()) {
            g.setColor(new Color(30 + RANDOM.nextInt(80), 30 + RANDOM.nextInt(80), 120 + RANDOM.nextInt(120)));
            g.setFont(new Font("Arial", Font.BOLD | Font.ITALIC, 20 + RANDOM.nextInt(6)));
            double rot = (RANDOM.nextDouble() - 0.5) * 0.5;
            g.rotate(rot, x, 22);
            g.drawString(String.valueOf(c), x, 22);
            g.rotate(-rot, x, 22);
            x += 24;
        }
        g.dispose();

        try (OutputStream out = response.getOutputStream()) {
            ImageIO.write(img, "png", out);
            out.flush();
        }
    }

    static boolean matches(HttpServletRequest request, String submitted) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }
        Object expected = session.getAttribute(SESSION_KEY);
        if (expected == null || submitted == null) return false;
        byte[] expectedBytes = expected.toString().trim().toUpperCase().getBytes(StandardCharsets.US_ASCII);
        byte[] submittedBytes = submitted.trim().toUpperCase().getBytes(StandardCharsets.US_ASCII);
        return java.security.MessageDigest.isEqual(expectedBytes, submittedBytes);
    }

    /**
     * Validates and consumes the session captcha server-side. The expected
     * captcha text is never exposed to browser JavaScript.
     */
    @PostMapping(value = "/verify")
    @ResponseBody
    public ResponseEntity<Void> verify(@RequestParam("captcha") String submitted,
                                       HttpServletRequest request) {
        if (!BackendGatewayController.sameOrigin(request)) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        HttpSession session = request.getSession(false);
        if (session == null) return ResponseEntity.badRequest().build();
        Object attemptsValue = session.getAttribute(ATTEMPTS_KEY);
        int attempts = attemptsValue instanceof Number number ? number.intValue() : 0;
        if (attempts >= MAX_ATTEMPTS) {
            session.removeAttribute(SESSION_KEY);
            return ResponseEntity.status(429).build();
        }
        if (!matches(request, submitted)) {
            attempts++;
            session.setAttribute(ATTEMPTS_KEY, attempts);
            if (attempts >= MAX_ATTEMPTS) session.removeAttribute(SESSION_KEY);
            return ResponseEntity.badRequest().build();
        }
        session.removeAttribute(SESSION_KEY);
        session.removeAttribute(ATTEMPTS_KEY);
        session.setAttribute(VERIFIED_AT_KEY, System.currentTimeMillis());
        // Step 1 save + final registration are the two writes in the public
        // registration flow. Other identity gates consume the proof once.
        session.setAttribute(VERIFIED_USES_KEY, 2);
        return ResponseEntity.noContent().build();
    }

    private static String randomText(int len) {
        StringBuilder sb = new StringBuilder(len);
        for (int i = 0; i < len; i++) sb.append(CHARS.charAt(RANDOM.nextInt(CHARS.length())));
        return sb.toString();
    }
}
