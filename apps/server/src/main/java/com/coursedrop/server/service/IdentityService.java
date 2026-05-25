package com.coursedrop.server.service;

import java.time.Instant;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.dto.AccountRequest;
import com.coursedrop.server.dto.AccountResponse;
import com.coursedrop.server.dto.DeviceFingerprintRequest;
import com.coursedrop.server.dto.DeviceFingerprintResponse;
import com.coursedrop.server.mapper.IdentityRepository;
import com.coursedrop.server.security.PasswordHasher;

@Service
public class IdentityService {
    private final IdentityRepository identityRepository;
    private final PasswordHasher passwordHasher;

    public IdentityService(IdentityRepository identityRepository, PasswordHasher passwordHasher) {
        this.identityRepository = identityRepository;
        this.passwordHasher = passwordHasher;
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
        var passwordHash = passwordHasher.hash(request.password());
        identityRepository.saveAccount(account, passwordHash.hash(), passwordHash.salt(), passwordHash.algorithm());
        identityRepository.bindFingerprint(request.fingerprintId(), account.id());
        return account;
    }
}
