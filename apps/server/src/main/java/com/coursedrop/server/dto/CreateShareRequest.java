package com.coursedrop.server.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

import com.coursedrop.server.enums.OwnerIdentityType;

public record CreateShareRequest(
        @Min(1) @Max(168) int expireHours,
        boolean downloadAuthRequired,
        String ownerIdentityId,
        OwnerIdentityType ownerIdentityType
) {
}
