package com.coursedrop.server.dto;

import java.time.Instant;

import com.coursedrop.server.enums.WebLoginStatus;

public record WebLoginSessionResponse(
        String loginCode,
        String accountId,
        String fingerprintId,
        WebLoginStatus status,
        Instant createdAt,
        Instant expiresAt
) {
}
