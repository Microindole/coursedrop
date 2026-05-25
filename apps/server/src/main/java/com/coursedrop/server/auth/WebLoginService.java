package com.coursedrop.server.auth;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.identity.IdentityRepository;

@Service
public class WebLoginService {
    private static final String CODE_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";

    private final WebLoginRepository webLoginRepository;
    private final IdentityRepository identityRepository;
    private final SecureRandom random = new SecureRandom();

    public WebLoginService(WebLoginRepository webLoginRepository, IdentityRepository identityRepository) {
        this.webLoginRepository = webLoginRepository;
        this.identityRepository = identityRepository;
    }

    public WebLoginResponse create() {
        var now = Instant.now();
        var session = new WebLoginSession(
                UUID.randomUUID().toString(),
                nextUniqueCode(),
                null,
                null,
                WebLoginStatus.PENDING,
                now,
                now.plus(5, ChronoUnit.MINUTES));
        webLoginRepository.save(session);
        return toResponse(session);
    }

    public WebLoginResponse confirm(String loginCode, ConfirmWebLoginRequest request) {
        var session = requireSession(loginCode);
        ensurePending(session);
        var fingerprint = identityRepository.findFingerprintById(request.fingerprintId())
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Device fingerprint not found"));
        webLoginRepository.confirm(loginCode, fingerprint.accountId(), fingerprint.id());
        return toResponse(new WebLoginSession(
                session.id(),
                session.loginCode(),
                fingerprint.accountId(),
                fingerprint.id(),
                WebLoginStatus.CONFIRMED,
                session.createdAt(),
                session.expiresAt()));
    }

    public WebLoginResponse get(String loginCode) {
        var session = requireSession(loginCode);
        if (session.status() == WebLoginStatus.PENDING && session.expiresAt().isBefore(Instant.now())) {
            webLoginRepository.expire(loginCode);
            return toResponse(new WebLoginSession(
                    session.id(),
                    session.loginCode(),
                    session.accountId(),
                    session.fingerprintId(),
                    WebLoginStatus.EXPIRED,
                    session.createdAt(),
                    session.expiresAt()));
        }
        return toResponse(session);
    }

    private WebLoginSession requireSession(String loginCode) {
        return webLoginRepository.findByCode(loginCode)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Web login session not found"));
    }

    private void ensurePending(WebLoginSession session) {
        if (session.status() != WebLoginStatus.PENDING) {
            throw new ApiException(HttpStatus.CONFLICT, "Web login session is not pending");
        }
        if (session.expiresAt().isBefore(Instant.now())) {
            webLoginRepository.expire(session.loginCode());
            throw new ApiException(HttpStatus.GONE, "Web login session expired");
        }
    }

    private String nextUniqueCode() {
        var code = nextCode();
        if (webLoginRepository.findByCode(code).isPresent()) {
            return nextUniqueCode();
        }
        return code;
    }

    private String nextCode() {
        var code = new StringBuilder();
        for (int i = 0; i < 10; i++) {
            code.append(CODE_ALPHABET.charAt(random.nextInt(CODE_ALPHABET.length())));
        }
        return code.toString();
    }

    private WebLoginResponse toResponse(WebLoginSession session) {
        return new WebLoginResponse(
                session.loginCode(),
                session.status(),
                session.accountId(),
                session.fingerprintId(),
                session.expiresAt());
    }
}
