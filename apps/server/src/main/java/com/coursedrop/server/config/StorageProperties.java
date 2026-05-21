package com.coursedrop.server.config;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "coursedrop.storage")
public record StorageProperties(
    String uploadDir,
    long roomTtlHours,
    long fileTtlHours,
    long maxFileSizeMb
) {
}

