package com.coursedrop.server.service;

import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.UUID;

import org.springframework.core.io.PathResource;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.coursedrop.server.enums.ShareAuditActorType;
import com.coursedrop.server.enums.ShareAuditReason;
import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.config.StorageProperties;
import com.coursedrop.server.mapper.ShareItemRepository;
import com.coursedrop.server.mapper.ShareSessionRepository;
import com.coursedrop.server.mapper.IdentityRepository;
import com.coursedrop.server.dto.CreateShareRequest;
import com.coursedrop.server.enums.OwnerIdentityType;
import com.coursedrop.server.share.ShareCodeGenerator;
import com.coursedrop.server.dto.ShareDownloadPageResponse;
import com.coursedrop.server.share.ShareItemRecord;
import com.coursedrop.server.dto.ShareItemResponse;
import com.coursedrop.server.share.ShareSessionRecord;
import com.coursedrop.server.dto.ShareSessionResponse;
import com.coursedrop.server.enums.ShareSessionStatus;
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
    private final ShareAuditService auditService;
    private final IdentityRepository identityRepository;

    public ShareService(
            ShareSessionRepository sessionRepository,
            ShareItemRepository itemRepository,
            ShareCodeGenerator codeGenerator,
            LocalFileStorageService storageService,
            StorageProperties storageProperties,
            ShareAuditService auditService,
            IdentityRepository identityRepository) {
        this.sessionRepository = sessionRepository;
        this.itemRepository = itemRepository;
        this.codeGenerator = codeGenerator;
        this.storageService = storageService;
        this.storageProperties = storageProperties;
        this.auditService = auditService;
        this.identityRepository = identityRepository;
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

    public ShareItemResponse uploadItem(
            String shareId,
            MultipartFile file,
            boolean encrypted,
            String encryptionAlgorithm,
            String kdfAlgorithm,
            String kdfSalt,
            String nonce,
            String sha256,
            Long plainSizeBytes) {
        var session = requireActiveSessionById(shareId);
        if (file.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "File is empty");
        }
        var maxBytes = storageProperties.maxFileSizeMb() * 1024L * 1024L;
        if (file.getSize() > maxBytes) {
            throw new ApiException(HttpStatus.PAYLOAD_TOO_LARGE, "File is too large");
        }
        validateEncryptionMetadata(encrypted, encryptionAlgorithm, kdfAlgorithm, kdfSalt, nonce, sha256, plainSizeBytes);

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
                blankToNull(encryptionAlgorithm),
                blankToNull(kdfAlgorithm),
                blankToNull(kdfSalt),
                blankToNull(nonce),
                blankToNull(sha256),
                plainSizeBytes,
                now,
                session.expiresAt());
        itemRepository.save(item);
        return toResponse(item);
    }

    public DownloadFile downloadApp(String code, String itemId, String fingerprintId, String accountId) {
        var session = requireDownloadableSession(code);
        ensureAppDownloadAuthorized(session, fingerprintId, accountId);
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
        deleteShareFiles(session.id(), ShareAuditReason.REVOKED, ShareAuditActorType.FINGERPRINT, session.ownerIdentityId());
    }

    public List<ShareSessionResponse> listMine(String ownerIdentityId, OwnerIdentityType ownerIdentityType) {
        if (ownerIdentityId == null || ownerIdentityId.isBlank() || ownerIdentityType == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Owner identity is required");
        }
        return sessionRepository.findByOwner(ownerIdentityId, ownerIdentityType).stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ShareSessionResponse> listByStatus(ShareSessionStatus status) {
        return sessionRepository.findByStatus(status).stream()
                .map(this::toResponse)
                .toList();
    }

    public ShareSessionResponse extendExpiry(String shareId, int expireHours) {
        var session = requireActiveSessionById(shareId);
        var expiresAt = Instant.now().plus(expireHours, ChronoUnit.HOURS);
        sessionRepository.updateExpiresAt(shareId, expiresAt);
        return toResponse(new ShareSessionRecord(
                session.id(),
                session.code(),
                session.ownerIdentityId(),
                session.ownerIdentityType(),
                session.status(),
                session.downloadAuthRequired(),
                session.createdAt(),
                expiresAt));
    }

    public void deleteItem(String shareId, String itemId, ShareAuditActorType actorType, String actorId) {
        requireActiveSessionById(shareId);
        var item = itemRepository.findById(itemId)
                .filter(value -> value.shareId().equals(shareId))
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Share item not found"));
        if (!storageService.deleteIfExistsWithResult(item.storageKey())) {
            auditService.record(shareId, item.id(), ShareAuditReason.CLEANUP_FAILED, actorType, actorId, item.sizeBytes());
        }
        auditService.record(shareId, item.id(), ShareAuditReason.REVOKED, actorType, actorId, item.sizeBytes());
        itemRepository.deleteById(item.id());
    }

    public void cleanupExpired(Instant now) {
        sessionRepository.findExpiredActive(now).forEach(session -> {
            sessionRepository.updateStatus(session.id(), ShareSessionStatus.EXPIRED);
            deleteShareFiles(session.id(), ShareAuditReason.EXPIRED, ShareAuditActorType.SYSTEM, null);
        });
        itemRepository.findExpired(now).forEach(item -> {
            if (!storageService.deleteIfExistsWithResult(item.storageKey())) {
                auditService.record(
                        item.shareId(),
                        item.id(),
                        ShareAuditReason.CLEANUP_FAILED,
                        ShareAuditActorType.SYSTEM,
                        null,
                        item.sizeBytes());
            }
            auditService.record(
                    item.shareId(),
                    item.id(),
                    ShareAuditReason.EXPIRED,
                    ShareAuditActorType.SYSTEM,
                    null,
                    item.sizeBytes());
        });
        itemRepository.deleteExpired(now);
    }

    public List<String> listReferencedStorageKeys() {
        return itemRepository.findAll().stream()
                .map(ShareItemRecord::storageKey)
                .toList();
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

    private void deleteShareFiles(
            String shareId,
            ShareAuditReason reason,
            ShareAuditActorType actorType,
            String actorId) {
        itemRepository.findByShareId(shareId).forEach(item -> {
            if (!storageService.deleteIfExistsWithResult(item.storageKey())) {
                auditService.record(shareId, item.id(), ShareAuditReason.CLEANUP_FAILED, actorType, actorId, item.sizeBytes());
            }
            auditService.record(shareId, item.id(), reason, actorType, actorId, item.sizeBytes());
        });
        itemRepository.deleteByShareId(shareId);
    }

    private void ensureAppDownloadAuthorized(ShareSessionRecord session, String fingerprintId, String accountId) {
        if (!session.downloadAuthRequired()) {
            return;
        }
        if ((fingerprintId == null || fingerprintId.isBlank()) && (accountId == null || accountId.isBlank())) {
            throw new ApiException(HttpStatus.UNAUTHORIZED, "App identity required");
        }
        if (session.ownerIdentityType() == OwnerIdentityType.ANONYMOUS) {
            validateAnyIdentity(fingerprintId, accountId);
            return;
        }
        if (session.ownerIdentityType() == OwnerIdentityType.ACCOUNT) {
            if (session.ownerIdentityId().equals(accountId)) {
                return;
            }
            if (fingerprintId != null && !fingerprintId.isBlank()) {
                var fingerprint = identityRepository.findFingerprintById(fingerprintId)
                        .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Unknown fingerprint"));
                if (session.ownerIdentityId().equals(fingerprint.accountId())) {
                    return;
                }
            }
            throw new ApiException(HttpStatus.FORBIDDEN, "Share is not available for this account");
        }
        if (session.ownerIdentityType() == OwnerIdentityType.FINGERPRINT) {
            if (session.ownerIdentityId().equals(fingerprintId)) {
                return;
            }
            throw new ApiException(HttpStatus.FORBIDDEN, "Share is not available for this device");
        }
    }

    private void validateAnyIdentity(String fingerprintId, String accountId) {
        if (accountId != null && !accountId.isBlank()) {
            identityRepository.findAccountById(accountId)
                    .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Unknown account"));
            return;
        }
        identityRepository.findFingerprintById(fingerprintId)
                .orElseThrow(() -> new ApiException(HttpStatus.UNAUTHORIZED, "Unknown fingerprint"));
    }

    private void validateEncryptionMetadata(
            boolean encrypted,
            String encryptionAlgorithm,
            String kdfAlgorithm,
            String kdfSalt,
            String nonce,
            String sha256,
            Long plainSizeBytes) {
        if (!encrypted) {
            return;
        }
        if (isBlank(encryptionAlgorithm) || isBlank(kdfAlgorithm) || isBlank(kdfSalt)
                || isBlank(nonce) || isBlank(sha256) || plainSizeBytes == null || plainSizeBytes < 0) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Encrypted item metadata is incomplete");
        }
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

    private boolean isBlank(String value) {
        return value == null || value.isBlank();
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
                item.encryptionAlgorithm(),
                item.kdfAlgorithm(),
                item.kdfSalt(),
                item.nonce(),
                item.sha256(),
                item.plainSizeBytes(),
                item.createdAt(),
                item.expiresAt());
    }
}
