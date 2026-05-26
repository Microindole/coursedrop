package com.coursedrop.server.share;

import java.time.Instant;

import com.coursedrop.server.enums.OwnerIdentityType;
import com.coursedrop.server.enums.DownloadPolicy;
import com.coursedrop.server.enums.ShareSessionStatus;

public record ShareSessionRecord(
        String id,
        String code,
        String ownerIdentityId,
        OwnerIdentityType ownerIdentityType,
        ShareSessionStatus status,
        DownloadPolicy downloadPolicy,
        Instant createdAt,
        Instant expiresAt
) {
}
