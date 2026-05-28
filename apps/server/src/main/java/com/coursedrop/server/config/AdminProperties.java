package com.coursedrop.server.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "coursedrop.admin")
public record AdminProperties(
        String username,
        String password
) {
}
