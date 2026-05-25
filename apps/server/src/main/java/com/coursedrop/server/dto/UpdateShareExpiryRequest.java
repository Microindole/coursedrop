package com.coursedrop.server.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record UpdateShareExpiryRequest(
        @Min(1) @Max(168) int expireHours
) {
}
