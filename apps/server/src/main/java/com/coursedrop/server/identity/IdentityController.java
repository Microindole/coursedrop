package com.coursedrop.server.identity;

import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
}
