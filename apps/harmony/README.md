# 鸿蒙客户端

CourseDrop 的原生鸿蒙客户端，使用 ArkTS / ArkUI，Stage 模型。

## 目录结构

```text
AppScope/          应用级元数据和资源
entry/             Entry HAP 模块
  src/main/ets/
    common/        常量、主题
    components/    通用 ArkUI 组件
    entryability/  UIAbility 入口
    models/        API 数据模型
    pages/         页面
    services/      API 和设备能力封装
    viewmodels/    页面状态
```

## 当前状态

已初始化标准鸿蒙工程骨架，并完成首页壳：

- 应用入口：`entry/src/main/ets/entryability/EntryAbility.ets`
- 首页：`entry/src/main/ets/pages/HomePage.ets`
- 模型：`Room`、`TransferItem`
- 服务占位：`ApiClient`、`RoomService`、`TransferService`

## 下一步

- 用鸿蒙网络 API 接入服务端 REST 接口
- 创建房间后进入房间页
- 加入房间后进入房间页
- 实现房间传输项列表
- 实现文件选择和上传

