package com.coursedrop.server.service;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.dto.AccountLoginRequest;
import com.coursedrop.server.dto.AccountRequest;
import com.coursedrop.server.dto.AccountResponse;
import com.coursedrop.server.dto.AccountSecurityRequest;
import com.coursedrop.server.dto.BindFingerprintRequest;
import com.coursedrop.server.dto.ChangePasswordRequest;
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
        var username = request.username().trim();
        if (identityRepository.usernameExists(username)) {
            throw new ApiException(HttpStatus.CONFLICT, "Username already exists");
        }
        identityRepository.findFingerprintById(request.fingerprintId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Device fingerprint not found"));

        var now = Instant.now();
        var account = new AccountResponse(
                UUID.randomUUID().toString(),
                username,
                request.passwordLoginEnabled(),
                now);
        var passwordHash = passwordHasher.hash(request.password());
        identityRepository.saveAccount(account, passwordHash.hash(), passwordHash.salt(), passwordHash.algorithm());
        identityRepository.bindFingerprint(request.fingerprintId(), account.id());
        return account;
    }

    public AccountResponse loginAccount(AccountLoginRequest request) {
        var fingerprint = identityRepository.findFingerprintById(request.fingerprintId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Device fingerprint not found"));
        var account = identityRepository.findAccountByUsername(request.username().trim())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Invalid username or password"));
        if (!passwordHasher.verify(
                request.password(),
                account.getPasswordHash(),
                account.getPasswordSalt(),
                account.getPasswordAlgorithm())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid username or password");
        }
        if (fingerprint.accountId() != null && !fingerprint.accountId().equals(account.getId())) {
            throw new ApiException(HttpStatus.CONFLICT, "Device fingerprint is already bound to another account");
        }
        identityRepository.bindFingerprint(request.fingerprintId(), account.getId());
        return new AccountResponse(
                account.getId(),
                account.getUsername(),
                account.getPasswordLoginEnabled() != null && account.getPasswordLoginEnabled() == 1,
                Instant.parse(account.getCreatedAt()));
    }

    public AccountResponse getAccount(String accountId, String fingerprintId, String actorAccountId) {
        ensureAccountAccess(accountId, fingerprintId, actorAccountId);
        return getAccountUnchecked(accountId);
    }

    private AccountResponse getAccountUnchecked(String accountId) {
        var account = identityRepository.findAccountById(accountId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Account not found"));
        return new AccountResponse(
                account.getId(),
                account.getUsername(),
                account.getPasswordLoginEnabled() != null && account.getPasswordLoginEnabled() == 1,
                Instant.parse(account.getCreatedAt()));
    }

    public AccountResponse updateSecurity(
            String accountId,
            String fingerprintId,
            String actorAccountId,
            AccountSecurityRequest request) {
        ensureAccountAccess(accountId, fingerprintId, actorAccountId);
        identityRepository.updatePasswordLoginEnabled(accountId, request.passwordLoginEnabled());
        return getAccountUnchecked(accountId);
    }

    public AccountResponse changePassword(
            String accountId,
            String fingerprintId,
            String actorAccountId,
            ChangePasswordRequest request) {
        ensureAccountAccess(accountId, fingerprintId, actorAccountId);
        var passwordHash = passwordHasher.hash(request.password());
        identityRepository.updatePassword(accountId, passwordHash.hash(), passwordHash.salt(), passwordHash.algorithm());
        return getAccountUnchecked(accountId);
    }

    public DeviceFingerprintResponse bindFingerprint(
            String accountId,
            String actorFingerprintId,
            String actorAccountId,
            BindFingerprintRequest request) {
        ensureAccountAccess(accountId, actorFingerprintId, actorAccountId);
        var fingerprint = identityRepository.findFingerprintById(request.fingerprintId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Device fingerprint not found"));
        if (fingerprint.accountId() != null && !fingerprint.accountId().equals(accountId)) {
            throw new ApiException(HttpStatus.CONFLICT, "Device fingerprint is already bound to another account");
        }
        identityRepository.bindFingerprint(request.fingerprintId(), accountId);
        return new DeviceFingerprintResponse(
                fingerprint.id(),
                fingerprint.fingerprint(),
                fingerprint.deviceName(),
                fingerprint.platform(),
                accountId,
                fingerprint.createdAt(),
                fingerprint.lastSeenAt());
    }

    public List<DeviceFingerprintResponse> listAccountDevices(String accountId, String fingerprintId, String actorAccountId) {
        ensureAccountAccess(accountId, fingerprintId, actorAccountId);
        return identityRepository.findFingerprintsByAccountId(accountId);
    }

    public void unbindFingerprint(String accountId, String actorFingerprintId, String actorAccountId, String fingerprintId) {
        ensureAccountAccess(accountId, actorFingerprintId, actorAccountId);
        identityRepository.findFingerprintById(fingerprintId)
                .filter(fingerprint -> accountId.equals(fingerprint.accountId()))
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Bound device fingerprint not found"));
        identityRepository.unbindFingerprint(fingerprintId, accountId);
    }

    private void ensureAccountAccess(String accountId, String fingerprintId, String actorAccountId) {
        var account = identityRepository.findAccountById(accountId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Account not found"));
        if (actorAccountId != null && actorAccountId.equals(account.getId())) {
            return;
        }
        if (fingerprintId != null && !fingerprintId.isBlank()) {
            var fingerprint = identityRepository.findFingerprintById(fingerprintId)
                    .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Unknown fingerprint"));
            if (account.getId().equals(fingerprint.accountId())) {
                return;
            }
        }
        throw new ApiException(HttpStatus.FORBIDDEN, "Account access denied");
    }
}
