package com.coursedrop.server.transfer;

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
import com.coursedrop.server.room.RoomService;
import com.coursedrop.server.storage.LocalFileStorageService;

@Service
public class TransferService {
    private final TransferItemRepository transferItemRepository;
    private final RoomService roomService;
    private final LocalFileStorageService storageService;
    private final StorageProperties storageProperties;

    public TransferService(
            TransferItemRepository transferItemRepository,
            RoomService roomService,
            LocalFileStorageService storageService,
            StorageProperties storageProperties) {
        this.transferItemRepository = transferItemRepository;
        this.roomService = roomService;
        this.storageService = storageService;
        this.storageProperties = storageProperties;
    }

    public TransferItemResponse upload(String roomId, MultipartFile file) {
        roomService.requireActiveRoom(roomId);
        if (file.isEmpty()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "File is empty");
        }
        var maxBytes = storageProperties.maxFileSizeMb() * 1024L * 1024L;
        if (file.getSize() > maxBytes) {
            throw new ApiException(HttpStatus.PAYLOAD_TOO_LARGE, "File is too large");
        }

        var storedObject = storageService.store(file);
        var now = Instant.now();
        var item = new TransferItemStored(
                UUID.randomUUID().toString(),
                roomId,
                guessType(file.getContentType()),
                safeName(file.getOriginalFilename()),
                storedObject.storageKey(),
                file.getContentType(),
                storedObject.sizeBytes(),
                now,
                now.plus(storageProperties.fileTtlHours(), ChronoUnit.HOURS));
        transferItemRepository.save(item);
        return toResponse(item);
    }

    public List<TransferItemResponse> list(String roomId) {
        roomService.requireActiveRoom(roomId);
        return transferItemRepository.findByRoomId(roomId);
    }

    public DownloadFile download(String itemId) {
        var item = transferItemRepository.findStoredById(itemId)
                .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Transfer item not found"));
        if (item.expiresAt().isBefore(Instant.now())) {
            throw new ApiException(HttpStatus.GONE, "Transfer item expired");
        }
        if (item.storageKey() == null) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "Transfer item has no file");
        }
        return new DownloadFile(item.displayName(), item.contentType(),
                new PathResource(storageService.resolve(item.storageKey())));
    }

    private TransferItemType guessType(String contentType) {
        if (contentType != null && contentType.startsWith("image/")) {
            return TransferItemType.IMAGE;
        }
        return TransferItemType.FILE;
    }

    private String safeName(String filename) {
        if (filename == null || filename.isBlank()) {
            return "unnamed";
        }
        return FileNameCleaner.clean(filename);
    }

    private TransferItemResponse toResponse(TransferItemStored item) {
        return new TransferItemResponse(
                item.id(), item.roomId(), item.type(), item.displayName(), item.contentType(),
                item.sizeBytes(), item.createdAt(), item.expiresAt());
    }
}
