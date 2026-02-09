#!/bin/bash
# Python build script using PyInstaller

set -e

echo "Building Python UDP Streamer..."

# Install dependencies
echo "Installing dependencies..."
pip install --upgrade pip setuptools wheel
pip install -r requirements.txt
pip install pyinstaller

# Build
echo "Building with PyInstaller..."
pyinstaller --onefile \
  --name udp_streamer \
  --add-data "." \
  --hidden-import=cv2 \
  --hidden-import=mss \
  --collect-all cv2 \
  --windowed \
  --icon=assets/icon.ico 2>/dev/null || \
pyinstaller --onefile \
  --name udp_streamer \
  --hidden-import=cv2 \
  --hidden-import=mss \
  --collect-all cv2 \
  udp_streamer.py

# Check output
if [ -f "dist/udp_streamer" ]; then
    echo "✓ Build successful"
    ls -lh dist/udp_streamer
elif [ -f "dist/udp_streamer.exe" ]; then
    echo "✓ Build successful (Windows)"
    ls -lh dist/udp_streamer.exe
else
    echo "✗ Build failed"
    exit 1
fi
