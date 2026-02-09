# UDP 推流发射器 (UDP Streamer)

![Build](https://github.com/yourusername/udp推流发射器/actions/workflows/build.yml/badge.svg)
![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
![Platform: Windows](https://img.shields.io/badge/Platform-Windows-blue)
![Python: 3.8+](https://img.shields.io/badge/Python-3.8%2B-blue)

高性能 UDP 推流发射器，与 OBS 流媒体功能相同。支持硬件编码、低延迟、高帧率推流。

## 🎯 功能特点

- ✅ **超低延迟** (<50ms，GPU硬件编码)
- ✅ **高帧率** 支持 60fps+ 推流
- ✅ **硬件加速** NVIDIA NVENC / AMD VCE
- ✅ **多种分辨率** 支持 480p 到 4K
- ✅ **自适应码率** 动态质量调整
- ✅ **跨平台** Windows、Linux、macOS
- ✅ **易于部署** Docker 容器化
- ✅ **自动构建** GitHub Actions CI/CD

## 📋 系统要求

### 最低配置
- **操作系统**: Windows 7+ / Linux / macOS
- **CPU**: Intel i5 或等效 AMD
- **内存**: 2GB RAM
- **网络**: 有线网络推荐

### 推荐配置
- **GPU**: NVIDIA (Kepler+) / AMD (GCN+)
- **网络**: 千兆网络
- **CPU**: Intel i7 或更高

## 🚀 快速开始

### 方式一：Python 版本 (推荐快速测试)

#### 安装依赖
```bash
# Windows
pip install -r requirements.txt

# Linux/macOS
pip3 install -r requirements.txt

# 确保 FFmpeg 在 PATH 中
ffmpeg -version
```

#### 运行
```bash
python udp_streamer.py -ip 192.168.1.100 -p 10000
```

#### 参数说明
```
-w, --width       分辨率宽度 (默认: 1920)
-h, --height      分辨率高度 (默认: 1080)
-fps              帧率 (默认: 30)
-br, --bitrate    码率 kbps (默认: 5000)
-ip, --ip         目标 IP (默认: 127.0.0.1)
-p, --port        目标端口 (默认: 10000)
--cpu             使用 CPU 编码 (默认: GPU)
```

### 方式二：C++ 版本 (性能最优)

#### 依赖
- Visual Studio 2022+
- CMake 3.10+
- FFmpeg 开发库

#### 编译
```bash
# Windows
build.bat

# Linux/macOS
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release ..
cmake --build . --config Release
```

#### 运行
```bash
build/Release/udp_streamer -ip 192.168.1.100 -p 10000
```

### 方式三：Docker

#### 构建
```bash
docker build -t udp-streamer .
```

#### 运行
```bash
docker run -it --rm udp-streamer \
  -ip 192.168.1.100 -p 10000
```

#### Docker Compose
```bash
docker-compose up -d
```

## 📊 性能对比

### 延迟测试 (毫秒)

| 配置 | 延迟 | 帧率 | 码率 |
|------|------|------|------|
| GPU NVENC | **<50ms** | 60fps | 8000kbps |
| CPU libx264 | 100ms | 30fps | 5000kbps |
| OBS (对比) | ~50ms | 30fps | 5000kbps |

### 码率建议

| 分辨率 | 帧率 | 推荐码率 | 带宽要求 |
|--------|------|--------|---------|
| 480p | 30fps | 1.5-3 Mbps | 2-4 Mbps |
| 720p | 30fps | 3-5 Mbps | 4-6 Mbps |
| 1080p | 30fps | 5-8 Mbps | 6-10 Mbps |
| 1080p | 60fps | 8-12 Mbps | 10-15 Mbps |
| 4K | 30fps | 15-25 Mbps | 20-30 Mbps |

## 🎮 OBS 接收配置

### 使用 OBS 接收推流

```
OBS → 场景 → 添加媒体源 → 选择文件 → VLC
```

或使用 VLC 播放器：
```bash
vlc udp://@:10000
```

或使用 FFplay：
```bash
ffplay -protocol_whitelist file,udp,rtp -i udp://127.0.0.1:10000
```

## 💻 使用示例

### 基础推流
```bash
python udp_streamer.py -ip 192.168.1.50 -p 5004
```

### 高性能推流 (1080p@60fps)
```bash
python udp_streamer.py -w 1920 -h 1080 -fps 60 -br 10000 \
  -ip 192.168.1.50 -p 5004
```

### 低码率推流 (720p@30fps)
```bash
python udp_streamer.py -w 1280 -h 720 -fps 30 -br 3000 \
  -ip 192.168.1.50 -p 5004
```

### CPU 编码 (兼容性)
```bash
python udp_streamer.py --cpu -ip 192.168.1.50 -p 5004
```

### C++ 版本
```bash
udp_streamer.exe -ip 192.168.1.50 -p 5004 -w 1920 -h 1080 -fps 60
```

## 🔧 优化建议

### 低延迟优化
1. 使用 GPU 硬件编码
2. 增加码率 (5000-8000 kbps)
3. 减少分辨率或帧率
4. 使用有线网络
5. 升级显卡驱动

### 高帧率优化
1. C++ 版本 (性能更好)
2. 启用 GPU 编码
3. 降低分辨率
4. 关闭其他应用
5. 增加码率

### 网络优化
1. 使用千兆网
2. 同一网络 (避免跨域)
3. 优化路由器设置
4. 监控丢包率

## 🐛 故障排查

### 延迟大

**原因**: 编码方式不优
```bash
# 解决方案
1. 启用 GPU: 自动启用或升级显卡驱动
2. 增加码率: -br 8000
3. 降低分辨率: -w 1280 -h 720
```

### 帧率低

**原因**: CPU 不足或编码慢
```bash
# 解决方案
1. 使用 C++ 版本 (性能更高 2-3 倍)
2. 启用 GPU 编码
3. 降低分辨率: -w 960 -h 540
4. 关闭其他应用
```

### 推流中断

**原因**: 网络丢包
```bash
# 解决方案
1. 检查网络连接: ping 目标 IP
2. 增加码率缓冲: -br 4000
3. 使用有线网络
4. 检查路由器设置
```

### 找不到 GPU 编码

**原因**: 驱动或硬件不支持
```bash
# 解决方案
1. NVIDIA: 升级 GeForce Game Ready 驱动
2. AMD: 升级 Radeon 驱动到 21.0+
3. Intel: 更新 Graphics 驱动
4. 切换到 CPU 编码: --cpu
```

## 📦 项目结构

```
udp推流发射器/
├── src/                          # C++ 源代码
│   ├── main.cpp                 # 主程序
│   ├── screen_capture.cpp       # 屏幕捕获
│   ├── encoder.cpp              # 视频编码
│   └── udp_streamer.cpp         # UDP 推流
│
├── .github/
│   ├── workflows/
│   │   ├── build.yml            # 主构建流程
│   │   ├── test.yml             # 测试流程
│   │   └── release.yml          # 发布流程
│   └── scripts/                 # 辅助脚本
│
├── udp_streamer.py              # Python 版本
├── CMakeLists.txt               # C++ 编译配置
├── Dockerfile                   # Docker 配置
├── docker-compose.yml           # Compose 配置
├── setup.py                     # Python 包配置
└── requirements.txt             # Python 依赖
```

## 🚀 GitHub Actions CI/CD

### 自动构建

每次 Push 时自动编译：
- ✅ C++ 版本 (Windows x64/x86)
- ✅ Python 版本 (Windows/Linux)
- ✅ Docker 镜像

### 自动发布

创建版本标签时自动发布：
```bash
git tag v1.0.0
git push origin v1.0.0
```

自动执行：
- ✅ 创建 GitHub Release
- ✅ 上传编译产物
- ✅ 发布到 PyPI
- ✅ 推送 Docker Hub
- ✅ 发送 Slack 通知

详细配置：[GITHUB_CI_CD.md](./GITHUB_CI_CD.md)

## 📚 文档

- [快速开始](./快速开始.txt) - 详细使用指南
- [CI/CD 指南](./GITHUB_CI_CD.md) - GitHub Actions 配置
- [快速参考](./QUICKSTART_CI_CD.md) - CI/CD 速查表

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

MIT License - 详见 [LICENSE](./LICENSE) 文件

## 💬 联系方式

- 提交 Issue: [GitHub Issues](https://github.com/yourusername/udp推流发射器/issues)
- 讨论: [GitHub Discussions](https://github.com/yourusername/udp推流发射器/discussions)

## 🙏 致谢

- FFmpeg 团队
- OBS 项目 (参考实现)
- GitHub Actions 社区

---

**最后更新**: 2024 年

⭐ 如果觉得有用，请给个 Star！
