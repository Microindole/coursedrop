package com.coursedrop.server.dto;

import jakarta.validation.constraints.NotBlank;

public record AccountLoginRequest(
        @NotBlank String username,
        @NotBlank String password,
        @NotBlank String fingerprintId
) {
}
