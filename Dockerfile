FROM ubuntu:22.04

LABEL maintainer="UDP Streamer"
LABEL description="High-performance UDP streaming sender"

# 安装依赖
RUN apt-get update && apt-get install -y \
    python3.10 \
    python3-pip \
    ffmpeg \
    xvfb \
    x11-apps \
    libsm6 \
    libxext6 \
    libxrender-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /app

# 复制项目文件
COPY requirements.txt .
COPY udp_streamer.py .

# 安装 Python 依赖
RUN pip3 install --no-cache-dir -r requirements.txt

# 设置虚拟显示
ENV DISPLAY=:99

# 启动虚拟显示和应用
ENTRYPOINT ["python3", "udp_streamer.py"]
CMD ["-ip", "127.0.0.1", "-p", "10000"]
