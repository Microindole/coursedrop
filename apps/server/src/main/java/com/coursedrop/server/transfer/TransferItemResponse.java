package com.coursedrop.server.transfer;

import java.time.Instant;

public record TransferItemResponse(
        String id,
        String roomId,
        TransferItemType type,
        String displayName,
        String contentType,
        long sizeBytes,
        Instant createdAt,
        Instant expiresAt) {
}
