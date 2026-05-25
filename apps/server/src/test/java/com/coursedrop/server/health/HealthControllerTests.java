package com.coursedrop.server.health;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

import org.junit.jupiter.api.Test;

class HealthControllerTests {
    @Test
    void healthReturnsRelaySourceProbePayload() {
        Instant now = Instant.parse("2026-05-25T12:00:00Z");
        HealthController controller = new HealthController(Clock.fixed(now, ZoneOffset.UTC));

        HealthResponse response = controller.health();

        assertThat(response.status()).isEqualTo("UP");
        assertThat(response.service()).isEqualTo("coursedrop-server");
        assertThat(response.time()).isEqualTo(now);
    }
}
