package com.coursedrop.server.transfer;

import java.time.Instant;

public record TransferItemStored(
        String id,
        String roomId,
        TransferItemType type,
        String displayName,
        String storageKey,
        String contentType,
        long sizeBytes,
        Instant createdAt,
        Instant expiresAt) {
}
