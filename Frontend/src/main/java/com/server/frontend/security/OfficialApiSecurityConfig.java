package com.server.frontend.security;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** Registers session/role checks for legacy same-origin proxy endpoints. */
@Configuration
public class OfficialApiSecurityConfig implements WebMvcConfigurer {

    private final OfficialApiSessionInterceptor interceptor;

    public OfficialApiSecurityConfig(OfficialApiSessionInterceptor interceptor) {
        this.interceptor = interceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(interceptor)
                .addPathPatterns(
                        "/ReservationEntry/**",
                        "/SeatCorrection/**",
                        "/ScheduleEntryView/**",
                        "/admissions/search/**",
                        "/admissions/admission-update/**",
                        "/admissions/application-reprint/**",
                        "/admissions/discharge-admission/**",
                        "/admissions/print-admission-slip/**",
                        "/admissions/reprint-verified-application/**",
                        "/admissions/dsc-list/**",
                        "/VerifyApplication/**",
                        "/CallLetterView/**",
                        "/AdmissionPhase/**",
                        "/AddTrade/**",
                        "/itiList/**",
                        "/iti-details/**",
                        "/iti-create/**",
                        "/iti-trade-selection/**",
                        "/shift-unit-permitted/**");
    }
}
