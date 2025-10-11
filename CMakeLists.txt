cmake_minimum_required(VERSION 3.15)
project(QuakePrism VERSION 1.0 LANGUAGES CXX)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Build type default
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Debug)
endif()

# Set output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR})

# Option for cross-compilation
option(CROSS_COMPILE_WINDOWS "Cross-compile for Windows from Linux" OFF)

# Detect cross-compilation
if(CMAKE_CROSSCOMPILING OR CROSS_COMPILE_WINDOWS)
    set(IS_CROSS_COMPILE TRUE)
    message(STATUS "Cross-compiling for Windows")
else()
    set(IS_CROSS_COMPILE FALSE)
endif()

# ImGui directory
set(IMGUI_DIR ${CMAKE_SOURCE_DIR}/lib/imgui)
set(SRC_DIR ${CMAKE_SOURCE_DIR}/src)

# GLM directory
set(GLM_DIR ${CMAKE_SOURCE_DIR}/lib/glm)

# Collect source files
file(GLOB SOURCES "${SRC_DIR}/*.cpp")

# ImGui sources
set(IMGUI_SOURCES
    ${IMGUI_DIR}/imgui.cpp
    ${IMGUI_DIR}/imgui_demo.cpp
    ${IMGUI_DIR}/imgui_draw.cpp
    ${IMGUI_DIR}/imgui_tables.cpp
    ${IMGUI_DIR}/imgui_widgets.cpp
    ${IMGUI_DIR}/backends/imgui_impl_sdl2.cpp
    ${IMGUI_DIR}/backends/imgui_impl_opengl3.cpp
)

# Create executable
add_executable(QuakePrism ${SOURCES} ${IMGUI_SOURCES})

# Include directories
target_include_directories(QuakePrism PRIVATE
    ${IMGUI_DIR}
    ${IMGUI_DIR}/backends
    ${GLM_DIR}
    ${SRC_DIR}
)

# Compiler flags
target_compile_options(QuakePrism PRIVATE
    -g
    -Wall
    -Wformat
)

# Platform-specific settings
if(WIN32 OR IS_CROSS_COMPILE)
    # Windows or cross-compile settings
    message(STATUS "Configuring for Windows")
    
    if(IS_CROSS_COMPILE)
        # Cross-compilation specific includes
        target_include_directories(QuakePrism PRIVATE
            /usr/x86_64-w64-mingw32/include
            /usr/x86_64-w64-mingw32/include/SDL2
        )
        
        target_compile_definitions(QuakePrism PRIVATE
            _UNICODE
            UNICODE
        )
        
        target_compile_options(QuakePrism PRIVATE -mwindows)
    endif()
    
    # Windows libraries
    target_link_libraries(QuakePrism PRIVATE
        mingw32
        SDL2main
        SDL2
        gdi32
        opengl32
        imm32
        glew32
        glu32
    )
    
    # Add resource file if cross-compiling
    if(IS_CROSS_COMPILE AND EXISTS ${CMAKE_SOURCE_DIR}/logo.rc)
        target_sources(QuakePrism PRIVATE logo.rc)
    endif()
    
elseif(APPLE)
    # macOS settings
    message(STATUS "Configuring for macOS")
    
    # Find SDL2
    find_package(SDL2 REQUIRED)
    target_include_directories(QuakePrism PRIVATE
        ${SDL2_INCLUDE_DIRS}
        /usr/local/include
        /opt/local/include
    )
    
    # macOS frameworks and libraries
    target_link_libraries(QuakePrism PRIVATE
        ${SDL2_LIBRARIES}
        "-framework OpenGL"
        "-framework Cocoa"
        "-framework IOKit"
        "-framework CoreVideo"
    )
    
    target_link_directories(QuakePrism PRIVATE
        /usr/local/lib
        /opt/local/lib
    )
    
elseif(UNIX)
    # Linux settings
    message(STATUS "Configuring for Linux")
    
    # Find packages
    find_package(SDL2 REQUIRED)
    find_package(OpenGL REQUIRED)
    find_package(GLEW REQUIRED)
    
    # Use pkg-config for SDL2
    find_package(PkgConfig REQUIRED)
    pkg_check_modules(SDL2 REQUIRED sdl2)
    pkg_check_modules(SDL2_IMAGE REQUIRED SDL2_image)
    
    target_include_directories(QuakePrism PRIVATE
        ${SDL2_INCLUDE_DIRS}
        ${SDL2_IMAGE_INCLUDE_DIRS}
        ${OPENGL_INCLUDE_DIR}
        ${GLEW_INCLUDE_DIRS}
    )
    
    target_link_libraries(QuakePrism PRIVATE
        ${SDL2_LIBRARIES}
        ${SDL2_IMAGE_LIBRARIES}
        ${OPENGL_LIBRARIES}
        GL
        GLU
        GLEW
        dl
    )
    
    target_compile_options(QuakePrism PRIVATE ${SDL2_CFLAGS_OTHER})
endif()

# Post-build: Copy resources
add_custom_command(TARGET QuakePrism POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo "Copying resources directory..."
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${SRC_DIR}/res
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/res
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/imgui.ini
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/imgui.ini
    COMMENT "Copying resource files"
)

# Copy DLLs for cross-compilation
if(IS_CROSS_COMPILE AND EXISTS ${SRC_DIR}/.dlls)
    add_custom_command(TARGET QuakePrism POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
            ${SRC_DIR}/.dlls
            ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}
        COMMENT "Copying Windows DLLs"
    )
endif()

# Print build configuration
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Output directory: ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}")
