#include "screen_capture.h"
#include <windows.h>
#include <chrono>
#include <cstring>

ScreenCapture::ScreenCapture(int width, int height, int fps)
    : width_(width), height_(height), fps_(fps) {}

ScreenCapture::~ScreenCapture() {
    Stop();
}

bool ScreenCapture::Start() {
    if (running_) return false;
    
    running_ = true;
    capture_thread_ = std::thread(&ScreenCapture::CaptureThread, this);
    return true;
}

void ScreenCapture::Stop() {
    running_ = false;
    if (capture_thread_.joinable()) {
        cv_.notify_all();
        capture_thread_.join();
    }
}

std::shared_ptr<Frame> ScreenCapture::GetFrame() {
    std::unique_lock<std::mutex> lock(queue_mutex_);
    if (frame_queue_.empty()) {
        return nullptr;
    }
    auto frame = frame_queue_.front();
    frame_queue_.pop();
    return frame;
}

void ScreenCapture::CaptureThread() {
    auto frame_interval = std::chrono::milliseconds(1000 / fps_);
    auto last_capture = std::chrono::steady_clock::now();

    while (running_) {
        auto now = std::chrono::steady_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::milliseconds>(now - last_capture);

        if (elapsed >= frame_interval) {
            auto frame = CaptureScreenDXGI();
            if (frame) {
                {
                    std::unique_lock<std::mutex> lock(queue_mutex_);
                    if (frame_queue_.size() >= MAX_QUEUE_SIZE) {
                        frame_queue_.pop(); // 丢弃最旧的帧
                    }
                    frame_queue_.push(frame);
                    frame->timestamp = std::chrono::duration_cast<std::chrono::milliseconds>(
                        std::chrono::steady_clock::now().time_since_epoch()).count();
                }
                cv_.notify_one();
            }
            last_capture = now;
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }
}

std::shared_ptr<Frame> ScreenCapture::CaptureScreenDXGI() {
    auto frame = std::make_shared<Frame>();
    frame->width = width_;
    frame->height = height_;
    frame->format = 0; // RGB

    // GDI 屏幕捕获（简化版本）
    HDC hdc = GetDC(nullptr);
    HDC memdc = CreateCompatibleDC(hdc);
    HBITMAP hbm = CreateCompatibleBitmap(hdc, width_, height_);
    
    SelectObject(memdc, hbm);
    BitBlt(memdc, 0, 0, width_, height_, hdc, 0, 0, SRCCOPY);

    // 获取位图数据
    BITMAPINFOHEADER bi = {};
    bi.biSize = sizeof(BITMAPINFOHEADER);
    bi.biWidth = width_;
    bi.biHeight = height_;
    bi.biPlanes = 1;
    bi.biBitCount = 32;
    bi.biCompression = BI_RGB;

    frame->pitch = width_ * 4;
    frame->data.resize(frame->pitch * height_);

    GetDIBits(memdc, hbm, 0, height_, frame->data.data(), (BITMAPINFO*)&bi, DIB_RGB_COLORS);

    DeleteObject(hbm);
    DeleteDC(memdc);
    ReleaseDC(nullptr, hdc);

    return frame;
}
