package com.coursedrop.server.controller;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.config.ServerProperties;
import com.coursedrop.server.dto.ConfirmWebLoginRequest;
import com.coursedrop.server.dto.PasswordLoginRequest;
import com.coursedrop.server.dto.WebLoginResponse;
import com.coursedrop.server.dto.WebLoginSessionResponse;
import com.coursedrop.server.service.QrCodeService;
import com.coursedrop.server.service.WebLoginService;

import jakarta.validation.Valid;
import java.util.List;
import java.util.Map;

@Validated
@RestController
@RequestMapping("/api/auth/web-login")
public class WebLoginController {
    private final WebLoginService webLoginService;
    private final QrCodeService qrCodeService;
    private final ServerProperties serverProperties;

    public WebLoginController(
            WebLoginService webLoginService,
            QrCodeService qrCodeService,
            ServerProperties serverProperties) {
        this.webLoginService = webLoginService;
        this.qrCodeService = qrCodeService;
        this.serverProperties = serverProperties;
    }

    @PostMapping
    public WebLoginResponse create() {
        return webLoginService.create();
    }

    @PostMapping("/{loginCode}/confirm")
    public WebLoginResponse confirm(
            @PathVariable String loginCode,
            @Valid @RequestBody ConfirmWebLoginRequest request) {
        return webLoginService.confirm(loginCode, request);
    }

    @GetMapping("/{loginCode}")
    public ResponseEntity<WebLoginResponse> get(@PathVariable String loginCode) {
        var issue = webLoginService.get(loginCode);
        if (issue.cookieToken() == null) {
            return ResponseEntity.ok(issue.response());
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, loginCookie(issue.cookieToken(), 300).toString())
                .body(issue.response());
    }

    @GetMapping(value = "/{loginCode}/qr.svg", produces = "image/svg+xml")
    public String qr(@PathVariable String loginCode) {
        return qrCodeService.renderSvg(loginPayload(loginCode));
    }

    @PostMapping("/password")
    public ResponseEntity<WebLoginResponse> passwordLogin(@Valid @RequestBody PasswordLoginRequest request) {
        var issue = webLoginService.passwordLogin(request);
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, loginCookie(issue.cookieToken(), 300).toString())
                .body(issue.response());
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(@CookieValue(name = "CD_SESSION", required = false) String cookieToken) {
        webLoginService.logout(cookieToken);
        return ResponseEntity.noContent()
                .header(HttpHeaders.SET_COOKIE, loginCookie("", 0).toString())
                .build();
    }

    @GetMapping("/current")
    public Map<String, Object> current(@CookieValue(name = "CD_SESSION", required = false) String cookieToken) {
        return Map.of("authorized", webLoginService.isCookieAuthorized(cookieToken));
    }

    @DeleteMapping("/{loginCode}")
    public ResponseEntity<Void> revoke(@PathVariable String loginCode) {
        webLoginService.revoke(loginCode);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/sessions")
    public List<WebLoginSessionResponse> sessions(
            @RequestParam(required = false) String fingerprintId,
            @RequestParam(required = false) String accountId) {
        if (accountId != null && !accountId.isBlank()) {
            return webLoginService.listByAccount(accountId);
        }
        return webLoginService.listByFingerprint(fingerprintId);
    }

    private ResponseCookie loginCookie(String value, long maxAgeSeconds) {
        return ResponseCookie.from("CD_SESSION", value)
                .httpOnly(true)
                .secure(serverProperties.secureCookie())
                .sameSite("Lax")
                .path("/")
                .maxAge(maxAgeSeconds)
                .build();
    }

    private String loginPayload(String loginCode) {
        return serverProperties.publicBaseUrl() + "/api/auth/web-login/" + loginCode;
    }
}
