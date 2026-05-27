package com.coursedrop.server.controller;

import java.util.List;

import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.dto.AccountLoginRequest;
import com.coursedrop.server.dto.AccountRequest;
import com.coursedrop.server.dto.AccountResponse;
import com.coursedrop.server.dto.AccountSecurityRequest;
import com.coursedrop.server.dto.BindFingerprintRequest;
import com.coursedrop.server.dto.ChangePasswordRequest;
import com.coursedrop.server.dto.DeviceFingerprintRequest;
import com.coursedrop.server.dto.DeviceFingerprintResponse;
import com.coursedrop.server.service.IdentityService;

import jakarta.validation.Valid;

@Validated
@RestController
@RequestMapping("/api")
public class IdentityController {
    private final IdentityService identityService;

    public IdentityController(IdentityService identityService) {
        this.identityService = identityService;
    }

    @PostMapping("/identity/fingerprints")
    public DeviceFingerprintResponse registerFingerprint(@Valid @RequestBody DeviceFingerprintRequest request) {
        return identityService.registerFingerprint(request);
    }

    @PostMapping("/accounts")
    public AccountResponse createAccount(@Valid @RequestBody AccountRequest request) {
        return identityService.createAccount(request);
    }

    @PostMapping("/accounts/login")
    public AccountResponse loginAccount(@Valid @RequestBody AccountLoginRequest request) {
        return identityService.loginAccount(request);
    }

    @GetMapping("/accounts/{accountId}")
    public AccountResponse getAccount(
            @PathVariable String accountId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String actorAccountId) {
        return identityService.getAccount(accountId, fingerprintId, actorAccountId);
    }

    @PostMapping("/accounts/{accountId}/security")
    public AccountResponse updateSecurity(
            @PathVariable String accountId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String actorAccountId,
            @RequestBody AccountSecurityRequest request) {
        return identityService.updateSecurity(accountId, fingerprintId, actorAccountId, request);
    }

    @PostMapping("/accounts/{accountId}/password")
    public AccountResponse changePassword(
            @PathVariable String accountId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String actorAccountId,
            @Valid @RequestBody ChangePasswordRequest request) {
        return identityService.changePassword(accountId, fingerprintId, actorAccountId, request);
    }

    @GetMapping("/accounts/{accountId}/fingerprints")
    public List<DeviceFingerprintResponse> listAccountDevices(
            @PathVariable String accountId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String actorAccountId) {
        return identityService.listAccountDevices(accountId, fingerprintId, actorAccountId);
    }

    @PostMapping("/accounts/{accountId}/fingerprints")
    public DeviceFingerprintResponse bindFingerprint(
            @PathVariable String accountId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String actorAccountId,
            @Valid @RequestBody BindFingerprintRequest request) {
        return identityService.bindFingerprint(accountId, fingerprintId, actorAccountId, request);
    }

    @DeleteMapping("/accounts/{accountId}/fingerprints/{fingerprintId}")
    public ResponseEntity<Void> unbindFingerprint(
            @PathVariable String accountId,
            @PathVariable String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String actorFingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String actorAccountId) {
        identityService.unbindFingerprint(accountId, actorFingerprintId, actorAccountId, fingerprintId);
        return ResponseEntity.noContent().build();
    }
}
