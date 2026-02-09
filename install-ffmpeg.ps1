<#
.SYNOPSIS
    Windows FFmpeg 安装脚本

.DESCRIPTION
    自动下载并安装 FFmpeg 到 C:\ffmpeg

.EXAMPLE
    .\install-ffmpeg.ps1
#>

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "FFmpeg Windows 安装程序" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$FFMPEG_URL = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full-shared.zip"
$FFMPEG_ZIP = "$env:TEMP\ffmpeg.zip"
$FFMPEG_DIR = "C:\ffmpeg"
$MAX_RETRIES = 3

Write-Host "安装目标: $FFMPEG_DIR" -ForegroundColor Yellow
Write-Host ""

# 检查管理员权限
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "警告: 建议以管理员身份运行此脚本" -ForegroundColor Yellow
    Write-Host "否则可能无法安装到 C:\ffmpeg" -ForegroundColor Yellow
    Write-Host ""
    $response = Read-Host "是否继续? (Y/N)"
    if ($response -ne "Y" -and $response -ne "y") {
        Write-Host "安装已取消" -ForegroundColor Red
        exit 1
    }
}

# 创建临时目录
$tempDir = Join-Path $env:TEMP "ffmpeg_install_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
Write-Host "临时目录: $tempDir" -ForegroundColor Gray
Write-Host ""

# 下载 FFmpeg
Write-Host "正在下载 FFmpeg..." -ForegroundColor Yellow
$retryCount = 0
$downloadSuccess = $false

while ($retryCount -lt $MAX_RETRIES -and -not $downloadSuccess) {
    $retryCount++
    Write-Host "下载尝试 $retryCount/$MAX_RETRIES..." -ForegroundColor Gray
    
    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $FFMPEG_URL -OutFile $FFMPEG_ZIP -UseBasicParsing -TimeoutSec 300
        $ProgressPreference = 'Continue'
        
        $fileSize = (Get-Item $FFMPEG_ZIP).Length
        
        if ($fileSize -gt 50MB) {
            Write-Host "下载成功 (大小: $([math]::Round($fileSize/1MB, 2)) MB)" -ForegroundColor Green
            $downloadSuccess = $true
        } else {
            Write-Host "下载的文件太小 ($([math]::Round($fileSize/1MB, 2)) MB)，可能已损坏" -ForegroundColor Red
            Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
        }
    } catch {
        Write-Host "下载失败: $_" -ForegroundColor Red
        Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
    }
}

if (-not $downloadSuccess) {
    Write-Host "下载 FFmpeg 失败，已尝试 $MAX_RETRIES 次" -ForegroundColor Red
    Write-Host ""
    Write-Host "请手动下载:" -ForegroundColor Yellow
    Write-Host "  $FFMPEG_URL" -ForegroundColor Gray
    Write-Host ""
    Write-Host "然后解压到: $FFMPEG_DIR" -ForegroundColor Gray
    exit 1
}

Write-Host ""

# 解压 FFmpeg
Write-Host "正在解压 FFmpeg..." -ForegroundColor Yellow

