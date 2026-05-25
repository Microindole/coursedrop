package com.coursedrop.server.auth;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class WebLoginRepository {
    private final JdbcTemplate jdbcTemplate;

    public WebLoginRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(WebLoginSession session) {
        jdbcTemplate.update("""
                insert into web_login_sessions
                  (id, login_code, account_id, fingerprint_id, status, created_at, expires_at)
                values (?, ?, ?, ?, ?, ?, ?)
                """,
                session.id(), session.loginCode(), session.accountId(), session.fingerprintId(),
                session.status().name(), session.createdAt().toString(), session.expiresAt().toString());
    }

    public Optional<WebLoginSession> findByCode(String loginCode) {
        var sessions = jdbcTemplate.query(
                "select * from web_login_sessions where login_code = ?",
                this::mapSession,
                loginCode);
        return sessions.stream().findFirst();
    }

    public void confirm(String loginCode, String accountId, String fingerprintId) {
        jdbcTemplate.update("""
                update web_login_sessions
                set status = ?, account_id = ?, fingerprint_id = ?
                where login_code = ?
                """, WebLoginStatus.CONFIRMED.name(), accountId, fingerprintId, loginCode);
    }

    public void expire(String loginCode) {
        jdbcTemplate.update(
                "update web_login_sessions set status = ? where login_code = ?",
                WebLoginStatus.EXPIRED.name(),
                loginCode);
    }

    private WebLoginSession mapSession(ResultSet rs, int rowNum) throws SQLException {
        return new WebLoginSession(
                rs.getString("id"),
                rs.getString("login_code"),
                rs.getString("account_id"),
                rs.getString("fingerprint_id"),
                WebLoginStatus.valueOf(rs.getString("status")),
                Instant.parse(rs.getString("created_at")),
                Instant.parse(rs.getString("expires_at")));
    }
}
