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
        jdbcTemplate.execute("""
                create table if not exists device_fingerprints (
                  id text primary key,
                  fingerprint text not null unique,
                  device_name text not null,
                  platform text not null,
                  account_id text,
                  created_at text not null,
                  last_seen_at text not null
                )
                """);
        jdbcTemplate.execute("""
                create table if not exists accounts (
                  id text primary key,
                  username text not null unique,
                  password_hash text,
                  password_login_enabled integer not null,
                  created_at text not null
                )
                """);
        jdbcTemplate.execute("""
                create table if not exists web_login_sessions (
                  id text primary key,
                  login_code text not null unique,
                  account_id text,
                  fingerprint_id text,
                  status text not null,
                  created_at text not null,
                  expires_at text not null
                )
                """);
        jdbcTemplate.execute("""
                create table if not exists share_sessions (
                  id text primary key,
                  code text not null unique,
                  owner_identity_id text,
                  owner_identity_type text not null,
                  status text not null,
                  download_auth_required integer not null,
                  created_at text not null,
                  expires_at text not null
                )
                """);
        jdbcTemplate.execute("""
                create table if not exists share_items (
                  id text primary key,
                  share_id text not null,
                  display_name text not null,
                  storage_key text not null,
                  content_type text,
                  size_bytes integer not null,
                  encrypted integer not null,
                  sha256 text,
                  created_at text not null,
                  expires_at text not null,
                  foreign key(share_id) references share_sessions(id)
                )
                """);
    }
}
