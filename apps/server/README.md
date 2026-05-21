# Java 服务端

CourseDrop 的 Java Spring Boot 服务端，负责临时房间、服务器中转上传下载、限时存储和过期清理。

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

- `POST /api/rooms`
- `POST /api/rooms/{code}/join`
- `GET /api/rooms/{roomId}`
- `GET /api/rooms/{roomId}/items`
- `POST /api/files/upload`
- `GET /api/files/{itemId}/download`

