package com.coursedrop.server.room;

import java.security.SecureRandom;
import java.time.Instant;
import java.time.temporal.ChronoUnit;
import java.util.Locale;
import java.util.UUID;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import com.coursedrop.server.common.ApiException;
import com.coursedrop.server.config.StorageProperties;

@Service
public class RoomService {
  private static final String CODE_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZ";

  private final RoomRepository roomRepository;
  private final StorageProperties storageProperties;
  private final SecureRandom random = new SecureRandom();

  public RoomService(RoomRepository roomRepository, StorageProperties storageProperties) {
    this.roomRepository = roomRepository;
    this.storageProperties = storageProperties;
  }

  public RoomResponse create(CreateRoomRequest request) {
    var now = Instant.now();
    var room = new RoomResponse(
        UUID.randomUUID().toString(),
        nextCode(),
        request.name().trim(),
        now,
        now.plus(storageProperties.roomTtlHours(), ChronoUnit.HOURS));
    roomRepository.save(room);
    return room;
  }

  public RoomResponse join(String code) {
    var normalized = code.trim().toUpperCase(Locale.ROOT);
    var room = roomRepository.findByCode(normalized)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Room not found"));
    if (room.expiresAt().isBefore(Instant.now())) {
      throw new ApiException(HttpStatus.GONE, "Room expired");
    }
    return room;
  }

  public RoomResponse requireActiveRoom(String roomId) {
    var room = roomRepository.findById(roomId)
        .orElseThrow(() -> new ApiException(HttpStatus.NOT_FOUND, "Room not found"));
    if (room.expiresAt().isBefore(Instant.now())) {
      throw new ApiException(HttpStatus.GONE, "Room expired");
    }
    return room;
  }

  private String nextCode() {
    var code = new StringBuilder();
    for (int i = 0; i < 6; i++) {
      code.append(CODE_ALPHABET.charAt(random.nextInt(CODE_ALPHABET.length())));
    }
    if (roomRepository.findByCode(code.toString()).isPresent()) {
      return nextCode();
    }
    return code.toString();
  }
}

