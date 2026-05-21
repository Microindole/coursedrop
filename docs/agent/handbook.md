# Agent 接手指南

这份文档用于让新的 agent 或开发者快速接手 CourseDrop。

## 项目一句话

CourseDrop / 课递：面向课程小组的资料快传与临时存储工具。

## 当前重点

先完成服务器中转传输 MVP：

```text
创建房间 -> 加入房间 -> 上传文件 -> 查看列表 -> 下载文件 -> 过期清理
```

局域网直传、WebSocket、剪贴板高级能力都放在后面，不要一开始扩大范围。

## 技术栈

- 客户端：HarmonyOS ArkTS / ArkUI
- 服务端：Java 17 + Spring Boot 3
- 数据库：SQLite
- 文件存储：服务器本地磁盘

## 重要目录

```text
apps/harmony/   鸿蒙客户端
apps/server/    Java 服务端
docs/           中文文档
packages/api-contract/  接口契约
.github/        GitHub Actions 工作流和可复用 action
```

## 服务端现状

已完成基础 Spring Boot 工程和传输主干。

关键文件：

- `apps/server/src/main/java/com/coursedrop/server/CourseDropApplication.java`
- `apps/server/src/main/java/com/coursedrop/server/room/RoomController.java`
- `apps/server/src/main/java/com/coursedrop/server/transfer/TransferController.java`
- `apps/server/src/main/java/com/coursedrop/server/storage/LocalFileStorageService.java`
- `apps/server/src/main/java/com/coursedrop/server/cleanup/CleanupTask.java`

验证命令：

```powershell
cd D:\works\coursedrop\apps\server
mvn test
```

## 客户端现状

已完成标准鸿蒙工程骨架和首页壳。

关键文件：

- `apps/harmony/build-profile.json5`
- `apps/harmony/AppScope/app.json5`
- `apps/harmony/entry/src/main/module.json5`
- `apps/harmony/entry/src/main/ets/entryability/EntryAbility.ets`
- `apps/harmony/entry/src/main/ets/pages/HomePage.ets`

## 下一步建议

1. 先用 HTTP 客户端或 curl 手动验证服务端 API。
2. 在鸿蒙客户端实现 `ApiClient` 的 GET、POST、multipart 上传能力。
3. 创建 `RoomPage`，展示房间码和传输项列表。
4. 首页创建/加入成功后跳转到 `RoomPage`。
5. 再做文件选择和上传。

## 开发约定

- 文档优先使用中文。
- 根目录 README 保持简洁，只做入口。
- 业务文档放在 `docs/product`、`docs/api`、`docs/architecture`。
- 接手说明、当前状态、下一步计划放在 `docs/agent`。
- CI 说明放在 `docs/agent/ci.md`。
- 服务端按业务域组织代码，不把所有 controller/service/repository 分散到顶层。
- 客户端按 `common`、`models`、`services`、`viewmodels`、`components`、`pages` 分层。
