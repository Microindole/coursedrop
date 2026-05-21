package com.coursedrop.server.room;

import java.time.Instant;

public record RoomResponse(
    String id,
    String code,
    String name,
    Instant createdAt,
    Instant expiresAt
) {
}

