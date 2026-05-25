package com.coursedrop.server.auth;

import java.time.Instant;

public record WebLoginSession(
        String id,
        String loginCode,
        String accountId,
        String fingerprintId,
        WebLoginStatus status,
        Instant createdAt,
        Instant expiresAt
) {
}
