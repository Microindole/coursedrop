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
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import com.coursedrop.server.service.ShareService;
import com.coursedrop.server.service.ShareAuditService;
import com.coursedrop.server.dto.CreateShareRequest;
import com.coursedrop.server.dto.ShareDownloadPageResponse;
import com.coursedrop.server.dto.ShareItemResponse;
import com.coursedrop.server.dto.ShareSessionResponse;
import com.coursedrop.server.dto.UpdateShareExpiryRequest;
import com.coursedrop.server.enums.OwnerIdentityType;
import com.coursedrop.server.enums.ShareAuditActorType;
import com.coursedrop.server.enums.ShareSessionStatus;

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
    public ResponseEntity<?> downloadApp(
            @PathVariable String code,
            @PathVariable String itemId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String accountId) {
        return downloadResponse(shareService.downloadApp(code, itemId, fingerprintId, accountId));
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

    @GetMapping
    public java.util.List<ShareSessionResponse> list(
            @RequestParam(required = false) String ownerIdentityId,
            @RequestParam(required = false) OwnerIdentityType ownerIdentityType,
            @RequestParam(required = false) ShareSessionStatus status) {
        if (status != null) {
            return shareService.listByStatus(status);
        }
        return shareService.listMine(ownerIdentityId, ownerIdentityType);
    }

    @PostMapping("/{shareId}/expiry")
    public ShareSessionResponse extendExpiry(
            @PathVariable String shareId,
            @Valid @RequestBody UpdateShareExpiryRequest request) {
        return shareService.extendExpiry(shareId, request.expireHours());
    }

    @DeleteMapping("/{shareId}/items/{itemId}")
    public ResponseEntity<Void> deleteItem(
            @PathVariable String shareId,
            @PathVariable String itemId,
            @RequestHeader(name = "X-CourseDrop-Fingerprint-Id", required = false) String fingerprintId,
            @RequestHeader(name = "X-CourseDrop-Account-Id", required = false) String accountId) {
        var actorType = accountId == null || accountId.isBlank()
                ? ShareAuditActorType.FINGERPRINT
                : ShareAuditActorType.ACCOUNT;
        var actorId = accountId == null || accountId.isBlank() ? fingerprintId : accountId;
        shareService.deleteItem(shareId, itemId, actorType, actorId);
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
