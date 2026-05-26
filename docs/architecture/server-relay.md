# 服务端中转与身份设计

CourseDrop 服务端不是网盘，也不是聊天后端。服务端只负责在有效期内保存中转内容、提供下载入口、维护设备指纹与账号映射，并在过期或撤回后删除服务器副本。

## 服务端职责

- 保存有效期内的公网中转文件。
- 为分享生成浏览器可打开的下载页面或直链。
- 支持任何二维码工具扫码后在浏览器中下载。
- 支持 CourseDrop 手机端直接下载。
- 到期后删除分享记录和对应文件。
- 维护设备指纹、账号、账号与设备指纹的绑定关系。
- 支持手机 CourseDrop 扫码登录 Web 管理端。

## 服务端不做

- 不做永久文件存储。
- 不做普通网盘目录。
- 不保存端到端加密明文密钥。
- 不把账号密码登录作为默认入口暴露给普通用户。
- 不用聊天关系、好友关系或群聊关系承载文件传输。

## 分享与下载

一次公网分享由一个 `ShareSession` 表示，包含多个 `ShareItem`。

```text
手机 CourseDrop
  -> 创建分享
  -> 上传密文/文件
  -> 服务端返回分享码和下载 URL
  -> 二维码编码下载 URL
  -> 浏览器或 CourseDrop App 下载
```

下载入口分两类：

- 浏览器下载：访问公开下载页面，必须完成登录或扫码授权后下载。
- App 下载：CourseDrop 客户端携带设备指纹或账号身份下载。

服务端必须在每次下载前校验：

- 分享是否存在。
- 分享是否已过期。
- 分享是否已撤回。
- 当前访问者是否满足下载策略。
- 对应文件是否仍在服务器临时存储目录中。

## 生命周期

服务器文件必须绑定过期时间。

```text
CREATED -> ACTIVE -> EXPIRED
        -> REVOKED
```

- `ACTIVE`：可下载。
- `EXPIRED`：到期后不可下载，清理任务删除文件。
- `REVOKED`：用户主动撤回，立即不可下载并等待清理或立即删除。

清理任务以分享会话为主维度，删除：

- 分享记录。
- 分享项记录。
- 对应临时文件。
- 相关下载票据。

## 身份模型

CourseDrop 的身份以设备指纹为底层身份，账号是设备指纹之上的聚合身份。

```text
DeviceFingerprint
  -> 可以单独使用
  -> 可以绑定到 Account

Account
  -> 可以绑定多个 DeviceFingerprint
  -> 登录后服务端把设备指纹归并为账号身份
```

没有账号时，服务端按设备指纹识别用户。有账号时，服务端把已绑定指纹转换为账号身份。

### 默认身份规则

CourseDrop 的默认身份不是账号，而是手机端设备指纹。

- 手机 App 首次使用时注册或刷新 `DeviceFingerprint`。
- 手机扫码登录 Web 时，服务端使用该手机指纹确认身份。
- 没有账号也可以完成扫码登录、创建分享、下载需要登录的分享。
- 账号只是可选增强，用于把多个手机指纹归并到一个用户身份，并允许账号密码登录 Web。

账号和指纹的关系：

```text
手机指纹 A
  -> 默认可以独立使用
  -> 用户在安全设置中创建账号
  -> 手机指纹 A 绑定到账号
  -> 后续可继续扫码登录，也可在允许后使用账号密码登录
```

这意味着：账号不能替代手机指纹成为默认身份。账号只是在用户主动创建后，为跨设备和电脑登录提供便利。

## 账号与登录

账号密码可以存在，但不是默认公开登录方式。

默认登录方式：

```text
Web 管理端显示登录二维码
手机 CourseDrop 扫码
手机确认
服务端创建 Web 登录会话
浏览器进入管理端
```

账号创建在手机端完成。创建账号时，当前手机设备指纹自动绑定到账号。

安全设置：

- 默认：Web 端必须使用手机扫码登录。
- 用户在手机端关闭安全设置后：允许账号密码登录。

当前账号安全接口支持：

- 查询账号状态。
- 开启或关闭账号密码登录。
- 修改账号密码。
- 查询账号绑定设备指纹。
- 绑定新的设备指纹。
- 解绑已有设备指纹。

账号安全接口必须携带账号身份或已绑定设备指纹身份，不能只依赖 URL 中的 `accountId`。

## 下载策略

