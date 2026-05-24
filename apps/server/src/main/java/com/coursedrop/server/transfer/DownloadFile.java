package com.coursedrop.server.transfer;

import org.springframework.core.io.Resource;

public record DownloadFile(
        String filename,
        String contentType,
        Resource resource) {
}
