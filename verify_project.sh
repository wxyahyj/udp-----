#!/bin/bash
# UDP 推流发射器 - 项目验证脚本

echo "====================================="
echo "UDP 推流发射器 - 项目验证"
echo "====================================="
echo ""

errors=0
warnings=0
success=0

# 检查函数
check_file() {
    local file=$1
    local desc=$2
    local optional=${3:-false}
    
    if [ -f "$file" ]; then
        echo "✓ $desc"
        ((success++))
        return 0
    else
        if [ "$optional" = true ]; then
            echo "⚠ $desc (可选，未找到)"
            ((warnings++))
            return 1
        else
            echo "✗ $desc (缺失)"
            ((errors++))
            return 1
        fi
    fi
}

echo "检查核心源代码文件..."
check_file "src/main.cpp" "C++ 主程序"
check_file "src/screen_capture.cpp" "屏幕捕获模块"
check_file "src/screen_capture.h" "屏幕捕获头文件"
check_file "src/encoder.cpp" "视频编码模块"
check_file "src/encoder.h" "编码器头文件"
check_file "src/udp_streamer.cpp" "UDP 推流模块"
check_file "src/udp_streamer.h" "推流器头文件"
check_file "udp_streamer.py" "Python 版本"

echo ""
echo "检查编译配置文件..."
check_file "CMakeLists.txt" "CMake 配置"
check_file "setup.py" "Python 包配置"
check_file "build.bat" "Windows 编译脚本" true
check_file "requirements.txt" "Python 依赖"

echo ""
echo "检查容器配置..."
check_file "Dockerfile" "Docker 镜像配置"
check_file "docker-compose.yml" "Docker Compose 配置"

echo ""
echo "检查 GitHub Actions 配置..."
check_file ".github/workflows/build.yml" "主构建工作流"
check_file ".github/workflows/test.yml" "测试工作流"
check_file ".github/workflows/release.yml" "发布工作流"
check_file ".github/scripts/setup-ffmpeg.sh" "FFmpeg 安装脚本"
check_file ".github/scripts/build-cpp.sh" "C++ 构建脚本"
check_file ".github/scripts/build-python.sh" "Python 构建脚本"

echo ""
echo "检查文档文件..."
check_file "README.md" "项目主文档"
check_file "LICENSE" "许可证"
check_file ".gitignore" "Git 忽略配置"
check_file "GITHUB_CI_CD.md" "CI/CD 详细文档"
check_file "DEPLOY_GITHUB.md" "GitHub 部署指南"
check_file "QUICKSTART_CI_CD.md" "CI/CD 快速参考"
check_file "CHECKLIST.md" "部署检查清单"
check_file "快速开始.txt" "快速开始指南"
check_file "GITHUB_SETUP_SUMMARY.txt" "部署总结文档"

echo ""
echo "====================================="
echo "验证结果"
echo "====================================="
echo ""
echo "✓ 成功: $success"
echo "⚠ 警告: $warnings"
echo "✗ 错误: $errors"

echo ""

# 检查 Git
echo "检查 Git 配置..."
if command -v git &> /dev/null; then
    git_version=$(git --version)
    echo "✓ Git 已安装: $git_version"
    
    if [ -d ".git" ]; then
        echo "✓ Git 仓库已初始化"
    else
        echo "⚠ Git 仓库未初始化 (需要运行: git init)"
    fi
else
    echo "✗ Git 未安装"
fi

# 检查 Python
echo ""
echo "检查 Python..."
if command -v python3 &> /dev/null; then
    python_version=$(python3 --version)
    echo "✓ Python 已安装: $python_version"
else
    echo "⚠ Python 未安装或不在 PATH 中"
fi

# 检查 CMake
echo ""
echo "检查 CMake..."
if command -v cmake &> /dev/null; then
    cmake_version=$(cmake --version | head -1)
    echo "✓ CMake 已安装: $cmake_version"
else
    echo "⚠ CMake 未安装或不在 PATH 中"
fi

# 检查 FFmpeg
echo ""
echo "检查 FFmpeg..."
if command -v ffmpeg &> /dev/null; then
    ffmpeg_version=$(ffmpeg -version 2>&1 | head -1)
    echo "✓ FFmpeg 已安装: $ffmpeg_version"
else
    echo "⚠ FFmpeg 未安装或不在 PATH 中"
fi

echo ""
echo "====================================="
echo "最终检查结果"
echo "====================================="
echo ""

total=$((success + warnings + errors))
echo "检查项总数: $total"
echo "✓ 成功: $success"
echo "⚠ 警告: $warnings"
echo "✗ 错误: $errors"

echo ""

if [ $errors -eq 0 ]; then
    echo "✅ 所有必要文件已准备好！"
    echo ""
    echo "下一步:"
    echo "  1. git init                  # 初始化 Git 仓库"
    echo "  2. git add .                 # 添加所有文件"
    echo "  3. git commit -m \"Initial\" # 提交初始版本"
    echo "  4. 在 GitHub 创建仓库"
    echo "  5. git remote add origin ... # 添加远程仓库"
    echo "  6. git push -u origin main   # 推送到 GitHub"
    echo ""
    exit 0
else
    echo "❌ 有 $errors 个文件缺失！请检查上述错误。"
    echo ""
    exit 1
fi
