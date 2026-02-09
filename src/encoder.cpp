#include "encoder.h"
#include <stdexcept>
#include <cstring>

Encoder::Encoder(int width, int height, int bitrate_kbps, int fps)
    : width_(width), height_(height), bitrate_kbps_(bitrate_kbps), fps_(fps) {}

Encoder::~Encoder() {
    if (sws_ctx_) {
        sws_freeContext(sws_ctx_);
    }
    if (frame_) {
        av_frame_free(&frame_);
    }
    if (codec_ctx_) {
        avcodec_free_context(&codec_ctx_);
    }
}

bool Encoder::Initialize(const char* codec_name) {
    const AVCodec* codec = avcodec_find_encoder_by_name(codec_name);
    
    // 如果找不到 GPU 编码器，尝试软编码
    if (!codec) {
        codec = avcodec_find_encoder_by_name("libx264");
    }
    
    if (!codec) {
        throw std::runtime_error("找不到编码器");
    }

    codec_ctx_ = avcodec_alloc_context3(codec);
    if (!codec_ctx_) {
        throw std::runtime_error("分配编码器上下文失败");
    }

    codec_ctx_->width = width_;
    codec_ctx_->height = height_;
    codec_ctx_->pix_fmt = AV_PIX_FMT_YUV420P;
    codec_ctx_->time_base = {1, fps_};
    codec_ctx_->framerate = {fps_, 1};
    codec_ctx_->bit_rate = bitrate_kbps_ * 1000;
    codec_ctx_->gop_size = fps_; // 关键帧间隔
    codec_ctx_->max_b_frames = 0; // 禁用 B 帧降低延迟
    
    // 低延迟选项
    AVDictionary* opts = nullptr;
    av_dict_set(&opts, "preset", "ultrafast", 0);
    av_dict_set(&opts, "tune", "zerolatency", 0);
    av_dict_set(&opts, "rc", "vbr", 0);

    if (avcodec_open2(codec_ctx_, codec, &opts) < 0) {
        av_dict_free(&opts);
        throw std::runtime_error("打开编码器失败");
    }
    av_dict_free(&opts);

    // 初始化图像格式转换
    sws_ctx_ = sws_getContext(
        width_, height_, AV_PIX_FMT_BGR0,
        width_, height_, AV_PIX_FMT_YUV420P,
        SWS_FAST_BILINEAR, nullptr, nullptr, nullptr
    );

    frame_ = av_frame_alloc();
    frame_->format = AV_PIX_FMT_YUV420P;
    frame_->width = width_;
    frame_->height = height_;
    av_frame_get_buffer(frame_, 0);

    initialized_ = true;
    return true;
}

void Encoder::Encode(const uint8_t* rgb_data, int pitch) {
    if (!initialized_) {
        return;
    }

    // 转换 RGB 到 YUV420
    const uint8_t* src[1] = {rgb_data};
    int src_linesize[1] = {pitch};
    sws_scale(sws_ctx_, src, src_linesize, 0, height_, 
              frame_->data, frame_->linesize);

    // 编码
    int ret = avcodec_send_frame(codec_ctx_, frame_);
    if (ret < 0) {
        return;
    }

    AVPacket* pkt = av_packet_alloc();
    while (ret >= 0) {
        ret = avcodec_receive_packet(codec_ctx_, pkt);
        if (ret == AVERROR(EAGAIN) || ret == AVERROR_EOF) {
            break;
        }

        auto encoded = std::make_shared<EncodedPacket>();
        encoded->data.assign(pkt->data, pkt->data + pkt->size);
        encoded->timestamp = frame_->pts;
        encoded->is_key_frame = (pkt->flags & AV_PKT_FLAG_KEY) != 0;

        {
            std::unique_lock<std::mutex> lock(queue_mutex_);
            packet_queue_.push(encoded);
        }
    }
    av_packet_free(&pkt);
}

std::shared_ptr<EncodedPacket> Encoder::GetPacket() {
    std::unique_lock<std::mutex> lock(queue_mutex_);
    if (packet_queue_.empty()) {
        return nullptr;
    }
    auto pkt = packet_queue_.front();
    packet_queue_.pop();
    return pkt;
}

void Encoder::Stop() {
    // 刷新编码器缓冲
    AVPacket* pkt = av_packet_alloc();
    avcodec_send_frame(codec_ctx_, nullptr);
    
    while (avcodec_receive_packet(codec_ctx_, pkt) >= 0) {
        auto encoded = std::make_shared<EncodedPacket>();
        encoded->data.assign(pkt->data, pkt->data + pkt->size);
        {
            std::unique_lock<std::mutex> lock(queue_mutex_);
            packet_queue_.push(encoded);
        }
    }
    av_packet_free(&pkt);
}
