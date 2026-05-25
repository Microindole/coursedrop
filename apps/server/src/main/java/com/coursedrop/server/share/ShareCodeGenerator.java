package com.coursedrop.server.share;

import java.security.SecureRandom;

import org.springframework.stereotype.Component;

@Component
public class ShareCodeGenerator {
    private static final String CODE_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";
    private final SecureRandom random = new SecureRandom();

    public String nextCode() {
        var code = new StringBuilder();
        for (int i = 0; i < 8; i++) {
            code.append(CODE_ALPHABET.charAt(random.nextInt(CODE_ALPHABET.length())));
        }
        return code.toString();
    }
}
