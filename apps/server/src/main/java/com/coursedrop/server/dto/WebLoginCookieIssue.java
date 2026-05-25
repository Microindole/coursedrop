package com.coursedrop.server.dto;

public record WebLoginCookieIssue(
        WebLoginResponse response,
        String cookieToken
) {
}
