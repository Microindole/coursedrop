package com.coursedrop.server.transfer;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api")
public class TransferController {
    private final TransferService transferService;

    public TransferController(TransferService transferService) {
        this.transferService = transferService;
    }

    @GetMapping("/rooms/{roomId}/items")
    public List<TransferItemResponse> list(@PathVariable String roomId) {
        return transferService.list(roomId);
    }

    @PostMapping("/files/upload")
    public TransferItemResponse upload(@RequestParam String roomId, @RequestParam MultipartFile file) {
        return transferService.upload(roomId, file);
    }

    @GetMapping("/files/{itemId}/download")
    public ResponseEntity<?> download(@PathVariable String itemId) {
        var file = transferService.download(itemId);
        var encoded = URLEncoder.encode(file.filename(), StandardCharsets.UTF_8).replace("+", "%20");
        return ResponseEntity.ok()
                .contentType(MediaType
                        .parseMediaType(file.contentType() == null ? "application/octet-stream" : file.contentType()))
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename*=UTF-8''" + encoded)
                .body(file.resource());
    }
}
