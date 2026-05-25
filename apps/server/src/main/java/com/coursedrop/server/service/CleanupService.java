package com.coursedrop.server.service;

import java.time.Instant;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import com.coursedrop.server.mapper.RoomRepository;
import com.coursedrop.server.mapper.TransferItemRepository;
import com.coursedrop.server.storage.LocalFileStorageService;

@Service
public class CleanupService {
    private final TransferItemRepository transferItemRepository;
    private final RoomRepository roomRepository;
    private final LocalFileStorageService storageService;
    private final ShareService shareService;

    public CleanupService(
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
