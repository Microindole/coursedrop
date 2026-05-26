# 客户端服务层设计

CourseDrop 客户端从页面层进入 services 阶段。页面只调用 viewmodel，viewmodel 再调用 services；services 负责本地索引、文件库、公网中转源、设备发现和传输任务。

## 文件管理方向

CourseDrop 不做传统目录树文件管理器。

文件仍应落在应用专属目录中，例如：

```text
CourseDrop/
  library/       应用管理的本地文件副本
  incoming/      接收内容
  staging/       待上传、待加密、待打包内容
  cache/         公网中转临时缓存
```

后续真实实现应使用 SQLite 保存索引，不把目录结构直接暴露为主交互模型。

建议索引维度：

- 文件类型：文件、图片、文本、链接
- 交互对象：来自哪个设备、发给哪个设备、通过哪个分享会话产生
- 分享状态：仅本地、公网副本有效、已撤回、已过期
- 安全状态：明文本地项、端到端加密项、待加密项
- 生命周期：创建时间、最后分享时间、过期时间、清理策略

当前服务层已经拆成接口、仓储和实现。页面不能直接制造演示数据；未接入系统能力的位置应返回空状态或明确失败原因，后续直接替换仓储实现。

应用专属目录由 `EntryAbility` 启动时把 `this.context.filesDir` 写入 `AppRuntimeContext`，服务层基于真实应用沙箱根目录推导本地库路径。Ability 启动期不直接导入 services，避免启动阶段初始化业务单例。

公网服务地址不再有默认本地地址。`RelaySourceService` 负责维护多中转源，并把当前最高优先级的启用源同步到 `ApiClient`。

## 当前服务

```text
services/
  ApiClient.ets                公网中转 HTTP 客户端基础配置
  ShareService.ets             分享服务兼容导出
  LocalLibraryService.ets      本地库服务兼容导出
  RelaySourceService.ets       中转源服务兼容导出
  DeviceDiscoveryService.ets   设备发现服务兼容导出
  TransferService.ets          传输项接口占位

  share/
    ShareService.ets           分享领域接口
    ShareSessionRepository.ets 分享会话仓储
    TransferTaskRepository.ets 传输任务仓储
    LocalShareService.ets      分享业务实现
    RelayShareApi.ets          公网分享 API 封装

  local/
    LocalLibraryService.ets    本地库领域接口
    LocalFileIndexRepository.ets 本地文件索引仓储
    CourseDropFileStore.ets    应用专属文件目录抽象
    IndexedLocalLibraryService.ets 本地库业务实现

  relay/
    RelaySourceService.ets     中转源领域接口
    RelaySourceRepository.ets  中转源仓储
    ConfigurableRelaySourceService.ets 中转源业务实现
    RelayHealthService.ets     中转源健康检查和能力探测

  identity/
    IdentityService.ets        设备指纹注册和本机身份状态
    IdentityRepository.ets     本机身份仓储

  device/
    DeviceDiscoveryService.ets 设备发现领域接口
    DeviceRegistry.ets         设备注册表
    LanDeviceDiscoveryService.ets 局域网发现业务实现
```

## 替换路线

1. `RelaySourceRepository` 接首选项持久化。
2. `LocalFileIndexRepository` 接 SQLite 索引。
3. `CourseDropFileStore` 接应用沙箱目录、文件选择器和导入流程。
4. `ApiClient` 已接入 HarmonyOS HTTP 能力，使用启用的中转源作为 base URL。
5. `RelayHealthService` 已可探测 `/api/health` 和 `/api/health/capabilities`。
6. `IdentityService` 已可调用 `/api/identity/fingerprints` 注册或刷新本机指纹身份，并可用输入的网页登录码调用 `/api/auth/web-login/{loginCode}/confirm` 模拟扫码确认。
7. `ShareService` 已可调用 `/api/shares` 创建公网分享码；上传、续期、撤回继续接后端接口。
8. `DeviceDiscoveryService` 接局域网发现和公网在线状态。
9. `TransferService` 接上传、下载、局域网直传和公网 fallback。
