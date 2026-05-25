package com.coursedrop.server.identity;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Instant;
import java.util.HexFormat;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.common.ApiException;

@Service
public class IdentityService {
    private final IdentityRepository identityRepository;

    public IdentityService(IdentityRepository identityRepository) {
        this.identityRepository = identityRepository;
    }

    public DeviceFingerprintResponse registerFingerprint(DeviceFingerprintRequest request) {
        var now = Instant.now();
        var existing = identityRepository.findFingerprint(request.fingerprint());
        if (existing.isPresent()) {
            identityRepository.updateFingerprintSeen(existing.get().id(), now);
            return new DeviceFingerprintResponse(
                    existing.get().id(),
                    existing.get().fingerprint(),
                    existing.get().deviceName(),
                    existing.get().platform(),
                    existing.get().accountId(),
                    existing.get().createdAt(),
                    now);
        }

        var response = new DeviceFingerprintResponse(
                UUID.randomUUID().toString(),
                request.fingerprint(),
                request.deviceName().trim(),
                request.platform().trim(),
                null,
                now,
                now);
        identityRepository.saveFingerprint(response);
        return response;
    }

    public AccountResponse createAccount(AccountRequest request) {
        if (identityRepository.usernameExists(request.username())) {
            throw new ApiException(HttpStatus.CONFLICT, "Username already exists");
        }
        identityRepository.findFingerprintById(request.fingerprintId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Device fingerprint not found"));

        var now = Instant.now();
        var account = new AccountResponse(
                UUID.randomUUID().toString(),
                request.username().trim(),
                request.passwordLoginEnabled(),
                now);
        identityRepository.saveAccount(account, hashPassword(request.password()));
        identityRepository.bindFingerprint(request.fingerprintId(), account.id());
        return account;
    }

    private String hashPassword(String password) {
        if (password == null || password.isBlank()) {
            return null;
        }
        try {
            var digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(password.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Password hash unavailable");
        }
    }
}
