package com.coursedrop.server.share;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

import org.springframework.core.io.PathResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.config.StorageProperties;
import com.coursedrop.server.storage.FileNameCleaner;
import com.coursedrop.server.storage.LocalFileStorageService;
import com.coursedrop.server.transfer.DownloadFile;

@Service
public class ShareService {
    private final ShareSessionRepository sessionRepository;
    private final ShareItemRepository itemRepository;
    private final ShareCodeGenerator codeGenerator;
    private final LocalFileStorageService storageService;
    private final StorageProperties storageProperties;

    public ShareService(
            ShareSessionRepository sessionRepository,
            ShareItemRepository itemRepository,
            ShareCodeGenerator codeGenerator,
            LocalFileStorageService storageService,
            StorageProperties storageProperties) {
        this.sessionRepository = sessionRepository;
        this.itemRepository = itemRepository;
        this.codeGenerator = codeGenerator;
        this.storageService = storageService;
        this.storageProperties = storageProperties;
    }

    public ShareSessionResponse create(CreateShareRequest request) {
        var now = Instant.now();
        var identityType = request.ownerIdentityType() == null ? OwnerIdentityType.ANONYMOUS : request.ownerIdentityType();
        var session = new ShareSessionRecord(
                UUID.randomUUID().toString(),
                nextUniqueCode(),
                request.ownerIdentityId(),
                identityType,
                ShareSessionStatus.ACTIVE,
                request.downloadAuthRequired(),
                now,
                now.plus(request.expireHours(), ChronoUnit.HOURS));
        sessionRepository.save(session);
        return toResponse(session);
    }

    public ShareDownloadPageResponse getByCode(String code) {
        var session = requireDownloadableSession(code);
        return new ShareDownloadPageResponse(
                session.code(),
                session.status(),
                session.downloadAuthRequired(),
                session.expiresAt(),
                itemRepository.findByShareId(session.id()).stream().map(this::toResponse).toList());
    }

    public ShareItemResponse uploadItem(String shareId, MultipartFile file, boolean encrypted, String sha256) {
        var session = requireActiveSessionById(shareId);
        if (file.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "File is empty");
        }
        var maxBytes = storageProperties.maxFileSizeMb() * 1024L * 1024L;
        if (file.getSize() > maxBytes) {
            throw new ApiException(HttpStatus.PAYLOAD_TOO_LARGE, "File is too large");
        }

        var storedObject = storageService.store(file);
        var now = Instant.now();
        var item = new ShareItemRecord(
                UUID.randomUUID().toString(),
                session.id(),
                safeName(file.getOriginalFilename()),
                storedObject.storageKey(),
                file.getContentType(),
                storedObject.sizeBytes(),
                encrypted,
                blankToNull(sha256),
                now,
                session.expiresAt());
        itemRepository.save(item);
        return toResponse(item);
    }

    public DownloadFile downloadApp(String code, String itemId) {
        return download(code, itemId);
    }

    public DownloadFile downloadBrowser(String code, String itemId, boolean authorized) {
        if (!authorized) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "Login required");
        }
        return download(code, itemId);
    }

    public void revoke(String shareId) {
        var session = sessionRepository.findById(shareId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Share not found"));
        sessionRepository.updateStatus(session.id(), ShareSessionStatus.REVOKED);
        deleteShareFiles(session.id());
    }

    public void cleanupExpired(Instant now) {
        sessionRepository.findExpiredActive(now).forEach(session -> {
            sessionRepository.updateStatus(session.id(), ShareSessionStatus.EXPIRED);
            deleteShareFiles(session.id());
        });
        itemRepository.findExpired(now).forEach(item -> storageService.deleteIfExists(item.storageKey()));
        itemRepository.deleteExpired(now);
    }

    private DownloadFile download(String code, String itemId) {
        var session = requireDownloadableSession(code);
        var item = itemRepository.findById(itemId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Share item not found"));
        if (!item.shareId().equals(session.id())) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Share item not found");
        }
        if (item.expiresAt().isBefore(Instant.now())) {
            throw new ApiException(HttpStatus.GONE, "Share item expired");
        }
        return new DownloadFile(item.displayName(), item.contentType(),
                new PathResource(storageService.resolve(item.storageKey())));
    }

    private ShareSessionRecord requireActiveSessionById(String shareId) {
        var session = sessionRepository.findById(shareId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Share not found"));
        ensureActive(session);
        return session;
    }

    private ShareSessionRecord requireDownloadableSession(String code) {
        var session = sessionRepository.findByCode(code)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Share not found"));
        ensureActive(session);
        return session;
    }

    private void ensureActive(ShareSessionRecord session) {
        if (session.status() == ShareSessionStatus.REVOKED) {
            throw new ApiException(HttpStatus.GONE, "Share revoked");
        }
        if (session.status() == ShareSessionStatus.EXPIRED || session.expiresAt().isBefore(Instant.now())) {
            sessionRepository.updateStatus(session.id(), ShareSessionStatus.EXPIRED);
            throw new ApiException(HttpStatus.GONE, "Share expired");
        }
    }

    private void deleteShareFiles(String shareId) {
        itemRepository.findByShareId(shareId).forEach(item -> storageService.deleteIfExists(item.storageKey()));
        itemRepository.deleteByShareId(shareId);
    }

    private String nextUniqueCode() {
        var code = codeGenerator.nextCode();
        if (sessionRepository.findByCode(code).isPresent()) {
            return nextUniqueCode();
        }
        return code;
    }

    private String safeName(String filename) {
        if (filename == null || filename.isBlank()) {
            return "unnamed";
        }
        return FileNameCleaner.clean(filename);
    }

    private String blankToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value;
    }

    private ShareSessionResponse toResponse(ShareSessionRecord session) {
        return new ShareSessionResponse(
                session.id(),
                session.code(),
                "/s/" + session.code(),
                session.status(),
                session.downloadAuthRequired(),
                session.createdAt(),
                session.expiresAt());
    }

    private ShareItemResponse toResponse(ShareItemRecord item) {
        return new ShareItemResponse(
                item.id(),
                item.shareId(),
                item.displayName(),
                item.contentType(),
                item.sizeBytes(),
                item.encrypted(),
                item.sha256(),
                item.createdAt(),
                item.expiresAt());
    }
}