分享下载策略需要和身份模型分离。身份用于证明“访问者是谁”，下载策略用于决定“这个访问者能不能拿到密文”。

下载策略分三类：

```text
PUBLIC
  不登录也能下载。

LOGIN_REQUIRED
  任意已登录身份可下载。
  手机端用设备指纹登录；电脑端用手机扫码登录或账号密码登录。

OWNER_ONLY
  只有分享创建者的设备指纹或账号可下载。
  适合自己在多设备间传文件。
```

典型场景：

- 给别人发文件：使用 `LOGIN_REQUIRED`。别人拿到二维码后，只要登录就能下载；手机端扫码可直接下载，电脑端可用手机扫码授权后下载到电脑，也可在允许账号密码登录后用账号登录下载。
- 自己跨设备传文件：使用 `OWNER_ONLY`。只有自己的手机指纹、绑定账号或绑定设备可下载。
- 临时公开文件：使用 `PUBLIC`。不要求登录，但仍受有效期和撤回控制。

当前服务端已使用明确的 `downloadPolicy` 作为内部鉴权依据：

```text
PUBLIC
LOGIN_REQUIRED
OWNER_ONLY
```

`downloadAuthRequired` 只作为旧客户端兼容入参和响应字段保留：

```text
downloadAuthRequired=false -> PUBLIC
downloadAuthRequired=true  -> LOGIN_REQUIRED
```

新客户端应直接传 `downloadPolicy`。`LOGIN_REQUIRED` 表示任意已登录身份可下载，`OWNER_ONLY` 才表示只能所有者下载。

## 已落地的安全与审计基线

### 扫码登录会话 Cookie

Web 端扫码登录完成后，服务端需要签发 HttpOnly、Secure、SameSite Cookie，浏览器后续下载和管理操作都依赖该会话。

要求：

- Cookie 不暴露给前端 JavaScript。
- 会话绑定登录确认时的账号或设备指纹。
- 会话有明确过期时间。
- 退出登录和手机端撤销登录都能让 Cookie 失效。
- 浏览器下载接口必须校验 Cookie 或一次性扫码授权票据。

当前实现：

- `POST /api/auth/web-login` 创建登录码。
- 手机端调用 `POST /api/auth/web-login/{loginCode}/confirm` 绑定指纹身份。
- 浏览器轮询 `GET /api/auth/web-login/{loginCode}`，确认成功后服务端签发 `CD_SESSION` HttpOnly Cookie。
- 浏览器下载接口校验 `CD_SESSION`，开发测试阶段仍保留显式授权头作为兼容入口。

### 密码哈希盐

账号密码登录只是安全设置关闭后的例外入口，但只要存在密码，就必须使用带盐的强哈希。

要求：

- 每个账号使用独立随机 salt。
- 数据库存储 `passwordHash`、`passwordSalt`、`passwordAlgorithm`。
- 不使用裸 SHA-256 保存密码。
- 后续优先使用 Argon2、bcrypt 或 PBKDF2。

当前实现：

- 账号创建时使用独立随机 salt。
- 密码使用 `PBKDF2WithHmacSHA256` 派生后存储。
- 数据库同时保存 `password_hash`、`password_salt`、`password_algorithm`。

### 浏览器登录页面

`/s/{code}` 下载页需要承担浏览器登录入口。

要求：

- 未登录时显示扫码登录二维码。
- 手机 CourseDrop 扫码确认后，浏览器轮询登录状态或通过 WebSocket/SSE 更新。
- 登录成功后刷新下载权限。
- 账号密码登录入口默认隐藏，仅当账号关闭安全设置后可用。

当前实现：

- `/s/{code}` 返回浏览器下载页。
- 页面由 Thymeleaf 渲染，使用 Tailwind CDN 提供简约样式，不引入 React/Vue 构建链。
- 未登录时页面展示真实 QR SVG、登录码和登录状态轮询。
- 登录成功后通过 Cookie 放行浏览器下载，并启用下载按钮，文件下载到当前电脑浏览器。
- 账号密码登录表单存在，但仍作为安全设置关闭后的例外入口。

### 端到端加密元数据校验

服务端不保存明文密钥，但必须保存和校验密文元数据，保证客户端能正确解密并发现损坏。

要求：

- 分享项保存加密算法、KDF、salt、nonce/iv、密文 hash、明文大小等元数据。
- 上传时校验必需元数据是否齐全。
- 下载时完整返回加密元数据。
- 服务端只能存储密文和元数据，不能存储解密密钥。

