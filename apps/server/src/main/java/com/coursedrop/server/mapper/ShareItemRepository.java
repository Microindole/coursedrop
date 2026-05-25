package com.coursedrop.server.mapper;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.coursedrop.server.entity.ShareItemEntity;
import com.coursedrop.server.share.ShareItemRecord;

@Repository
public class ShareItemRepository {
    private final ShareItemMapper mapper;

    public ShareItemRepository(ShareItemMapper mapper) {
        this.mapper = mapper;
    }

    public void save(ShareItemRecord item) {
        mapper.insert(toEntity(item));
    }

    public List<ShareItemRecord> findByShareId(String shareId) {
        return mapper.selectList(new LambdaQueryWrapper<ShareItemEntity>()
                .eq(ShareItemEntity::getShareId, shareId)
                .orderByDesc(ShareItemEntity::getCreatedAt))
                .stream()
                .map(this::toRecord)
                .toList();
    }

    public Optional<ShareItemRecord> findById(String id) {
        return Optional.ofNullable(mapper.selectById(id)).map(this::toRecord);
    }

    public List<ShareItemRecord> findAll() {
        return mapper.selectList(new LambdaQueryWrapper<ShareItemEntity>())
                .stream()
                .map(this::toRecord)
                .toList();
    }

    public List<ShareItemRecord> findExpired(Instant now) {
        return mapper.selectList(new LambdaQueryWrapper<ShareItemEntity>()
                .lt(ShareItemEntity::getExpiresAt, now.toString()))
                .stream()
                .map(this::toRecord)
                .toList();
    }

    public void deleteByShareId(String shareId) {
        mapper.delete(new LambdaQueryWrapper<ShareItemEntity>().eq(ShareItemEntity::getShareId, shareId));
    }

    public void deleteById(String id) {
        mapper.deleteById(id);
    }

    public int deleteExpired(Instant now) {
        return mapper.delete(new LambdaQueryWrapper<ShareItemEntity>().lt(ShareItemEntity::getExpiresAt, now.toString()));
    }

    private ShareItemEntity toEntity(ShareItemRecord record) {
        var entity = new ShareItemEntity();
        entity.setId(record.id());
        entity.setShareId(record.shareId());
        entity.setDisplayName(record.displayName());
        entity.setStorageKey(record.storageKey());
        entity.setContentType(record.contentType());
        entity.setSizeBytes(record.sizeBytes());
        entity.setEncrypted(record.encrypted() ? 1 : 0);
        entity.setEncryptionAlgorithm(record.encryptionAlgorithm());
        entity.setKdfAlgorithm(record.kdfAlgorithm());
        entity.setKdfSalt(record.kdfSalt());
        entity.setNonce(record.nonce());
        entity.setSha256(record.sha256());
        entity.setPlainSizeBytes(record.plainSizeBytes());
        entity.setCreatedAt(record.createdAt().toString());
        entity.setExpiresAt(record.expiresAt().toString());
        return entity;
    }

    private ShareItemRecord toRecord(ShareItemEntity entity) {
        return new ShareItemRecord(
                entity.getId(),
                entity.getShareId(),
                entity.getDisplayName(),
                entity.getStorageKey(),
                entity.getContentType(),
                entity.getSizeBytes(),
                entity.getEncrypted() != null && entity.getEncrypted() == 1,
                entity.getEncryptionAlgorithm(),
                entity.getKdfAlgorithm(),
                entity.getKdfSalt(),
                entity.getNonce(),
                entity.getSha256(),
                entity.getPlainSizeBytes(),
                Instant.parse(entity.getCreatedAt()),
                Instant.parse(entity.getExpiresAt()));
    }
}
