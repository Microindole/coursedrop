package com.coursedrop.server.dto;

import jakarta.validation.constraints.NotBlank;

public record BindFingerprintRequest(
        @NotBlank String fingerprintId
) {
}
