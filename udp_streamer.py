#!/usr/bin/env python3
"""
高性能 UDP 推流发射器 - Python 版本
支持硬件编码和低延迟推流
"""

import cv2
import subprocess
import socket
import argparse
import time
import threading
import queue
from pathlib import Path

class GPUEncoder:
    """GPU 硬件编码器"""
    
    def __init__(self, width, height, fps, bitrate_kbps, codec='h264_nvenc'):
        self.width = width
        self.height = height
        self.fps = fps
        self.bitrate_kbps = bitrate_kbps
        self.codec = codec
        self.process = None
        
    def start(self):
        """启动编码进程"""
        # NVIDIA NVENC 参数优化
        if self.codec == 'h264_nvenc':
            cmd = [
                'ffmpeg',
                '-f', 'rawvideo',
                '-pixel_format', 'bgr24',
                '-video_size', f'{self.width}x{self.height}',
                '-framerate', str(self.fps),
                '-i', 'pipe:0',
                '-c:v', 'h264_nvenc',
                '-preset', 'low',  # 低延迟预设
                '-b:v', f'{self.bitrate_kbps}k',
                '-g', str(self.fps),  # GOP 大小 = 1秒
                '-bf', '0',  # 无 B 帧
                '-f', 'rtp',
                'rtp://127.0.0.1:10000'
            ]
        else:
            # libx264 软编码
            cmd = [
                'ffmpeg',
                '-f', 'rawvideo',
                '-pixel_format', 'bgr24',
                '-video_size', f'{self.width}x{self.height}',
                '-framerate', str(self.fps),
                '-i', 'pipe:0',
                '-c:v', 'libx264',
                '-preset', 'ultrafast',  # 最快编码速度
                '-tune', 'zerolatency',  # 零延迟模式
                '-b:v', f'{self.bitrate_kbps}k',
                '-g', str(self.fps),
                '-bf', '0',
                '-f', 'rtp',
                'rtp://127.0.0.1:10000'
            ]
        
        self.process = subprocess.Popen(
            cmd,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            bufsize=0
        )
    
    def send_frame(self, frame):
        """发送原始视频帧"""
        if self.process and frame is not None:
            try:
                self.process.stdin.write(frame.tobytes())
                self.process.stdin.flush()
            except Exception as e:
                print(f"发送帧失败: {e}")
    
    def stop(self):
        """停止编码器"""
        if self.process:
            self.process.stdin.close()
            self.process.wait(timeout=5)


class ScreenCaptureThread(threading.Thread):
    """屏幕捕获线程"""
    
    def __init__(self, width, height, fps, frame_queue):
        super().__init__(daemon=True)
        self.width = width
        self.height = height
        self.fps = fps
        self.frame_queue = frame_queue
        self.running = False
        self.frame_count = 0
        
    def run(self):
        """捕获屏幕"""
        self.running = True
        cap = cv2.VideoCapture(0)  # 使用桌面捐获
        
        # 使用 DXGI 捕获（Windows 特定）
        try:
            import mss
            monitor = mss.mss().monitors[1]
            
            frame_time = 1.0 / self.fps
            last_time = time.time()
            
            while self.running:
                with mss.mss() as sct:
                    screenshot = sct.grab(monitor)
                    frame = cv2.cvtColor(
                        cv2.UMat(screenshot).get_mat(),
                        cv2.COLOR_BGRA2BGR
                    )
                    frame = cv2.resize(frame, (self.width, self.height))
                    
                    if self.frame_queue.qsize() < 3:
                        self.frame_queue.put(frame)
                    
                    self.frame_count += 1
                    
                    elapsed = time.time() - last_time
                    sleep_time = max(0, frame_time - elapsed)
                    if sleep_time > 0:
                        time.sleep(sleep_time)
                    last_time = time.time()
                    
        except ImportError:
            print("未找到 mss 库，使用 OpenCV 捕获...")
            # Fallback: 使用 OpenCV 的桌面捕获
            # 注: 这种方式性能不如 mss
            cap = cv2.VideoCapture(-1, cv2.CAP_DSHOW)
            
            while self.running:
                ret, frame = cap.read()
                if ret:
                    frame = cv2.resize(frame, (self.width, self.height))
                    if self.frame_queue.qsize() < 3:
                        self.frame_queue.put(frame)
            
            cap.release()


