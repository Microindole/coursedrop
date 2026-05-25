package com.coursedrop.server.health;

import java.time.Clock;
import java.time.Instant;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/health")
public class HealthController {
    private final Clock clock;

    public HealthController() {
        this(Clock.systemUTC());
    }

    HealthController(Clock clock) {
        this.clock = clock;
    }

    @GetMapping
    public HealthResponse health() {
        return new HealthResponse("UP", "coursedrop-server", Instant.now(clock));
    }
}
