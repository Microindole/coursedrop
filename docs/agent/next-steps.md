# 下一步任务拆解

这份文档给接手者使用，按当前产品方向列出下一轮最应该做的事情。

## 当前产品方向

CourseDrop / 课递现在定位为：

```text
本地优先的加密文件传输与分享管理工具
```

核心思路：

- 局域网优先直传。
- 公网服务器只做临时中转、二维码分发、设备发现和过期缓存。
- 公网内容应有时效，到期删除。
- 后续接入端到端加密，服务器不应该理解文件明文。
- 客户端不是普通文件管理器，而是以“分享行为、传输状态、过期状态”为核心的可视化管理器。

## P0：稳定客户端模型层

目标：先把页面需要的数据结构定义清楚，后续页面和服务层都围绕这些模型工作。

建议改动范围：

```text
apps/harmony/entry/src/main/ets/models/
```

需要补齐：

- `ShareSession`：一次分享会话，包含分享码、公网链接、过期状态、传输方式、文件列表。
- `Device`：局域网设备，包含平台、在线状态、连接方式、延迟。
- `TransferTask`：上传/下载任务，包含进度、状态、速度、错误信息。
- `LocalFileEntry`：本地分享管理器中的文件项。

验收标准：

- 模型能覆盖首页、分享页、本地库、设备页所需展示数据。
- 保留旧 `Room`、`TransferItem`，但后续页面优先使用新模型。
- 不在模型层写请求逻辑。

## P1：用 viewmodel 驱动页面

目标：先用 services 驱动页面信息架构，不让页面直接接触网络、文件和加密能力。

建议新增：

```text
apps/harmony/entry/src/main/ets/viewmodels/ShareViewModel.ets
apps/harmony/entry/src/main/ets/viewmodels/LocalLibraryViewModel.ets
apps/harmony/entry/src/main/ets/viewmodels/DeviceViewModel.ets
```

验收标准：

- 每个页面的加载、空状态、错误状态、列表数据都有明确字段。
- 页面不直接拼服务数据。
- 页面点击事件先调用 viewmodel 或 toast 占位。

## P2：搭核心页面骨架

目标：使用 `components/` 和 `components/business/` 组件先搭出完整 App 骨架。

建议新增：

```text
apps/harmony/entry/src/main/ets/pages/SharePage.ets
apps/harmony/entry/src/main/ets/pages/LocalLibraryPage.ets
apps/harmony/entry/src/main/ets/pages/DevicePage.ets
apps/harmony/entry/src/main/ets/pages/SettingsPage.ets
```

需要修改：

```text
apps/harmony/entry/src/main/resources/base/profile/main_pages.json
apps/harmony/entry/src/main/ets/pages/HomePage.ets
```

验收标准：

- 首页能看到传输统计、最近分享、局域网设备入口。
- 分享页展示分享码、过期状态、文件列表、文件添加入口。
- 本地库页展示本地文件管理器视角。
- 设备页展示局域网设备列表。
- 设置页展示服务器地址、加密、缓存、清理策略入口。

## P3：接入服务层能力

目标：等页面结构稳定后，再逐步接真实能力。

建议顺序：

1. `ApiClient`：JSON GET/POST。
2. `ShareService`：公网临时分享、撤回、续期。
3. `TransferService`：上传/下载任务。
4. `FileService`：文件选择和本地文件信息。
5. `DeviceDiscoveryService`：局域网设备发现。
6. `CryptoService`：端到端加密/解密。

验收标准：

- 页面只依赖 viewmodel，不直接调 HTTP、文件系统或加密实现。
- services 替换为真实网络、文件系统或数据库实现时，页面结构不用大改。

## P4：服务端按新定位演进

目标：服务端从“房间中转”逐步演进为“限时公网中转、浏览器下载、设备指纹和扫码登录服务”。

当前已落地：

- `health`：健康检查接口，给鸿蒙端测试中转源。
- `share`：分享会话、分享项、分享码、浏览器下载 URL。
- `identity`：设备指纹、账号创建、账号与设备指纹绑定。
- `auth`：Web 扫码登录码、真实 QR SVG、手机确认、浏览器 `CD_SESSION` Cookie、账号密码例外登录、退出和撤销。
- `cleanup`：服务器限时存储、过期删除、撤回删除。
- `download`：浏览器下载页、登录状态轮询、浏览器下载接口、App 身份鉴权下载接口。
- `audit`：分享撤回和过期清理的删除审计。
- `security`：账号密码使用独立 salt 和 PBKDF2 哈希。
- `mapper/entity`：主要 CRUD 已迁到 MyBatis-Plus，`dto/`、`enums/` 已集中。
- `migration`：数据库初始化已收敛为带版本表的轻量迁移服务。
- `management`：分享列表、状态筛选、续期、删除单项、服务能力查询已具备。

服务端后续增强：

1. 将下载授权从 `downloadAuthRequired` 过渡到 `downloadPolicy`：`PUBLIC`、`LOGIN_REQUIRED`、`OWNER_ONLY`。
2. 默认身份继续以手机设备指纹为核心；账号只作为用户主动创建后的可选增强。
3. 端到端加密协议需要和鸿蒙客户端联调：默认算法、KDF 参数、密钥来源、解密和完整性校验。
4. Web 端完整解密阶段需要读取 URL fragment 中的 `key`，用 WebCrypto 在浏览器本地解密。
5. 当前限流是进程内实现，生产部署可替换为 Redis 或网关限流。
6. 当前迁移服务是轻量内部实现，生产部署可替换为 Flyway 或 Liquibase。
7. 测试已覆盖主流程、扫码 Cookie、加密元数据和分享管理；后续可继续补 room/transfer 兼容接口和清理任务细节。

下一轮建议顺序：

1. 让鸿蒙客户端接入 server API，先跑通设备注册、创建分享、上传、扫码下载。
2. 服务端先把下载策略补成 `PUBLIC / LOGIN_REQUIRED / OWNER_ONLY`。
3. 在客户端实现端到端加密，再和服务端元数据校验联调。
4. 根据真实联调结果完善浏览器下载页和分享管理体验。

不要过早扩大范围。当前优先级仍是：

```text
模型层 -> viewmodel -> 页面骨架 -> services -> 真实传输
```
