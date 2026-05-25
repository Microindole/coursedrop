package com.coursedrop.server.dto;

import jakarta.validation.constraints.NotBlank;

public record DeviceFingerprintRequest(
        @NotBlank String fingerprint,
        @NotBlank String deviceName,
        @NotBlank String platform
) {
}
