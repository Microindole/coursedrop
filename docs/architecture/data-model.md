# 数据模型

CourseDrop 当前定位为本地优先的加密文件传输与分享管理工具。模型层按“分享会话、传输项、设备、任务、本地库”组织。

## ShareSession

一次分享会话。它可以走局域网直传，也可以走公网临时中转。

字段：

- `id`：分享会话 ID
- `title`：分享标题
- `code`：分享码
- `shareUrl`：公网分享链接，可以为空
- `networkMode`：`LAN`、`RELAY`、`E2EE`、`OFFLINE`
- `expireStatus`：`ACTIVE`、`EXPIRING_SOON`、`EXPIRED`
- `createdAt`：创建时间
- `expiresAt`：过期时间
- `items`：分享包含的传输项

## TransferItem

分享中的内容项。文件、图片、文本、链接都归一到这个模型。

字段：

- `id`：传输项唯一 ID
- `sessionId`：所属分享会话 ID
- `type`：`FILE`、`IMAGE`、`TEXT`、`LINK`
- `displayName`：展示名称
- `contentType`：MIME 类型
- `sizeBytes`：大小
- `localUri`：本地文件 URI，可以为空
- `remoteUrl`：公网临时副本地址，可以为空
- `createdAt`：创建时间
- `expiresAt`：过期时间
- `encrypted`：是否端到端加密

## Device

局域网或已发现设备。

字段：

- `id`：设备 ID
- `name`：设备显示名
- `platform`：设备平台
- `status`：`ONLINE`、`IDLE`、`OFFLINE`
- `networkMode`：当前连接方式
- `latencyMs`：局域网延迟，可以为空
- `lastSeenAt`：最后发现时间

## TransferTask

上传、下载或局域网直传任务。

字段：

- `id`：任务 ID
- `itemId`：关联传输项 ID
- `direction`：`UPLOAD`、`DOWNLOAD`、`SEND`、`RECEIVE`
- `status`：`PENDING`、`RUNNING`、`COMPLETED`、`FAILED`、`CANCELED`
- `progress`：0 到 100 的进度
- `speedBytesPerSecond`：传输速度，可以为空
- `errorMessage`：失败原因，可以为空

## LocalFileEntry

本地分享管理器中的文件项。

字段：

- `id`：本地记录 ID
- `displayName`：展示名称
- `type`：文件类型
- `sizeBytes`：大小
- `localUri`：本地 URI
- `lastSharedAt`：上次分享时间，可以为空
- `shareCount`：分享次数
- `remoteCached`：公网临时副本是否仍存在
- `encrypted`：是否加密

## 兼容模型

当前服务端仍保留早期房间模型：

- `Room`
- 旧版 `TransferItem.roomId`

后续客户端页面优先使用 `ShareSession`，服务端可以逐步从“房间中转”演进到“临时分享会话”。
