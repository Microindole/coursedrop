package com.coursedrop.server.share;

import java.time.Instant;

public record ShareItemRecord(
        String id,
        String shareId,
        String displayName,
        String storageKey,
        String contentType,
        long sizeBytes,
        boolean encrypted,
        String sha256,
        Instant createdAt,
        Instant expiresAt
) {
}
