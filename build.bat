@echo off
REM UDP 推流发射器编译脚本

setlocal enabledelayedexpansion

REM 检查 CMake
cmake --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到 CMake，请先安装 CMake
    exit /b 1
)

REM 检查 FFmpeg
echo 检查 FFmpeg 库...
if not exist "C:\ffmpeg" (
    echo.
    echo 警告: FFmpeg 未找到
    echo.
    echo 请按照以下步骤安装 FFmpeg:
    echo   方式 1 (推荐): 运行安装脚本
    echo     powershell -ExecutionPolicy Bypass -File install-ffmpeg.ps1
    echo.
    echo   方式 2: 手动安装
    echo     1. 下载: https://ffmpeg.org/download.html
    echo     2. 解压到: C:\ffmpeg
    echo     3. 添加环境变量 FFMPEG_PATH=C:\ffmpeg
    echo     4. 运行此脚本
    echo.
    pause
    exit /b 1
)

REM 创建构建目录
if not exist build mkdir build
cd build

REM 配置 CMake
set FFMPEG_PATH=C:\ffmpeg
cmake -G "Visual Studio 17 2022" -A x64 ^
    -DFFMPEG_INCLUDE_DIRS="%FFMPEG_PATH%\include" ^
    -DFFMPEG_LIBRARIES="%FFMPEG_PATH%\lib\avcodec.lib;%FFMPEG_PATH%\lib\avformat.lib;%FFMPEG_PATH%\lib\swscale.lib" ^
    ..

if errorlevel 1 (
    echo CMake 配置失败
    exit /b 1
)

REM 编译
echo 正在编译...
cmake --build . --config Release

if errorlevel 1 (
    echo 编译失败
    exit /b 1
)

echo.
echo ============ 编译成功 ============
echo 可执行文件: build\Release\udp_streamer.exe
echo.
echo 使用示例:
echo   udp_streamer.exe -ip 192.168.1.100 -p 10000
echo   udp_streamer.exe -w 1280 -h 720 -fps 60 -br 8000
echo.
echo 参数说明:
echo   -w     分辨率宽度 (默认 1920)
echo   -h     分辨率高度 (默认 1080)
echo   -fps   帧率 (默认 30)
echo   -br    码率 kbps (默认 5000)
echo   -ip    目标 IP (默认 127.0.0.1)
echo   -p     目标端口 (默认 10000)
echo ====================================

pause
