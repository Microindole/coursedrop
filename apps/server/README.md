# Java 服务端

CourseDrop 的 Java Spring Boot 服务端，负责公网限时中转、浏览器下载、设备指纹身份、扫码登录和过期清理。当前房间接口是早期兼容层。

## 技术栈

- Java 17
- Spring Boot 3
- SQLite
- MyBatis-Plus
- 本地磁盘文件存储
- Maven

## 当前模块

```text
controller/ HTTP 接口入口
dto/        请求、响应和页面数据对象
enums/      业务枚举
service/    业务逻辑编排
mapper/     MyBatis-Plus 数据访问
entity/     数据库实体
common/     通用异常和错误响应
config/     配置、数据库初始化

auth/       Web 扫码登录内部会话对象
share/      公网限时分享内部记录
storage/    本地文件存储
security/   密码哈希等安全工具
room/       早期房间兼容模型
transfer/   早期传输兼容模型
```

## 运行

```powershell
mvn test
mvn spring-boot:run
```

默认端口：

```text
8080
```

默认配置在：

```text
src/main/resources/application.yml
```

## 当前已实现接口

- `GET /api/health`
- `POST /api/identity/fingerprints`
- `POST /api/accounts`
- `POST /api/auth/web-login`
- `POST /api/auth/web-login/{loginCode}/confirm`
- `GET /api/auth/web-login/{loginCode}`
- `POST /api/shares`
- `GET /api/shares/{code}`
- `POST /api/shares/{shareId}/items`
- `GET /api/shares/{code}/items/{itemId}/download`
- `DELETE /api/shares/{shareId}`
- `GET /api/shares/{shareId}/audit`
- `GET /s/{code}`
- `GET /s/{code}/items/{itemId}/download`
- `POST /api/rooms`
- `POST /api/rooms/{code}/join`
- `GET /api/rooms/{roomId}`
- `GET /api/rooms/{roomId}/items`
- `POST /api/files/upload`
- `GET /api/files/{itemId}/download`

## 待补齐能力

- `/s/{code}` 下载页需要补真实二维码、登录状态轮询脚本和授权后的下载状态刷新。
- Web 登录会话需要补退出登录、手机端撤销、会话列表和失效管理。
- App 下载鉴权需要补设备指纹/账号会话策略。
- 分享管理需要补我的分享列表、状态筛选、续期、删除单个分享项。
- 清理任务需要补失败重试、孤儿文件扫描和 `CLEANUP_FAILED` 审计。
- 数据库迁移后续建议从 `DatabaseInitializer` 切换到 Flyway 或 Liquibase。
- 公网部署需要补 HTTPS、`Secure=true` Cookie、限流、CORS 和反向代理 base URL 配置。
