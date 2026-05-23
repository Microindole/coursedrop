# CourseDrop / 课递

面向课程小组的资料快传与临时存储工具。

## 目录

- [产品说明](docs/product/overview.md)
- [开发路线](docs/product/roadmap.md)
- [系统设计](docs/architecture/system-design.md)
- [数据模型](docs/architecture/data-model.md)
- [模块边界](docs/architecture/module-boundaries.md)
- [客户端 UI 规范](docs/architecture/client-ui.md)
- [REST API 草案](docs/api/rest-api.md)
- [WebSocket 事件草案](docs/api/websocket-events.md)
- [Agent 接手指南](docs/agent/handbook.md)
- [下一步任务拆解](docs/agent/next-steps.md)
- [CI 说明](docs/agent/ci.md)
- [鸿蒙客户端](apps/harmony/README.md)
- [Java 服务端](apps/server/README.md)

## 当前阶段

先做服务器中转传输 MVP：

```text
创建房间 -> 加入房间 -> 上传文件 -> 查看房间文件 -> 下载文件 -> 过期清理
```
