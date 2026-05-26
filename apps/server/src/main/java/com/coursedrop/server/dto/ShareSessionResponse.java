package com.coursedrop.server.dto;

import java.time.Instant;

import com.coursedrop.server.enums.DownloadPolicy;
import com.coursedrop.server.enums.ShareSessionStatus;

public record ShareSessionResponse(
        String id,
        String code,
        String downloadUrl,
        ShareSessionStatus status,
        DownloadPolicy downloadPolicy,
        boolean downloadAuthRequired,
        Instant createdAt,
        Instant expiresAt
) {
}
