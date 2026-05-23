# CourseDrop UI 组件

这里放项目内部封装的轻量 ArkUI 组件。组件参考 `PageAndData` 鸿蒙原生教程的页面规范：浅灰页面底色、12vp 页面边距、26fp 页面标题、16vp 白色功能区、40vp 胶囊按钮、列表和宫格承载主要操作。全部使用 ArkUI 原生实现，不依赖现成 UI 库。

## 目录结构

```text
components/
  index.ets       统一导出入口
  actions/        按钮、图标按钮、链接、操作宫格
  inputs/         输入框、开关等表单控件
  layout/         页面、滚动容器、面板、标题分区
  navigation/     抽屉、底部标签栏等导航外壳
  display/        文本、列表、文件项、信息行、轮播
  feedback/       状态标签、空状态、后续弹窗/进度
```

页面侧优先从 `../components` 导入，不直接引用子目录：

```ts
import { CdButton, CdPanel, CdTextField } from '../components';
```

## 风格原则

- 页面底色使用 `AppColors.BACKGROUND`，功能区使用白色 `CdPanel`。
- 常规页面优先使用 `CdScrollContainer` 或 `CdPage` 承载，不在页面里重复写整页背景和边距。
- 页面标题使用 `CdPageTitle`，分区标题使用 `CdSectionHeader`。
- 主要操作用 40vp 胶囊按钮；高频入口用 `CdActionTile` 宫格。
- 列表项、状态标签、输入框、开关不要在页面里重复写样式。
- 组件只负责展示和基础交互，不直接请求接口。

## 组件清单

### actions

- `CdButton`：统一按钮，支持 `contained`、`tonal`、`text`、`danger`。
- `CdIconButton`：仅图标按钮，用于顶部栏、列表操作和抽屉关闭。
- `CdLink`：文本链接，可选图标。
- `CdActionTile`：宫格操作入口，例如本地发送、公网分享、分享管理。

### inputs

- `CdTextField`：下划线输入框，支持 label、placeholder 和字符串双向绑定。
- `CdSwitchRow`：设置项开关行，支持标题、说明和布尔双向绑定。

### layout

- `CdPage`：非滚动整页容器。
- `CdScrollContainer`：滚动页面容器，统一页面背景、边距和滚动条策略。
- `CdPanel`：白色圆角功能面板。
- `CdPageTitle`：页面主标题和副标题。
- `CdSectionHeader`：分区标题，支持右侧文字操作。

### navigation

- `CdDrawer`：抽屉遮罩外壳，适合后续放服务器设置、筛选、文件详情。
- `CdTabBar`：底部标签栏外壳，适合后续“首页 / 分享 / 设置”主导航。

### display

- `CdText`：统一文字样式，支持 title、subtitle、body、caption、muted。
- `CdList`：统一列表容器。
- `CdListItem`：通用列表项，支持图标、标题、说明和箭头。
- `CdFileItem`：文件/图片/文本/链接传输项。
- `CdInfoRow`：带图标的信息行。
- `CdCarousel`：轮播图容器，后续可用于引导页、分享状态说明或教程卡片。

### feedback

- `CdStatusPill`：状态标签，支持 info、success、warning。
- `CdEmptyState`：空状态，用于暂无文件、暂无分享记录、未发现局域网设备等场景。

## 扩展计划

```text
feedback/CdProgressRow.ets   上传/下载进度行
feedback/CdToastBanner.ets   页面内提示条
display/CdShareCode.ets      二维码和分享码展示
display/CdDeviceItem.ets     局域网设备列表项
layout/CdTopBar.ets          页面顶部栏
```
