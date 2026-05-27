package com.coursedrop.server.controller;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.service.QrCodeService;

@RestController
@RequestMapping("/api/qr")
public class QrController {
    private final QrCodeService qrCodeService;

    public QrController(QrCodeService qrCodeService) {
        this.qrCodeService = qrCodeService;
    }

    @GetMapping(produces = "image/svg+xml")
    public String render(@RequestParam String text) {
        if (text == null || text.isBlank()) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "QR text is required");
        }
        if (text.length() > 1024) {
            throw new ApiException(HttpStatus.BAD_REQUEST, "QR text is too long");
        }
        return qrCodeService.renderSvg(text);
    }
}
