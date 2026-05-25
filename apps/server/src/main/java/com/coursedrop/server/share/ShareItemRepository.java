package com.coursedrop.server.share;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class ShareItemRepository {
    private final JdbcTemplate jdbcTemplate;

    public ShareItemRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(ShareItemRecord item) {
        jdbcTemplate.update("""
                insert into share_items
                  (id, share_id, display_name, storage_key, content_type, size_bytes, encrypted, sha256, created_at, expires_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                item.id(), item.shareId(), item.displayName(), item.storageKey(), item.contentType(),
                item.sizeBytes(), item.encrypted() ? 1 : 0, item.sha256(),
                item.createdAt().toString(), item.expiresAt().toString());
    }

    public List<ShareItemRecord> findByShareId(String shareId) {
        return jdbcTemplate.query("""
                select * from share_items
                where share_id = ?
                order by created_at desc
                """, this::mapItem, shareId);
    }

    public Optional<ShareItemRecord> findById(String id) {
        var items = jdbcTemplate.query("select * from share_items where id = ?", this::mapItem, id);
        return items.stream().findFirst();
    }

    public List<ShareItemRecord> findExpired(Instant now) {
        return jdbcTemplate.query("select * from share_items where expires_at < ?", this::mapItem, now.toString());
    }

    public void deleteByShareId(String shareId) {
        jdbcTemplate.update("delete from share_items where share_id = ?", shareId);
    }

    public int deleteExpired(Instant now) {
        return jdbcTemplate.update("delete from share_items where expires_at < ?", now.toString());
    }

    private ShareItemRecord mapItem(ResultSet rs, int rowNum) throws SQLException {
        return new ShareItemRecord(
                rs.getString("id"),
                rs.getString("share_id"),
                rs.getString("display_name"),
                rs.getString("storage_key"),
                rs.getString("content_type"),
                rs.getLong("size_bytes"),
                rs.getInt("encrypted") == 1,
                rs.getString("sha256"),
                Instant.parse(rs.getString("created_at")),
                Instant.parse(rs.getString("expires_at")));
    }
}
