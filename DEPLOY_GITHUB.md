# 部署到 GitHub 完整指南

## 🎯 三步快速启动

### 步骤 1：在本地初始化 Git 仓库 (2分钟)

```bash
cd e:/udp推流发射器

# 初始化 Git
git init

# 添加所有文件
git add .

# 提交初始版本
git commit -m "Initial commit: UDP Streamer with GitHub Actions CI/CD"

# 创建主分支
git branch -M main
```

### 步骤 2：在 GitHub 上创建仓库 (2分钟)

1. 访问 https://github.com/new
2. 填写仓库信息：
   - **Repository name**: `udp推流发射器` (或其他名称)
   - **Description**: `高性能 UDP 推流发射器`
   - **Public/Private**: 选择 Public (如果要自动构建)
   - 不要初始化 README、.gitignore、LICENSE (已有)

3. 点击 "Create repository"

### 步骤 3：推送到 GitHub (1分钟)

```bash
# 添加远程仓库 (替换 yourusername)
git remote add origin https://github.com/yourusername/udp推流发射器.git

# 推送代码
git push -u origin main

# 检查是否成功
git remote -v
```

✅ **完成！** GitHub Actions 自动开始编译

---

## 📊 验证构建状态

### 查看自动构建

1. 访问: https://github.com/yourusername/udp推流发射器
2. 点击 "Actions" 标签
3. 查看工作流运行状态

预期流程：
```
✓ Build UDP Streamer
  ├── build-windows-cpp (x64) ............ ✓
  ├── build-windows-cpp (x86) ............ ✓
  ├── build-python-windows .............. ✓
  ├── build-python ...................... ✓
  ├── build-docker ...................... ✓
  └── test-cpp .......................... ✓
```

### 下载编译产物

1. 点击最近的 "Build UDP Streamer" Run
2. 向下滚动找 "Artifacts" 部分
3. 下载所需的编译产物

**可用产物：**
- `udp-streamer-cpp-windows-x64` (C++ 版本 x64)
- `udp-streamer-cpp-windows-x86` (C++ 版本 x86)
- `udp-streamer-python-windows` (Python 版本 Windows)
- `udp-streamer-python-linux` (Python 版本 Linux)

---

## 🚀 创建第一个发布版本

### 方法一：创建 Git 标签 (推荐)

```bash
# 查看当前代码
git log --oneline -5

# 创建版本标签
git tag v1.0.0

# 推送标签到 GitHub
git push origin v1.0.0

# ✨ GitHub Actions 自动执行：
# - 编译所有版本
# - 创建 GitHub Release
# - 上传编译产物
# - 发布到 PyPI (如配置)
# - 推送到 Docker Hub (如配置)
```

### 方法二：手动发布

1. GitHub → Releases → "Create a new release"
2. 输入标签: `v1.0.0`
3. 标题: `Release v1.0.0`
4. 描述: 写下发布说明
5. "Publish release"

✨ GitHub Actions 自动触发发布流程

---

## 🔐 配置可选功能 (5分钟)

### 启用 Docker Hub 发布 (可选)

1. 在 Docker Hub 创建账户: https://hub.docker.com
2. GitHub 仓库设置 → Secrets → New secret
3. 添加以下 Secrets:

```
DOCKER_USERNAME = 你的DockerHub用户名
DOCKER_PASSWORD = 你的DockerHub密码或Token
```

创建 Token 方法：
- https://hub.docker.com/settings/security → New Access Token

### 启用 PyPI 发布 (可选)

1. 在 PyPI 创建账户: https://pypi.org
2. https://pypi.org/manage/account/ → Add API token
3. GitHub 仓库 → Secrets → New secret

```
PYPI_API_TOKEN = 你的PyPI_Token
```

### 启用 Slack 通知 (可选)

1. 在 Slack 创建 Webhook
2. GitHub 仓库 → Secrets → New secret

```
SLACK_WEBHOOK_URL = 你的Webhook_URL
```

---

## 📈 监控和管理

### 查看编译历史

```
GitHub → Actions → 选择工作流 → 查看历史记录
```

### 查看发布版本

```
GitHub → Releases → 所有发布版本
```

### 查看代码质量

```
GitHub → Insights → Network/Traffic
```

### 管理 Workflows

```
GitHub → Settings → Actions → Workflow permissions
```

---

## 🎯 常见工作流

### 日常开发

