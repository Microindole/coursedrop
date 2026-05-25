package com.coursedrop.server.security;

public record PasswordHashResult(
        String hash,
        String salt,
        String algorithm
) {
}
