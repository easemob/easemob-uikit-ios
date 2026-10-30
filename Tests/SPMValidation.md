# SPM 本地集成验证

验证日期：2026-10-29。使用当前工作区原始 `Package.swift`，由
`ExampleSPM/EaseChatUIKitSPMExample.xcodeproj` 通过 `..` 引用本地包。
没有替换依赖声明、使用临时 package 或修改 Xcode 构建流程。

## 环境与依赖

- Xcode 26.0.1（17A400）。
- 宿主测试：iPhone 17、iOS 26.2、arm64 模拟器。
- 正式依赖解析：HyphenateChat 4.26.0、FLAnimatedImage 1.0.17、ShengwangInfra_iOS 1.3.16。
- AMRCodec 使用仓库内 xcframework；Release 归档选择 arm64 真机切片。

## 结果

| 检查 | 结果 |
| --- | --- |
| Xcode 本地 package 解析与正式依赖获取 | 通过 |
| 模拟器 App 与宿主测试构建 | 通过 |
| 宿主 XCTest | 12 项通过，0 失败，0 跳过 |
| 330 张图片、Unicode 图片名、倍率、语音动画帧 | 通过 |
| 自定义 bundle、恢复默认、宿主图片覆盖 | 通过 |
| 中英文、宿主文案覆盖、现有语言回退行为 | 通过 |
| AMR-NB 8 kHz / AMR-WB 16 kHz 编解码往返、无效输入 | 通过 |
| 单独安装并启动示例 | 通过；页面显示头像、表情、语音图片、宿主文案和 AMR 编码结果 |
| 无签名 arm64 Release archive | 通过 |
| Debug / Release 产物资源与隐私清单核对 | 通过 |
| Release AMR 动态库嵌入与链接 | 通过，App 链接 `@rpath/AMRCodec.framework/AMRCodec` |

本次构建和测试输出位于 `/private/tmp/easechatuikit-spm-integration/`：

- `hosted-tests.log`、`HostedTests-20261029.xcresult`
- `archive.log`、`EaseChatUIKitSPMExample.xcarchive`
- `example-launch.png`

依赖解析日志：`/private/tmp/easechatuikit-spm-resolve-current.log`。
可按根目录 README 的集成验证命令重复运行。

## 检查脚本修正

Xcode 在此 Debug 宿主测试配置中同时把资源包放入 App 根目录和自动生成的
`*_PackageProduct.framework`；两份内容与源文件一致。Release 归档只有根目录
中的一份。`verify_integration_artifacts.py` 现改为逐份核对图片内容及翻译，
不再把合法的多份副本误报为失败。

脚本正反例检查通过：单份／双份完整资源通过，第二份副本中图片被修改、图片缺失、
翻译改变，以及全部资源包缺失均会失败。

## 验证边界

尚未执行真机签名安装、麦克风录音和扬声器播放验收；未运行 Intel 模拟器或 iOS 15。
模拟器中的 AMR 编解码与动态库加载已经实际执行，不只是编译检查。
