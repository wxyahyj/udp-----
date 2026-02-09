#pragma once

#include <cstdint>
#include <vector>
#include <memory>
#include <thread>
#include <atomic>
#include <queue>
#include <mutex>
#include <condition_variable>

struct Frame {
    std::vector<uint8_t> data;
    int width;
    int height;
    int pitch;
    uint64_t timestamp;
    int format; // 0: RGB, 1: YUV420
};

class ScreenCapture {
public:
    ScreenCapture(int width, int height, int fps);
    ~ScreenCapture();

    bool Start();
    void Stop();
    std::shared_ptr<Frame> GetFrame();
    bool IsRunning() const { return running_; }

private:
    void CaptureThread();
    std::shared_ptr<Frame> CaptureScreenDXGI();

    int width_;
    int height_;
    int fps_;
    std::atomic<bool> running_{false};
    std::thread capture_thread_;
    
    std::queue<std::shared_ptr<Frame>> frame_queue_;
    std::mutex queue_mutex_;
    std::condition_variable cv_;
    static constexpr int MAX_QUEUE_SIZE = 3;
};
