package com.coursedrop.server.storage;

import java.nio.file.Path;

public record StoredObject(
        String storageKey,
        Path path,
        long sizeBytes) {
}
