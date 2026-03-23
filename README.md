# DataEyes OpenClaw Installer

DataEyes 的 OpenClaw 一键安装仓库。

适合场景：
- 从 GitHub 分发给测试用户
- 让用户通过终端一条命令完成安装
- 在未做 Apple 签名、公证前，尽量降低 macOS 双击脚本带来的阻力

## 安装特点

- 优先直接执行 `npm install -g openclaw@latest`
- 如果当前环境没有全局安装权限，会自动回退到 `~/.npm-global`
- OpenClaw 模型列表默认只显示 DataEyes 模型，不再混入其他 provider
- 自动检测或安装 Node.js 22
- 自动写入 DataEyes 配置
- 自动启动 OpenClaw Gateway
- 安装完成后自动打开本机控制台
- 不修改全局 npm registry
- 不修改 shell 配置文件

## 一键安装

推荐直接在终端执行：

```bash
curl -fsSL https://raw.githubusercontent.com/cyf1124906008-ai/dataeyes-openclaw-installer/main/install.sh | bash
```

或者先克隆仓库再执行：

```bash
git clone https://github.com/cyf1124906008-ai/dataeyes-openclaw-installer.git
cd dataeyes-openclaw-installer
bash install.sh
```

仓库地址：
- `https://github.com/cyf1124906008-ai/dataeyes-openclaw-installer`

## 安装完成后

默认控制台地址：
- `http://127.0.0.1:18789`

默认配置文件：
- `~/.openclaw/openclaw.json`

默认模型：
- 主模型：`dataeyes/gpt-5.4`
- 自动回退：`dataeyes/gemini-3.1-pro-preview-customtools`
- 自动回退：`dataeyes/claude-opus-4-6`

OpenClaw 命令位置说明：
- 如果当前机器允许直接全局安装，`openclaw` 会进入 npm 全局路径
- 如果当前机器没有全局安装权限，会自动回退到 `~/.npm-global/bin/openclaw`

如果安装后当前终端找不到 `openclaw`，先执行：

```bash
export PATH="$HOME/.npm-global/bin:$PATH"
```

## 图文教程

### 方式一：终端一键安装

1. 打开终端。
2. 执行下面这条命令：

```bash
curl -fsSL https://raw.githubusercontent.com/cyf1124906008-ai/dataeyes-openclaw-installer/main/install.sh | bash
```

3. 按提示输入 DataEyes API Key。
4. 等待安装器自动完成 OpenClaw 安装、配置写入和 Gateway 启动。
5. 安装完成后，浏览器会自动打开本地控制台。

### 方式二：双击安装包

#### 第 1 步：确认安装包内容

![步骤 1](图片教程/01.png)

#### 第 2 步：双击 `双击开始安装.command`

![步骤 2](图片教程/02.png)

#### 第 3 步：如果 macOS 提示安全限制，到“系统设置 > 隐私与安全性”中放行

![步骤 3](图片教程/03.png)

#### 第 4 步：重新打开安装程序

![步骤 4](图片教程/04.png)

#### 第 5 步：等待 OpenClaw 安装完成

![步骤 5](图片教程/05.png)

#### 第 6 步：输入 DataEyes API Key

![步骤 6](图片教程/06.png)

#### 第 7 步：等待自动写入 DataEyes 配置并启动 Gateway

![步骤 7](图片教程/07.png)

#### 第 8 步：安装完成后自动打开本机控制台

![步骤 8](图片教程/08.png)

## 常见问题

### 1. 为什么没有安装到 `~/.dataeyes-openclaw`

因为现在的安装策略已经改成：
- 优先直接使用 `npm install -g openclaw@latest`
- 没有权限时再回退到 `~/.npm-global`

这样更符合大家对 Node CLI 的常见使用习惯。

### 2. 为什么还会提示 macOS 安全限制

如果你是双击本地脚本包，而不是通过终端执行 GitHub 安装命令，macOS 仍可能因为 Gatekeeper 拦截未签名脚本。

这不是安装逻辑问题，而是苹果平台对未签名脚本的默认限制。

### 3. 网络慢的时候会卡多久

如果当前机器没有可用的 Node.js 22，安装器会先下载 Node.js，再安装 OpenClaw。网络较慢时持续几分钟属于正常现象。

## 仓库结构

- `install.sh`
  GitHub 安装入口
- `内部文件/`
  真实安装逻辑
- `图片教程/`
  安装引导图片
- `DELIVERY.md`
  后续做签名、公证时的交付建议
