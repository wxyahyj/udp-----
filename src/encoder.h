#pragma once

#include <cstdint>
#include <vector>
#include <memory>
#include <queue>
#include <thread>
#include <atomic>
#include <mutex>
#include <condition_variable>

extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
#include <libswscale/swscale.h>
}

struct EncodedPacket {
    std::vector<uint8_t> data;
    uint64_t timestamp;
    bool is_key_frame;
};

class Encoder {
public:
    Encoder(int width, int height, int bitrate_kbps, int fps);
    ~Encoder();

    bool Initialize(const char* codec_name = "h264_nvenc"); // GPU 编码
    void Encode(const uint8_t* rgb_data, int pitch);
    std::shared_ptr<EncodedPacket> GetPacket();
    void Stop();

private:
    int width_;
    int height_;
    int bitrate_kbps_;
    int fps_;
    
    AVCodecContext* codec_ctx_ = nullptr;
    SwsContext* sws_ctx_ = nullptr;
    AVFrame* frame_ = nullptr;
    
    std::queue<std::shared_ptr<EncodedPacket>> packet_queue_;
    std::mutex queue_mutex_;
    std::condition_variable cv_;
    std::atomic<bool> initialized_{false};
};
