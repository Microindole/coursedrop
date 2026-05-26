package com.coursedrop.server.mapper;

import java.time.Instant;
import java.util.List;
import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.coursedrop.server.entity.AccountEntity;
import com.coursedrop.server.entity.DeviceFingerprintEntity;
import com.coursedrop.server.dto.AccountResponse;
import com.coursedrop.server.dto.DeviceFingerprintResponse;

@Repository
public class IdentityRepository {
    private final DeviceFingerprintMapper fingerprintMapper;
    private final AccountMapper accountMapper;

    public IdentityRepository(DeviceFingerprintMapper fingerprintMapper, AccountMapper accountMapper) {
        this.fingerprintMapper = fingerprintMapper;
        this.accountMapper = accountMapper;
    }

    public Optional<DeviceFingerprintResponse> findFingerprint(String fingerprint) {
        return Optional.ofNullable(fingerprintMapper.selectOne(new LambdaQueryWrapper<DeviceFingerprintEntity>()
                .eq(DeviceFingerprintEntity::getFingerprint, fingerprint)))
                .map(this::toFingerprintResponse);
    }

    public Optional<DeviceFingerprintResponse> findFingerprintById(String id) {
        return Optional.ofNullable(fingerprintMapper.selectById(id)).map(this::toFingerprintResponse);
    }

    public void saveFingerprint(DeviceFingerprintResponse response) {
        fingerprintMapper.insert(toFingerprintEntity(response));
    }

    public void updateFingerprintSeen(String id, Instant lastSeenAt) {
        fingerprintMapper.update(new LambdaUpdateWrapper<DeviceFingerprintEntity>()
                .eq(DeviceFingerprintEntity::getId, id)
                .set(DeviceFingerprintEntity::getLastSeenAt, lastSeenAt.toString()));
    }

    public void bindFingerprint(String fingerprintId, String accountId) {
        fingerprintMapper.update(new LambdaUpdateWrapper<DeviceFingerprintEntity>()
                .eq(DeviceFingerprintEntity::getId, fingerprintId)
                .set(DeviceFingerprintEntity::getAccountId, accountId));
    }

    public void unbindFingerprint(String fingerprintId, String accountId) {
        fingerprintMapper.update(new LambdaUpdateWrapper<DeviceFingerprintEntity>()
                .eq(DeviceFingerprintEntity::getId, fingerprintId)
                .eq(DeviceFingerprintEntity::getAccountId, accountId)
                .set(DeviceFingerprintEntity::getAccountId, null));
    }

    public List<DeviceFingerprintResponse> findFingerprintsByAccountId(String accountId) {
        return fingerprintMapper.selectList(new LambdaQueryWrapper<DeviceFingerprintEntity>()
                .eq(DeviceFingerprintEntity::getAccountId, accountId)
                .orderByDesc(DeviceFingerprintEntity::getLastSeenAt))
                .stream()
                .map(this::toFingerprintResponse)
                .toList();
    }

    public boolean usernameExists(String username) {
        return accountMapper.selectCount(new LambdaQueryWrapper<AccountEntity>()
                .eq(AccountEntity::getUsername, username)) > 0;
    }

    public Optional<AccountEntity> findAccountByUsername(String username) {
        return Optional.ofNullable(accountMapper.selectOne(new LambdaQueryWrapper<AccountEntity>()
                .eq(AccountEntity::getUsername, username)));
    }

    public Optional<AccountEntity> findAccountById(String id) {
        return Optional.ofNullable(accountMapper.selectById(id));
    }

    public void saveAccount(AccountResponse account, String passwordHash, String passwordSalt, String passwordAlgorithm) {
        var entity = new AccountEntity();
        entity.setId(account.id());
        entity.setUsername(account.username());
        entity.setPasswordHash(passwordHash);
        entity.setPasswordSalt(passwordSalt);
        entity.setPasswordAlgorithm(passwordAlgorithm);
        entity.setPasswordLoginEnabled(account.passwordLoginEnabled() ? 1 : 0);
        entity.setCreatedAt(account.createdAt().toString());
        accountMapper.insert(entity);
    }

    public void updatePasswordLoginEnabled(String accountId, boolean enabled) {
        accountMapper.update(new LambdaUpdateWrapper<AccountEntity>()
                .eq(AccountEntity::getId, accountId)
                .set(AccountEntity::getPasswordLoginEnabled, enabled ? 1 : 0));
    }

    public void updatePassword(String accountId, String passwordHash, String passwordSalt, String passwordAlgorithm) {
        accountMapper.update(new LambdaUpdateWrapper<AccountEntity>()
                .eq(AccountEntity::getId, accountId)
                .set(AccountEntity::getPasswordHash, passwordHash)
                .set(AccountEntity::getPasswordSalt, passwordSalt)
                .set(AccountEntity::getPasswordAlgorithm, passwordAlgorithm));
    }

    private DeviceFingerprintEntity toFingerprintEntity(DeviceFingerprintResponse response) {
        var entity = new DeviceFingerprintEntity();
        entity.setId(response.id());
        entity.setFingerprint(response.fingerprint());
        entity.setDeviceName(response.deviceName());
        entity.setPlatform(response.platform());
        entity.setAccountId(response.accountId());
        entity.setCreatedAt(response.createdAt().toString());
        entity.setLastSeenAt(response.lastSeenAt().toString());
        return entity;
    }

    private DeviceFingerprintResponse toFingerprintResponse(DeviceFingerprintEntity entity) {
        return new DeviceFingerprintResponse(
                entity.getId(),
                entity.getFingerprint(),
                entity.getDeviceName(),
                entity.getPlatform(),
                entity.getAccountId(),
                Instant.parse(entity.getCreatedAt()),
                Instant.parse(entity.getLastSeenAt()));
    }
}
