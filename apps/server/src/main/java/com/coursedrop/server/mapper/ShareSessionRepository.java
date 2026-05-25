package com.coursedrop.server.mapper;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.coursedrop.server.entity.ShareSessionEntity;
import com.coursedrop.server.enums.OwnerIdentityType;
import com.coursedrop.server.share.ShareSessionRecord;
import com.coursedrop.server.enums.ShareSessionStatus;

@Repository
public class ShareSessionRepository {
    private final ShareSessionMapper mapper;

    public ShareSessionRepository(ShareSessionMapper mapper) {
        this.mapper = mapper;
    }

    public void save(ShareSessionRecord session) {
        mapper.insert(toEntity(session));
    }

    public void updateStatus(String id, ShareSessionStatus status) {
        mapper.update(new LambdaUpdateWrapper<ShareSessionEntity>()
                .eq(ShareSessionEntity::getId, id)
                .set(ShareSessionEntity::getStatus, status.name()));
    }

    public Optional<ShareSessionRecord> findById(String id) {
        return Optional.ofNullable(mapper.selectById(id)).map(this::toRecord);
    }

    public Optional<ShareSessionRecord> findByCode(String code) {
        return Optional.ofNullable(mapper.selectOne(new LambdaQueryWrapper<ShareSessionEntity>()
                .eq(ShareSessionEntity::getCode, code)))
                .map(this::toRecord);
    }

    public List<ShareSessionRecord> findExpiredActive(Instant now) {
        return mapper.selectList(new LambdaQueryWrapper<ShareSessionEntity>()
                .eq(ShareSessionEntity::getStatus, ShareSessionStatus.ACTIVE.name())
                .lt(ShareSessionEntity::getExpiresAt, now.toString()))
                .stream()
                .map(this::toRecord)
                .toList();
    }

    public List<ShareSessionRecord> findByOwner(String ownerIdentityId, OwnerIdentityType ownerIdentityType) {
        return mapper.selectList(new LambdaQueryWrapper<ShareSessionEntity>()
                .eq(ShareSessionEntity::getOwnerIdentityId, ownerIdentityId)
                .eq(ShareSessionEntity::getOwnerIdentityType, ownerIdentityType.name())
                .orderByDesc(ShareSessionEntity::getCreatedAt))
                .stream()
                .map(this::toRecord)
                .toList();
    }

    public List<ShareSessionRecord> findByStatus(ShareSessionStatus status) {
        return mapper.selectList(new LambdaQueryWrapper<ShareSessionEntity>()
                .eq(ShareSessionEntity::getStatus, status.name())
                .orderByDesc(ShareSessionEntity::getCreatedAt))
                .stream()
                .map(this::toRecord)
                .toList();
    }

    public void updateExpiresAt(String id, Instant expiresAt) {
        mapper.update(new LambdaUpdateWrapper<ShareSessionEntity>()
                .eq(ShareSessionEntity::getId, id)
                .set(ShareSessionEntity::getExpiresAt, expiresAt.toString()));
    }

    public void delete(String id) {
        mapper.deleteById(id);
    }

    private ShareSessionEntity toEntity(ShareSessionRecord record) {
        var entity = new ShareSessionEntity();
        entity.setId(record.id());
        entity.setCode(record.code());
        entity.setOwnerIdentityId(record.ownerIdentityId());
        entity.setOwnerIdentityType(record.ownerIdentityType().name());
        entity.setStatus(record.status().name());
        entity.setDownloadAuthRequired(record.downloadAuthRequired() ? 1 : 0);
        entity.setCreatedAt(record.createdAt().toString());
        entity.setExpiresAt(record.expiresAt().toString());
        return entity;
    }

    private ShareSessionRecord toRecord(ShareSessionEntity entity) {
        return new ShareSessionRecord(
                entity.getId(),
                entity.getCode(),
                entity.getOwnerIdentityId(),
                OwnerIdentityType.valueOf(entity.getOwnerIdentityType()),
                ShareSessionStatus.valueOf(entity.getStatus()),
                entity.getDownloadAuthRequired() != null && entity.getDownloadAuthRequired() == 1,
                Instant.parse(entity.getCreatedAt()),
                Instant.parse(entity.getExpiresAt()));
    }
}
