package com.coursedrop.server.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.coursedrop.server.entity.RoomEntity;

@Mapper
public interface RoomMapper extends BaseMapper<RoomEntity> {
}
