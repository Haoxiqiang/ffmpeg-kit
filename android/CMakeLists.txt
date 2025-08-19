cmake_minimum_required(VERSION 3.4.1)

# 设置构建类型
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()

# 设置编译器标志
set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} -O3 -DANDROID -DFFMPEG_KIT_LTS -DFFMPEG_KIT_BUILD_DATE=20250818 -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable")
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -DANDROID -DFFMPEG_KIT_LTS -DFFMPEG_KIT_BUILD_DATE=20250818 -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--hash-style=both")

# 定义预构建库路径
set(PREBUILT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../prebuilt)

# 根据架构和特性设置路径
# 注意：实际目录名与 ANDROID_ABI 不完全一致，需要映射
if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
    set(ARCH_NAME "arm")
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

# 设置 FFmpeg 头文件路径
set(FFMPEG_INCLUDE_DIRS ${PREBUILT_DIR}/${ARCH_DIR}/ffmpeg/include)

# 设置 cpu-features 头文件路径
set(CPU_FEATURES_INCLUDE_DIRS ${PREBUILT_DIR}/${ARCH_DIR}/cpu-features/include/ndk_compat)

# 添加 cpu-features 静态库
add_library(cpu-features STATIC IMPORTED)
set_target_properties(cpu-features PROPERTIES IMPORTED_LOCATION
    ${PREBUILT_DIR}/${ARCH_DIR}/cpu-features/lib/libndk_compat.a)

# 添加 FFmpeg 预构建共享库
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

# 如果是 NEON 架构，则添加 NEON 版本的库
if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
    # 检查是否存在 NEON 版本
    if(EXISTS ${PREBUILT_DIR}/android-${ARCH_NAME}-neon${LTS_POSTFIX})
        set(NEON_ARCH_DIR "android-${ARCH_NAME}-neon${LTS_POSTFIX}")
        
        add_library(libavcodec_neon SHARED IMPORTED)
        set_target_properties(libavcodec_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libavcodec_neon.so)

        add_library(libavfilter_neon SHARED IMPORTED)
        set_target_properties(libavfilter_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libavfilter_neon.so)

        add_library(libavdevice_neon SHARED IMPORTED)
        set_target_properties(libavdevice_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libavdevice_neon.so)

        add_library(libavformat_neon SHARED IMPORTED)
        set_target_properties(libavformat_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libavformat_neon.so)

        add_library(libavutil_neon SHARED IMPORTED)
        set_target_properties(libavutil_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libavutil_neon.so)
        set_target_properties(libavutil_neon PROPERTIES INTERFACE_INCLUDE_DIRECTORIES
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/include)

        add_library(libswresample_neon SHARED IMPORTED)
        set_target_properties(libswresample_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libswresample_neon.so)

        add_library(libswscale_neon SHARED IMPORTED)
        set_target_properties(libswscale_neon PROPERTIES IMPORTED_LOCATION
            ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/lib/libswscale_neon.so)
            
        set(NEON_AVAILABLE TRUE)
    else()
        set(NEON_AVAILABLE FALSE)
    endif()
endif()

# 设置源文件
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

# 添加 LTS 支持源文件（如果需要）
if(${ANDROID_PLATFORM_LEVEL} LESS 18)
    list(APPEND FFMPEG_KIT_SRC_FILES ffmpeg-kit-android-lib/src/main/cpp/android_lts_support.c)
endif()

# 设置架构标志
if(${ANDROID_ABI} STREQUAL "armeabi-v7a")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_ARM_V7A)
elseif(${ANDROID_ABI} STREQUAL "arm64-v8a")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_ARM64_V8A)
elseif(${ANDROID_ABI} STREQUAL "x86")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_X86)
elseif(${ANDROID_ABI} STREQUAL "x86_64")
    set(FFMPEG_KIT_ARCH_FLAGS FFMPEG_KIT_X86_64)
endif()

# 构建 ffmpegkit_abidetect 库
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

# 构建主 ffmpegkit 库
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

# 如果是 NEON 架构且存在 NEON 版本，则构建 NEON 版本的 ffmpegkit
if(${ANDROID_ABI} STREQUAL "armeabi-v7a" AND NEON_AVAILABLE)
    add_library(ffmpegkit_armv7a_neon SHARED
        ${FFMPEG_KIT_SRC_FILES})

    target_include_directories(ffmpegkit_armv7a_neon PRIVATE
        ${PREBUILT_DIR}/${NEON_ARCH_DIR}/ffmpeg/include)

    target_compile_definitions(ffmpegkit_armv7a_neon PRIVATE
        ${FFMPEG_KIT_ARCH_FLAGS})

    target_link_libraries(ffmpegkit_armv7a_neon
        android
        log
        z
        libavfilter_neon
        libavformat_neon
        libavcodec_neon
        libavutil_neon
        libswresample_neon
        libavdevice_neon
        libswscale_neon)
endif()