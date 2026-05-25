package com.coursedrop.server.identity;

import jakarta.validation.constraints.NotBlank;

public record DeviceFingerprintRequest(
        @NotBlank String fingerprint,
        @NotBlank String deviceName,
        @NotBlank String platform
) {
}
