# WebSocket 事件草案

WebSocket 不在第一阶段实现，先保留事件设计。

## 客户端发送

### join_room

加入房间实时通道。

```json
{
  "type": "join_room",
  "payload": {
    "roomId": "room-id",
    "deviceName": "MatePad"
  }
}
```

### heartbeat

设备心跳。

```json
{
  "type": "heartbeat",
  "payload": {
    "roomId": "room-id",
    "deviceId": "device-id"
  }
}
```

## 服务端发送

### room_member_joined

有设备加入房间。

### item_created

房间内出现新的文件、图片、文本或链接。

### item_deleted

传输项被删除或过期清理。

### room_expiring

房间即将过期。

