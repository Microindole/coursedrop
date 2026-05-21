# REST API 草案

基础地址：

```text
http://{server}:8080/api
```

## 房间

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

