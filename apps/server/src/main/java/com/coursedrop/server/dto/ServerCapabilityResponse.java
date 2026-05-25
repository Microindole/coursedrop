package com.coursedrop.server.dto;

public record ServerCapabilityResponse(
        String service,
        String version,
        long maxFileSizeMb,
        long defaultRoomTtlHours,
        long defaultFileTtlHours,
        boolean browserLoginRequired,
        boolean appIdentityDownloadSupported,
        String publicBaseUrl
) {
}
