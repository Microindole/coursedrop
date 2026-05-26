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
```

## 替换路线

1. `RelaySourceRepository` 接首选项持久化。
2. `LocalFileIndexRepository` 接 SQLite 索引。当前运行期实现只保留内存状态，但已经返回拷贝，避免页面或服务层直接修改仓储内部数组。
3. `CourseDropFileStore` 已按应用沙箱根目录推导 `library/incoming/staging/cache`，后续补目录创建和真实文件复制。
4. `ApiClient` 已接入 HarmonyOS HTTP 能力，使用启用的中转源作为 base URL。
5. `RelayHealthService` 已可探测 `/api/health` 和 `/api/health/capabilities`。
6. `IdentityService` 已可调用 `/api/identity/fingerprints` 注册或刷新本机指纹身份，并可用输入的网页登录码调用 `/api/auth/web-login/{loginCode}/confirm` 模拟扫码确认。
7. `ShareService` 已可调用 `/api/shares` 创建公网分享码；上传、续期、撤回继续接后端接口。
8. `ShareDraftWorkflow` 已把“选择文件 -> 导入索引 -> 加入分享草稿”串成独立编排。页面只表达用户意图，不直接访问 picker 或仓储。
9. `FilePickerService` 负责系统文件选择器，未接入时必须明确失败，不能返回假文件。
10. `FileImportService` 负责把选择结果写入本地索引；真实文件复制和目录创建在文件系统能力接入后补齐。
11. `ShareService` 已提供 `attachLocalFile` 和 `markItemUploaded`。本地草稿项保留本地 id，上传成功后单独记录 `remoteItemId/remoteUrl/expiresAt`，避免上传任务、本地索引和远端项互相覆盖。
12. `TransferTaskService` 已提供传输任务状态机：创建、开始、进度、完成、失败、取消。
13. `RelayTransferApi` 是公网中转上传/下载边界；multipart 上传和下载保存接入后替换当前明确失败实现。
14. `EncryptionService` 是端到端加密边界；真实 AES-GCM/密钥派生接入前不能伪造已加密结果。
15. `DeviceDiscoveryService` 接局域网发现和公网在线状态。
