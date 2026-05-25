package com.coursedrop.server.identity;

import jakarta.validation.constraints.NotBlank;

public record AccountRequest(
        @NotBlank String username,
        String password,
        @NotBlank String fingerprintId,
        boolean passwordLoginEnabled
) {
}
