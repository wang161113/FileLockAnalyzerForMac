# FileLockAnalyzer For Mac

原生 macOS 版本的 FileLockAnalyzer，独立仓库实现，不依赖 Qt。

## 技术栈

- 原生 UI: AppKit
- 语言: Objective-C++
- 后端分析: `lsof` + `libproc`
- 构建系统: CMake
- CI: GitHub Actions

## 当前功能

- 选择文件或文件夹并分析占用
- 显示占用进程名、PID、进程路径、占用路径、来源
- 结束选中的占用进程
- 在 Finder 中定位当前目标
- 支持命令行传入初始路径

## 本地构建

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

## CI

仓库内置了 macOS GitHub Actions 工作流：

- `push` / `pull_request` 自动编译
- 推送 `v*` tag 时自动打包 `.app` 并上传到 GitHub Release

## 说明

- 目录分析依赖系统自带的 `lsof`
- 某些系统进程或其他用户进程可能需要更高权限才能完整显示
- 当前版本优先实现分析和基础进程操作，后续可以继续补高级解锁能力
