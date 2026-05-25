package com.coursedrop.server.storage;

public final class FileNameCleaner {
    private FileNameCleaner() {
    }

    public static String clean(String filename) {
        return filename.replace('\\', '_').replace('/', '_').trim();
    }
}
