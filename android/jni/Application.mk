APP_OPTIM := release

APP_ABI := arm64-v8a x86_64 

APP_STL := none

APP_PLATFORM := android-29

APP_CFLAGS := -O3 -DANDROID -DFFMPEG_KIT_LTS -DFFMPEG_KIT_BUILD_DATE=20250819 -Wall -Wno-deprecated-declarations -Wno-pointer-sign -Wno-switch -Wno-unused-result -Wno-unused-variable

APP_LDFLAGS := -Wl,--hash-style=both
