package com.coursedrop.server.mapper;

import java.time.Instant;
import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper;
import com.coursedrop.server.auth.WebLoginSession;
import com.coursedrop.server.enums.WebLoginStatus;
import com.coursedrop.server.entity.WebLoginSessionEntity;

@Repository
public class WebLoginRepository {
    private final WebLoginSessionMapper mapper;

    public WebLoginRepository(WebLoginSessionMapper mapper) {
        this.mapper = mapper;
    }

    public void save(WebLoginSession session) {
        mapper.insert(toEntity(session));
    }

    public Optional<WebLoginSession> findByCode(String loginCode) {
        return Optional.ofNullable(mapper.selectOne(new LambdaQueryWrapper<WebLoginSessionEntity>()
                .eq(WebLoginSessionEntity::getLoginCode, loginCode)))
                .map(this::toRecord);
    }

    public void confirm(String loginCode, String accountId, String fingerprintId) {
        mapper.update(new LambdaUpdateWrapper<WebLoginSessionEntity>()
                .eq(WebLoginSessionEntity::getLoginCode, loginCode)
                .set(WebLoginSessionEntity::getStatus, WebLoginStatus.CONFIRMED.name())
                .set(WebLoginSessionEntity::getAccountId, accountId)
                .set(WebLoginSessionEntity::getFingerprintId, fingerprintId));
    }

    public void expire(String loginCode) {
        mapper.update(new LambdaUpdateWrapper<WebLoginSessionEntity>()
                .eq(WebLoginSessionEntity::getLoginCode, loginCode)
                .set(WebLoginSessionEntity::getStatus, WebLoginStatus.EXPIRED.name()));
    }

    public void setCookieTokenHash(String loginCode, String cookieTokenHash) {
        mapper.update(new LambdaUpdateWrapper<WebLoginSessionEntity>()
                .eq(WebLoginSessionEntity::getLoginCode, loginCode)
                .set(WebLoginSessionEntity::getCookieTokenHash, cookieTokenHash));
    }

    public Optional<WebLoginSession> findByCookieTokenHash(String cookieTokenHash) {
        return Optional.ofNullable(mapper.selectOne(new LambdaQueryWrapper<WebLoginSessionEntity>()
                .eq(WebLoginSessionEntity::getCookieTokenHash, cookieTokenHash)))
                .map(this::toRecord);
    }

    private WebLoginSessionEntity toEntity(WebLoginSession session) {
        var entity = new WebLoginSessionEntity();
        entity.setId(session.id());
        entity.setLoginCode(session.loginCode());
        entity.setAccountId(session.accountId());
        entity.setFingerprintId(session.fingerprintId());
        entity.setCookieTokenHash(session.cookieTokenHash());
        entity.setStatus(session.status().name());
        entity.setCreatedAt(session.createdAt().toString());
        entity.setExpiresAt(session.expiresAt().toString());
        return entity;
    }

    private WebLoginSession toRecord(WebLoginSessionEntity entity) {
        return new WebLoginSession(
                entity.getId(),
                entity.getLoginCode(),
                entity.getAccountId(),
                entity.getFingerprintId(),
                entity.getCookieTokenHash(),
                WebLoginStatus.valueOf(entity.getStatus()),
                Instant.parse(entity.getCreatedAt()),
                Instant.parse(entity.getExpiresAt()));
    }
}
