package com.coursedrop.server.storage;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.config.StorageProperties;

@Service
public class LocalFileStorageService {
    private final Path uploadRoot;

    public LocalFileStorageService(StorageProperties storageProperties) {
        this.uploadRoot = Path.of(storageProperties.uploadDir()).toAbsolutePath().normalize();
    }

    public StoredObject store(MultipartFile file) {
        try {
            Files.createDirectories(uploadRoot);
            var storageKey = UUID.randomUUID().toString();
            var target = uploadRoot.resolve(storageKey).normalize();
            file.transferTo(target);
            return new StoredObject(storageKey, target, Files.size(target));
        } catch (IOException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "Failed to store file");
        }
    }

    public Path resolve(String storageKey) {
        var path = uploadRoot.resolve(storageKey).normalize();
        if (!path.startsWith(uploadRoot) || !Files.exists(path)) {
            throw new ApiException(HttpStatus.NOT_FOUND, "Stored file not found");
        }
        return path;
    }

    public void deleteIfExists(String storageKey) {
        try {
            Files.deleteIfExists(uploadRoot.resolve(storageKey).normalize());
        } catch (IOException ignored) {
            // Cleanup should be best-effort; metadata cleanup can still continue.
        }
    }
}
