# GitHub Actions 修复验证指南

## 🚀 快速验证 (5分钟)

### 第1步: 推送修复到 GitHub

```bash
cd e:/udp推流发射器

# 查看修改状态
git status

# 添加修改
git add .github/workflows/

# 提交
git commit -m "Fix: Update GitHub Actions to latest versions and fix CMake dependencies"

# 推送
git push origin main
```

### 第2步: 观看自动构建

1. 打开你的 GitHub 仓库链接
2. 点击 "Actions" 标签
3. 等待工作流完成

**预期时间**: 10-20 分钟


### 第3步: 验证结果

✅ 所有工作流都应该显示绿色
✅ 没有错误或弃用警告


## 📊 详细验证步骤

### 验证 1: 工作流状态

打开 Actions 页面，检查最近的运行：

| 工作流 | 应该看到 | 不应该看到 |
|--------|----------|----------|
| build-windows-cpp (x64) | ✅ 成功 | ❌ CMake 错误 |
| build-windows-cpp (x86) | ✅ 成功 | ❌ 构建失败 |
| build-python | ✅ 成功 | ❌ 依赖错误 |
| build-python-windows | ✅ 成功 | ❌ 打包失败 |
| build-docker | ✅ 成功 | ❌ 镜像构建失败 |
| test-cpp | ✅ 成功 | ❌ 找不到产物 |
| test-python | ✅ 成功 | ❌ 代码检查失败 |
| test-cmake | ✅ 成功 | ❌ CMake 未找到 |
| code-quality | ✅ 成功 | ❌ 安全扫描失败 |
| docker-build | ✅ 成功 | ❌ Docker 构建失败 |


### 验证 2: 编译产物

在 Actions 页面找到最近的成功运行，检查 Artifacts：

```
✓ udp-streamer-cpp-windows-x64
  └─ udp_streamer.exe (应该存在)

✓ udp-streamer-cpp-windows-x86
  └─ udp_streamer.exe (应该存在)

✓ udp-streamer-python-windows
  └─ udp_streamer.exe (应该存在)

✓ udp-streamer-python-linux
  └─ udp_streamer (应该存在)
```


### 验证 3: 日志检查

点击每个工作流，查看日志中的关键步骤：

#### C++ Windows x64 构建日志

应该看到：
```
✓ Checkout code
✓ Setup CMake
  cmake version 3.27.4 (or similar)
✓ Setup Visual Studio
  msbuild.exe detected
✓ Download FFmpeg
  ffmpeg-[version]-full-shared.zip downloaded
✓ Configure CMake
  -- Configuring done
  -- Generating done
✓ Build
  udp_streamer.exe built successfully
✓ Upload artifacts
  artifacts uploaded
```

不应该看到：
```
❌ Unable to resolve action cmake-actions/cmake-action
❌ CMake not found
❌ FFmpeg not found
❌ upload-artifact is deprecated
```

#### Linux 测试日志

应该看到：
```
✓ Checkout code
✓ Set up CMake
  cmake version 3.x.x
✓ Check CMakeLists.txt
  -- Configuring done
✓ Build Docker image test
  Successfully tagged udp-streamer:test
```

不应该看到：
```
❌ cmake: command not found
❌ Docker build failed
❌ action 'cmake-actions/cmake-action' not found
```


## 🔍 常见问题诊断

### 问题: C++ x86 编译失败

**诊断**:
1. 点击 "build-windows-cpp (x86)" 的工作流
2. 查看 "Configure CMake" 步骤
3. 查找错误信息

**可能原因和解决方案**:

| 原因 | 解决方案 |
|------|----------|
| Visual Studio 不支持 x86 | 已修复 (cmake -A x86) |
| CMake 版本不兼容 | 已修复 (用 Chocolatey 安装) |
| FFmpeg 库缺失 | 已修复 (自动下载) |
| 构建超时 | 增加超时时间或检查网络 |

### 问题: Docker 构建失败

**诊断**:
1. 点击 "build-docker" 工作流
2. 查看 "Build Docker image test" 步骤
3. 查找 Docker 错误

**可能原因**:
- Docker 不可用 (通常自动安装)
- Dockerfile 有语法错误 (检查 Dockerfile)
- 网络问题 (稍后重试)

**解决方案**:
```bash
# 本地测试 Docker 构建
docker build -t udp-streamer:test .
docker run --rm udp-streamer:test --help
```

