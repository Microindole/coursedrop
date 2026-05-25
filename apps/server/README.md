# Java 服务端

CourseDrop 的 Java Spring Boot 服务端，负责公网限时中转、浏览器下载、设备指纹身份、扫码登录和过期清理。当前房间接口是早期兼容层。

## 技术栈

- Java 17
- Spring Boot 3
- SQLite
- 本地磁盘文件存储
- Maven

## 当前模块

```text
common/     通用异常和错误响应
config/     配置、数据库初始化
health/     中转源健康检查
identity/   设备指纹、账号和绑定
auth/       Web 扫码登录会话
share/      公网限时分享和分享项
download/   浏览器下载页和下载入口
room/       房间创建、加入和校验
transfer/   文件上传、下载、列表
storage/    本地文件存储
cleanup/    过期清理
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
- `GET /s/{code}`
- `GET /s/{code}/items/{itemId}/download`
- `POST /api/rooms`
- `POST /api/rooms/{code}/join`
- `GET /api/rooms/{roomId}`
- `GET /api/rooms/{roomId}/items`
- `POST /api/files/upload`
- `GET /api/files/{itemId}/download`
