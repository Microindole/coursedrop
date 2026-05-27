# CI 说明

项目使用 GitHub Actions 做持续集成，配置位于 `.github`。

## 设计原则

- workflow 只负责编排
- 具体检查封装成 `.github/actions` 下的 composite action
- 服务端、鸿蒙客户端、文档检查互相独立
- 鸿蒙端结构校验在通用 CI 中执行，HAP 构建在 GitHub 托管 runner 上临时安装 Harmony 命令行工具后执行

## 当前 Workflow

```text
.github/workflows/ci.yml
.github/workflows/deploy-server.yml
.github/workflows/release-harmony.yml
```

`ci.yml` 包含四个 job：

- `format`：检查受 Git 跟踪的文本文件是否符合 `.editorconfig` 的基础规则
- `docs`：检查关键文档是否存在，确认根 README 指向重要入口，并校验 Markdown 链接
- `server`：设置 Java 17，执行服务端 `mvn verify`
- `harmony`：检查鸿蒙原生工程的标准目录和关键文件

`deploy-server.yml` 是服务器发布工作流：

- `main` 分支更新且命中 server/deploy 相关路径时自动运行
- `workflow_dispatch` 仍可手动运行
- 构建并测试 Java server
- 上传 jar 到 `/home/cd/coursedrop/incoming`
- 通过 `systemctl --user restart coursedrop` 重启 `cd` 用户服务
- 不使用 `sudo`，不重启 Nginx；Nginx 和证书属于服务器一次性初始化

部署说明见 `docs/deploy/server-debian.md`。

`release-harmony.yml` 是鸿蒙 ArkTS 客户端发布工作流：

- `main` 分支命中 `apps/harmony/**` 或相关 CI 文件时自动构建 `dev` 版本
- `dev` release 每次都会删除旧 release、移动 `dev` tag，并重新上传 HAP
- tag 推送会按 tag 名创建对应版本 release
- 默认从本仓库 `harmony-toolchain` release 下载 `harmony-command-line-tools-linux.zip`
- 如需覆盖下载源，可配置仓库 secret `HARMONY_COMMANDLINE_TOOLS_URL`
- workflow 会递归查找 zip 中的 `ohpm`、`hvigorw`/`hvigor` 和 SDK 路径，再执行 HAP 构建

## Composite Actions

```text
.github/actions/check-docs
.github/actions/check-format
.github/actions/build-server
.github/actions/check-harmony
.github/actions/build-harmony
```

后续如果要增加 Docker 镜像或多环境部署，只需要新增 action 或 job，不要把所有脚本堆进一个 workflow。
