package com.coursedrop.server.dto;

import jakarta.validation.constraints.NotBlank;

public record ConfirmWebLoginRequest(
        @NotBlank String fingerprintId
) {
}