当前实现：

- 分享项支持 `encryptionAlgorithm`、`kdfAlgorithm`、`kdfSalt`、`nonce`、`sha256`、`plainSizeBytes`。
- `encrypted=true` 时上传接口会校验这些字段必须齐全。
- 分享项查询返回加密元数据，客户端据此完成解密与完整性校验。
- 服务端不接收、不保存明文解密密钥。

### 分享删除审计

分享过期、撤回和清理都应留下审计记录，便于排查文件为什么不可下载。

要求：

- 记录删除原因：`EXPIRED`、`REVOKED`、`CLEANUP_FAILED`、`MANUAL_ADMIN`。
- 记录触发者：系统、账号、设备指纹或管理员。
- 记录删除时间、分享 ID、分享项 ID、文件大小。
- 审计记录不保留文件内容。

当前实现：

- 新增 `share_audit_logs` 表记录分享项删除事件。
- 主动撤回记录 `REVOKED`，过期清理记录 `EXPIRED`。
- 提供 `GET /api/shares/{shareId}/audit` 查询审计记录。
- 审计只保存原因、触发者、分享项和大小，不保存文件内容。

## 后端模块方向

```text
controller/   HTTP 接口入口，只做参数接收和响应组装
dto/          Request、Response 和页面数据对象
enums/        业务枚举，例如分享状态、身份类型、审计原因
service/      业务编排，例如分享、身份、扫码登录、审计
mapper/       MyBatis-Plus 数据访问
entity/       数据库表实体
config/       应用配置、数据库初始化
common/       通用异常和错误响应

auth/         登录会话内部对象
share/        公网分享内部记录和分享码生成
storage/      临时文件保存、读取、删除
security/     密码哈希等安全工具
room/         早期房间兼容模型
transfer/     早期传输兼容模型
```

当前 `room/transfer` 是早期兼容层，后续不再作为公网分享的主模型扩展。

## 服务端补齐情况

### 浏览器扫码下载闭环

`/s/{code}` 现在是完整浏览器入口：

- 页面渲染 ZXing 生成的真实 QR SVG。
- 页面自动轮询 `GET /api/auth/web-login/{loginCode}`。
- 登录成功后服务端写入 `CD_SESSION` Cookie。
- 下载按钮根据授权状态动态启用，Web 端可直接下载到电脑。
- 页面提供账号密码登录表单，用于已经允许账号密码登录的账号。

### Web 会话管理

当前 `CD_SESSION` Cookie 可用于浏览器下载授权，并支持基础生命周期：

- `POST /api/auth/web-login/logout` 退出当前浏览器会话。
- `DELETE /api/auth/web-login/{loginCode}` 撤销指定登录会话。
- `GET /api/auth/web-login/sessions` 查询账号或设备下的会话。
- 服务端撤销会话时清空 Cookie token hash。
- `coursedrop.server.secure-cookie` 控制公网 HTTPS 部署时的 `Secure` Cookie。

### 下载鉴权策略

下载接口分浏览器和 App 两类：

- `PUBLIC` 分享允许浏览器和 App 不登录下载。
- `LOGIN_REQUIRED` 分享要求浏览器持有 `CD_SESSION`，或 App 携带有效设备指纹/账号身份。
- `OWNER_ONLY` 分享要求访问者匹配分享创建者指纹、账号，或绑定到该账号的设备指纹。
- 浏览器下载优先校验 `CD_SESSION`。
- CourseDrop App 下载请求可携带 `X-CourseDrop-Fingerprint-Id` 或 `X-CourseDrop-Account-Id`。
- 账号型分享允许已绑定到该账号的设备指纹下载。

`X-CourseDrop-Web-Authorized` 只保留为测试兼容入口，不作为正式 Web 鉴权方式。

### 端到端加密协议

服务端协议边界已经明确：

- 明确默认加密算法、KDF、nonce/iv 长度和 hash 算法。
- 客户端上传前加密，服务端只接收密文和元数据。
- 客户端下载后按 `sha256` 和明文大小做完整性校验。
- 服务端接口不得接收明文密钥、口令或可直接恢复密钥的材料。

服务端已校验和返回必要元数据；真正加密、解密和校验动作由客户端实现。

## 端到端加密实施方案

端到端加密和登录鉴权是两层独立机制：

