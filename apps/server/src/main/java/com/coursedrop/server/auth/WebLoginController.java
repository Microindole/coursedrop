package com.coursedrop.server.auth;

import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

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
    public WebLoginResponse get(@PathVariable String loginCode) {
        return webLoginService.get(loginCode);
    }
}