try {
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($FFMPEG_ZIP, $tempDir)
    Write-Host "解压成功" -ForegroundColor Green
} catch {
    Write-Host "解压失败: $_" -ForegroundColor Red
    Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host ""

# 查找解压后的目录
$extractedDir = Get-ChildItem -Path $tempDir -Directory | Where-Object { $_.Name -like "ffmpeg-*" } | Select-Object -First 1

if (-not $extractedDir) {
    Write-Host "错误: 未找到解压后的 FFmpeg 目录" -ForegroundColor Red
    Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host "找到 FFmpeg 目录: $($extractedDir.Name)" -ForegroundColor Gray
Write-Host ""

# 删除旧的安装
if (Test-Path $FFMPEG_DIR) {
    Write-Host "删除旧的 FFmpeg 安装..." -ForegroundColor Yellow
    try {
        Remove-Item $FFMPEG_DIR -Recurse -Force
        Write-Host "旧安装已删除" -ForegroundColor Green
    } catch {
        Write-Host "警告: 无法删除旧安装: $_" -ForegroundColor Yellow
        Write-Host "请手动删除 $FFMPEG_DIR 后重试" -ForegroundColor Yellow
        Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        exit 1
    }
    Write-Host ""
}

# 移动到目标目录
Write-Host "正在安装到 $FFMPEG_DIR..." -ForegroundColor Yellow

try {
    Move-Item -Path $extractedDir.FullName -Destination $FFMPEG_DIR
    Write-Host "安装成功" -ForegroundColor Green
} catch {
    Write-Host "安装失败: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "请手动将以下目录移动到 $FFMPEG_DIR:" -ForegroundColor Yellow
    Write-Host "  $($extractedDir.FullName)" -ForegroundColor Gray
    Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
    exit 1
}

Write-Host ""

# 清理临时文件
Write-Host "清理临时文件..." -ForegroundColor Gray
Remove-Item $FFMPEG_ZIP -Force -ErrorAction SilentlyContinue
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue

# 验证安装
Write-Host "验证安装..." -ForegroundColor Yellow

$ffmpegExe = Join-Path $FFMPEG_DIR "bin\ffmpeg.exe"
if (Test-Path $ffmpegExe) {
    try {
        $version = & $ffmpegExe -version 2>&1 | Select-Object -First 1
        Write-Host "FFmpeg 已安装: $version" -ForegroundColor Green
    } catch {
        Write-Host "警告: 无法获取 FFmpeg 版本信息" -ForegroundColor Yellow
    }
} else {
    Write-Host "警告: 未找到 ffmpeg.exe" -ForegroundColor Yellow
}

Write-Host ""

# 设置环境变量
Write-Host "配置环境变量..." -ForegroundColor Yellow

$binPath = Join-Path $FFMPEG_DIR "bin"
$envPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
$ffmpegPath = [Environment]::GetEnvironmentVariable("FFMPEG_PATH", "Machine")

if ($envPath -notlike "*$binPath*") {
    Write-Host "添加 FFmpeg 到系统 PATH..." -ForegroundColor Gray
    
    if ($isAdmin) {
        [Environment]::SetEnvironmentVariable("Path", "$envPath;$binPath", "Machine")
        [Environment]::SetEnvironmentVariable("FFMPEG_PATH", $FFMPEG_DIR, "Machine")
        Write-Host "环境变量已设置" -ForegroundColor Green
    } else {
        Write-Host "需要管理员权限来设置系统环境变量" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "请手动添加以下到系统 PATH:" -ForegroundColor Yellow
        Write-Host "  $binPath" -ForegroundColor Gray
        Write-Host ""
        Write-Host "并设置环境变量 FFMPEG_PATH=$FFMPEG_DIR" -ForegroundColor Yellow
    }
} else {
    Write-Host "PATH 已包含 FFmpeg" -ForegroundColor Green
}

if ($ffmpegPath -ne $FFMPEG_DIR) {
    if ($isAdmin) {
        [Environment]::SetEnvironmentVariable("FFMPEG_PATH", $FFMPEG_DIR, "Machine")
    }
}

Write-Host ""
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "安装完成!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "安装位置: $FFMPEG_DIR" -ForegroundColor Cyan
Write-Host "可执行文件: $ffmpegExe" -ForegroundColor Cyan
Write-Host ""

if (-not $isAdmin) {
    Write-Host "注意: 请以管理员身份运行此脚本以设置环境变量" -ForegroundColor Yellow
    Write-Host ""
}

Write-Host "下一步:" -ForegroundColor Green
Write-Host "  1. 重新打开命令提示符或 PowerShell" -ForegroundColor Gray
Write-Host "  2. 运行: ffmpeg -version" -ForegroundColor Gray
Write-Host "  3. 运行: .\build.bat" -ForegroundColor Gray
Write-Host ""
