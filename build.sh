#!/bin/bash

if [[ -z ${ANDROID_SDK_ROOT} ]]; then
  echo -e "\n(*) ANDROID_SDK_ROOT not defined\n"
  exit 1
fi

if [[ -z ${ANDROID_NDK_ROOT} ]]; then
  echo -e "\n(*) ANDROID_NDK_ROOT not defined\n"
  exit 1
fi

# apply patches
if [ -d "patches" ]; then
  for patch_dir in patches/*/; do
    if [ -d "$patch_dir" ]; then
      # Get the directory name (e.g., "cpu-features" from "patches/cpu-features/")
      dir_name=$(basename "$patch_dir")
      
      # Check if corresponding directory exists in src
      if [ -d "src/$dir_name" ]; then
        echo "Applying patches for $dir_name"
        
        # Apply each patch in the directory
        for patch_file in "$patch_dir"*.patch; do
          if [ -f "$patch_file" ]; then
            patch_name=$(basename "$patch_file")
            echo "  Applying patch: $patch_name"
            patch -d "src/$dir_name" -p1 < "$patch_file"
          fi
        done
      else
        echo "Warning: No corresponding directory src/$dir_name for patch directory $dir_name"
      fi
    fi
  done
fi

# build 32 bits
export ANDROID_NDK_ROOT=${ANDROID_SDK_HOME}/ndk/22.1.7171670
./android.sh --lts --api-level=26 --disable-arm64-v8a --disable-x86-64

# build 64 bits
export ANDROID_NDK_ROOT=${ANDROID_SDK_HOME}/ndk/29.0.13599879
./android.sh --lts --api-level=29 --disable-arm-v7a --disable-arm-v7a-neon --disable-x86