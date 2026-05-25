package com.coursedrop.server.dto;

import java.time.Instant;

import com.coursedrop.server.enums.ShareAuditActorType;
import com.coursedrop.server.enums.ShareAuditReason;

public record ShareAuditLogResponse(
        String id,
        String shareId,
        String itemId,
        ShareAuditReason reason,
        ShareAuditActorType actorType,
        String actorId,
        Long sizeBytes,
        Instant createdAt
) {
}
