package com.coursedrop.server.dto;

import java.time.Instant;

public record ShareItemResponse(
        String id,
        String shareId,
        String displayName,
        String contentType,
        long sizeBytes,
        boolean encrypted,
        String encryptionAlgorithm,
        String kdfAlgorithm,
        String kdfSalt,
        String nonce,
        String sha256,
        Long plainSizeBytes,
        Instant createdAt,
        Instant expiresAt
) {
}
