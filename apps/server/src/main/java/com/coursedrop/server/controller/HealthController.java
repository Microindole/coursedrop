package com.coursedrop.server.controller;

import java.time.Clock;
import java.time.Instant;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.config.ServerProperties;
import com.coursedrop.server.config.StorageProperties;
import com.coursedrop.server.dto.HealthResponse;
import com.coursedrop.server.dto.ServerCapabilityResponse;

@RestController
@RequestMapping("/api/health")
public class HealthController {
    private final Clock clock;
    private final StorageProperties storageProperties;
    private final ServerProperties serverProperties;

    public HealthController() {
        this(Clock.systemUTC(), null, null);
    }

    public HealthController(StorageProperties storageProperties, ServerProperties serverProperties) {
        this(Clock.systemUTC(), storageProperties, serverProperties);
    }

    public HealthController(Clock clock) {
        this(clock, null, null);
    }

    public HealthController(Clock clock, StorageProperties storageProperties, ServerProperties serverProperties) {
        this.clock = clock;
        this.storageProperties = storageProperties;
        this.serverProperties = serverProperties;
    }

    @GetMapping
    public HealthResponse health() {
        return new HealthResponse("UP", "coursedrop-server", Instant.now(clock));
    }

    @GetMapping("/capabilities")
    public ServerCapabilityResponse capabilities() {
        return new ServerCapabilityResponse(
                "coursedrop-server",
                "0.1.0",
                storageProperties.maxFileSizeMb(),
                storageProperties.roomTtlHours(),
                storageProperties.fileTtlHours(),
                true,
                true,
                serverProperties.publicBaseUrl());
    }
}
