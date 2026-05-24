package com.coursedrop.server.config;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

@Component
public class DatabaseInitializer {
    private final JdbcTemplate jdbcTemplate;

    public DatabaseInitializer(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    void initialize() {
        jdbcTemplate.execute("""
                create table if not exists rooms (
                  id text primary key,
                  code text not null unique,
                  name text not null,
                  created_at text not null,
                  expires_at text not null
                )
                """);
        jdbcTemplate.execute("""
                create table if not exists transfer_items (
                  id text primary key,
                  room_id text not null,
                  type text not null,
                  display_name text not null,
                  storage_key text,
                  content_type text,
                  size_bytes integer not null,
                  created_at text not null,
                  expires_at text not null,
                  foreign key(room_id) references rooms(id)
                )
                """);
    }
}
