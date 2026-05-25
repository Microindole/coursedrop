package com.coursedrop.server.security;

import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Component;

import com.coursedrop.server.common.ApiException;

@Component
public class PasswordHasher {
    private static final String ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int ITERATIONS = 120_000;
    private static final int KEY_LENGTH = 256;

    private final SecureRandom secureRandom = new SecureRandom();

    public PasswordHashResult hash(String password) {
        if (password == null || password.isBlank()) {
            return new PasswordHashResult(null, null, null);
        }
        var salt = new byte[16];
        secureRandom.nextBytes(salt);
        return new PasswordHashResult(
                hashWithSalt(password, salt),
                Base64.getEncoder().encodeToString(salt),
                ALGORITHM);
    }

    private String hashWithSalt(String password, byte[] salt) {
        try {
            var spec = new PBEKeySpec(password.toCharArray(), salt, ITERATIONS, KEY_LENGTH);
            var factory = SecretKeyFactory.getInstance(ALGORITHM);
            return Base64.getEncoder().encodeToString(factory.generateSecret(spec).getEncoded());
        } catch (NoSuchAlgorithmException | InvalidKeySpecException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Password hash unavailable");
        }
    }
}
