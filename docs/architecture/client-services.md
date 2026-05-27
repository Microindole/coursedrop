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

轻量配置使用 Preferences 持久化，当前包括中转源、本机身份和设置策略。结构化业务数据，例如本地文件索引、分享草稿和传输任务，后续使用 RDB/SQLite，不放入 Preferences。

公网服务地址不再有默认本地地址。`RelaySourceService` 负责维护多中转源，并把当前最高优先级的启用源同步到 `ApiClient`。

## 当前服务

```text
services/
  ApiClient.ets                公网中转 HTTP 客户端基础配置
  common/AppPreferencesStore.ets Preferences 封装，持久化轻量配置
  common/AppRdbStore.ets       RDB/SQLite 连接封装
  ShareService.ets             分享服务兼容导出
  LocalLibraryService.ets      本地库服务兼容导出
  RelaySourceService.ets       中转源服务兼容导出
  DeviceDiscoveryService.ets   设备发现服务兼容导出
  TransferService.ets          传输项接口占位

  share/
    ShareService.ets           分享领域接口
    ShareDraftWorkflow.ets     文件选择、导入、挂载到分享草稿的编排
    ShareSessionRepository.ets 分享会话仓储
    TransferTaskRepository.ets 传输任务仓储
    LocalShareService.ets      分享业务实现
    RelayShareApi.ets          公网分享 API 封装

  local/
    LocalLibraryService.ets    本地库领域接口
    LocalFileIndexRepository.ets 本地文件索引仓储
    CourseDropFileStore.ets    应用专属文件目录抽象
    IndexedLocalLibraryService.ets 本地库业务实现

  file/
    FilePickerService.ets      系统文件选择器边界
    FileImportService.ets      选择文件导入和索引写入边界
    FileSystemService.ets      文件元数据、复制和读取能力
    LocalFileImportWorkflow.ets 本地库导入编排
    FileTypeResolver.ets       MIME/文件名到业务类型的解析
    FileModels.ets             文件选择和导入 DTO

  relay/
    RelaySourceService.ets     中转源领域接口
    RelaySourceRepository.ets  中转源仓储
    ConfigurableRelaySourceService.ets 中转源业务实现
    RelayHealthService.ets     中转源健康检查和能力探测

  identity/
    IdentityService.ets        设备指纹注册和本机身份状态
    IdentityRepository.ets     本机身份仓储

  settings/
    SettingsService.ets        安全、过期和缓存策略服务
    SettingsRepository.ets     设置项 Preferences 仓储
    SettingsModels.ets         设置 DTO 和枚举

  device/
    DeviceDiscoveryService.ets 设备发现领域接口
    DeviceRegistry.ets         设备注册表
    LanDeviceDiscoveryService.ets 局域网发现业务实现

  transfer/
    TransferService.ets        上传/下载编排服务
    TransferTaskService.ets    传输任务状态机
    TransferTaskRepository.ets 传输任务仓储
    RelayTransferApi.ets       公网中转上传/下载 API 边界
    TransferModels.ets         上传/下载 DTO

  crypto/
    EncryptionService.ets      端到端加解密边界
    CryptoModels.ets           加解密 DTO

  scan/
    QrPayloadParser.ets        二维码内容解析
    ScanDispatchService.ets    扫码结果分发到登录/分享流程
    CameraScanService.ets      系统相机入口边界
```

## 替换路线

1. `RelaySourceRepository` 已接 Preferences 持久化，中转源重启后保留。
2. `LocalFileIndexRepository` 已有 RDB/SQLite 仓储实现，并保留同步内存缓存供页面读取。后续需要补 RDB 初始化完成后的页面刷新事件。
3. `CourseDropFileStore` 已按应用沙箱根目录推导 `library/incoming/staging/cache`，`FileImportService` 导入时会复制到 `library`。
4. `ApiClient` 已接入 HarmonyOS HTTP 能力，使用启用的中转源作为 base URL。
5. `RelayHealthService` 已可探测 `/api/health` 和 `/api/health/capabilities`。
6. `IdentityService` 已可调用 `/api/identity/fingerprints` 注册或刷新本机指纹身份，本机身份已接 Preferences 持久化，并可用输入的网页登录码调用 `/api/auth/web-login/{loginCode}/confirm` 模拟扫码确认。
7. `SettingsService` 已持久化 E2EE、局域网优先、默认过期时间和缓存策略。
8. `ShareService` 已可调用 `/api/shares` 创建公网分享码；上传、续期、撤回继续接后端接口。
9. `ShareDraftWorkflow` 已把“选择文件 -> 导入索引 -> 加入分享草稿”串成独立编排。页面只表达用户意图，不直接访问 picker 或仓储。
10. `FilePickerService` 已接入 `DocumentViewPicker`，当前依赖系统返回的 URI，并从 URI/文件名推断显示名和类型。
11. `LocalFileImportWorkflow` 已把本地库“导入文件/图片”串到 `FilePickerService -> FileImportService -> LocalFileIndexRepository`。本地库页面只调用 ViewModel，不直接访问 picker 或仓储。
12. `LocalFileImportWorkflow` 还提供开发用 `createDebugTextFile`，用于在模拟器文件选择器不可用时真实写入 CourseDrop/library 并写入索引；它不是假数据，后续可隐藏到调试入口。
13. `FileImportService` 负责读取文件元数据、复制到 `CourseDrop/library`，并把本地副本写入 RDB 索引。
14. `ShareService` 已提供 `attachLocalFile` 和 `markItemUploaded`。本地草稿项保留本地 id，上传成功后单独记录 `remoteItemId/remoteUrl/expiresAt`，避免上传任务、本地索引和远端项互相覆盖。
15. `TransferTaskService` 已提供传输任务状态机：创建、开始、进度、完成、失败、取消。
16. `RelayTransferApi` 已实现 multipart 上传到 `/api/shares/{shareId}/items`，App 下载会携带本机指纹或账号鉴权头。
17. `ShareViewModel` 创建公网分享后会遍历草稿项发起上传任务，上传状态由 `TransferTaskService` 管理。
18. `QrPayloadParser` 可识别网页登录二维码 `/m/login/{code}`、分享链接 `/s/{code}`、`login:` 和 `share:` 前缀；`ScanDispatchService` 已能分发网页登录确认。
19. `EncryptionService` 已替换早期占位逻辑，使用 `cryptoFramework` 做 AES-256-GCM 加密、解密和 SHA-256 摘要。
20. E2EE 上传不会把 content key 上传给服务器。服务器只保存密文和 nonce/authTag 等元数据；分享二维码链接通过 URL fragment 携带 `cdkey`，浏览器请求不会把 fragment 发送到服务器。
21. App 内下载会解析分享链接中的 `#cdkey=`，下载密文后在本地解密，再写入 `incoming/` 并建立本地库索引。
22. `CameraScanService` 已提供系统相机入口。当前 OpenHarmony SDK 未提供通用二维码解码 API，因此相机入口只负责打开系统相机并返回拍摄 URI；二维码文本解析仍由 `ScanDispatchService` 处理，后续可替换为厂商 Scan Kit 或自研图像解码实现。
23. `DeviceDiscoveryService` 已改为异步局域网发现边界，`LanDeviceDiscoveryService` 使用 UDP 广播发送 CourseDrop 发现报文并收集同协议节点，不再在页面中制造假设备或 setTimeout 假扫描。
