#!/bin/bash
# build-windows.sh - Cross-compile for Windows
mkdir -p build-windows && cd build-windows
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchain-mingw64.cmake -DCROSS_COMPILE_WINDOWS=ON ..
cmake --build . -j$(nproc)
