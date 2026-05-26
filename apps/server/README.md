# Java 服务端

CourseDrop 的 Java Spring Boot 服务端，负责公网限时中转、浏览器下载、设备指纹身份、扫码登录和过期清理。当前房间接口是早期兼容层。

## 技术栈

- Java 17
- Spring Boot 3
- Thymeleaf
- Tailwind CDN
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

- `GET /`
- `GET /api/health`
- `POST /api/identity/fingerprints`
- `POST /api/accounts`
- `GET /api/accounts/{accountId}`
- `POST /api/accounts/{accountId}/security`
- `POST /api/accounts/{accountId}/password`
- `GET /api/accounts/{accountId}/fingerprints`
- `POST /api/accounts/{accountId}/fingerprints`
- `DELETE /api/accounts/{accountId}/fingerprints/{fingerprintId}`
- `POST /api/auth/web-login`
- `POST /api/auth/web-login/{loginCode}/confirm`
- `GET /api/auth/web-login/{loginCode}`
- `GET /api/auth/web-login/{loginCode}/qr.svg`
- `POST /api/auth/web-login/password`
- `POST /api/auth/web-login/logout`
- `DELETE /api/auth/web-login/{loginCode}`
- `GET /api/auth/web-login/sessions`
- `POST /api/shares`
- `GET /api/shares`
- `GET /api/shares/{code}`
- `POST /api/shares/{shareId}/items`
- `GET /api/shares/{code}/items/{itemId}/download`
- `DELETE /api/shares/{shareId}`
- `POST /api/shares/{shareId}/expiry`
- `DELETE /api/shares/{shareId}/items/{itemId}`
- `GET /api/shares/{shareId}/audit`
- `GET /api/health/capabilities`
- `GET /s/{code}`
- `GET /s/{code}/items/{itemId}/download`
- `POST /api/rooms`
- `POST /api/rooms/{code}/join`
- `GET /api/rooms/{roomId}`
- `GET /api/rooms/{roomId}/items`
- `POST /api/files/upload`
- `GET /api/files/{itemId}/download`

## 当前补齐情况

- `/s/{code}` 下载页已接入真实 QR SVG、登录状态轮询和授权后下载按钮启用。
- `/` 首页已接入服务状态、分享码入口、健康检查入口和服务器能力概览。
- 分享下载策略已使用 `downloadPolicy`：`PUBLIC`、`LOGIN_REQUIRED`、`OWNER_ONLY`。
- Web 登录会话已支持 Cookie 签发、账号密码例外登录、退出登录、撤销、会话列表。
- 账号安全设置已支持开关账号密码登录、修改密码、绑定和解绑设备指纹。
- 浏览器下载页已支持使用 URL fragment 中的 `#key=` 对 AES-GCM 加密文件做本地 WebCrypto 解密。
- Web 端认证成功后可以直接把文件下载到当前电脑浏览器。
- App 下载接口已支持设备指纹和账号身份鉴权。
- 分享管理已支持我的分享列表、状态筛选、续期、删除单个分享项。
- 清理任务已支持孤儿文件扫描和 `CLEANUP_FAILED` 审计。
- 数据库初始化已收敛为带版本表的轻量迁移服务 `DatabaseMigrationService`。
- 公网部署基础配置已包含 `secure-cookie`、CORS allowed origins 和 public base URL。

## 后续增强

- 端到端加密协议需要和鸿蒙客户端一起落地，包括客户端加密、解密和完整性校验。
- 生产部署建议继续接入成熟迁移工具 Flyway 或 Liquibase。
- 限流目前是进程内实现，生产环境可换成 Redis 或网关限流。
