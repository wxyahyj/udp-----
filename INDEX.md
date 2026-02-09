# UDP 推流发射器 - 文件索引

本项目包含完整的 UDP 推流发射器实现，包括 C++ 高性能版本、Python 跨平台版本、以及完整的 GitHub Actions CI/CD 自动化构建。

## 📖 文档导航

### 🚀 快速开始 (新用户必读)

| 文件 | 说明 | 适用于 |
|------|------|--------|
| **[GITHUB_SETUP_SUMMARY.txt](./GITHUB_SETUP_SUMMARY.txt)** | 完整部署总结，3 步快速上手 | 所有用户 |
| **[快速开始.txt](./快速开始.txt)** | 项目使用快速指南 | 想快速使用的用户 |
| **[README.md](./README.md)** | 项目主文档，功能介绍 | 所有用户 |

### 📚 详细文档

| 文件 | 说明 | 包含内容 |
|------|------|---------|
| **[DEPLOY_GITHUB.md](./DEPLOY_GITHUB.md)** | GitHub 部署完整指南 | 3 步本地初始化、GitHub 仓库创建、代码推送、验证构建、发布版本 |
| **[GITHUB_CI_CD.md](./GITHUB_CI_CD.md)** | GitHub Actions CI/CD 详细文档 | 工作流说明、设置步骤、高级配置、故障排查 |
| **[QUICKSTART_CI_CD.md](./QUICKSTART_CI_CD.md)** | CI/CD 快速参考卡片 | 常用命令、工作流对照、常见问题速解 |
| **[CHECKLIST.md](./CHECKLIST.md)** | 部署检查清单 | 逐步检查项、验证清单、故障排查 |

### ⚙️ 配置和脚本

| 文件 | 说明 | 用途 |
|------|------|------|
| **[CMakeLists.txt](./CMakeLists.txt)** | C++ CMake 编译配置 | Windows/Linux C++ 编译 |
| **[build.bat](./build.bat)** | Windows 快速编译脚本 | 一键编译 C++ 版本 |
| **[setup.py](./setup.py)** | Python 包配置 | Python 包发布配置 |
| **[requirements.txt](./requirements.txt)** | Python 依赖列表 | `pip install -r requirements.txt` |
| **[Dockerfile](./Dockerfile)** | Docker 镜像配置 | Docker 容器构建 |
| **[docker-compose.yml](./docker-compose.yml)** | Docker Compose 配置 | 一键启动容器 |
| **[.gitignore](./.gitignore)** | Git 忽略配置 | 版本控制配置 |
| **[LICENSE](./LICENSE)** | MIT 许可证 | 开源协议 |

### 🔍 验证脚本

| 文件 | 说明 | 用法 |
|------|------|------|
| **[verify_project.ps1](./verify_project.ps1)** | Windows 项目验证脚本 | `.\verify_project.ps1` |
| **[verify_project.sh](./verify_project.sh)** | Linux/macOS 项目验证脚本 | `bash verify_project.sh` |

### 🔧 GitHub Actions 工作流

| 路径 | 说明 | 触发条件 |
|------|------|---------|
| **[.github/workflows/build.yml](./.github/workflows/build.yml)** | 主构建工作流 | Push 到 main/develop，创建 v* 标签 |
| **[.github/workflows/test.yml](./.github/workflows/test.yml)** | 自动测试工作流 | 每次 Push 和 Pull Request |
| **[.github/workflows/release.yml](./.github/workflows/release.yml)** | 发布工作流 | 创建 v* 版本标签 |
| **[.github/scripts/setup-ffmpeg.sh](./.github/scripts/setup-ffmpeg.sh)** | FFmpeg 安装脚本 | 在 CI 中自动安装 FFmpeg |
| **[.github/scripts/build-cpp.sh](./.github/scripts/build-cpp.sh)** | C++ 构建脚本 | 在 CI 中编译 C++ 版本 |
| **[.github/scripts/build-python.sh](./.github/scripts/build-python.sh)** | Python 构建脚本 | 在 CI 中打包 Python 版本 |

## 💻 源代码

### C++ 源代码 (src/)

