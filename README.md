# 京城账本 / Beijing Fushengji-style macOS Prototype

这是一个使用 Swift + SwiftUI 编写的 macOS 13+ 原生单机文字生存经营游戏骨架。

本仓库目前是独立重制原型：

- 不复制原版 Windows/MFC 源代码、图片、音频或文本。
- 不使用网络、登录、广告、内购或额外系统权限。
- 游戏核心位于 `FushengjiCore`，SwiftUI 只展示状态并发送玩家操作。
- 游戏数据从 JSON 配置读取，便于后续替换为正式原创内容或按许可证导入内容。

原始《北京浮生记》源码包附带 GPLv2 许可证。若未来直接移植或改写其代码、资源、文本、算法，需要在项目中保留并遵守对应许可证条款。本原型当前只复刻“有限天数、债务利息、地点旅行、低买高卖、随机事件”的通用玩法结构。

## 环境要求

- macOS 13 或更高版本
- Swift 6 工具链或完整 Xcode

## 构建与运行

```sh
swift build
swift run FushengjiMac
```

## 核心自测

```sh
swift run FushengjiCoreSelfTests
```

自测覆盖初始化、每日利息、商品买卖、旅行消耗、随机事件、负债失败、胜利结算和存档读写。

## 打包 macOS App

```sh
./scripts/package-release.sh 0.1.0
```

打包结果位于 `.build/releases/`。当前脚本生成 Apple Silicon 版本并使用临时签名；正式分发仍需要 Apple Developer ID 签名与公证。

## 主要结构

- `FushengjiCore`：模型、规则、市场、事件、存档、排行榜和可注入 seed 的游戏引擎。
- `FushengjiMac`：SwiftUI 原生 macOS 窗口、菜单、快捷键和状态展示。
- `GameConfiguration.json`：地点、商品、价格范围、事件、新闻、角色初始状态和结局条件。
