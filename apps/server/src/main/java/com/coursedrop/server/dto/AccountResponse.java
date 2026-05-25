package com.coursedrop.server.dto;

import java.time.Instant;

public record AccountResponse(
        String id,
        String username,
        boolean passwordLoginEnabled,
        Instant createdAt
) {
}
