cmake_minimum_required(VERSION 3.21)

project(FileLockAnalyzerMac VERSION 0.1.0 LANGUAGES CXX OBJC OBJCXX)

if(NOT APPLE)
    message(FATAL_ERROR "The mac native version can only be built on macOS.")
endif()

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

set(CMAKE_OBJCXX_STANDARD 17)
set(CMAKE_OBJCXX_STANDARD_REQUIRED ON)

find_library(COCOA_FRAMEWORK Cocoa REQUIRED)

add_executable(FileLockAnalyzerMac MACOSX_BUNDLE
    src/main.mm
    src/AppDelegate.h
    src/AppDelegate.mm
    src/MainWindowController.h
    src/MainWindowController.mm
    src/LockAnalyzer.h
    src/LockAnalyzer.mm
    src/LockInfo.h
)

target_compile_options(FileLockAnalyzerMac PRIVATE
    "$<$<COMPILE_LANGUAGE:OBJC,OBJCXX>:-fobjc-arc>"
)

target_link_libraries(FileLockAnalyzerMac PRIVATE
    ${COCOA_FRAMEWORK}
)

set_target_properties(FileLockAnalyzerMac PROPERTIES
    MACOSX_BUNDLE_BUNDLE_NAME "FileLockAnalyzer"
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.finnsoft.filelockanalyzer.mac"
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
)
