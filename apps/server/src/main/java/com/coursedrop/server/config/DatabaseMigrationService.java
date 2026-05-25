package com.coursedrop.server.config;

import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import jakarta.annotation.PostConstruct;

@Component
public class DatabaseMigrationService {
    private final JdbcTemplate jdbcTemplate;

    public DatabaseMigrationService(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @PostConstruct
    void migrate() {
        jdbcTemplate.execute("""
                create table if not exists schema_migrations (
                  version integer primary key,
                  description text not null,
                  applied_at text not null default current_timestamp
                )
                """);
        run(1, "create base relay schema", this::createBaseSchema);
        run(2, "add security and encryption metadata", this::addSecurityColumns);
    }

    private void run(int version, String description, Runnable migration) {
        Integer count = jdbcTemplate.queryForObject(
                "select count(*) from schema_migrations where version = ?",
                Integer.class,
                version);
        if (count != null && count > 0) {
            return;
        }
        migration.run();
        jdbcTemplate.update(
                "insert into schema_migrations (version, description) values (?, ?)",
                version,
                description);
    }

    private void createBaseSchema() {
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
                  password_salt text,
                  password_algorithm text,
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
                  cookie_token_hash text,
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
                  encryption_algorithm text,
                  kdf_algorithm text,
                  kdf_salt text,
                  nonce text,
                  sha256 text,
                  plain_size_bytes integer,
                  created_at text not null,
                  expires_at text not null,
                  foreign key(share_id) references share_sessions(id)
                )
                """);
        jdbcTemplate.execute("""
                create table if not exists share_audit_logs (
                  id text primary key,
                  share_id text not null,
                  item_id text,
                  reason text not null,
                  actor_type text not null,
                  actor_id text,
                  size_bytes integer,
                  created_at text not null
                )
                """);
    }

    private void addSecurityColumns() {
        addColumnIfMissing("accounts", "password_salt", "text");
        addColumnIfMissing("accounts", "password_algorithm", "text");
        addColumnIfMissing("web_login_sessions", "cookie_token_hash", "text");
        addColumnIfMissing("share_items", "encryption_algorithm", "text");
        addColumnIfMissing("share_items", "kdf_algorithm", "text");
        addColumnIfMissing("share_items", "kdf_salt", "text");
        addColumnIfMissing("share_items", "nonce", "text");
        addColumnIfMissing("share_items", "plain_size_bytes", "integer");
    }

    private void addColumnIfMissing(String tableName, String columnName, String definition) {
        var exists = jdbcTemplate.queryForList("pragma table_info(" + tableName + ")").stream()
                .anyMatch(row -> columnName.equals(row.get("name")));
        if (!exists) {
            jdbcTemplate.execute("alter table " + tableName + " add column " + columnName + " " + definition);
        }
    }
}
