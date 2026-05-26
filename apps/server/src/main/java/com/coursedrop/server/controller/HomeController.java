package com.coursedrop.server.controller;

import java.time.Instant;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import com.coursedrop.server.config.ServerProperties;
import com.coursedrop.server.config.StorageProperties;

@Controller
public class HomeController {
    private final StorageProperties storageProperties;
    private final ServerProperties serverProperties;

    public HomeController(StorageProperties storageProperties, ServerProperties serverProperties) {
        this.storageProperties = storageProperties;
        this.serverProperties = serverProperties;
    }

    @GetMapping("/")
    public String home(Model model) {
        model.addAttribute("service", "coursedrop-server");
        model.addAttribute("status", "online");
        model.addAttribute("version", "0.1.0");
        model.addAttribute("checkedAt", Instant.now());
        model.addAttribute("maxFileSizeMb", storageProperties.maxFileSizeMb());
        model.addAttribute("defaultTtlHours", storageProperties.fileTtlHours());
        model.addAttribute("publicBaseUrl", serverProperties.publicBaseUrl());
        return "home";
    }
}