| 文件 | 说明 | 功能 |
|------|------|------|
| **[src/main.cpp](./src/main.cpp)** | 主程序入口 | 初始化、参数解析、主循环 |
| **[src/screen_capture.h](./src/screen_capture.h)** | 屏幕捕获头文件 | 类声明和接口 |
| **[src/screen_capture.cpp](./src/screen_capture.cpp)** | 屏幕捕获实现 | Windows GDI/DXGI 屏幕捕获 |
| **[src/encoder.h](./src/encoder.h)** | 视频编码头文件 | 类声明和接口 |
| **[src/encoder.cpp](./src/encoder.cpp)** | 视频编码实现 | FFmpeg 硬件编码（NVIDIA/AMD） |
| **[src/udp_streamer.h](./src/udp_streamer.h)** | UDP 推流头文件 | 类声明和接口 |
| **[src/udp_streamer.cpp](./src/udp_streamer.cpp)** | UDP 推流实现 | 发送编码数据到 UDP |

### Python 源代码

| 文件 | 说明 | 功能 |
|------|------|------|
| **[udp_streamer.py](./udp_streamer.py)** | Python 完整实现 | 屏幕捕获、编码、推流一体 |

## 📊 文档结构概览

```
文档分类：
├── 🚀 快速开始
│   ├── GITHUB_SETUP_SUMMARY.txt     ← 从这里开始！
│   ├── 快速开始.txt
│   └── README.md
│
├── 📚 详细指南
│   ├── DEPLOY_GITHUB.md             ← GitHub 部署
│   ├── GITHUB_CI_CD.md              ← CI/CD 详解
│   ├── QUICKSTART_CI_CD.md          ← 速查表
│   └── CHECKLIST.md                 ← 检查清单
│
├── ⚙️ 配置文件
│   ├── CMakeLists.txt               ← C++ 编译
│   ├── setup.py                     ← Python 包
│   ├── Dockerfile                   ← Docker
│   └── .gitignore                   ← Git 配置
│
├── 🔍 验证工具
│   ├── verify_project.ps1           ← Windows
│   └── verify_project.sh            ← Linux/macOS
│
├── 💻 源代码
│   ├── src/                         ← C++ 源代码
│   └── udp_streamer.py              ← Python 源代码
│
└── 🔧 GitHub Actions
    └── .github/
        ├── workflows/               ← 工作流定义
        └── scripts/                 ← 辅助脚本
```

## 🎯 使用场景导航

### 场景 1：我想快速了解项目
1. 阅读 [README.md](./README.md)
2. 查看 [快速开始.txt](./快速开始.txt)

### 场景 2：我想在本地运行
1. 安装依赖：`pip install -r requirements.txt`
2. 运行 Python 版本：`python udp_streamer.py`
3. 或查看 [快速开始.txt](./快速开始.txt)

### 场景 3：我想部署到 GitHub
1. 阅读 [GITHUB_SETUP_SUMMARY.txt](./GITHUB_SETUP_SUMMARY.txt)
2. 按照 [DEPLOY_GITHUB.md](./DEPLOY_GITHUB.md) 的 3 个步骤操作
3. 参考 [CHECKLIST.md](./CHECKLIST.md) 验证

### 场景 4：我需要编译 C++ 版本
1. 安装依赖和工具
2. 运行 `build.bat` (Windows) 或查看 [CMakeLists.txt](./CMakeLists.txt)
3. 查看 [快速开始.txt](./快速开始.txt) 中的 C++ 编译部分

### 场景 5：我想深入了解 GitHub Actions
1. 阅读 [GITHUB_CI_CD.md](./GITHUB_CI_CD.md)
2. 查看 [.github/workflows/](./.github/workflows/) 中的工作流文件

### 场景 6：我遇到了问题
1. 查看 [CHECKLIST.md](./CHECKLIST.md) 的故障排查
2. 查看 [GITHUB_CI_CD.md](./GITHUB_CI_CD.md) 的常见问题
3. 查看工作流的详细日志

## 📋 文件清单

### 文档 (9 个)
- [x] README.md
- [x] GITHUB_SETUP_SUMMARY.txt
- [x] DEPLOY_GITHUB.md
- [x] GITHUB_CI_CD.md
- [x] QUICKSTART_CI_CD.md
- [x] CHECKLIST.md
- [x] 快速开始.txt
- [x] LICENSE
- [x] INDEX.md (本文件)

