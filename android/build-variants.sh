#!/bin/bash

# FFmpegKit Android 构建脚本
# 支持针对不同架构使用不同的API级别和NDK版本进行构建

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认配置
PROJECT_ROOT=$(pwd)
BUILD_DIR="${PROJECT_ROOT}/build"

# 检查环境变量
check_environment() {
    if [ -z "$ANDROID_SDK_ROOT" ]; then
        echo -e "${RED}Error: ANDROID_SDK_ROOT is not set${NC}"
        exit 1
    fi
    
    if [ -z "$ANDROID_NDK_ROOT" ]; then
        echo -e "${RED}Error: ANDROID_NDK_ROOT is not set${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Environment check passed${NC}"
    echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
    echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
}

# 创建构建目录
mkdir -p "${BUILD_DIR}"

# 构建 armeabi-v7a (API 26, NDK 22.1.7171670)
build_armv7a_api26_ndk22() {
    echo -e "${YELLOW}Building armeabi-v7a with API level 26 and NDK 22.1.7171670...${NC}"
    
    # 使用Gradle属性指定配置
    ./gradlew clean
    ./gradlew :ffmpeg-kit-android-lib:assembleRelease \
        -Pandroid.compileSdk=33 \
        -Pandroid.minSdk=26 \
        -Pandroid.targetSdk=33 \
        -Pandroid.ndkVersion=22.1.7171670 \
        -Pandroid.native.buildOutput=verbose \
        --info \
        --stacktrace
    
    # 检查构建结果
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful for armeabi-v7a (API 26, NDK 22)${NC}"
        # 复制生成的so文件到指定目录
        mkdir -p "${BUILD_DIR}/armeabi-v7a-api26-ndk22"
        if [ -d "ffmpeg-kit-android-lib/build/intermediates/cmake/release/obj/armeabi-v7a" ]; then
            cp ffmpeg-kit-android-lib/build/intermediates/cmake/release/obj/armeabi-v7a/*.so "${BUILD_DIR}/armeabi-v7a-api26-ndk22/"
            echo -e "${GREEN}SO files copied to ${BUILD_DIR}/armeabi-v7a-api26-ndk22/${NC}"
        else
            echo -e "${YELLOW}Warning: SO files directory not found${NC}"
        fi
    else
        echo -e "${RED}Build failed for armeabi-v7a (API 26, NDK 22)${NC}"
        exit 1
    fi
}

# 构建 arm64-v8a (API 29, NDK 29.0.13599879)
build_arm64_api29_ndk29() {
    echo -e "${YELLOW}Building arm64-v8a with API level 29 and NDK 29.0.13599879...${NC}"
    
    # 使用Gradle属性指定配置
    ./gradlew clean
    ./gradlew :ffmpeg-kit-android-lib:assembleRelease \
        -Pandroid.compileSdk=33 \
        -Pandroid.minSdk=29 \
        -Pandroid.targetSdk=33 \
        -Pandroid.ndkVersion=29.0.13599879 \
        -Pandroid.native.buildOutput=verbose \
        --info \
        --stacktrace
    
    # 检查构建结果
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful for arm64-v8a (API 29, NDK 29)${NC}"
        # 复制生成的so文件到指定目录
        mkdir -p "${BUILD_DIR}/arm64-v8a-api29-ndk29"
        if [ -d "ffmpeg-kit-android-lib/build/intermediates/cmake/release/obj/arm64-v8a" ]; then
            cp ffmpeg-kit-android-lib/build/intermediates/cmake/release/obj/arm64-v8a/*.so "${BUILD_DIR}/arm64-v8a-api29-ndk29/"
            echo -e "${GREEN}SO files copied to ${BUILD_DIR}/arm64-v8a-api29-ndk29/${NC}"
        else
            echo -e "${YELLOW}Warning: SO files directory not found${NC}"
        fi
    else
        echo -e "${RED}Build failed for arm64-v8a (API 29, NDK 29)${NC}"
        exit 1
    fi
}

# 显示帮助信息
show_help() {
    echo "Usage: $0 {armv7a|arm64|all|help}"
    echo ""
    echo "  armv7a: Build armeabi-v7a with API level 26 and NDK 22.1.7171670"
    echo "  arm64:  Build arm64-v8a with API level 29 and NDK 29.0.13599879"
    echo "  all:    Build both variants"
    echo "  help:   Show this help message"
    echo ""
    echo "Environment variables required:"
    echo "  ANDROID_SDK_ROOT - Path to Android SDK"
    echo "  ANDROID_NDK_ROOT - Path to Android NDK"
    echo ""
}

# 主函数
main() {
    export ANDROID_HOME=/home/haoxiqiang/Android/Sdk
    export ANDROID_NDK_ROOT=${ANDROID_HOME}/ndk
    check_environment
    
    case "$1" in
        armv7a)
            build_armv7a_api26_ndk22
            ;;
        arm64)
            build_arm64_api29_ndk29
            ;;
        all)
            build_arm64_api29_ndk29
            build_armv7a_api26_ndk22
            ;;
        help|-h|--help)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"