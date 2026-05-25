package com.coursedrop.server.identity;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class IdentityRepository {
    private final JdbcTemplate jdbcTemplate;

    public IdentityRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<DeviceFingerprintResponse> findFingerprint(String fingerprint) {
        var devices = jdbcTemplate.query(
                "select * from device_fingerprints where fingerprint = ?",
                this::mapFingerprint,
                fingerprint);
        return devices.stream().findFirst();
    }

    public Optional<DeviceFingerprintResponse> findFingerprintById(String id) {
        var devices = jdbcTemplate.query("select * from device_fingerprints where id = ?", this::mapFingerprint, id);
        return devices.stream().findFirst();
    }

    public void saveFingerprint(DeviceFingerprintResponse response) {
        jdbcTemplate.update("""
                insert into device_fingerprints
                  (id, fingerprint, device_name, platform, account_id, created_at, last_seen_at)
                values (?, ?, ?, ?, ?, ?, ?)
                """,
                response.id(), response.fingerprint(), response.deviceName(), response.platform(),
                response.accountId(), response.createdAt().toString(), response.lastSeenAt().toString());
    }

    public void updateFingerprintSeen(String id, Instant lastSeenAt) {
        jdbcTemplate.update("update device_fingerprints set last_seen_at = ? where id = ?", lastSeenAt.toString(), id);
    }

    public void bindFingerprint(String fingerprintId, String accountId) {
        jdbcTemplate.update("update device_fingerprints set account_id = ? where id = ?", accountId, fingerprintId);
    }

    public boolean usernameExists(String username) {
        Integer count = jdbcTemplate.queryForObject(
                "select count(*) from accounts where username = ?",
                Integer.class,
                username);
        return count != null && count > 0;
    }

    public void saveAccount(AccountResponse account, String passwordHash) {
        jdbcTemplate.update("""
                insert into accounts
                  (id, username, password_hash, password_login_enabled, created_at)
                values (?, ?, ?, ?, ?)
                """,
                account.id(), account.username(), passwordHash,
                account.passwordLoginEnabled() ? 1 : 0, account.createdAt().toString());
    }

    private DeviceFingerprintResponse mapFingerprint(ResultSet rs, int rowNum) throws SQLException {
        return new DeviceFingerprintResponse(
                rs.getString("id"),
                rs.getString("fingerprint"),
                rs.getString("device_name"),
                rs.getString("platform"),
                rs.getString("account_id"),
                Instant.parse(rs.getString("created_at")),
                Instant.parse(rs.getString("last_seen_at")));
    }
}
