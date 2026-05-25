package com.coursedrop.server.controller;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.service.ShareService;

@RestController
@RequestMapping("/s")
public class BrowserDownloadController {
    private final ShareService shareService;
    private final com.coursedrop.server.service.WebLoginService webLoginService;

    public BrowserDownloadController(
            ShareService shareService,
            com.coursedrop.server.service.WebLoginService webLoginService) {
        this.shareService = shareService;
        this.webLoginService = webLoginService;
    }

    @GetMapping(value = "/{code}", produces = MediaType.TEXT_HTML_VALUE)
    public String downloadPage(@PathVariable String code) {
        var share = shareService.getByCode(code);
        var login = webLoginService.create();
        var html = new StringBuilder();
        html.append("<!doctype html><html><head><meta charset=\"utf-8\"><title>CourseDrop</title></head><body>");
        html.append("<h1>CourseDrop</h1>");
        html.append("<p>分享码：").append(escape(share.code())).append("</p>");
        html.append("<p>有效期：").append(share.expiresAt()).append("</p>");
        html.append("<p>浏览器下载需要登录或手机扫码授权。</p>");
        html.append("<p>扫码登录码：").append(escape(login.loginCode())).append("</p>");
        html.append("<p>登录状态接口：/api/auth/web-login/").append(escape(login.loginCode())).append("</p>");
        html.append("<ul>");
        share.items().forEach(item -> html.append("<li>")
                .append(escape(item.displayName()))
                .append(" - <a href=\"/s/")
                .append(escape(share.code()))
                .append("/items/")
                .append(escape(item.id()))
                .append("/download\">下载</a></li>"));
        html.append("</ul></body></html>");
        return html.toString();
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

    private String escape(String value) {
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
