#include "udp_streamer.h"
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdexcept>
#include <iostream>

#pragma comment(lib, "ws2_32.lib")

UDPStreamer::UDPStreamer(const std::string& host, int port, int mtu)
    : host_(host), port_(port), mtu_(mtu), addr_len_(sizeof(dest_addr_)) {
    
    WSADATA wsa;
    if (WSAStartup(MAKEWORD(2, 2), &wsa) != 0) {
        throw std::runtime_error("WSAStartup 失败");
    }
}

UDPStreamer::~UDPStreamer() {
    Stop();
    if (socket_ != INVALID_SOCKET) {
        closesocket(socket_);
    }
    WSACleanup();
}

bool UDPStreamer::InitSocket() {
    socket_ = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
    if (socket_ == INVALID_SOCKET) {
        std::cerr << "创建 socket 失败: " << WSAGetLastError() << std::endl;
        return false;
    }

    // 增加 UDP 缓冲大小
    int send_buf = 10 * 1024 * 1024; // 10MB
    setsockopt(socket_, SOL_SOCKET, SO_SNDBUF, (char*)&send_buf, sizeof(send_buf));

    // 非阻塞模式
    u_long mode = 1;
    ioctlsocket(socket_, FIONBIO, &mode);

    dest_addr_.sin_family = AF_INET;
    dest_addr_.sin_port = htons(port_);
    inet_pton(AF_INET, host_.c_str(), &dest_addr_.sin_addr);

    connected_ = true;
    return true;
}

bool UDPStreamer::Start() {
    if (!InitSocket()) {
        return false;
    }

    running_ = true;
    send_thread_ = std::thread(&UDPStreamer::SendThreadFunc, this);
    return true;
}

void UDPStreamer::Stop() {
    running_ = false;
    if (send_thread_.joinable()) {
        send_thread_.join();
    }
}

void UDPStreamer::SendData(const uint8_t* data, size_t size) {
    std::vector<uint8_t> packet(data, data + size);
    {
        std::unique_lock<std::mutex> lock(queue_mutex_);
        send_queue_.push(packet);
    }
}

void UDPStreamer::SendThreadFunc() {
    while (running_) {
        std::unique_lock<std::mutex> lock(queue_mutex_);
        
        if (!send_queue_.empty()) {
            auto packet = send_queue_.front();
            send_queue_.pop();
            lock.unlock();

            // 分割大包
            size_t offset = 0;
            while (offset < packet.size()) {
                size_t chunk_size = std::min(size_t(mtu_), packet.size() - offset);
                int ret = sendto(socket_, 
                    (const char*)(packet.data() + offset), 
                    chunk_size, 
                    0, 
                    (sockaddr*)&dest_addr_, 
                    addr_len_);
                
                if (ret == SOCKET_ERROR) {
                    int err = WSAGetLastError();
                    if (err != WSAEWOULDBLOCK) {
                        std::cerr << "发送失败: " << err << std::endl;
                    }
                }
                offset += chunk_size;
            }
        } else {
            lock.unlock();
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
    }
}
