# FileLockAnalyzer For Mac

[![English](https://img.shields.io/badge/English-切换-gray)](README.md)
[![简体中文](https://img.shields.io/badge/简体中文-当前-blue)](README.zh-CN.md)

FileLockAnalyzer 的原生 macOS 版本。

## 技术栈

- 原生 UI：AppKit
- 语言：Objective-C++
- 后端：`lsof` + `libproc`
- 构建系统：CMake

## 功能

- 分析文件或文件夹的占用进程
- 显示进程名、PID、进程路径、占用路径和来源
- 结束选中的进程
- 在 Finder 中定位当前目标
- 支持命令行传入初始路径

## 构建

在 macOS 上执行：

```bash
cmake -S . -B build -G Xcode
cmake --build build --config Release
```

构建完成后，应用位于：

```bash
build/Release/FileLockAnalyzerMac.app
```

也可以使用 Ninja：

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

## 说明

- 目录分析依赖系统自带的 `lsof`
- 某些系统进程或其他用户的进程可能需要更高权限才能完整显示
- 当前版本优先实现分析与基础进程操作
