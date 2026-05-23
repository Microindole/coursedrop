# 客户端 UI 规范

CourseDrop 客户端参考 MUI 的产品界面风格，但不直接依赖 MUI。

原因：

- MUI 是 Web 生态组件库，不适用于鸿蒙 ArkTS 原生工程。
- 鸿蒙端优先使用 ArkUI 原生组件，避免第三方 UI 库兼容风险。
- 项目内部沉淀一层轻量 CourseDrop UI 组件，保证页面一致性。

## 设计方向

- 轻量、清晰、工具型
- 以白色 surface、浅灰背景和蓝色主操作建立层级
- 使用 8px 间距体系
- 表单、按钮、状态标签、列表项组件化
- 页面只组合业务组件，不裸写复杂样式

## 组件策略

禁止在页面中散落颜色、字号、圆角和复杂按钮样式。

允许：

- 页面使用 `Theme.ets` 中的 token
- 页面组合 `components/` 中的通用组件
- 业务页面拥有少量布局代码

不允许：

- 每个页面自己定义一套颜色
- 每个页面自己写按钮样式
- 业务逻辑写进通用组件
- 为了 UI 引入重型跨平台框架

## 当前 UI 模块

```text
common/
  Theme.ets          颜色、间距、圆角、字号 token
components/
  README.md          组件目录说明
  CdButton.ets       CourseDrop 按钮
  CdTextField.ets    CourseDrop 输入框
  CdStatusPill.ets   状态标签
pages/
  HomePage.ets       首页入口
```

## 后续组件计划

```text
CdTopBar.ets
CdRoomHeader.ets
CdFileItem.ets
CdEmptyState.ets
CdProgressRow.ets
CdSectionHeader.ets
```

## 命名约定

通用 UI 组件统一使用 `Cd` 前缀，例如 `CdButton`、`CdTextField`。

页面组件使用业务名，例如 `HomePage`、`RoomPage`。

组件目录内必须维护 `README.md`，说明组件职责、使用场景和扩展规则。
