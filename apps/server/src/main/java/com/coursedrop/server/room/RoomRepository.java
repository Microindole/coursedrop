package com.coursedrop.server.room;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.Optional;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
public class RoomRepository {
  private final JdbcTemplate jdbcTemplate;

  public RoomRepository(JdbcTemplate jdbcTemplate) {
    this.jdbcTemplate = jdbcTemplate;
  }

  public void save(RoomResponse room) {
    jdbcTemplate.update(
        "insert into rooms (id, code, name, created_at, expires_at) values (?, ?, ?, ?, ?)",
        room.id(), room.code(), room.name(), room.createdAt().toString(), room.expiresAt().toString());
  }

  public Optional<RoomResponse> findByCode(String code) {
    var rooms = jdbcTemplate.query("select * from rooms where code = ?", this::mapRoom, code);
    return rooms.stream().findFirst();
  }

  public Optional<RoomResponse> findById(String id) {
    var rooms = jdbcTemplate.query("select * from rooms where id = ?", this::mapRoom, id);
    return rooms.stream().findFirst();
  }

  public int deleteExpired(Instant now) {
    return jdbcTemplate.update("delete from rooms where expires_at < ?", now.toString());
  }

  private RoomResponse mapRoom(ResultSet rs, int rowNum) throws SQLException {
    return new RoomResponse(
        rs.getString("id"),
        rs.getString("code"),
        rs.getString("name"),
        Instant.parse(rs.getString("created_at")),
        Instant.parse(rs.getString("expires_at")));
  }
}

