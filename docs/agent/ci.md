# CI 说明

项目使用 GitHub Actions 做持续集成，配置位于 `.github`。

## 设计原则

- workflow 只负责编排
- 具体检查封装成 `.github/actions` 下的 composite action
- 服务端、鸿蒙客户端、文档检查互相独立
- 鸿蒙端先做结构校验，等 CI 环境具备 HarmonyOS 构建工具后再接入 HAP 构建

## 当前 Workflow

```text
.github/workflows/ci.yml
```

包含三个 job：

- `docs`：检查关键文档是否存在，并确认根 README 指向重要入口
- `server`：设置 Java 17，执行服务端 `mvn test`
- `harmony`：检查鸿蒙原生工程的标准目录和关键文件

## Composite Actions

```text
.github/actions/check-docs
.github/actions/build-server
.github/actions/check-harmony
```

后续如果要增加构建产物上传、Docker 镜像、部署服务器，只需要新增 action 或 job，不要把所有脚本堆进一个 workflow。
