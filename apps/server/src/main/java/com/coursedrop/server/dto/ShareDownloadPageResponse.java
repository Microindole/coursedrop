package com.coursedrop.server.dto;

import java.time.Instant;
import java.util.List;

import com.coursedrop.server.enums.ShareSessionStatus;

public record ShareDownloadPageResponse(
        String code,
        ShareSessionStatus status,
        boolean downloadAuthRequired,
        Instant expiresAt,
        List<ShareItemResponse> items
) {
}
