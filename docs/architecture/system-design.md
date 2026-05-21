# 系统设计

## 总体结构

```text
鸿蒙 ArkTS 客户端
        |
        | REST：房间、上传、下载、剪贴板
        | WebSocket：房间事件、在线状态
        |
Java Spring Boot 服务端
        |
        | 元数据
        v
SQLite / MySQL
        |
        | 文件内容
        v
服务器本地磁盘
```

## 当前实现策略

第一版只做服务器中转，不做局域网直传。

原因：

- 端到端传输链路更容易先跑通
- 鸿蒙客户端可以尽快接入真实 API
- 后续增加局域网直传时，可以复用房间、传输项和历史记录模型

## Monorepo 结构

```text
apps/
  harmony/   鸿蒙原生客户端
  server/    Java Spring Boot 服务端
packages/
  api-contract/  REST 和 WebSocket 契约
docs/
  agent/         Agent 接手指南
  api/           接口文档
  architecture/  架构和数据模型
  product/       产品说明和路线图
deploy/          部署配置
scripts/         本地脚本
```

## 服务端模块

服务端按业务域组织，而不是把所有 controller、service、repository 分散到顶层。

```text
common/     通用异常和返回处理
config/     配置、数据库初始化
room/       房间创建、加入、过期校验
transfer/   传输项、上传、下载、列表
storage/    本地文件存储
cleanup/    过期清理任务
```

计划中的模块：

```text
clipboard/  剪贴板文本和链接
device/     设备信息、在线心跳
websocket/  房间实时事件
```

## 客户端模块

```text
common/        常量、主题
components/    通用 ArkUI 组件
entryability/  应用入口
models/        API 数据模型
pages/         页面
services/      API 和设备能力封装
viewmodels/    页面状态与展示逻辑
```

