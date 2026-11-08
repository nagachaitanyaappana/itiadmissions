package com.server.frontend.security;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/** Registers the global same-origin CSRF guard and role checks for legacy proxy endpoints. */
@Configuration
public class OfficialApiSecurityConfig implements WebMvcConfigurer {

    private final OfficialApiSessionInterceptor interceptor;

    public OfficialApiSecurityConfig(OfficialApiSessionInterceptor interceptor) {
        this.interceptor = interceptor;
    }

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(interceptor).addPathPatterns("/**");
    }
}
