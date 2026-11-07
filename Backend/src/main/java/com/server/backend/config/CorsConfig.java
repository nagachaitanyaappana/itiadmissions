package com.server.backend.config;

import java.util.Arrays;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * The single place CORS is configured. The former per-controller {@code @CrossOrigin} annotations
 * were inert duplicates of this class and were removed — see WRONG_IMPLEMENTATIONS.md §6.
 *
 * <p>Origins come from {@code app.cors.allowed-origins}. The fallback is restricted to known
 * localhost development origins. Deployments must set {@code CORS_ALLOWED_ORIGINS} to a
 * comma-separated allowlist of exact trusted UI origins.
 *
 * <p>Credentialed CORS must use exact origins. A wildcard is rejected at startup rather than
 * silently turning every website into a trusted origin.
 */
@Configuration
public class CorsConfig {

    private static final Logger logger = LoggerFactory.getLogger(CorsConfig.class);

    /**
     * Comma-separated list of allowed origins. An empty value denies every cross-origin request.
     */
    @Value("${app.cors.allowed-origins:http://localhost:5051,http://127.0.0.1:5051,http://localhost:6051,http://127.0.0.1:6051,http://localhost:8080,http://localhost:8081}")
    private String allowedOrigins;

    @Bean
    public WebMvcConfigurer corsConfigurer() {
        return new WebMvcConfigurer() {
            @Override
            public void addCorsMappings(CorsRegistry registry) {
                CorsRegistration registration = registry.addMapping("/**")
                        .allowedMethods("GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS")
                        .allowedHeaders("*")
                        .allowCredentials(true);

                applyOrigins(registration);
            }
        };
    }

    /** Applies {@link #allowedOrigins} to the registration. */
    private void applyOrigins(CorsRegistration registration) {
        List<String> origins = Arrays.stream(allowedOrigins.split(","))
                .map(String::trim)
                .filter(origin -> !origin.isEmpty())
                .toList();

        if (origins.isEmpty()) {
            logger.warn("app.cors.allowed-origins is empty — denying every cross-origin request. "
                    + "Set an explicit comma-separated list of trusted origins.");
            registration.allowedOrigins(new String[0]);
            return;
        }

        if (origins.contains("*")) {
            throw new IllegalStateException(
                    "Wildcard CORS origins are forbidden when credentials are enabled. "
                    + "Configure CORS_ALLOWED_ORIGINS with exact trusted origins.");
        }

        logger.info("CORS allowed origins: {}", origins);
        registration.allowedOrigins(origins.toArray(String[]::new));
    }
}
