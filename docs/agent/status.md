# 当前状态

更新时间：2026-05-23

## 已完成

- 初始化 monorepo：`apps`、`docs`、`packages`、`deploy`、`scripts`
- 初始化 Java Spring Boot 服务端
- 服务端实现房间、文件上传下载、传输项列表、过期清理
- 服务端 `mvn test` 已通过
- 初始化鸿蒙 ArkTS 客户端标准工程骨架
- 客户端完成首页壳和基础分层
- 客户端建立 `components/` 通用 UI 组件层
- 客户端建立 `components/business/` CourseDrop 业务组件层
- 客户端建立分享领域模型层
- 客户端开始建立 mock 数据和 viewmodel 层
- 文档改为中文，并新增 agent 接手目录
- 新增模块化 GitHub Actions：文档检查、服务端测试、鸿蒙工程结构检查
- 新增下一步任务拆解和模块边界文档
- 客户端开始建立参考 MUI 的 CourseDrop UI 轻量组件层

## 未完成

- 服务端接口手动联调
- 服务端 WebSocket
- 服务端剪贴板片段
- 鸿蒙客户端真实网络请求
- 鸿蒙客户端页面跳转
- 鸿蒙客户端文件选择和上传
- 客户端 SharePage、LocalLibraryPage、DevicePage、SettingsPage
- 客户端页面骨架
- 部署到 2 核 2G 服务器
- 鸿蒙 HAP 在 CI 中完整构建

## 当前建议优先级

详见 `docs/agent/next-steps.md`。

当前顺序：

1. 完成 mock viewmodel 覆盖。
2. 搭建首页、分享页、本地库、设备页、设置页骨架。
3. 页面结构稳定后接入 services。
4. 再接真实传输、局域网发现和端到端加密。
