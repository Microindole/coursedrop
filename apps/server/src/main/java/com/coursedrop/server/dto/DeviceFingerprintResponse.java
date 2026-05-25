package com.coursedrop.server.dto;

import java.time.Instant;

public record DeviceFingerprintResponse(
        String id,
        String fingerprint,
        String deviceName,
        String platform,
        String accountId,
        Instant createdAt,
        Instant lastSeenAt
) {
}
