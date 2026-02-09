cmake_minimum_required(VERSION 3.10)
project(UDPStreamer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 查找依赖
find_package(FFmpeg REQUIRED)
find_package(Threads REQUIRED)

# Windows 特定设置
if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /O2")
    # Windows GDI 屏幕捕获
    set(SOURCES
        src/main.cpp
        src/screen_capture.cpp
        src/udp_streamer.cpp
        src/encoder.cpp
    )
endif()

add_executable(udp_streamer ${SOURCES})

target_link_libraries(udp_streamer
    PRIVATE
    ${FFMPEG_LIBRARIES}
    Threads::Threads
    ws2_32
)

target_include_directories(udp_streamer
    PRIVATE
    ${FFMPEG_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
