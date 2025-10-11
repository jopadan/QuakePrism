#!/bin/bash
# build.sh - Normal build
mkdir -p build && cd build
cmake ..
cmake --build . -j$(nproc)
