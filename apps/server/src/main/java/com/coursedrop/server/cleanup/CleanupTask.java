package com.coursedrop.server.cleanup;

import java.time.Instant;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import com.coursedrop.server.room.RoomRepository;
import com.coursedrop.server.share.ShareService;
import com.coursedrop.server.storage.LocalFileStorageService;
import com.coursedrop.server.transfer.TransferItemRepository;

@Component
public class CleanupTask {
    private final TransferItemRepository transferItemRepository;
    private final RoomRepository roomRepository;
    private final LocalFileStorageService storageService;
    private final ShareService shareService;

    public CleanupTask(
            TransferItemRepository transferItemRepository,
            RoomRepository roomRepository,
            LocalFileStorageService storageService,
            ShareService shareService) {
        this.transferItemRepository = transferItemRepository;
        this.roomRepository = roomRepository;
        this.storageService = storageService;
        this.shareService = shareService;
    }

    @Scheduled(fixedDelayString = "PT30M")
    public void cleanupExpiredItems() {
        var now = Instant.now();
        transferItemRepository.findExpired(now).stream()
                .filter(item -> item.storageKey() != null)
                .forEach(item -> storageService.deleteIfExists(item.storageKey()));
        transferItemRepository.deleteExpired(now);
        shareService.cleanupExpired(now);
        roomRepository.deleteExpired(now);
    }
}
