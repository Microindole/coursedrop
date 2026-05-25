package com.coursedrop.server.dto;

import java.time.Instant;

import com.coursedrop.server.enums.TransferItemType;

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
