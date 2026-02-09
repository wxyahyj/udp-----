#!/usr/bin/env pwsh
<#
.SYNOPSIS
    验证 UDP 推流发射器项目的完整性

.DESCRIPTION
    检查所有必要文件是否存在，为 GitHub 部署做准备

.EXAMPLE
    .\verify_project.ps1
#>

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "UDP 推流发射器 - 项目验证" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$errors = @()
$warnings = @()
$success = @()

# 检查函数
function Test-File {
    param(
        [string]$Path,
        [string]$Description,
        [bool]$Optional = $false
    )
    
    if (Test-Path $Path) {
        $success += "✓ $Description"
        return $true
    } else {
        if ($Optional) {
            $warnings += "⚠ $Description (可选，未找到)"
            return $false
        } else {
            $errors += "✗ $Description (缺失)"
            return $false
        }
    }
}

Write-Host "检查核心源代码文件..." -ForegroundColor Yellow
Test-File "src/main.cpp" "C++ 主程序" | Out-Null
Test-File "src/screen_capture.cpp" "屏幕捕获模块" | Out-Null
Test-File "src/screen_capture.h" "屏幕捕获头文件" | Out-Null
Test-File "src/encoder.cpp" "视频编码模块" | Out-Null
Test-File "src/encoder.h" "编码器头文件" | Out-Null
Test-File "src/udp_streamer.cpp" "UDP 推流模块" | Out-Null
Test-File "src/udp_streamer.h" "推流器头文件" | Out-Null
Test-File "udp_streamer.py" "Python 版本" | Out-Null

Write-Host ""
Write-Host "检查编译配置文件..." -ForegroundColor Yellow
Test-File "CMakeLists.txt" "CMake 配置" | Out-Null
Test-File "setup.py" "Python 包配置" | Out-Null
Test-File "build.bat" "Windows 编译脚本" | Out-Null
Test-File "requirements.txt" "Python 依赖" | Out-Null

Write-Host ""
Write-Host "检查容器配置..." -ForegroundColor Yellow
Test-File "Dockerfile" "Docker 镜像配置" | Out-Null
Test-File "docker-compose.yml" "Docker Compose 配置" | Out-Null

Write-Host ""
Write-Host "检查 GitHub Actions 配置..." -ForegroundColor Yellow
Test-File ".github/workflows/build.yml" "主构建工作流" | Out-Null
Test-File ".github/workflows/test.yml" "测试工作流" | Out-Null
Test-File ".github/workflows/release.yml" "发布工作流" | Out-Null
Test-File ".github/scripts/setup-ffmpeg.sh" "FFmpeg 安装脚本" | Out-Null
Test-File ".github/scripts/build-cpp.sh" "C++ 构建脚本" | Out-Null
Test-File ".github/scripts/build-python.sh" "Python 构建脚本" | Out-Null

Write-Host ""
Write-Host "检查文档文件..." -ForegroundColor Yellow
Test-File "README.md" "项目主文档" | Out-Null
Test-File "LICENSE" "许可证" | Out-Null
Test-File ".gitignore" "Git 忽略配置" | Out-Null
Test-File "GITHUB_CI_CD.md" "CI/CD 详细文档" | Out-Null
Test-File "DEPLOY_GITHUB.md" "GitHub 部署指南" | Out-Null
Test-File "QUICKSTART_CI_CD.md" "CI/CD 快速参考" | Out-Null
Test-File "CHECKLIST.md" "部署检查清单" | Out-Null
Test-File "快速开始.txt" "快速开始指南" | Out-Null
Test-File "GITHUB_SETUP_SUMMARY.txt" "部署总结文档" | Out-Null

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "验证结果" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

if ($success.Count -gt 0) {
    Write-Host "成功 ($($success.Count) 个):" -ForegroundColor Green
    foreach ($item in $success) {
        Write-Host $item -ForegroundColor Green
    }
    Write-Host ""
}

