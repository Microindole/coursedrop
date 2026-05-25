package com.coursedrop.server.controller;

import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.dto.ConfirmWebLoginRequest;
import com.coursedrop.server.dto.WebLoginResponse;
import com.coursedrop.server.service.WebLoginService;

import jakarta.validation.Valid;

@Validated
@RestController
@RequestMapping("/api/auth/web-login")
public class WebLoginController {
    private final WebLoginService webLoginService;

    public WebLoginController(WebLoginService webLoginService) {
        this.webLoginService = webLoginService;
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
        var cookie = ResponseCookie.from("CD_SESSION", issue.cookieToken())
                .httpOnly(true)
                .secure(false)
                .sameSite("Lax")
                .path("/")
                .maxAge(300)
                .build();
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .body(issue.response());
    }
}
