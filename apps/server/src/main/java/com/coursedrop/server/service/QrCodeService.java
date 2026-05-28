package com.coursedrop.server.service;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Map;

import javax.imageio.ImageIO;

import org.springframework.stereotype.Service;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

import org.springframework.http.HttpStatus;

import com.coursedrop.server.common.ApiException;

@Service
public class QrCodeService {
    public byte[] renderPng(String value) {
        try {
            BitMatrix matrix = new QRCodeWriter().encode(
                    value, BarcodeFormat.QR_CODE, 256, 256,
                    Map.of(EncodeHintType.MARGIN, 2));
            BufferedImage image = new BufferedImage(matrix.getWidth(), matrix.getHeight(), BufferedImage.TYPE_INT_RGB);
            for (int y = 0; y < matrix.getHeight(); y++) {
                for (int x = 0; x < matrix.getWidth(); x++) {
                    image.setRGB(x, y, matrix.get(x, y) ? 0x111111 : 0xFFFFFF);
                }
            }
            ByteArrayOutputStream bos = new ByteArrayOutputStream();
            ImageIO.write(image, "png", bos);
            return bos.toByteArray();
        } catch (WriterException | IOException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "QR code unavailable");
        }
    }

    public String renderSvg(String value) {
        try {
            return toSvg(new QRCodeWriter().encode(
                    value,
                    BarcodeFormat.QR_CODE,
                    220,
                    220,
                    Map.of(EncodeHintType.MARGIN, 1)));
        } catch (WriterException exception) {
            throw new ApiException(HttpStatus.INTERNAL_SERVER_ERROR, "QR code unavailable");
        }
    }

    private String toSvg(BitMatrix matrix) {
        var html = new StringBuilder();
        html.append("<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"")
                .append(matrix.getWidth())
                .append("\" height=\"")
                .append(matrix.getHeight())
                .append("\" viewBox=\"0 0 ")
                .append(matrix.getWidth())
                .append(' ')
                .append(matrix.getHeight())
                .append("\">");
        html.append("<rect width=\"100%\" height=\"100%\" fill=\"#fff\"/>");
        for (int y = 0; y < matrix.getHeight(); y++) {
            for (int x = 0; x < matrix.getWidth(); x++) {
                if (matrix.get(x, y)) {
                    html.append("<rect x=\"").append(x).append("\" y=\"").append(y)
                            .append("\" width=\"1\" height=\"1\" fill=\"#111\"/>");
                }
            }
        }
        html.append("</svg>");
        return html.toString();
    }
}
