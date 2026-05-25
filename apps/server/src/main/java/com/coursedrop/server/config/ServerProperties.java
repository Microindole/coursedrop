package com.coursedrop.server.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "coursedrop.server")
public record ServerProperties(
        String publicBaseUrl,
        boolean secureCookie,
        String corsAllowedOrigins
) {
}
