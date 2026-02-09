#pragma once

#include <string>
#include <cstdint>
#include <winsock2.h>
#include <thread>
#include <atomic>
#include <queue>
#include <mutex>
#include <vector>

class UDPStreamer {
public:
    UDPStreamer(const std::string& host, int port, int mtu = 1500);
    ~UDPStreamer();

    bool Start();
    void Stop();
    void SendData(const uint8_t* data, size_t size);
    
    bool IsConnected() const { return connected_; }

private:
    std::string host_;
    int port_;
    int mtu_;
    SOCKET socket_ = INVALID_SOCKET;
    std::atomic<bool> connected_{false};
    
    struct sockaddr_in dest_addr_;
    int addr_len_;

    bool InitSocket();
    void SendThreadFunc();
    
    std::thread send_thread_;
    std::queue<std::vector<uint8_t>> send_queue_;
    std::mutex queue_mutex_;
    std::atomic<bool> running_{false};
};
