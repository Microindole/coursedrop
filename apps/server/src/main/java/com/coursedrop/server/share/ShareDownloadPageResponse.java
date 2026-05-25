package com.coursedrop.server.share;

import java.time.Instant;
import java.util.List;

public record ShareDownloadPageResponse(
        String code,
        ShareSessionStatus status,
        boolean downloadAuthRequired,
        Instant expiresAt,
        List<ShareItemResponse> items
) {
}