if ($warnings.Count -gt 0) {
    Write-Host "警告 ($($warnings.Count) 个):" -ForegroundColor Yellow
    foreach ($item in $warnings) {
        Write-Host $item -ForegroundColor Yellow
    }
    Write-Host ""
}

if ($errors.Count -gt 0) {
    Write-Host "错误 ($($errors.Count) 个):" -ForegroundColor Red
    foreach ($item in $errors) {
        Write-Host $item -ForegroundColor Red
    }
    Write-Host ""
}

Write-Host "=====================================" -ForegroundColor Cyan

# 检查 Git
Write-Host ""
Write-Host "检查 Git 配置..." -ForegroundColor Yellow

if (Get-Command git -ErrorAction SilentlyContinue) {
    $gitVersion = git --version
    Write-Host "✓ Git 已安装: $gitVersion" -ForegroundColor Green
    
    if (Test-Path ".git") {
        Write-Host "✓ Git 仓库已初始化" -ForegroundColor Green
    } else {
        Write-Host "⚠ Git 仓库未初始化 (需要运行: git init)" -ForegroundColor Yellow
    }
} else {
    Write-Host "✗ Git 未安装" -ForegroundColor Red
}

# 检查 Python
Write-Host ""
Write-Host "检查 Python..." -ForegroundColor Yellow

if (Get-Command python -ErrorAction SilentlyContinue) {
    $pythonVersion = python --version
    Write-Host "✓ Python 已安装: $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "⚠ Python 未安装或不在 PATH 中" -ForegroundColor Yellow
}

# 检查 CMake
Write-Host ""
Write-Host "检查 CMake..." -ForegroundColor Yellow

if (Get-Command cmake -ErrorAction SilentlyContinue) {
    $cmakeVersion = cmake --version | Select-Object -First 1
    Write-Host "✓ CMake 已安装: $cmakeVersion" -ForegroundColor Green
} else {
    Write-Host "⚠ CMake 未安装或不在 PATH 中" -ForegroundColor Yellow
}

# 检查 FFmpeg
Write-Host ""
Write-Host "检查 FFmpeg..." -ForegroundColor Yellow

if (Get-Command ffmpeg -ErrorAction SilentlyContinue) {
    $ffmpegVersion = ffmpeg -version | Select-Object -First 1
    Write-Host "✓ FFmpeg 已安装: $ffmpegVersion" -ForegroundColor Green
} else {
    Write-Host "⚠ FFmpeg 未安装或不在 PATH 中" -ForegroundColor Yellow
}

# 最终总结
Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "最终检查结果" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$totalFiles = $success.Count + $warnings.Count + $errors.Count
Write-Host "检查项总数: $totalFiles" -ForegroundColor Cyan
Write-Host "✓ 成功: $($success.Count)" -ForegroundColor Green
Write-Host "⚠ 警告: $($warnings.Count)" -ForegroundColor Yellow
Write-Host "✗ 错误: $($errors.Count)" -ForegroundColor Red

Write-Host ""

if ($errors.Count -eq 0) {
    Write-Host "✅ 所有必要文件已准备好！" -ForegroundColor Green
    Write-Host ""
    Write-Host "下一步:" -ForegroundColor Green
    Write-Host "  1. git init                  # 初始化 Git 仓库" -ForegroundColor Gray
    Write-Host "  2. git add .                 # 添加所有文件" -ForegroundColor Gray
    Write-Host "  3. git commit -m \"Initial\" # 提交初始版本" -ForegroundColor Gray
    Write-Host "  4. 在 GitHub 创建仓库" -ForegroundColor Gray
    Write-Host "  5. git remote add origin ... # 添加远程仓库" -ForegroundColor Gray
    Write-Host "  6. git push -u origin main   # 推送到 GitHub" -ForegroundColor Gray
    Write-Host ""
    exit 0
} else {
    Write-Host "❌ 有 $($errors.Count) 个文件缺失！请检查上述错误。" -ForegroundColor Red
    Write-Host ""
    exit 1
}
