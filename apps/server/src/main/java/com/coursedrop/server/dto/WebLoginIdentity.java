package com.coursedrop.server.dto;

public record WebLoginIdentity(
        String accountId,
        String fingerprintId
) {
}
