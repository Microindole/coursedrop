package com.coursedrop.server.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import com.coursedrop.server.dto.ConfirmWebLoginRequest;
import com.coursedrop.server.service.WebLoginService;

@Controller
@RequestMapping("/m/login")
public class MobileLoginController {
    private final WebLoginService webLoginService;

    public MobileLoginController(WebLoginService webLoginService) {
        this.webLoginService = webLoginService;
    }

    @GetMapping("/{loginCode}")
    public String page(@PathVariable String loginCode, Model model) {
        model.addAttribute("loginCode", loginCode);
        model.addAttribute("confirmed", false);
        model.addAttribute("errorMessage", "");
        return "mobile-login";
    }

    @PostMapping("/{loginCode}")
    public String confirm(
            @PathVariable String loginCode,
            @RequestParam String fingerprintId,
            Model model) {
        model.addAttribute("loginCode", loginCode);
        try {
            webLoginService.confirm(loginCode, new ConfirmWebLoginRequest(fingerprintId));
            model.addAttribute("confirmed", true);
            model.addAttribute("errorMessage", "");
        } catch (RuntimeException exception) {
            model.addAttribute("confirmed", false);
            model.addAttribute("errorMessage", exception.getMessage());
        }
        return "mobile-login";
    }
}
