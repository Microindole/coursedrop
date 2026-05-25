package com.coursedrop.server.identity;

import java.time.Instant;

public record AccountResponse(
        String id,
        String username,
        boolean passwordLoginEnabled,
        Instant createdAt
) {
}
