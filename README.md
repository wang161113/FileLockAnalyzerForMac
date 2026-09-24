# FileLockAnalyzer For Mac

[![English](https://img.shields.io/badge/English-Current-blue)](README.md)
[![简体中文](https://img.shields.io/badge/简体中文-切换-gray)](README.zh-CN.md)

Native macOS version of FileLockAnalyzer.

## Tech Stack

- Native UI: AppKit
- Language: Objective-C++
- Backend: `lsof` + `libproc`
- Build system: CMake

## Features

- Analyze file or folder lock owners
- Show process name, PID, process path, locked path, and source
- Terminate the selected process
- Reveal the current target in Finder
- Accept an initial path from the command line

## Build

Run on macOS:

```bash
cmake -S . -B build -G Xcode
cmake --build build --config Release
```

The built app is located at:

```bash
build/Release/FileLockAnalyzerMac.app
```

You can also build with Ninja:

```bash
cmake -S . -B build -G Ninja
cmake --build build
```

## Notes

- Directory analysis depends on the system `lsof`
- Some system processes or processes owned by other users may require elevated privileges to appear completely
- The current version focuses on analysis and basic process actions first
