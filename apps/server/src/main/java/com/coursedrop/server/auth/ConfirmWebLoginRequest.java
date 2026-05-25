package com.coursedrop.server.auth;

import jakarta.validation.constraints.NotBlank;

public record ConfirmWebLoginRequest(
        @NotBlank String fingerprintId
) {
}
