#include "screen_capture.h"
#include "encoder.h"
#include "udp_streamer.h"
#include <iostream>
#include <chrono>
#include <iomanip>

int main(int argc, char* argv[]) {
    // 配置参数
    int width = 1920;
    int height = 1080;
    int fps = 30;
    int bitrate = 5000; // kbps
    std::string udp_host = "127.0.0.1";
    int udp_port = 10000;

    // 解析命令行参数
    for (int i = 1; i < argc; i++) {
        std::string arg = argv[i];
        if (arg == "-w" && i + 1 < argc) {
            width = std::stoi(argv[++i]);
        } else if (arg == "-h" && i + 1 < argc) {
            height = std::stoi(argv[++i]);
        } else if (arg == "-fps" && i + 1 < argc) {
            fps = std::stoi(argv[++i]);
        } else if (arg == "-br" && i + 1 < argc) {
            bitrate = std::stoi(argv[++i]);
        } else if (arg == "-ip" && i + 1 < argc) {
            udp_host = argv[++i];
        } else if (arg == "-p" && i + 1 < argc) {
            udp_port = std::stoi(argv[++i]);
        }
    }

    std::cout << "========== UDP 推流发射器 ==========" << std::endl;
    std::cout << "分辨率: " << width << "x" << height << std::endl;
    std::cout << "帧率: " << fps << " fps" << std::endl;
    std::cout << "码率: " << bitrate << " kbps" << std::endl;
    std::cout << "推流目标: " << udp_host << ":" << udp_port << std::endl;
    std::cout << "====================================" << std::endl;

    try {
        // 初始化模块
        ScreenCapture capture(width, height, fps);
        Encoder encoder(width, height, bitrate, fps);
        UDPStreamer streamer(udp_host, udp_port);

        // 尝试 GPU 编码
        std::cout << "正在初始化 NVIDIA GPU 编码..." << std::endl;
        bool gpu_success = false;
        try {
            encoder.Initialize("h264_nvenc");
            gpu_success = true;
            std::cout << "✓ GPU 编码已启用 (NVIDIA)" << std::endl;
        } catch (...) {
            std::cout << "✗ 未找到 NVIDIA GPU，尝试 AMD VCE..." << std::endl;
            try {
                encoder.Initialize("h264_amf");
                gpu_success = true;
                std::cout << "✓ GPU 编码已启用 (AMD)" << std::endl;
            } catch (...) {
                std::cout << "⚠ 使用软件编码 (libx264) - 性能会降低" << std::endl;
                encoder.Initialize("libx264");
            }
        }

        if (!capture.Start()) {
            std::cerr << "屏幕捕获启动失败" << std::endl;
            return -1;
        }
        std::cout << "✓ 屏幕捕获已启动" << std::endl;

        if (!streamer.Start()) {
            std::cerr << "UDP 推流启动失败" << std::endl;
            return -1;
        }
        std::cout << "✓ UDP 推流已启动" << std::endl;

        // 统计信息
        uint64_t frame_count = 0;
        uint64_t total_bytes = 0;
        auto start_time = std::chrono::steady_clock::now();
        auto last_stat_time = start_time;

        std::cout << "\n开始推流... 按 Ctrl+C 停止\n" << std::endl;

        while (true) {
            // 获取屏幕帧
            auto frame = capture.GetFrame();
            if (frame) {
                // 编码
                encoder.Encode(frame->data.data(), frame->pitch);

                // 获取编码后的数据并发送
                std::shared_ptr<EncodedPacket> pkt;
                while ((pkt = encoder.GetPacket()) != nullptr) {
                    streamer.SendData(pkt->data.data(), pkt->data.size());
                    total_bytes += pkt->data.size();
                    frame_count++;
                }
            }

            // 定期显示统计信息
            auto now = std::chrono::steady_clock::now();
            auto elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - last_stat_time);
            
            if (elapsed.count() >= 5) {
                auto total_elapsed = std::chrono::duration_cast<std::chrono::seconds>(now - start_time);
                double fps_actual = frame_count / static_cast<double>(total_elapsed.count());
                double mbps = (total_bytes * 8) / (1024.0 * 1024.0 * total_elapsed.count());

                std::cout << std::fixed << std::setprecision(2);
                std::cout << "已发送: " << frame_count << " 帧 | "
                         << "实际帧率: " << fps_actual << " fps | "
                         << "码率: " << mbps << " Mbps" << std::endl;

                last_stat_time = now;
            }

            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }

    } catch (const std::exception& e) {
        std::cerr << "错误: " << e.what() << std::endl;
        return -1;
    }

    return 0;
}
