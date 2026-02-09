#!/bin/bash
# FFmpeg setup script for GitHub Actions

set -e

OS=$1
ARCH=${2:-x64}

echo "Setting up FFmpeg for $OS ($ARCH)..."

case "$OS" in
  linux)
    echo "Installing FFmpeg on Linux..."
    sudo apt-get update
    sudo apt-get install -y ffmpeg libavcodec-dev libavformat-dev libswscale-dev
    ffmpeg -version | head -1
    ;;
  
  macos)
    echo "Installing FFmpeg on macOS..."
    brew install ffmpeg
    ffmpeg -version | head -1
    ;;
  
  windows)
    echo "Downloading FFmpeg for Windows..."
    curl -L -o ffmpeg.zip "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full-shared.zip"
    powershell -Command "Expand-Archive -Path 'ffmpeg.zip' -DestinationPath '.'"
    
    ffmpeg_dir=$(ls -d ffmpeg-* | head -1)
    echo "FFMPEG_PATH=$(pwd)/$ffmpeg_dir" >> $GITHUB_ENV
    echo "FFmpeg installed at: $(pwd)/$ffmpeg_dir"
    ;;
  
  *)
    echo "Unknown OS: $OS"
    exit 1
    ;;
esac

echo "✓ FFmpeg setup completed"
