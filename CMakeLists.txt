cmake_minimum_required(VERSION 3.10)
project(UDPStreamer)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Threads REQUIRED)

set(SOURCES
    src/main.cpp
    src/screen_capture.cpp
    src/udp_streamer.cpp
    src/encoder.cpp
)

add_executable(udp_streamer ${SOURCES})

if(WIN32)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP /O2")
    
    if(DEFINED FFMPEG_PATH)
        set(FFMPEG_INCLUDE_DIRS "${FFMPEG_PATH}/include")
        set(FFMPEG_LIB_DIR "${FFMPEG_PATH}/lib")
        
        find_library(AVCODEC_LIB avcodec PATHS "${FFMPEG_LIB_DIR}" NO_DEFAULT_PATH)
        find_library(AVFORMAT_LIB avformat PATHS "${FFMPEG_LIB_DIR}" NO_DEFAULT_PATH)
        find_library(SWSCALE_LIB swscale PATHS "${FFMPEG_LIB_DIR}" NO_DEFAULT_PATH)
        
        if(NOT AVCODEC_LIB OR NOT AVFORMAT_LIB OR NOT SWSCALE_LIB)
            message(FATAL_ERROR "FFmpeg libraries not found in ${FFMPEG_LIB_DIR}")
        endif()
        
        set(FFMPEG_LIBRARIES ${AVCODEC_LIB} ${AVFORMAT_LIB} ${SWSCALE_LIB})
    else()
        find_package(FFmpeg REQUIRED)
        if(FFMPEG_FOUND OR FFmpeg_FOUND)
            if(DEFINED FFMPEG_INCLUDE_DIRS)
                message(STATUS "FFmpeg found via vcpkg")
            else()
                set(FFMPEG_INCLUDE_DIRS "")
            endif()
        else()
            message(FATAL_ERROR "FFmpeg not found. Set FFMPEG_PATH or use vcpkg")
        endif()
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
