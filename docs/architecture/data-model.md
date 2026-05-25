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

## 服务端身份模型

### DeviceFingerprint

设备指纹是服务端识别手机端的底层身份。

字段：

- `id`：设备指纹记录 ID
- `fingerprint`：设备指纹摘要
- `deviceName`：设备显示名
- `platform`：平台
- `accountId`：绑定账号 ID，可以为空
- `createdAt`：创建时间
- `lastSeenAt`：最后出现时间

### Account

账号用于把多个设备指纹归并为同一个用户身份。

字段：

- `id`：账号 ID
- `username`：账号名
- `passwordHash`：密码摘要，可以为空
- `passwordSalt`：密码盐，可以为空
- `passwordAlgorithm`：密码哈希算法，可以为空
- `passwordLoginEnabled`：是否允许账号密码登录
- `createdAt`：创建时间

默认登录方式是手机扫码。账号密码登录只有在手机端关闭安全设置后才允许。

### WebLoginSession

Web 管理端登录会话。

字段：

- `id`：会话 ID
- `loginCode`：二维码登录码
- `accountId`：登录账号 ID，可以为空
- `fingerprintId`：确认登录的手机设备指纹 ID
- `cookieTokenHash`：浏览器会话 Cookie 的服务端摘要，可以为空
- `status`：`PENDING`、`CONFIRMED`、`EXPIRED`
- `createdAt`：创建时间
- `expiresAt`：过期时间

### ServerShareSession

服务端公网分享会话。它只表示有效期内的临时中转，不表示永久文件夹。

字段：

- `id`：分享会话 ID
- `code`：分享码
- `ownerIdentityId`：设备指纹或账号身份
- `ownerIdentityType`：`FINGERPRINT` 或 `ACCOUNT`
- `status`：`ACTIVE`、`EXPIRED`、`REVOKED`
- `downloadPolicy`：`PUBLIC`、`LOGIN_REQUIRED`、`OWNER_ONLY`
- `downloadAuthRequired`：过渡字段，后续由 `downloadPolicy` 替代
- `createdAt`：创建时间
- `expiresAt`：过期时间

下载策略语义：

- `PUBLIC`：不登录也能下载。
- `LOGIN_REQUIRED`：任意已登录身份可下载。手机端使用设备指纹，电脑端使用手机扫码授权或账号密码登录。
- `OWNER_ONLY`：只有分享创建者的设备指纹、账号或绑定到该账号的设备可以下载。

### ServerShareItem

服务端分享项。

字段：

- `id`：分享项 ID
- `shareId`：所属分享 ID
- `displayName`：展示名称
- `contentType`：MIME 类型
- `sizeBytes`：大小
- `storagePath`：服务器临时存储路径
- `encrypted`：是否为端到端加密密文
- `encryptionAlgorithm`：加密算法，可以为空
- `kdfAlgorithm`：密钥派生算法，可以为空
- `kdfSalt`：密钥派生盐，可以为空
- `nonce`：加密 nonce/iv，可以为空
- `sha256`：文件摘要
- `plainSizeBytes`：明文大小，可以为空
- `createdAt`：创建时间
- `expiresAt`：过期时间

端到端加密约束：

- 服务端保存的是密文和元数据。
- `fileKey` 不进入数据库，不进入 HTTP query 参数。
- 浏览器分享链接使用 `#key={base64urlFileKey}`，由浏览器本地读取。
- 手机 App 扫码时从二维码解析 `code + key`，本地解密。

### ShareAuditLog

分享删除、撤回和过期清理审计记录。

字段：

- `id`：审计 ID
- `shareId`：分享 ID
- `itemId`：分享项 ID，可以为空
- `reason`：`EXPIRED`、`REVOKED`、`CLEANUP_FAILED`、`MANUAL_ADMIN`
- `actorType`：`SYSTEM`、`ACCOUNT`、`FINGERPRINT`、`ADMIN`
- `actorId`：触发者 ID，可以为空
- `sizeBytes`：被删除文件大小，可以为空
- `createdAt`：审计时间
