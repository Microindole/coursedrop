package com.coursedrop.server.mapper;

import java.time.Instant;
import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.coursedrop.server.entity.RoomEntity;
import com.coursedrop.server.dto.RoomResponse;

@Repository
public class RoomRepository {
    private final RoomMapper mapper;

    public RoomRepository(RoomMapper mapper) {
        this.mapper = mapper;
    }

    public void save(RoomResponse room) {
        mapper.insert(toEntity(room));
    }

    public Optional<RoomResponse> findByCode(String code) {
        return Optional.ofNullable(mapper.selectOne(new LambdaQueryWrapper<RoomEntity>()
                .eq(RoomEntity::getCode, code)))
                .map(this::toResponse);
    }

    public Optional<RoomResponse> findById(String id) {
        return Optional.ofNullable(mapper.selectById(id)).map(this::toResponse);
    }

    public int deleteExpired(Instant now) {
        return mapper.delete(new LambdaQueryWrapper<RoomEntity>()
                .lt(RoomEntity::getExpiresAt, now.toString()));
    }

    private RoomEntity toEntity(RoomResponse room) {
        var entity = new RoomEntity();
        entity.setId(room.id());
        entity.setCode(room.code());
        entity.setName(room.name());
        entity.setCreatedAt(room.createdAt().toString());
        entity.setExpiresAt(room.expiresAt().toString());
        return entity;
    }

    private RoomResponse toResponse(RoomEntity entity) {
        return new RoomResponse(
                entity.getId(),
                entity.getCode(),
                entity.getName(),
                Instant.parse(entity.getCreatedAt()),
                Instant.parse(entity.getExpiresAt()));
    }
}
