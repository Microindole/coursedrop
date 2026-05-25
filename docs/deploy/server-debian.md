# Debian 服务器部署

目标：

```text
https://coursedrop.microindole.me -> nginx -> 127.0.0.1:9090 -> CourseDrop Java server
```

当前服务器约束：

- 服务器：阿里云 Debian，2 核 2G。
- 域名：`microindole.me` 根域和 `www` 已占用。
- 建议子域名：`coursedrop.microindole.me`。
- 应用用户：`cd`，无 sudo。
- 8080 已被其他 Java 服务占用。
- CourseDrop 使用 9090。

## 1. DNS

在 DNS 控制台添加：

```text
coursedrop.microindole.me A {server_public_ip}
```

等待解析生效：

```bash
dig coursedrop.microindole.me
```

## 2. 首次 root 初始化

用有 sudo 的账号在服务器执行。

从仓库根目录运行：

```bash
sudo COURSEDROP_HOST=coursedrop.microindole.me \
  COURSEDROP_USER=cd \
  COURSEDROP_PORT=9090 \
  bash scripts/deploy/init-server-root.sh
```

脚本会完成：

- 创建 `/home/cd/coursedrop/app`
- 创建 `/home/cd/coursedrop/uploads`
- 创建 `/home/cd/coursedrop/logs`
- 创建 `/home/cd/coursedrop/releases`
- 安装 Nginx site 配置
- 启用 `cd` 用户 linger
- 安装 `cd` 用户级 systemd 服务
- 测试并 reload Nginx

## 3. 证书

确认 DNS 生效后执行：

```bash
sudo certbot --nginx -d coursedrop.microindole.me
```

首次初始化会安装 HTTP-only 的 bootstrap Nginx 配置。`certbot --nginx` 成功后会自动写入 HTTPS 监听和证书路径。

完成后检查：

```bash
sudo nginx -t
sudo systemctl reload nginx
```

## 4. 手动发布

本机或 CI 构建：

```bash
bash scripts/deploy/build-server.sh
```

上传 jar 到服务器：

```bash
scp apps/server/target/coursedrop-server-0.1.0-SNAPSHOT.jar \
  cd@coursedrop.microindole.me:/home/cd/coursedrop/incoming/
```

以 `cd` 用户在服务器执行：

```bash
bash scripts/deploy/deploy-server.sh \
  /home/cd/coursedrop/incoming/coursedrop-server-0.1.0-SNAPSHOT.jar
```

如果服务器上没有仓库脚本，也可以直接执行部署工作流里的内联发布命令。

## 5. 用户级 systemd

服务文件安装位置：

```text
/home/cd/.config/systemd/user/coursedrop.service
```

常用命令：

```bash
systemctl --user daemon-reload
systemctl --user enable --now coursedrop
systemctl --user restart coursedrop
systemctl --user status coursedrop
journalctl --user -u coursedrop -f
```

如果 SSH 非交互环境找不到 user bus，先确认 root 已执行：

```bash
sudo loginctl enable-linger cd
```

## 6. GitHub Actions 自动发布

工作流：

```text
.github/workflows/deploy-server.yml
```

先手动触发 `workflow_dispatch`，不要一开始绑定 push 自动部署。

需要配置仓库 Secrets：

```text
COURSEDROP_SSH_HOST=coursedrop.microindole.me
COURSEDROP_SSH_USER=cd
COURSEDROP_SSH_KEY={private_key}
COURSEDROP_SSH_PORT=22
```

`COURSEDROP_SSH_KEY` 对应的公钥需要加入：

```text
/home/cd/.ssh/authorized_keys
```

## 7. 验证

本机访问：

```text
https://coursedrop.microindole.me/api/health
https://coursedrop.microindole.me/api/health/capabilities
```

服务器检查：

```bash
ss -lntp | grep ':9090'
curl -i http://127.0.0.1:9090/api/health
curl -i https://coursedrop.microindole.me/api/health
```

## 8. 端口说明

当前 8080 已被占用：

```text
*:8080 users:(("java",...))
```

CourseDrop 固定部署到：

```text
127.0.0.1:9090
```

公网不直接暴露 9090，只通过 Nginx 443 访问。
