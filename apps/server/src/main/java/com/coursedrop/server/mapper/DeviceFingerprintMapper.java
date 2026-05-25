package com.coursedrop.server.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.coursedrop.server.entity.DeviceFingerprintEntity;

@Mapper
public interface DeviceFingerprintMapper extends BaseMapper<DeviceFingerprintEntity> {
}
