package com.coursedrop.server.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.coursedrop.server.dto.CreateRoomRequest;
import com.coursedrop.server.dto.RoomResponse;
import com.coursedrop.server.service.RoomService;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/api/rooms")
public class RoomController {
    private final RoomService roomService;

    public RoomController(RoomService roomService) {
        this.roomService = roomService;
    }

    @PostMapping
    public RoomResponse create(@Valid @RequestBody CreateRoomRequest request) {
        return roomService.create(request);
    }

    @PostMapping("/{code}/join")
    public RoomResponse join(@PathVariable String code) {
        return roomService.join(code);
    }

    @GetMapping("/{roomId}")
    public RoomResponse get(@PathVariable String roomId) {
        return roomService.requireActiveRoom(roomId);
    }
}