```bash
# 修改代码
echo "new code" > src/main.cpp

# 提交更改
git add .
git commit -m "Add new feature"

# 推送
git push origin main

# ✓ GitHub Actions 自动测试和构建
```

### 发布新版本

```bash
# 确保代码是最新的
git pull origin main

# 创建版本
git tag v1.0.1
git push origin v1.0.1

# ✓ 自动发布到所有平台
```

### 修复 Bug

```bash
# 创建修复分支
git checkout -b fix/critical-bug

# 修复代码
# ...

# 提交
git add .
git commit -m "Fix critical bug"

# 推送
git push origin fix/critical-bug

# GitHub → Create Pull Request → Review → Merge
# ✓ 自动测试和构建
```

---

## 📊 构建状态徽章

在 README.md 中添加徽章显示构建状态：

```markdown
![Build](https://github.com/yourusername/udp推流发射器/actions/workflows/build.yml/badge.svg)
![Tests](https://github.com/yourusername/udp推流发射器/actions/workflows/test.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
```

效果：
![Build](https://img.shields.io/badge/build-passing-green)
![License](https://img.shields.io/badge/License-MIT-yellow.svg)

---

## 🆘 常见问题

### Q: 推送后 Actions 没有运行？

**A:** 检查以下几点：
1. 仓库是否 Public (Private 仓库需要启用 Actions)
2. GitHub → Settings → Actions → 确保已启用
3. 刷新页面或等待几秒

### Q: FFmpeg 编译失败？

**A:** 
1. 检查 build.yml 中的下载链接是否有效
2. 尝试手动下载测试：`https://www.gyan.dev/ffmpeg/builds/`
3. 修改下载链接后重新推送

### Q: Docker 推送失败？

**A:**
1. 检查 Secrets 中的 DOCKER_USERNAME/PASSWORD
2. Docker Hub 是否有推送权限
3. 尝试本地登录: `docker login`

### Q: PyPI 发布失败？

**A:**
1. 检查 PYPI_API_TOKEN 是否正确
2. setup.py 中的包名是否唯一
3. 查看详细日志找错误信息

---

## 📚 完整文件结构检查清单

```
✓ udp推流发射器/
  ✓ src/
    ✓ main.cpp
    ✓ screen_capture.cpp
    ✓ encoder.cpp
    ✓ udp_streamer.cpp
  ✓ .github/
    ✓ workflows/
      ✓ build.yml
      ✓ test.yml
      ✓ release.yml
    ✓ scripts/
      ✓ setup-ffmpeg.sh
      ✓ build-cpp.sh
      ✓ build-python.sh
  ✓ udp_streamer.py
  ✓ CMakeLists.txt
  ✓ build.bat
  ✓ Dockerfile
  ✓ docker-compose.yml
  ✓ setup.py
  ✓ requirements.txt
  ✓ README.md
  ✓ LICENSE
  ✓ .gitignore
  ✓ GITHUB_CI_CD.md
  ✓ QUICKSTART_CI_CD.md
  ✓ DEPLOY_GITHUB.md (本文件)
```

---

## 🎉 下一步

### 立即行动：

1. ✅ 本地 Git 初始化 + 推送到 GitHub
2. ✅ 查看 GitHub Actions 自动构建
3. ✅ 创建版本标签 v1.0.0
4. ✅ 查看 Releases 页面下载产物

### 可选配置：

- 🔧 配置 Docker Hub (可选)
- 📦 配置 PyPI (可选)
- 💬 配置 Slack 通知 (可选)

### 分享你的项目：

```
GitHub: https://github.com/yourusername/udp推流发射器
PyPI: https://pypi.org/project/udp-streamer/
DockerHub: https://hub.docker.com/r/yourname/udp-streamer
```

---

## 📞 获取帮助

- GitHub 文档: https://docs.github.com/en/actions
- GitHub Actions Marketplace: https://github.com/marketplace?type=actions
- 提交 Issue: https://github.com/yourusername/udp推流发射器/issues

---

## ✨ 成功指标

✓ GitHub Actions 自动编译  
✓ 生成编译产物 (Windows/Linux)  
✓ 创建 GitHub Release  
✓ 下载可用的二进制文件  
✓ Docker 镜像可用 (可选)  
✓ PyPI 包可用 (可选)  

**恭喜！🎉 你已成功部署 CI/CD 流程！**

---

最后更新: 2024年
联系方式: GitHub Issues
