package com.coursedrop.server.service;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Base64;
import java.util.HexFormat;
import java.util.List;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.dto.ConfirmWebLoginRequest;
import com.coursedrop.server.dto.PasswordLoginRequest;
import com.coursedrop.server.dto.WebLoginCookieIssue;
import com.coursedrop.server.dto.WebLoginResponse;
import com.coursedrop.server.dto.WebLoginSessionResponse;
import com.coursedrop.server.auth.WebLoginSession;
import com.coursedrop.server.enums.WebLoginStatus;
import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.mapper.IdentityRepository;
import com.coursedrop.server.mapper.WebLoginRepository;
import com.coursedrop.server.security.PasswordHasher;

@Service
public class WebLoginService {
    private static final String CODE_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";

    private final WebLoginRepository webLoginRepository;
    private final IdentityRepository identityRepository;
    private final PasswordHasher passwordHasher;
    private final RateLimitService rateLimitService;
    private final SecureRandom random = new SecureRandom();

    public WebLoginService(
            WebLoginRepository webLoginRepository,
            IdentityRepository identityRepository,
            PasswordHasher passwordHasher,
            RateLimitService rateLimitService) {
        this.webLoginRepository = webLoginRepository;
        this.identityRepository = identityRepository;
        this.passwordHasher = passwordHasher;
        this.rateLimitService = rateLimitService;
    }

    public WebLoginResponse create() {
        rateLimitService.check("web-login:create", 30, 60);
        var now = Instant.now();
        var session = new WebLoginSession(
                UUID.randomUUID().toString(),
                nextUniqueCode(),
                null,
                null,
                null,
                WebLoginStatus.PENDING,
                now,
                now.plus(5, ChronoUnit.MINUTES));
        webLoginRepository.save(session);
        return toResponse(session);
    }

    public WebLoginResponse confirm(String loginCode, ConfirmWebLoginRequest request) {
        rateLimitService.check("web-login:confirm:" + loginCode, 12, 60);
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
                session.cookieTokenHash(),
                WebLoginStatus.CONFIRMED,
                session.createdAt(),
                session.expiresAt()));
    }

    public WebLoginCookieIssue get(String loginCode) {
        var session = requireSession(loginCode);
        if (session.status() == WebLoginStatus.PENDING && session.expiresAt().isBefore(Instant.now())) {
            webLoginRepository.expire(loginCode);
            var expired = new WebLoginSession(
                    session.id(),
                    session.loginCode(),
                    session.accountId(),
                    session.fingerprintId(),
                    session.cookieTokenHash(),
                    WebLoginStatus.EXPIRED,
                    session.createdAt(),
                    session.expiresAt());
            return new WebLoginCookieIssue(toResponse(expired), null);
        }
        if (session.status() == WebLoginStatus.CONFIRMED && session.cookieTokenHash() == null) {
            var cookieToken = nextCookieToken();
            webLoginRepository.setCookieTokenHash(session.loginCode(), hashToken(cookieToken));
            return new WebLoginCookieIssue(toResponse(session), cookieToken);
        }
        return new WebLoginCookieIssue(toResponse(session), null);
    }

    public WebLoginCookieIssue passwordLogin(PasswordLoginRequest request) {
        rateLimitService.check("web-login:password:" + request.username(), 8, 60);
        var account = identityRepository.findAccountByUsername(request.username())
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Invalid username or password"));
        if (account.getPasswordLoginEnabled() == null || account.getPasswordLoginEnabled() != 1) {
            throw new ApiException(HttpStatus.FORBIDDEN, "Password login is disabled");
        }
        if (!passwordHasher.verify(
                request.password(),
                account.getPasswordHash(),
                account.getPasswordSalt(),
                account.getPasswordAlgorithm())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Invalid username or password");
        }
        var now = Instant.now();
        var cookieToken = nextCookieToken();
        var session = new WebLoginSession(
                UUID.randomUUID().toString(),
                nextUniqueCode(),
                account.getId(),
                null,
                hashToken(cookieToken),
                WebLoginStatus.CONFIRMED,
                now,
                now.plus(5, ChronoUnit.MINUTES));
        webLoginRepository.save(session);
        return new WebLoginCookieIssue(toResponse(session), cookieToken);
    }

    public boolean isCookieAuthorized(String cookieToken) {
        if (cookieToken == null || cookieToken.isBlank()) {
            return false;
        }
        return webLoginRepository.findByCookieTokenHash(hashToken(cookieToken))
                .filter(session -> session.status() == WebLoginStatus.CONFIRMED)
                .filter(session -> session.expiresAt().isAfter(Instant.now()))
                .isPresent();
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

    public void logout(String cookieToken) {
        if (cookieToken == null || cookieToken.isBlank()) {
            return;
        }
        webLoginRepository.revokeCookieTokenHash(hashToken(cookieToken));
    }

    public void revoke(String loginCode) {
        requireSession(loginCode);
        webLoginRepository.revoke(loginCode);
    }

    public List<WebLoginSessionResponse> listByFingerprint(String fingerprintId) {
        return webLoginRepository.findByFingerprintId(fingerprintId).stream()
                .map(this::toSessionResponse)
                .toList();
    }

    public List<WebLoginSessionResponse> listByAccount(String accountId) {
        return webLoginRepository.findByAccountId(accountId).stream()
                .map(this::toSessionResponse)
                .toList();
    }

    private String nextCookieToken() {
        var bytes = new byte[32];
        random.nextBytes(bytes);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
    }

    private String hashToken(String token) {
        try {
            var digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(token.getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Cookie token hash unavailable");
        }
    }

    private WebLoginResponse toResponse(WebLoginSession session) {
        return new WebLoginResponse(
                session.loginCode(),
                session.status(),
                session.accountId(),
                session.fingerprintId(),
                session.expiresAt());
    }

    private WebLoginSessionResponse toSessionResponse(WebLoginSession session) {
        return new WebLoginSessionResponse(
                session.loginCode(),
                session.accountId(),
                session.fingerprintId(),
                session.status(),
                session.createdAt(),
                session.expiresAt());
    }
}
