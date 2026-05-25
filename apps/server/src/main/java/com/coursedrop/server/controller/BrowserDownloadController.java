package com.coursedrop.server.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;

import com.coursedrop.server.service.ShareService;
import com.coursedrop.server.service.WebLoginService;

@Controller
@RequestMapping("/s")
public class BrowserDownloadController {
    private final ShareService shareService;
    private final WebLoginService webLoginService;

    public BrowserDownloadController(
            ShareService shareService,
            WebLoginService webLoginService) {
        this.shareService = shareService;
        this.webLoginService = webLoginService;
    }

    @GetMapping("/{code}")
    public String downloadPage(@PathVariable String code, Model model) {
        var share = shareService.getByCode(code);
        var login = webLoginService.create();
        model.addAttribute("share", share);
        model.addAttribute("login", login);
        return "share-download";
    }

    @GetMapping("/{code}/items/{itemId}/download")
    public ResponseEntity<?> downloadBrowser(
            @PathVariable String code,
            @PathVariable String itemId,
            @CookieValue(name = "CD_SESSION", required = false) String cookieToken,
            @RequestHeader(name = "X-CourseDrop-Web-Authorized", defaultValue = "false") boolean authorized) {
        var cookieAuthorized = webLoginService.isCookieAuthorized(cookieToken);
        return ShareController.downloadResponse(shareService.downloadBrowser(code, itemId, authorized || cookieAuthorized));
    }

}
