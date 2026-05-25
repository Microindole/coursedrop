package com.coursedrop.server.dto;

import java.time.Instant;

import com.coursedrop.server.enums.WebLoginStatus;

public record WebLoginResponse(
        String loginCode,
        WebLoginStatus status,
        String accountId,
        String fingerprintId,
        Instant expiresAt
) {
}
