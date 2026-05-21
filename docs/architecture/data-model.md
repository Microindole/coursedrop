# 数据模型

## Room

临时传输房间。

字段：

- `id`：房间唯一 ID
- `code`：6 位加入码
- `name`：课程或小组名称
- `createdAt`：创建时间
- `expiresAt`：过期时间

## TransferItem

房间中的传输项。文件、图片、文本、链接都归一到这个模型。

字段：

- `id`：传输项唯一 ID
- `roomId`：所属房间 ID
- `type`：传输项类型，当前包含 `FILE`、`IMAGE`、`TEXT`、`LINK`
- `displayName`：展示名称
- `storageKey`：服务端本地文件键，文本类传输项可以为空
- `contentType`：MIME 类型
- `sizeBytes`：大小
- `createdAt`：创建时间
- `expiresAt`：过期时间

## Device

计划中的设备模型，用于 WebSocket 和在线状态。

字段设想：

- `id`：设备 ID
- `roomId`：所在房间
- `name`：设备显示名
- `platform`：设备平台
- `lastSeenAt`：最后心跳时间

## ClipboardSnippet

计划中的剪贴板片段模型。

短期内可以直接复用 `TransferItem`，把 `type` 设置为 `TEXT` 或 `LINK`。如果后续要支持收藏、搜索、自动识别链接标题，再拆出独立表。

