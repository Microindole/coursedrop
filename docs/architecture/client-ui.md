# 客户端 UI 规范

CourseDrop 客户端参考 `PageAndData` 的鸿蒙原生页面组织方式，并吸收 MUI 的产品界面层级，但不直接依赖 MUI 或第三方 UI 库。

原因：

- MUI 是 Web 生态组件库，不适用于鸿蒙 ArkTS 原生工程。
- 鸿蒙端优先使用 ArkUI 原生组件，避免第三方 UI 库兼容风险。
- 项目内部沉淀一层轻量 CourseDrop UI 组件，保证页面一致性。

## 设计方向

- 轻量、清晰、工具型
- 以白色 surface、浅灰背景和蓝色主操作建立层级
- 使用 12vp 页面边距、16vp 白色功能区、40vp 胶囊按钮
- 表单、按钮、状态标签、列表项、弹层、业务卡片组件化
- 页面只组合通用组件和业务组件，不裸写复杂样式

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
  index.ets          统一导出入口
  actions/           按钮、链接、操作宫格
  inputs/            输入、搜索、选择、分段、开关、复选
  layout/            页面、滚动容器、面板、顶部条、标题分区
  navigation/        抽屉、底部标签栏
  display/           文本、列表、文件项、消息、分页、信息行、轮播
  feedback/          状态、横幅、确认面板、进度、空状态
  business/          分享码、设备、过期、传输、文件操作等业务组件
pages/
  HomePage.ets       首页入口
```

## 页面路线

```text
HomePage             首页入口、统计、最近分享、设备入口
SharePage            分享码、过期状态、文件列表、文件添加入口
LocalLibraryPage     本地分享管理器
DevicePage           局域网设备列表
SettingsPage         服务器、加密、缓存、清理策略
```

## 命名约定

通用 UI 组件统一使用 `Cd` 前缀，例如 `CdButton`、`CdTextField`。

页面组件使用业务名，例如 `HomePage`、`SharePage`、`LocalLibraryPage`。

组件目录内必须维护 `README.md`，说明组件职责、使用场景和扩展规则。
