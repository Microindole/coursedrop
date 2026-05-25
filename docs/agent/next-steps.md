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
- `auth`：Web 扫码登录码、手机确认、浏览器 `CD_SESSION` Cookie。
- `cleanup`：服务器限时存储、过期删除、撤回删除。
- `download`：浏览器下载页、浏览器下载接口、App 下载接口。
- `audit`：分享撤回和过期清理的删除审计。
- `security`：账号密码使用独立 salt 和 PBKDF2 哈希。
- `mapper/entity`：主要 CRUD 已迁到 MyBatis-Plus，`dto/`、`enums/` 已集中。

当前仍未完成：

1. 浏览器下载页还不是完整页面：目前只展示登录码和轮询接口，缺真实二维码、轮询脚本、登录成功后的下载状态刷新。
2. Web 登录会话缺退出登录、手机端撤销登录、会话列表和会话失效管理。
3. 账号密码登录接口尚未开放；它应继续作为手机端关闭安全设置后的例外入口。
4. 下载鉴权还需要细化：浏览器端已有 Cookie 校验，App 端还缺设备指纹/账号会话策略。
5. 端到端加密目前只完成元数据保存和必填校验，缺客户端加密协议、密钥派生约定和下载后的完整性校验流程文档。
6. 数据库迁移仍在 `DatabaseInitializer` 中手写 DDL，后续建议换 Flyway 或 Liquibase。
7. 清理任务缺失败重试、`CLEANUP_FAILED` 审计、孤儿文件扫描。
8. 分享管理接口还不完整：缺我的分享列表、状态筛选、续期、删除单个分享项、容量/限额查询。
9. 公网部署安全还缺 HTTPS 下的 `Secure=true` Cookie、限流、CORS、反向代理 base URL 配置。
10. 测试覆盖仍偏少，缺 identity、web login Cookie、加密元数据、清理审计、兼容接口测试。

下一轮服务端建议顺序：

1. 做 `/s/{code}` 浏览器下载页和扫码登录闭环，让普通浏览器扫码后能真实下载。
2. 补 Web 登录退出、撤销和会话失效。
3. 补 App 端下载鉴权策略，把设备指纹和账号身份纳入下载判断。
4. 补分享管理接口：列表、筛选、续期、删除单项。
5. 引入数据库迁移工具，替换 `DatabaseInitializer` 中的建表/补列职责。
6. 增加清理失败审计、孤儿文件扫描和关键接口测试。

不要过早扩大范围。当前优先级仍是：

```text
模型层 -> viewmodel -> 页面骨架 -> services -> 真实传输
```
