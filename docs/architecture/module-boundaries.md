# 模块边界

这份文档说明各模块负责什么，以及不应该负责什么。

## Monorepo 边界

```text
apps/harmony/          鸿蒙客户端
apps/server/           Java 服务端
packages/api-contract/ API 契约
docs/                  文档
deploy/                部署配置
scripts/               本地辅助脚本
.github/               CI 工作流和复用 action
```

## 服务端边界

### common

职责：

- 通用异常
- 通用错误响应
- 跨模块共享的小工具

不放：

- 业务逻辑
- 数据库访问

### config

职责：

- Spring 配置
- 配置属性
- 数据库初始化

不放：

- Controller
- 业务流程

### room

职责：

- 创建房间
- 加入房间
- 房间码生成
- 房间是否过期的校验

不放：

- 文件落盘
- 上传下载细节
- 剪贴板内容处理

### transfer

职责：

- 传输项模型
- 上传文件生成传输项
- 查询房间传输项
- 下载传输项

不放：

- 本地磁盘路径细节
- WebSocket 推送细节

### storage

职责：

- 文件保存
- 文件路径解析
- 文件删除

不放：

- 房间业务
- 传输项业务

### cleanup

职责：

- 定时清理过期传输项
- 删除过期文件
- 删除过期房间

不放：

- 手动删除接口
- 业务查询接口

### 后续模块

```text
clipboard/  剪贴板文本、链接和代码片段
device/     设备注册、心跳、在线状态
websocket/  房间实时事件推送
```

## 客户端边界

### common

职责：

- App 配置
- 主题颜色
- 通用常量

### models

职责：

- 与 API 对齐的数据类型
- 页面之间传递的轻量结构

不放：

- 网络请求
- UI 逻辑

### services

职责：

- REST 请求
- CourseDrop 应用专属文件库索引
- 文件选择、上传、下载
- 中转源配置、设备发现
- 剪贴板、存储等系统能力封装

不放：

- 页面布局
- 长段 UI 状态

说明：

- 客户端已经移除独立演示数据层，页面数据必须通过 services 进入 viewmodels。
- services 按领域拆成接口、仓储和实现；页面只依赖 viewmodels，viewmodels 只依赖 service 接口或单例入口。
- 文件管理不是传统目录树，而是应用专属目录 + SQLite 索引 + 类型/对象/状态视图。
- 后续替换真实文件 API、SQLite、HTTP、局域网发现时，优先替换 service 实现，不改页面结构。

### viewmodels

职责：

- 页面状态
- 表单校验
- 调用 service 后整理成页面可展示状态

### pages

职责：

- 页面结构
- 页面级事件绑定
- 导航

不放：

- 复杂网络细节
- 文件存储细节

### components

职责：

- 可复用 UI 组件
- 不绑定具体业务数据源
- 统一使用 `Cd` 前缀
- 组件样式从 `common/Theme.ets` 读取
- 目录内维护组件说明文档

不放：

- 页面级业务流程
- 网络请求
- 临时随手写的单页样式

## API 契约边界

`packages/api-contract` 用于放 OpenAPI、事件 schema 等跨端契约。

当客户端和服务端字段不一致时，优先更新契约，再同步两端实现。
