package com.coursedrop.server.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.coursedrop.server.enums.OwnerIdentityType;
import com.coursedrop.server.enums.DownloadPolicy;

public record CreateShareRequest(
        @Min(1) @Max(168) int expireHours,
        DownloadPolicy downloadPolicy,
        Boolean downloadAuthRequired,
        String ownerIdentityId,
        OwnerIdentityType ownerIdentityType
) {
    @JsonIgnore
    public DownloadPolicy resolvedDownloadPolicy() {
        if (downloadPolicy != null) {
            return downloadPolicy;
        }
        return Boolean.TRUE.equals(downloadAuthRequired) ? DownloadPolicy.LOGIN_REQUIRED : DownloadPolicy.PUBLIC;
    }
}
