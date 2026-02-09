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
    FFMPEG_URL="https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-full-shared.zip"
    FFMPEG_ZIP="ffmpeg.zip"
    
    MAX_RETRIES=3
    RETRY_COUNT=0
    DOWNLOAD_SUCCESS=false
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ] && [ "$DOWNLOAD_SUCCESS" = false ]; do
      echo "Download attempt $((RETRY_COUNT + 1))/$MAX_RETRIES..."
      
      if curl -L -o "$FFMPEG_ZIP" "$FFMPEG_URL" --retry 3 --retry-delay 5; then
        FILE_SIZE=$(stat -c%s "$FFMPEG_ZIP" 2>/dev/null || stat -f%z "$FFMPEG_ZIP" 2>/dev/null || echo "0")
        
        if [ "$FILE_SIZE" -gt 50000000 ]; then
          echo "Download completed successfully (size: $FILE_SIZE bytes)"
          DOWNLOAD_SUCCESS=true
        else
          echo "Downloaded file is too small ($FILE_SIZE bytes), may be corrupted"
          rm -f "$FFMPEG_ZIP"
          RETRY_COUNT=$((RETRY_COUNT + 1))
        fi
      else
        echo "Download failed with curl exit code: $?"
        rm -f "$FFMPEG_ZIP"
        RETRY_COUNT=$((RETRY_COUNT + 1))
      fi
    done
    
    if [ "$DOWNLOAD_SUCCESS" = false ]; then
      echo "Failed to download FFmpeg after $MAX_RETRIES attempts"
      exit 1
    fi
    
    echo "Extracting FFmpeg..."
    if ! powershell -Command "
      try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        [System.IO.Compression.ZipFile]::ExtractToDirectory('$FFMPEG_ZIP', '.')
        exit 0
      } catch {
        Write-Error \"Extraction failed: \$_\"
        exit 1
      }
    "; then
      echo "Failed to extract FFmpeg archive"
      rm -f "$FFMPEG_ZIP"
      exit 1
    fi
    
    rm -f "$FFMPEG_ZIP"
    
    ffmpeg_dir=$(ls -d ffmpeg-* 2>/dev/null | head -1)
    if [ -z "$ffmpeg_dir" ] || [ ! -d "$ffmpeg_dir" ]; then
      echo "Error: FFmpeg directory not found after extraction"
      exit 1
    fi
    
    echo "FFMPEG_PATH=$(pwd)/$ffmpeg_dir" >> $GITHUB_ENV
    echo "FFmpeg installed at: $(pwd)/$ffmpeg_dir"
    ;;
  
  *)
    echo "Unknown OS: $OS"
    exit 1
    ;;
esac

echo "✓ FFmpeg setup completed"
