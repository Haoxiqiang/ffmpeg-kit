# 该文件已不再需要，因为项目已迁移到 CMake 构建系统
# 保留此文件仅为向后兼容性考虑
APP_OPTIM := release

APP_ABI := armeabi-v7a arm64-v8a

APP_STL := none

APP_PLATFORM := android-29

APP_CFLAGS := -O3 -DANDROID -DFFMPEG_KIT_LTS -DFFMPEG_KIT_BUILD_DATE=20250818 -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable

APP_LDFLAGS := -Wl,--hash-style=both