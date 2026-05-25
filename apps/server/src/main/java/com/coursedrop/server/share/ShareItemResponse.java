package com.coursedrop.server.share;

import java.time.Instant;

public record ShareItemResponse(
        String id,
        String shareId,
        String displayName,
        String contentType,
        long sizeBytes,
        boolean encrypted,
        String sha256,
        Instant createdAt,
        Instant expiresAt
) {
}
