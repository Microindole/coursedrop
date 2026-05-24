package com.coursedrop.server.transfer;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class TransferItemRepository {
    private final JdbcTemplate jdbcTemplate;

    public TransferItemRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public void save(TransferItemStored item) {
        jdbcTemplate.update("""
                insert into transfer_items
                  (id, room_id, type, display_name, storage_key, content_type, size_bytes, created_at, expires_at)
                values (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """,
                item.id(), item.roomId(), item.type().name(), item.displayName(), item.storageKey(),
                item.contentType(), item.sizeBytes(), item.createdAt().toString(), item.expiresAt().toString());
    }

    public List<TransferItemResponse> findByRoomId(String roomId) {
        return jdbcTemplate.query("""
                select * from transfer_items
                where room_id = ? and expires_at >= ?
                order by created_at desc
                """, this::mapResponse, roomId, Instant.now().toString());
    }

    public Optional<TransferItemStored> findStoredById(String id) {
        var items = jdbcTemplate.query("select * from transfer_items where id = ?", this::mapStored, id);
        return items.stream().findFirst();
    }

    public List<TransferItemStored> findExpired(Instant now) {
        return jdbcTemplate.query("select * from transfer_items where expires_at < ?", this::mapStored, now.toString());
    }

    public int deleteExpired(Instant now) {
        return jdbcTemplate.update("delete from transfer_items where expires_at < ?", now.toString());
    }

    private TransferItemResponse mapResponse(ResultSet rs, int rowNum) throws SQLException {
        return new TransferItemResponse(
                rs.getString("id"),
                rs.getString("room_id"),
                TransferItemType.valueOf(rs.getString("type")),
                rs.getString("display_name"),
                rs.getString("content_type"),
                rs.getLong("size_bytes"),
                Instant.parse(rs.getString("created_at")),
                Instant.parse(rs.getString("expires_at")));
    }

    private TransferItemStored mapStored(ResultSet rs, int rowNum) throws SQLException {
        return new TransferItemStored(
                rs.getString("id"),
                rs.getString("room_id"),
                TransferItemType.valueOf(rs.getString("type")),
                rs.getString("display_name"),
                rs.getString("storage_key"),
                rs.getString("content_type"),
                rs.getLong("size_bytes"),
                Instant.parse(rs.getString("created_at")),
                Instant.parse(rs.getString("expires_at")));
    }
}