class UDPStreamer:
    """UDP 推流器"""
    
    def __init__(self, width, height, fps, bitrate_kbps, 
                 target_ip, target_port, use_gpu=True):
        self.width = width
        self.height = height
        self.fps = fps
        self.bitrate_kbps = bitrate_kbps
        self.target_ip = target_ip
        self.target_port = target_port
        self.use_gpu = use_gpu
        
        self.frame_queue = queue.Queue(maxsize=3)
        self.running = False
        
        self.stats_frame_count = 0
        self.stats_bytes_sent = 0
        self.stats_start_time = time.time()
        
    def start(self):
        """启动推流器"""
        print("=" * 50)
        print("UDP 推流发射器 - Python 版本")
        print("=" * 50)
        print(f"分辨率: {self.width}x{self.height}")
        print(f"帧率: {self.fps} fps")
        print(f"码率: {self.bitrate_kbps} kbps")
        print(f"目标: {self.target_ip}:{self.target_port}")
        print("=" * 50)
        
        self.running = True
        
        # 启动屏幕捕获线程
        capture_thread = ScreenCaptureThread(
            self.width, self.height, self.fps, self.frame_queue
        )
        capture_thread.start()
        print("✓ 屏幕捕获已启动")
        
        # 初始化编码器
        codec = 'h264_nvenc' if self.use_gpu else 'libx264'
        encoder = GPUEncoder(self.width, self.height, self.fps, 
                           self.bitrate_kbps, codec)
        
        try:
            encoder.start()
            print(f"✓ 编码器已启动 ({codec})")
        except Exception as e:
            print(f"✗ 编码器启动失败: {e}")
            print("  尝试使用软编码...")
            codec = 'libx264'
            encoder = GPUEncoder(self.width, self.height, self.fps,
                               self.bitrate_kbps, codec)
            encoder.start()
            print(f"✓ 编码器已启动 ({codec})")
        
        # 初始化 UDP Socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.setsockopt(socket.SOL_SOCKET, socket.SO_SNDBUF, 10 * 1024 * 1024)
        print("✓ UDP 推流已启动\n")
        print("开始推流... 按 Ctrl+C 停止\n")
        
        # 主推流循环
        last_stat_time = time.time()
        
        try:
            while self.running:
                try:
                    frame = self.frame_queue.get(timeout=1)
                    if frame is not None:
                        encoder.send_frame(frame)
                        self.stats_frame_count += 1
                except queue.Empty:
                    continue
                
                # 统计信息
                now = time.time()
                if now - last_stat_time >= 5:
                    elapsed = now - self.stats_start_time
                    fps_actual = self.stats_frame_count / elapsed
                    mbps = (self.stats_bytes_sent * 8) / (1024 * 1024 * elapsed)
                    
                    print(f"已发送: {self.stats_frame_count} 帧 | "
                          f"实际帧率: {fps_actual:.2f} fps | "
                          f"码率: {mbps:.2f} Mbps")
                    
                    last_stat_time = now
                    
        except KeyboardInterrupt:
            print("\n\n停止推流...")
        finally:
            self.running = False
            encoder.stop()
            sock.close()
            print("✓ 已关闭")


def main():
    parser = argparse.ArgumentParser(
        description='UDP 推流发射器',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog='''
示例:
  python udp_streamer.py -ip 192.168.1.100 -p 10000
  python udp_streamer.py -w 1280 -h 720 -fps 60 -br 8000
  python udp_streamer.py --cpu  # 使用 CPU 编码
        '''
    )
    
    parser.add_argument('-w', '--width', type=int, default=1920,
                       help='分辨率宽度 (默认: 1920)')
    parser.add_argument('-h', '--height', type=int, default=1080,
                       help='分辨率高度 (默认: 1080)')
    parser.add_argument('-fps', type=int, default=30,
                       help='帧率 (默认: 30)')
    parser.add_argument('-br', '--bitrate', type=int, default=5000,
                       help='码率 kbps (默认: 5000)')
    parser.add_argument('-ip', '--ip', default='127.0.0.1',
                       help='目标 IP (默认: 127.0.0.1)')
    parser.add_argument('-p', '--port', type=int, default=10000,
                       help='目标端口 (默认: 10000)')
    parser.add_argument('--cpu', action='store_true',
                       help='使用 CPU 编码而不是 GPU')
    
    args = parser.parse_args()
    
    streamer = UDPStreamer(
        width=args.width,
        height=args.height,
        fps=args.fps,
        bitrate_kbps=args.bitrate,
        target_ip=args.ip,
        target_port=args.port,
        use_gpu=not args.cpu
    )
    
    streamer.start()


if __name__ == '__main__':
    main()
