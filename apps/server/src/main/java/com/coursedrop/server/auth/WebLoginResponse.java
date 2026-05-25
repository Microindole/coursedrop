package com.coursedrop.server.auth;

import java.time.Instant;

public record WebLoginResponse(
        String loginCode,
        WebLoginStatus status,
        String accountId,
        String fingerprintId,
        Instant expiresAt
) {
}
