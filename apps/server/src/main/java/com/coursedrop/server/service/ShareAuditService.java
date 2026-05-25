package com.coursedrop.server.service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.stereotype.Service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.coursedrop.server.enums.ShareAuditActorType;
import com.coursedrop.server.dto.ShareAuditLogResponse;
import com.coursedrop.server.enums.ShareAuditReason;
import com.coursedrop.server.entity.ShareAuditLogEntity;
import com.coursedrop.server.mapper.ShareAuditLogMapper;

@Service
public class ShareAuditService {
    private final ShareAuditLogMapper mapper;

    public ShareAuditService(ShareAuditLogMapper mapper) {
        this.mapper = mapper;
    }

    public void record(
            String shareId,
            String itemId,
            ShareAuditReason reason,
            ShareAuditActorType actorType,
            String actorId,
            Long sizeBytes) {
        var entity = new ShareAuditLogEntity();
        entity.setId(UUID.randomUUID().toString());
        entity.setShareId(shareId);
        entity.setItemId(itemId);
        entity.setReason(reason.name());
        entity.setActorType(actorType.name());
        entity.setActorId(actorId);
        entity.setSizeBytes(sizeBytes);
        entity.setCreatedAt(Instant.now().toString());
        mapper.insert(entity);
    }

    public List<ShareAuditLogResponse> listByShareId(String shareId) {
        return mapper.selectList(new LambdaQueryWrapper<ShareAuditLogEntity>()
                .eq(ShareAuditLogEntity::getShareId, shareId)
                .orderByDesc(ShareAuditLogEntity::getCreatedAt))
                .stream()
                .map(this::toResponse)
                .toList();
    }

    private ShareAuditLogResponse toResponse(ShareAuditLogEntity entity) {
        return new ShareAuditLogResponse(
                entity.getId(),
                entity.getShareId(),
                entity.getItemId(),
                ShareAuditReason.valueOf(entity.getReason()),
                ShareAuditActorType.valueOf(entity.getActorType()),
                entity.getActorId(),
                entity.getSizeBytes(),
                Instant.parse(entity.getCreatedAt()));
    }
}