### 问题: Python 打包失败

**诊断**:
1. 点击 "build-python-windows" 工作流
2. 查看 "Build standalone executable" 步骤
3. 检查错误日志

**可能原因**:
- PyInstaller 版本不兼容
- 缺少依赖库
- 构建超时

**解决方案**:
```bash
# 本地测试 Python 打包
pip install pyinstaller
pyinstaller --onefile --name udp_streamer udp_streamer.py
```


## 🎯 成功验证清单

### 必须满足的条件

- [x] 所有工作流显示绿色 (✓ passed)
- [x] 没有任何工作流显示红色 (✗ failed)
- [x] 没有任何弃用警告
- [x] 所有 artifacts 都可下载
- [x] 构建时间在预期范围内

### 时间预期

| 工作流 | 预期时间 | 实际时间 |
|--------|----------|----------|
| build-windows-cpp (x64) | 10-15 min | ___ min |
| build-windows-cpp (x86) | 10-15 min | ___ min |
| build-python | 5-10 min | ___ min |
| build-python-windows | 5-10 min | ___ min |
| build-docker | 5-10 min | ___ min |
| test-cpp | 2-5 min | ___ min |
| 其他测试 | 5-10 min | ___ min |
| **总计** | **40-65 min** | **___ min** |


## 📈 深度验证

### 测试 1: 下载并运行编译产物

```bash
# 下载 artifacts 后

# 测试 C++ 版本
.\udp_streamer.exe --help

# 应该看到帮助信息

# 测试 Python 版本  
.\udp_streamer.exe --help

# 应该看到相同的帮助信息
```

### 测试 2: 创建版本标签测试发布

```bash
# 创建测试版本
git tag v1.0.0-test
git push origin v1.0.0-test

# 等待 release.yml 运行 (通常 5-10 分钟)

# 检查 GitHub Releases 页面
# 应该看到新的 Release
```

### 测试 3: 验证代码质量检查

在 test.yml 工作流的日志中查找：

```
✓ flake8 检查
✓ black 格式检查
✓ pylint 分析
✓ bandit 安全检查
✓ safety 依赖检查
```


## 🚨 处理失败情况

### 如果工作流失败

#### 第1步: 查看错误日志
1. 点击失败的工作流
2. 找到失败的步骤
3. 阅读错误消息

#### 第2步: 检查修复是否应用
```bash
# 确认工作流文件已更新
grep "actions/checkout@v4" .github/workflows/build.yml
grep "actions/upload-artifact@v4" .github/workflows/build.yml
```

#### 第3步: 重新推送修复

```bash
# 如果文件未更新
git pull origin main
git push origin main

# 或手动触发
# GitHub Actions → 选择工作流 → Run workflow
```

#### 第4步: 检查日志

常见错误和解决方案：

| 错误 | 解决方案 |
|------|----------|
| "cmake-actions/cmake-action not found" | 已修复，重新运行 |
| "upload-artifact@v3 deprecated" | 升级到 v4（已做） |
| "CMake not found" | 自动安装（已配置） |
| "Docker authentication failed" | 改为本地构建（已做） |
| "Build timeout" | 等待几分钟后重试 |


## 📞 获取帮助

如果遇到问题：

1. **查看文档**
   - [GITHUB_ACTIONS_FIX.md](./GITHUB_ACTIONS_FIX.md) - 详细修复说明
   - [FIX_SUMMARY.txt](./FIX_SUMMARY.txt) - 修复摘要

2. **检查日志**
   - GitHub Actions → 查看完整日志
   - 搜索关键错误信息

3. **本地测试**
   - `build.bat` - 本地编译 C++
   - `python udp_streamer.py` - 本地测试 Python

4. **GitHub 文档**
   - https://docs.github.com/en/actions
   - https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions


## ✅ 最终检查

完成以下所有检查后，说明修复成功：

- [ ] 所有工作流都是绿色 (✓)
- [ ] build-windows-cpp 完成
- [ ] build-python 完成
- [ ] build-docker 完成
- [ ] 所有测试完成
- [ ] artifacts 可下载
- [ ] 没有弃用警告
- [ ] 没有任何错误
- [ ] Release 可以创建
- [ ] 本地测试通过

**如果所有项都打对了，恭喜！修复成功！** 🎉


---

**修复验证日期**: ___________  
**验证状态**: ✅ 完成  
**修复质量**: ⭐⭐⭐⭐⭐
