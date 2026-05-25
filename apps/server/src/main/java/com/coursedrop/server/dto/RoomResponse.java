package com.coursedrop.server.dto;

import java.time.Instant;

public record RoomResponse(
        String id,
        String code,
        String name,
        Instant createdAt,
        Instant expiresAt) {
}
