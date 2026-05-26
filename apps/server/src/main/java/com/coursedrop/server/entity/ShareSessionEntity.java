package com.coursedrop.server.entity;

import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;

@TableName("share_sessions")
public class ShareSessionEntity {
    @TableId
    private String id;
    private String code;
    private String ownerIdentityId;
    private String ownerIdentityType;
    private String status;
    private Integer downloadAuthRequired;
    private String downloadPolicy;
    private String createdAt;
    private String expiresAt;

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getOwnerIdentityId() {
        return ownerIdentityId;
    }

    public void setOwnerIdentityId(String ownerIdentityId) {
        this.ownerIdentityId = ownerIdentityId;
    }

    public String getOwnerIdentityType() {
        return ownerIdentityType;
    }

    public void setOwnerIdentityType(String ownerIdentityType) {
        this.ownerIdentityType = ownerIdentityType;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getDownloadAuthRequired() {
        return downloadAuthRequired;
    }

    public void setDownloadAuthRequired(Integer downloadAuthRequired) {
        this.downloadAuthRequired = downloadAuthRequired;
    }

    public String getDownloadPolicy() {
        return downloadPolicy;
    }

    public void setDownloadPolicy(String downloadPolicy) {
        this.downloadPolicy = downloadPolicy;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getExpiresAt() {
        return expiresAt;
    }

    public void setExpiresAt(String expiresAt) {
        this.expiresAt = expiresAt;
    }
}
