package com.coursedrop.server.share;

import java.time.Instant;

public record ShareSessionResponse(
        String id,
        String code,
        String downloadUrl,
        ShareSessionStatus status,
        boolean downloadAuthRequired,
        Instant createdAt,
        Instant expiresAt
) {
}
