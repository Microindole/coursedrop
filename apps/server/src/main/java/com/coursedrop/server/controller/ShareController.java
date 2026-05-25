package com.coursedrop.server.controller;

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

import com.coursedrop.server.service.ShareService;
import com.coursedrop.server.service.ShareAuditService;
import com.coursedrop.server.dto.CreateShareRequest;
import com.coursedrop.server.dto.ShareDownloadPageResponse;
import com.coursedrop.server.dto.ShareItemResponse;
import com.coursedrop.server.dto.ShareSessionResponse;

import jakarta.validation.Valid;

@Validated
@RestController
@RequestMapping("/api/shares")
public class ShareController {
    private final ShareService shareService;
    private final ShareAuditService shareAuditService;

    public ShareController(ShareService shareService, ShareAuditService shareAuditService) {
        this.shareService = shareService;
        this.shareAuditService = shareAuditService;
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
            @RequestParam(required = false) String encryptionAlgorithm,
            @RequestParam(required = false) String kdfAlgorithm,
            @RequestParam(required = false) String kdfSalt,
            @RequestParam(required = false) String nonce,
            @RequestParam(required = false) String sha256,
            @RequestParam(required = false) Long plainSizeBytes) {
        return shareService.uploadItem(
                shareId,
                file,
                encrypted,
                encryptionAlgorithm,
                kdfAlgorithm,
                kdfSalt,
                nonce,
                sha256,
                plainSizeBytes);
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

    @GetMapping("/{shareId}/audit")
    public java.util.List<com.coursedrop.server.dto.ShareAuditLogResponse> audit(@PathVariable String shareId) {
        return shareAuditService.listByShareId(shareId);
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
