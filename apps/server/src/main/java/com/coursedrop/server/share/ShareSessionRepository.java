package com.coursedrop.server.share;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ShareSessionRepository {
    private final JdbcTemplate jdbcTemplate;

    public ShareSessionRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(ShareSessionRecord session) {
        jdbcTemplate.update("""
                insert into share_sessions
                  (id, code, owner_identity_id, owner_identity_type, status, download_auth_required, created_at, expires_at)
                values (?, ?, ?, ?, ?, ?, ?, ?)
                """,
                session.id(), session.code(), session.ownerIdentityId(), session.ownerIdentityType().name(),
                session.status().name(), session.downloadAuthRequired() ? 1 : 0,
                session.createdAt().toString(), session.expiresAt().toString());
    }

    public void updateStatus(String id, ShareSessionStatus status) {
        jdbcTemplate.update("update share_sessions set status = ? where id = ?", status.name(), id);
    }

    public Optional<ShareSessionRecord> findById(String id) {
        var sessions = jdbcTemplate.query("select * from share_sessions where id = ?", this::mapSession, id);
        return sessions.stream().findFirst();
    }

    public Optional<ShareSessionRecord> findByCode(String code) {
        var sessions = jdbcTemplate.query("select * from share_sessions where code = ?", this::mapSession, code);
        return sessions.stream().findFirst();
    }

    public List<ShareSessionRecord> findExpiredActive(Instant now) {
        return jdbcTemplate.query("""
                select * from share_sessions
                where status = ? and expires_at < ?
                """, this::mapSession, ShareSessionStatus.ACTIVE.name(), now.toString());
    }

    public void delete(String id) {
        jdbcTemplate.update("delete from share_sessions where id = ?", id);
    }

    private ShareSessionRecord mapSession(ResultSet rs, int rowNum) throws SQLException {
        return new ShareSessionRecord(
                rs.getString("id"),
                rs.getString("code"),
                rs.getString("owner_identity_id"),
                OwnerIdentityType.valueOf(rs.getString("owner_identity_type")),
                ShareSessionStatus.valueOf(rs.getString("status")),
                rs.getInt("download_auth_required") == 1,
                Instant.parse(rs.getString("created_at")),
                Instant.parse(rs.getString("expires_at")));
    }
}
