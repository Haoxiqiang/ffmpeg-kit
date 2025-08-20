cmake_minimum_required(VERSION 3.4.1)

# Set build type
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# Set compiler flags
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -DANDROID -DFFMPEG_KIT_LTS -DFFMPEG_KIT_BUILD_DATE=20250818 -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -DANDROID -DFFMPEG_KIT_LTS -DFFMPEG_KIT_BUILD_DATE=20250818 -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--hash-style=both")

# Define prebuilt library path
set(PREBUILT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../prebuilt)

# Set path based on architecture and features
# Note: Actual directory names do not exactly match ANDROID_ABI, mapping required
if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
    set(ARCH_NAME "arm-neon")
elseif(${ANDROID_ABI} STREQUAL "arm64-v8a")
    set(ARCH_NAME "arm64")
elseif(${ANDROID_ABI} STREQUAL "x86")
    set(ARCH_NAME "x86")
elseif(${ANDROID_ABI} STREQUAL "x86_64")
    set(ARCH_NAME "x86_64")
endif()

if(FFMPEG_KIT_LTS)
    set(LTS_POSTFIX "-lts")
else()
    set(LTS_POSTFIX "")
endif()

set(ARCH_DIR "android-${ARCH_NAME}${LTS_POSTFIX}")

# Set FFmpeg header file path
set(FFMPEG_INCLUDE_DIRS ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/include)

# Set cpu-features header file path
set(CPU_FEATURES_INCLUDE_DIRS ${PREBUILT_DIR}/${ARCH_DIR}/cpu-features/include/ndk_compat)

# Add cpu-features static library
add_library(cpu-features STATIC IMPORTED)
set_target_properties(cpu-features PROPERTIES IMPORTED_LOCATION
    ${PREBUILT_DIR}/${ARCH_DIR}/cpu-features/lib/libndk_compat.a)

add_library(libavcodec SHARED IMPORTED)
set_target_properties(libavcodec PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libavcodec.so)

add_library(libavfilter SHARED IMPORTED)
set_target_properties(libavfilter PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libavfilter.so)

add_library(libavdevice SHARED IMPORTED)
set_target_properties(libavdevice PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libavdevice.so)

add_library(libavformat SHARED IMPORTED)
set_target_properties(libavformat PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libavformat.so)

add_library(libavutil SHARED IMPORTED)
set_target_properties(libavutil PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libavutil.so)
set_target_properties(libavutil PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/include)

add_library(libswresample SHARED IMPORTED)
set_target_properties(libswresample PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libswresample.so)

add_library(libswscale SHARED IMPORTED)
set_target_properties(libswscale PROPERTIES IMPORTED_LOCATION
        ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/lib/libswscale.so)

# Set source files
set(FFMPEG_KIT_SRC_FILES
    ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit.c
    ffmpeg-kit-android-lib/src/main/cpp/ffprobekit.c
    ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit_exception.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_cmdutils.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffprobe.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg_mux.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg_mux_init.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg_demux.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg_opt.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_opt_common.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg_hw.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_ffmpeg_filter.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_objpool.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_sync_queue.c
    ffmpeg-kit-android-lib/src/main/cpp/fftools_thread_queue.c
)

# Add LTS support source files (if needed)
if(${ANDROID_PLATFORM_LEVEL} LESS 18)
    list(APPEND FFMPEG_KIT_SRC_FILES ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.c)
endif()

# Set architecture flags
if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_ARM_V7A)
elseif(${ANDROID_ABI} STREQUAL "arm64-v8a")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_ARM64_V8A)
elseif(${ANDROID_ABI} STREQUAL "x86")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_X86)
elseif(${ANDROID_ABI} STREQUAL "x86_64")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_X86_64)
endif()

# Build ffmpegkit_abidetect library
add_library(ffmpegkit_abidetect SHARED
    ffmpeg-kit-android-lib/src/main/cpp/ffmpegkit_abidetect.c)

target_include_directories(ffmpegkit_abidetect PRIVATE
    ${FFMPEG_INCLUDE_DIRS}
    ${CPU_FEATURES_INCLUDE_DIRS})

target_compile_definitions(ffmpegkit_abidetect PRIVATE
    ${FFMPEG_KIT_ARCH_FLAGS})

target_link_libraries(ffmpegkit_abidetect
    android
    log
    z
    cpu-features)

# Build main ffmpegkit library
add_library(ffmpegkit SHARED
    ${FFMPEG_KIT_SRC_FILES})

target_include_directories(ffmpegkit PRIVATE
    ${FFMPEG_INCLUDE_DIRS})

target_compile_definitions(ffmpegkit PRIVATE
    ${FFMPEG_KIT_ARCH_FLAGS})

target_link_libraries(ffmpegkit
    android
    log
    z
    libavfilter
    libavformat
    libavcodec
    libavutil
    libswresample
    libavdevice
    libswscale)