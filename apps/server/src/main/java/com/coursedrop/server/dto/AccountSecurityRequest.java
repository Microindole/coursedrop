package com.coursedrop.server.dto;

public record AccountSecurityRequest(
        boolean passwordLoginEnabled
) {
}
