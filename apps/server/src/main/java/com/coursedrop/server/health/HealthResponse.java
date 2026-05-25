package com.coursedrop.server.health;

import java.time.Instant;

public record HealthResponse(
        String status,
        String service,
        Instant time
) {
}
