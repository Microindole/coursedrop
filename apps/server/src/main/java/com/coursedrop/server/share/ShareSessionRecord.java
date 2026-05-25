package com.coursedrop.server.share;

import java.time.Instant;

public record ShareSessionRecord(
        String id,
        String code,
        String ownerIdentityId,
        OwnerIdentityType ownerIdentityType,
        ShareSessionStatus status,
        boolean downloadAuthRequired,
        Instant createdAt,
        Instant expiresAt
) {
}
