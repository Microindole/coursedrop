package com.coursedrop.server.service;

import java.time.Instant;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.common.ApiException;

@Service
public class RateLimitService {
    private final Map<String, Window> windows = new ConcurrentHashMap<>();

    public void check(String key, int maxRequests, long windowSeconds) {
        var now = Instant.now().getEpochSecond();
        var window = windows.compute(key, (ignored, current) -> {
            if (current == null || now >= current.startsAt + windowSeconds) {
                return new Window(now, 1);
            }
            return new Window(current.startsAt, current.count + 1);
        });
        if (window.count > maxRequests) {
            throw new ApiException(HttpStatus.TOO_MANY_REQUESTS, "Too many requests");
        }
    }

    private record Window(long startsAt, int count) {
    }
}
