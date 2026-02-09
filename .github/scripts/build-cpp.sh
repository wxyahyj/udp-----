#!/bin/bash
# C++ build script

set -e

echo "Building C++ UDP Streamer..."

# Create build directory
mkdir -p build
cd build

# Configure
echo "Configuring CMake..."
cmake -DCMAKE_BUILD_TYPE=Release ..

# Build
echo "Building..."
cmake --build . --config Release -j$(nproc)

# Check output
if [ -f "udp_streamer" ]; then
    echo "✓ Build successful"
    ./udp_streamer --help 2>&1 | head -5 || true
    ls -lh udp_streamer
else
    echo "✗ Build failed"
    exit 1
fi

cd ..
