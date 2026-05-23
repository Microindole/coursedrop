# 下一步任务拆解

这份文档给接手者使用，按优先级列出下一轮最应该做的事情。

## P0：手动验证服务端 API

目标：确认服务端当前 MVP 真的能完成传输闭环。

工作目录：

```powershell
cd D:\works\coursedrop\apps\server
```

启动服务：

```powershell
mvn spring-boot:run
```

需要验证：

- `POST /api/rooms` 能创建房间
- `POST /api/rooms/{code}/join` 能加入房间
- `POST /api/files/upload` 能上传文件
- `GET /api/rooms/{roomId}/items` 能看到上传项
- `GET /api/files/{itemId}/download` 能下载文件

验收标准：

- 能用同一个房间完成“上传 -> 列表 -> 下载”
- 上传文件落到 `apps/server/uploads`
- SQLite 中出现 `rooms` 和 `transfer_items` 记录

## P1：实现客户端基础网络层

目标：让鸿蒙客户端可以调用服务端 REST API。

建议改动范围：

```text
apps/harmony/entry/src/main/ets/services/ApiClient.ets
apps/harmony/entry/src/main/ets/services/RoomService.ets
apps/harmony/entry/src/main/ets/services/TransferService.ets
```

注意：

- 先实现 JSON GET/POST。
- multipart 文件上传可以放到下一步。
- 服务端地址先使用 `AppConfig.DEFAULT_SERVER_URL`，后续再做设置页。

验收标准：

- `RoomService.createRoom` 返回真实 `Room`
- `RoomService.joinRoom` 返回真实 `Room`
- 错误响应能被转换成可展示的错误信息

## P2：创建 RoomPage

目标：创建或加入房间后进入房间页。

建议新增：

```text
apps/harmony/entry/src/main/ets/pages/RoomPage.ets
apps/harmony/entry/src/main/ets/viewmodels/RoomViewModel.ets
```

需要修改：

```text
apps/harmony/entry/src/main/resources/base/profile/main_pages.json
apps/harmony/entry/src/main/ets/pages/HomePage.ets
```

验收标准：

- 首页创建房间后进入房间页
- 首页加入房间后进入房间页
- 房间页展示房间名称、房间码、过期时间
- 房间页能拉取并展示传输项列表

## P3：实现文件上传下载

目标：客户端完成真实文件传输。

建议改动范围：

```text
apps/harmony/entry/src/main/ets/services/TransferService.ets
apps/harmony/entry/src/main/ets/pages/RoomPage.ets
```

验收标准：

- 可以从鸿蒙端选择文件上传
- 房间列表出现新文件
- 可以下载文件
- 上传和下载至少有基本状态提示

## P4：再做剪贴板

目标：扩展文本、链接、代码片段能力。

不要在 P0 到 P3 之前做剪贴板，避免主链路还没稳定就扩范围。

建议：

- 服务端先复用 `TransferItem`
- 文本类传输项类型为 `TEXT` 或 `LINK`
- 客户端只做手动读取/手动发送，不做后台自动监听剪贴板