- 登录鉴权决定访问者是否可以从服务器下载密文。
- 端到端加密保证服务器即使保存了文件，也无法读取明文。

### 加密流程

```text
发送端 CourseDrop
  -> 本地生成随机 fileKey
  -> 使用 fileKey 加密文件
  -> 上传密文和加密元数据
  -> 生成分享链接/二维码，二维码携带 share code 和解密材料

服务端
  -> 保存密文
  -> 保存算法、nonce、salt、hash、明文大小等元数据
  -> 不保存 fileKey
  -> 不保存明文

接收端 CourseDrop 或浏览器
  -> 登录或扫码获得下载权限
  -> 下载密文和元数据
  -> 从二维码/链接 fragment 中取得 fileKey
  -> 本地解密
  -> 校验 hash 和明文大小
```

### 密钥放置

浏览器分享链接应使用 URL fragment 携带解密密钥：

```text
https://server/s/{code}#key={base64urlFileKey}
```

原因：

- `#key` 不会随 HTTP 请求发送到服务端。
- 服务端日志、网关和 Controller 都看不到 `fileKey`。
- 浏览器页面可以在本地读取 fragment，用 WebCrypto 解密密文。

手机 App 扫码时，二维码中同样可以包含 `code + key`。App 解析后用本地密钥解密，服务端仍只负责密文下载。

禁止使用：

```text
https://server/s/{code}?key=...
```

因为 query 参数会发送给服务端，可能进入日志或监控系统。

### 推荐默认算法

初始版本建议固定一套默认算法，减少兼容复杂度：

- 文件加密：`AES-256-GCM`
- 随机密钥：每个分享项独立 `fileKey`
- nonce：每个分享项独立随机 96-bit nonce
- 完整性：密文 `sha256` + 明文大小 `plainSizeBytes`
- 密钥编码：`base64url`

如果后续需要用口令派生密钥，可以增加：

- KDF：`PBKDF2WithHmacSHA256` 或 `Argon2id`
- salt：每个分享项独立随机 salt
- iterations/memory/cost 写入元数据

### 服务端边界

服务端可以保存：

- `encrypted`
- `encryptionAlgorithm`
- `kdfAlgorithm`
- `kdfSalt`
- `nonce`
- `sha256`
- `plainSizeBytes`
- 密文文件

服务端绝不能保存：

- `fileKey`
- 明文文件
- 可直接恢复 `fileKey` 的口令或材料

### Web 端解密

Web 端下载到电脑有两种实现阶段：

1. 基础阶段：浏览器认证后下载密文文件，由 CourseDrop App 或后续工具解密。
2. 完整阶段：浏览器页面读取 URL fragment 中的 `key`，用 WebCrypto 在本地解密，然后把明文保存到电脑。

当前下载页已具备完整阶段的基础能力：加密分享项如果携带 `#key=`，浏览器会在本地使用 `AES-GCM` 解密并保存明文；服务端仍只看到分享码和密文下载请求，不接收解密密钥。

### 分享管理接口

当前分享管理接口包括：

- `GET /api/shares` 查询我的分享或按状态筛选。
- `POST /api/shares/{shareId}/expiry` 修改有效期。
- `DELETE /api/shares/{shareId}/items/{itemId}` 删除单个分享项。
- `GET /api/health/capabilities` 查询服务器能力、最大文件大小、默认有效期和版本。

### 清理与审计增强

当前撤回、过期清理和删除单项会写审计：

- 删除失败写入 `CLEANUP_FAILED`。
- 撤回或删除单项写入 `REVOKED`。
- 定期扫描孤儿文件，清理没有数据库记录的临时文件。
- 审计记录不保存文件内容。

### 工程化

当前工程化基线：

- 根路径 `/` 提供 Thymeleaf + Tailwind 服务首页，用于公网部署验收、分享码入口和健康检查入口。
- 账号安全和设备绑定接口已补齐，可供鸿蒙设置页直接接入。
- CRUD 使用 MyBatis-Plus。
- 数据库结构初始化收敛为带 `schema_migrations` 版本表的轻量迁移服务。
- 登录码创建、确认和密码登录有进程内限流。
- CORS、公网 base URL、Secure Cookie 都可通过配置调整。
- 测试覆盖健康检查、分享主流程、App 下载鉴权、扫码 Cookie、加密元数据和分享管理。

后续生产部署可以继续替换为 Flyway/Liquibase、Redis 限流和统一认证拦截器。
