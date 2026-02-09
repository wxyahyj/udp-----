# GitHub CI/CD 自动化构建指南

## 概述

本项目使用 GitHub Actions 进行自动化构建、测试和发布。支持以下功能：

- ✅ **自动编译** C++ 和 Python 版本
- ✅ **跨平台构建** (Windows, Linux, macOS)
- ✅ **自动测试** 代码质量、代码风格检查
- ✅ **Docker 构建** 和推送到 Docker Hub
- ✅ **自动发布** GitHub Release
- ✅ **PyPI 发布** Python 包
- ✅ **构建产物下载** 支持 Artifacts 下载

## 工作流文件说明

### 1. `.github/workflows/build.yml` - 主要构建流程

**触发条件：**
- Push 到 main/develop 分支
- 创建 v* 标签 (版本发布)
- Pull Request 到 main 分支
- 手动触发 (workflow_dispatch)

**包含的作业：**

#### build-windows-cpp
编译 C++ 版本 (x64 和 x86 架构)

```bash
# 自动执行
- 下载 FFmpeg
- 配置 CMake
- 编译 Release 版本
- 上传构建产物
```

#### build-python
编译 Python 版本 (Linux)

```bash
- 安装依赖
- 使用 PyInstaller 打包
- 生成独立可执行文件
- 上传产物
```

#### build-python-windows
编译 Python 版本 (Windows)

```bash
- 安装依赖
- 使用 PyInstaller 打包
- 生成 .exe 文件
- 上传产物
```

#### build-docker
构建 Docker 镜像

```bash
- 构建 Docker 镜像
- 推送到 Docker Hub (可选)
```

#### test-cpp
测试编译结果

```bash
- 下载构建产物
- 验证可执行文件
```

### 2. `.github/workflows/test.yml` - 测试流程

**触发条件：**
- Push 和 Pull Request

**包含的检查：**

- **test-python**: Python 代码质量检查
  - flake8 风格检查
  - black 代码格式化检查
  - 导入检查

- **test-cmake**: CMake 配置检查

- **code-quality**: 代码质量分析
  - pylint 检查
  - bandit 安全检查
  - safety 依赖检查

- **docker-build**: Docker 构建测试

### 3. `.github/workflows/release.yml` - 发布流程

**触发条件：**
- 创建 v* 标签
- 手动触发

**包含的作业：**

- **publish-release**: 创建 GitHub Release
  - 生成变更日志
  - 创建 Release 页面
  
- **publish-pypi**: 发布到 PyPI (可选)
  - 构建 Python 包
  - 上传到 PyPI
  
- **publish-docker**: 发布 Docker 镜像
  - 推送到 Docker Hub
  - 推送到 GitHub Container Registry
  
- **notify-release**: 发送 Slack 通知 (可选)

## 设置步骤

### 第一步：初始化 Git 仓库

```bash
# 在项目根目录
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/udp推流发射器.git
git push -u origin main
```

### 第二步：配置 GitHub Secrets

在 GitHub 仓库设置页面 (Settings → Secrets and variables → Actions)，添加以下 Secrets：

#### 必需：

无必需的 Secrets（GitHub Actions 默认可以编译）

#### 可选：

**Docker Hub 发布 (可选):**
```
DOCKER_USERNAME    # Docker Hub 用户名
DOCKER_PASSWORD    # Docker Hub 密码或 Token
```

**PyPI 发布 (可选):**
```
PYPI_API_TOKEN     # PyPI API Token (https://pypi.org/manage/account/)
```

**Slack 通知 (可选):**
```
SLACK_WEBHOOK_URL  # Slack Webhook URL
```

### 第三步：配置环境变量

编辑 `.github/workflows/build.yml`，更新以下内容：

```yaml
# 替换 repository URL
docker pull ${{ secrets.DOCKER_USERNAME }}/udp-streamer
```

### 第四步：创建版本标签

```bash
# 创建标签触发发布流程
git tag v1.0.0
git push origin v1.0.0
```

## 使用示例

### 自动构建流程

1. **推送代码触发构建：**
   ```bash
   git push origin main
   ```
   → Actions 自动编译 C++、Python、Docker

2. **创建版本标签发布：**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
   → 自动创建 Release，生成可下载的构建产物

### 手动触发构建

在 GitHub 仓库页面：
1. 点击 "Actions" 标签
2. 选择工作流 (如 "Build UDP Streamer")
3. 点击 "Run workflow"
4. 输入参数 (如需要)
5. 点击 "Run workflow"

### 下载构建产物

**方式一：从 Artifacts 下载**
```
Actions → 最新 Run → Artifacts → 选择产物 → 下载
```

**方式二：从 Release 页面下载**
```
Releases → 选择版本 → 下载对应的二进制文件
```

## 构建产物说明

### 生成的文件

| 产物 | 文件名 | 说明 |
|------|--------|------|
| C++ Windows x64 | `udp_streamer.exe` | 最高性能 |
| C++ Windows x86 | `udp_streamer.exe` | 32位兼容 |
| Python Windows | `udp_streamer.exe` | PyInstaller 打包 |
| Python Linux | `udp_streamer` | PyInstaller 打包 |
| Docker | `udp-streamer:v1.0.0` | Docker 镜像 |

### 下载链接示例

```
https://github.com/yourusername/udp推流发射器/releases/download/v1.0.0/udp_streamer.exe
```

## 工作流依赖关系

```
build-windows-cpp ─┐
build-python      ├─→ release
build-python-w... ├─→ publish-release
build-docker  ────┘
                  → publish-pypi
                  → publish-docker
                  → notify-release
```

## 常见问题

### Q: 如何跳过某些工作流？

**A:** 在 commit message 中包含跳过标记：
```bash
git commit -m "Fix typo [skip ci]"
```

### Q: 如何修改构建参数？

**A:** 编辑 `.github/workflows/build.yml`：

```yaml
- name: Configure CMake
  run: |
    cmake -DCMAKE_BUILD_TYPE=Release \
          -DENABLE_GPU=ON \
          ..
```

### Q: 构建失败如何调试？

**A:** 
1. 查看 Actions 日志
2. 本地重现问题
3. 推送修复
4. 查看新的 Actions 运行

### Q: 如何禁用某个工作流？

**A:** 在工作流文件顶部注释掉触发条件：

```yaml
# on:
#   push:
#     branches: [ main ]
```

## 高级配置

### 矩阵构建 (多配置)

```yaml
strategy:
  matrix:
    os: [windows-latest, ubuntu-latest]
    arch: [x64, x86]
    python-version: ['3.8', '3.9', '3.10']
```

### 条件步骤

```yaml
- name: Conditional step
  if: startsWith(github.ref, 'refs/tags/v')
  run: echo "This is a release"
```

### 缓存加速

```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
```

## 性能优化

1. **使用缓存** (已配置)
   - Python pip 缓存
   - Docker 层缓存

2. **并行构建** (已配置)
   - 多个 OS/架构同时构建
   - 减少总构建时间

3. **选择性构建**
   - 只在必需时构建 Docker
   - 只在发布时上传 PyPI

## 安全考虑

1. **Secrets 管理**
   - 从不在日志中打印 Secrets
   - 使用 GitHub Secrets 存储敏感信息
   - 定期轮换 Token

2. **权限管理**
   - 仅在需要时请求权限
   - 使用最小权限原则
   - 定期审查工作流权限

3. **依赖检查**
   - bandit 检查安全漏洞
   - safety 检查依赖漏洞
   - 定期更新依赖

## 参考资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Workflow 语法](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

## 许可证

MIT License - 详见 LICENSE 文件
