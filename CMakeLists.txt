cmake_minimum_required(VERSION 3.10)
project(UDPStreamer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Threads REQUIRED)

# 源文件列表
set(SOURCES
    src/main.cpp
    src/screen_capture.cpp
    src/udp_streamer.cpp
    src/encoder.cpp
)

add_executable(udp_streamer ${SOURCES})

# Windows 特定设置
if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /O2")
    
    # Try vcpkg first, then fallback to manual path
    find_package(FFmpeg QUIET)
    
    if(NOT FFmpeg_FOUND AND DEFINED FFMPEG_PATH)
        # 手动配置 FFmpeg 路径
        set(FFMPEG_INCLUDE_DIRS "${FFMPEG_PATH}/include")
        set(FFMPEG_LIB_DIR "${FFMPEG_PATH}/lib")
        
        find_library(AVCODEC_LIB avcodec PATHS "${FFMPEG_LIB_DIR}" NO_DEFAULT_PATH)
        find_library(AVFORMAT_LIB avformat PATHS "${FFMPEG_LIB_DIR}" NO_DEFAULT_PATH)
        find_library(SWSCALE_LIB swscale PATHS "${FFMPEG_LIB_DIR}" NO_DEFAULT_PATH)
        
        if(AVCODEC_LIB AND AVFORMAT_LIB AND SWSCALE_LIB)
            set(FFMPEG_LIBRARIES ${AVCODEC_LIB} ${AVFORMAT_LIB} ${SWSCALE_LIB})
        else()
            message(FATAL_ERROR "FFmpeg libraries not found in ${FFMPEG_LIB_DIR}")
        endif()
    elseif(NOT FFmpeg_FOUND)
        message(FATAL_ERROR "FFmpeg not found. Set FFMPEG_PATH or use vcpkg")
    endif()
    
    target_link_libraries(udp_streamer
        PRIVATE
        ${FFMPEG_LIBRARIES}
        Threads::Threads
        ws2_32
        gdi32
        dxva2
    )
else()
    # Linux/macOS
    find_package(FFmpeg REQUIRED)
    target_link_libraries(udp_streamer
        PRIVATE
        ${FFMPEG_LIBRARIES}
        Threads::Threads
    )
endif()

target_include_directories(udp_streamer
    PRIVATE
    ${FFMPEG_INCLUDE_DIRS}
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)
