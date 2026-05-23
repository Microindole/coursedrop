# Agent 接手指南

这份文档用于让新的 agent 或开发者快速接手 CourseDrop。

## 项目一句话

CourseDrop / 课递：本地优先的加密文件传输与分享管理工具。

## 当前重点

当前先把鸿蒙客户端的信息架构跑通，再接真实传输能力：

```text
模型层 -> mock viewmodel -> 页面骨架 -> services -> 真实传输
```

局域网直传、公网临时中转、二维码分享和端到端加密是产品主线，但不要在页面结构稳定前直接堆真实能力。

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

已完成标准鸿蒙工程骨架、首页壳、通用组件层和 CourseDrop 业务组件层。

关键文件：

- `apps/harmony/build-profile.json5`
- `apps/harmony/AppScope/app.json5`
- `apps/harmony/entry/src/main/module.json5`
- `apps/harmony/entry/src/main/ets/entryability/EntryAbility.ets`
- `apps/harmony/entry/src/main/ets/pages/HomePage.ets`
- `apps/harmony/entry/src/main/ets/components/`
- `apps/harmony/entry/src/main/ets/components/business/`

## 下一步建议

详细任务见 `docs/agent/next-steps.md`。

建议顺序：

1. 稳定客户端模型层。
2. 用 mock viewmodel 驱动页面。
3. 搭建首页、分享页、本地库、设备页、设置页骨架。
4. 页面结构稳定后接入 services。
5. 再接真实传输、局域网发现和端到端加密。

## 开发约定

- 文档优先使用中文。
- 根目录 README 保持简洁，只做入口。
- 业务文档放在 `docs/product`、`docs/api`、`docs/architecture`。
- 接手说明、当前状态、下一步计划放在 `docs/agent`。
- CI 说明放在 `docs/agent/ci.md`。
- 模块职责和边界放在 `docs/architecture/module-boundaries.md`。
- 客户端 UI 规范放在 `docs/architecture/client-ui.md`。
- 服务端按业务域组织代码，不把所有 controller/service/repository 分散到顶层。
- 客户端按 `common`、`models`、`services`、`viewmodels`、`components`、`pages` 分层。
