package com.coursedrop.server.mapper;

import org.apache.ibatis.annotations.Mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.coursedrop.server.entity.AccountEntity;

@Mapper
public interface AccountMapper extends BaseMapper<AccountEntity> {
}
