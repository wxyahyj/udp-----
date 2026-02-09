# GitHub Actions 快速参考

## 1️⃣ 初始化 GitHub 仓库 (5分钟)

```bash
# 初始化 Git
git init
git add .
git commit -m "Initial commit"

# 连接到 GitHub
git remote add origin https://github.com/你的用户名/udp推流发射器.git
git branch -M main
git push -u origin main
```

## 2️⃣ 配置 Secrets (可选，5分钟)

在 GitHub 仓库 → Settings → Secrets and variables → Actions：

### Docker Hub (可选)
```
DOCKER_USERNAME = your_docker_username
DOCKER_PASSWORD = your_docker_password
```

### PyPI (可选)
```
PYPI_API_TOKEN = your_pypi_token
```

## 3️⃣ 创建发布版本

### 自动方式：
```bash
# 创建标签
git tag v1.0.0
git push origin v1.0.0

# ✅ GitHub Actions 自动执行：
# - 编译 C++ (x64/x86)
# - 编译 Python (Windows/Linux)
# - 构建 Docker
# - 发布到 GitHub Releases
# - 发布到 PyPI (如配置)
# - 推送到 Docker Hub (如配置)
```

## 4️⃣ 查看构建结果

### 实时日志：
GitHub → Actions → 选择工作流 → 查看详细日志

### 下载产物：
- **方式一**：Actions → 最新 Run → Artifacts → 下载
- **方式二**：Releases → 选择版本 → 下载文件

## 构建产物一览

| 类型 | 文件 | 平台 |
|------|------|------|
| C++ | `udp_streamer.exe` | Windows x64 |
| C++ | `udp_streamer.exe` | Windows x86 |
| Python | `udp_streamer.exe` | Windows |
| Python | `udp_streamer` | Linux |
| Docker | `udp-streamer:v1.0.0` | 所有平台 |

## 工作流一览

| 工作流 | 触发条件 | 产物 |
|--------|---------|------|
| `build.yml` | Push/标签 | 所有编译产物 |
| `test.yml` | Push/PR | 测试报告 |
| `release.yml` | 标签 v* | Release + PyPI + Docker |

## 常用命令

```bash
# 查看所有标签
git tag

# 删除本地标签
git tag -d v1.0.0

# 删除远程标签
git push origin --delete v1.0.0

# 重新推送标签
git tag v1.0.0
git push origin v1.0.0 -f

# 查看最近提交
git log --oneline -5
```

## ✨ 高级技巧

### 跳过 CI/CD
```bash
git commit -m "Fix typo [skip ci]"
```

### 手动触发构建
GitHub → Actions → Build UDP Streamer → Run workflow

### 查看工作流状态
```bash
# 在 README.md 中添加
[![Build](https://github.com/yourusername/udp推流发射器/actions/workflows/build.yml/badge.svg)](https://github.com/yourusername/udp推流发射器/actions)
```

## 📊 监控面板

**GitHub Actions 页面：**
- 工作流执行历史
- 构建时间统计
- 失败构建日志
- 成本统计 (计费)

## 🆘 故障排查

| 问题 | 解决方案 |
|------|---------|
| 构建失败 | 查看 Actions 日志 → 找错误行 → 修复 → 重推 |
| FFmpeg 不找 | build.yml 中调整下载链接 |
| Docker 推送失败 | 检查 DOCKER_USERNAME/PASSWORD Secrets |
| PyPI 上传失败 | 检查 PYPI_API_TOKEN Secrets |

## 📚 更多信息

详细文档：[GITHUB_CI_CD.md](./GITHUB_CI_CD.md)

## 💡 下一步

1. ✅ 推送代码到 GitHub
2. ✅ 查看 Actions 自动运行
3. ✅ 创建版本标签 `v1.0.0`
4. ✅ 查看 Release 页面
5. ✅ 下载编译好的文件

就这么简单！🚀