### 配置 (7 个)
- [x] CMakeLists.txt
- [x] setup.py
- [x] Dockerfile
- [x] docker-compose.yml
- [x] requirements.txt
- [x] .gitignore
- [x] build.bat

### 源代码 (8 个)
- [x] src/main.cpp
- [x] src/screen_capture.h
- [x] src/screen_capture.cpp
- [x] src/encoder.h
- [x] src/encoder.cpp
- [x] src/udp_streamer.h
- [x] src/udp_streamer.cpp
- [x] udp_streamer.py

### GitHub Actions (6 个)
- [x] .github/workflows/build.yml
- [x] .github/workflows/test.yml
- [x] .github/workflows/release.yml
- [x] .github/scripts/setup-ffmpeg.sh
- [x] .github/scripts/build-cpp.sh
- [x] .github/scripts/build-python.sh

### 验证脚本 (2 个)
- [x] verify_project.ps1
- [x] verify_project.sh

**总计：32 个文件**

## 🚀 快速导航

| 我想... | 查看这个文件 |
|--------|------------|
| 了解项目 | [README.md](./README.md) |
| 快速开始 | [快速开始.txt](./快速开始.txt) |
| 部署到 GitHub | [GITHUB_SETUP_SUMMARY.txt](./GITHUB_SETUP_SUMMARY.txt) |
| 详细部署指南 | [DEPLOY_GITHUB.md](./DEPLOY_GITHUB.md) |
| 学习 GitHub Actions | [GITHUB_CI_CD.md](./GITHUB_CI_CD.md) |
| 常用命令速查 | [QUICKSTART_CI_CD.md](./QUICKSTART_CI_CD.md) |
| 编译 C++ | [CMakeLists.txt](./CMakeLists.txt) |
| 运行 Python | [udp_streamer.py](./udp_streamer.py) |
| 使用 Docker | [Dockerfile](./Dockerfile) |
| 验证项目 | [verify_project.ps1](./verify_project.ps1) 或 [verify_project.sh](./verify_project.sh) |

## 💡 推荐阅读顺序

**第一次接触项目：**
1. [GITHUB_SETUP_SUMMARY.txt](./GITHUB_SETUP_SUMMARY.txt) (5分钟)
2. [README.md](./README.md) (10分钟)
3. [快速开始.txt](./快速开始.txt) (5分钟)

**准备部署到 GitHub：**
1. [GITHUB_SETUP_SUMMARY.txt](./GITHUB_SETUP_SUMMARY.txt)
2. [DEPLOY_GITHUB.md](./DEPLOY_GITHUB.md)
3. [CHECKLIST.md](./CHECKLIST.md)

**深入学习 CI/CD：**
1. [QUICKSTART_CI_CD.md](./QUICKSTART_CI_CD.md)
2. [GITHUB_CI_CD.md](./GITHUB_CI_CD.md)
3. [.github/workflows/](./.github/workflows/)

## ⚡ 快速命令参考

### 验证项目
```bash
# Windows
.\verify_project.ps1

# Linux/macOS
bash verify_project.sh
```

### 部署到 GitHub
```bash
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/USERNAME/udp推流发射器.git
git push -u origin main
```

### 创建发布版本
```bash
git tag v1.0.0
git push origin v1.0.0
```

### 本地运行
```bash
python udp_streamer.py -ip 192.168.1.100 -p 10000
```

### 构建 C++
```bash
build.bat  # Windows
# 或
mkdir build && cd build && cmake .. && cmake --build .
```

## 🆘 需要帮助？

- **快速问题** → [QUICKSTART_CI_CD.md](./QUICKSTART_CI_CD.md)
- **部署问题** → [DEPLOY_GITHUB.md](./DEPLOY_GITHUB.md) + [CHECKLIST.md](./CHECKLIST.md)
- **技术问题** → [GITHUB_CI_CD.md](./GITHUB_CI_CD.md)
- **使用问题** → [快速开始.txt](./快速开始.txt)
- **概览** → [README.md](./README.md)

---

**提示**: 如果这是你第一次使用此项目，建议从 [GITHUB_SETUP_SUMMARY.txt](./GITHUB_SETUP_SUMMARY.txt) 开始！

最后更新：2024 年
