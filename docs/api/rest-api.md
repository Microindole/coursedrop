# REST API 草案

基础地址：

```text
http://{server}:8080/api
```

## 房间

`/api/rooms` 是早期兼容接口。新的公网中转优先使用 `/api/shares`。

## 健康检查

### 查询中转源状态

```text
GET /api/health
```

返回：

```json
{
  "status": "UP",
  "service": "coursedrop-server",
  "time": "2026-05-25T12:00:00Z"
}
```

## 公网分享

### 创建分享

```text
POST /api/shares
```

请求体：

```json
{
  "expireHours": 24,
  "downloadAuthRequired": true
}
```

### 上传分享项

```text
POST /api/shares/{shareId}/items
Content-Type: multipart/form-data
```

表单字段：

- `file`：上传文件或密文文件
- `encrypted`：是否端到端加密
- `sha256`：文件摘要
- `encryptionAlgorithm`：加密算法，`encrypted=true` 时必填
- `kdfAlgorithm`：密钥派生算法，`encrypted=true` 时必填
- `kdfSalt`：密钥派生 salt，`encrypted=true` 时必填
- `nonce`：加密 nonce/iv，`encrypted=true` 时必填
- `plainSizeBytes`：明文大小，`encrypted=true` 时必填

### 获取分享下载页信息

```text
GET /api/shares/{code}
```

### 浏览器下载

```text
GET /s/{code}
GET /s/{code}/items/{itemId}/download
```

浏览器下载必须登录或通过手机扫码授权。

登录成功后服务端应签发 HttpOnly Cookie。后续浏览器下载请求通过 Cookie 校验身份，不应依赖前端可读 token。

### App 下载

```text
GET /api/shares/{code}/items/{itemId}/download
```

CourseDrop App 可携带设备指纹或账号会话下载。

### 撤回分享

```text
DELETE /api/shares/{shareId}
```

撤回后下载立即失效，服务器删除或等待清理任务删除临时文件。

## 身份与扫码登录

### 注册或刷新设备指纹

```text
POST /api/identity/fingerprints
```

### 创建账号并绑定当前手机指纹

```text
POST /api/accounts
```

### 创建 Web 扫码登录会话

```text
POST /api/auth/web-login
```

返回二维码登录码。浏览器页面用该登录码生成二维码，并轮询登录状态。

### 手机确认 Web 登录

```text
POST /api/auth/web-login/{loginCode}/confirm
```

### 查询 Web 登录状态

```text
GET /api/auth/web-login/{loginCode}
```

确认成功后，服务端为浏览器写入 `CD_SESSION` HttpOnly Cookie。

### 账号密码登录

```text
POST /api/auth/password-login
```

账号密码登录默认不可见。只有用户在手机 CourseDrop 中关闭安全设置后才允许使用。

### 查询分享删除审计

```text
GET /api/shares/{shareId}/audit
```

用于排查分享过期、撤回或清理失败原因。审计不返回文件内容。

### 创建房间

```text
POST /api/rooms
```

请求体：

```json
{
  "name": "移动应用开发第 3 组"
}
```

### 加入房间

```text
POST /api/rooms/{code}/join
```

### 获取房间

```text
GET /api/rooms/{roomId}
```

## 传输项

### 查询房间传输项

```text
GET /api/rooms/{roomId}/items
```

### 上传文件

```text
POST /api/files/upload
Content-Type: multipart/form-data
```

表单字段：

- `roomId`：房间 ID
- `file`：上传文件

### 下载文件

```text
GET /api/files/{itemId}/download
```

## 后续接口

### 上传剪贴板片段

```text
POST /api/clipboard
```

### 查询剪贴板片段

```text
GET /api/clipboard?roomId={roomId}
```

### 删除传输项

```text
DELETE /api/items/{itemId}
```
