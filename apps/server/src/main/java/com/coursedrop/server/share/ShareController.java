package com.coursedrop.server.share;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import jakarta.validation.Valid;

@Validated
@RestController
@RequestMapping("/api/shares")
public class ShareController {
    private final ShareService shareService;

    public ShareController(ShareService shareService) {
        this.shareService = shareService;
    }

    @PostMapping
    public ShareSessionResponse create(@Valid @RequestBody CreateShareRequest request) {
        return shareService.create(request);
    }

    @GetMapping("/{code}")
    public ShareDownloadPageResponse get(@PathVariable String code) {
        return shareService.getByCode(code);
    }

    @PostMapping("/{shareId}/items")
    public ShareItemResponse uploadItem(
            @PathVariable String shareId,
            @RequestParam MultipartFile file,
            @RequestParam(defaultValue = "false") boolean encrypted,
            @RequestParam(required = false) String sha256) {
        return shareService.uploadItem(shareId, file, encrypted, sha256);
    }

    @GetMapping("/{code}/items/{itemId}/download")
    public ResponseEntity<?> downloadApp(@PathVariable String code, @PathVariable String itemId) {
        return downloadResponse(shareService.downloadApp(code, itemId));
    }

    @DeleteMapping("/{shareId}")
    public ResponseEntity<Void> revoke(@PathVariable String shareId) {
        shareService.revoke(shareId);
        return ResponseEntity.noContent().build();
    }

    public static ResponseEntity<?> downloadResponse(com.coursedrop.server.transfer.DownloadFile file) {
        var encoded = URLEncoder.encode(file.filename(), StandardCharsets.UTF_8).replace("+", "%20");
        return ResponseEntity.ok()
                .contentType(MediaType
                        .parseMediaType(file.contentType() == null ? "application/octet-stream" : file.contentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encoded)
                .body(file.resource());
    }
}
