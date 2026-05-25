package com.coursedrop.server.download;

import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.share.ShareController;
import com.coursedrop.server.share.ShareService;

@RestController
@RequestMapping("/s")
public class BrowserDownloadController {
    private final ShareService shareService;

    public BrowserDownloadController(ShareService shareService) {
        this.shareService = shareService;
    }

    @GetMapping(value = "/{code}", produces = MediaType.TEXT_HTML_VALUE)
    public String downloadPage(@PathVariable String code) {
        var share = shareService.getByCode(code);
        var html = new StringBuilder();
        html.append("<!doctype html><html><head><meta charset=\"utf-8\"><title>CourseDrop</title></head><body>");
        html.append("<h1>CourseDrop</h1>");
        html.append("<p>分享码：").append(escape(share.code())).append("</p>");
        html.append("<p>有效期：").append(share.expiresAt()).append("</p>");
        html.append("<p>浏览器下载需要登录或手机扫码授权。</p>");
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
            @RequestHeader(name = "X-CourseDrop-Web-Authorized", defaultValue = "false") boolean authorized) {
        return ShareController.downloadResponse(shareService.downloadBrowser(code, itemId, authorized));
    }

    private String escape(String value) {
        return value
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}
