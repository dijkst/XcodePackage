# XcodePackage
-
Package 是一个标准化的打包工具，初衷是遵循 Apple 开发习惯，全程使用标准流程，帮助开发人员直接生成 SDK 包，同时生成 Podspec 文件。

### 功能：

1. 使用 Xcode 配置输出产物，并生成含模拟器、真机多种架构的通用二进制；
- 自动识别正在打开的 Xcode 项目，方便快速打包；
- 自动分析用户 Git 信息以及项目信息，提取出必要信息，作为生成的 Podspec 参考信息；
- 发布成功将自动对 Git 项目打 Tag；
- 支持 GUI、命令行双模式，少量的交互模式，简化开发人员学习成本；
- 支持 subspec 模式打包

### 支持类型：
1. 静态/动态 Framework
- 静态二进制(`.a`)
- 动态二进制(`.dylib`)
- 资源包(`.bundle`)
- Object File (`.o`)

### 使用方法
1. 使用 Xcode 标准模版创建项目，并设置好相应 Target 参数
- 如果项目使用了 CocoaPods 作为依赖管理，最好准确编写源码依赖用的 podspec，会从该 podspec 中读取必要信息
- 保证项目能正常运行
- 打开 Package App，选择要打包的项目
- 请确保打包项目的 scheme 勾选了 `Shared` 类型
- 根据界面提示操作即可
- 输出产物请到 `菜单` -> `Window` -> `打开输出目录` 查看
- 查看日志请到 `菜单` -> `Window` -> `显示日志` 查看

### Podspec 生成规则 (IPA 无效)

| podspec 值 | 数据来源 | 数据来源类型 |
|:-----------:|:--------------------------------------------------------:|:---------:|
| name | Project 名 | [Xcode] |
| version | Target 的 `Deployment Target` | [Xcode] |
| authors | Git config | [Git] |
| homepage | Git config | [Git] |
| description | 项目根目录的 podspec，默认同 `name` | [Podspec] |
| source | 占位符 | - |
| license | 项目根目录的 podspec，默认 `MIT` | [Podspec] |
| source_code | Git config | [Git] |
| frameworks | Demo 中 link frameowrks | [Xcode] |
| libraries | Demo 中 link libraries | [Xcode] |
| xcconfig | Demo 中 `HEADER_SEARCH_PATHS`、`OTHER_LDFLAGS`、`OTHER_CFLAGS` | [Xcode] |
| default_subspec | 项目根目录的 podspec | [Podspec] |

|  | .a | .dylib | .framework (static) | .framework(dynamtic) | .bundle | .o |
|:-------------------:|:---:|:-------:|:----------------------------------------------------------------------------------------------------:|:----------------------:|:---------:|:--:|
| source_files | - | - | xx.framework/Headers/* | xx.framework/Headers/* | - | - |
| resources | - | - | 如果存在 Resources 文件夹： xx.framework/Resources/*  否则 xx.framework/*  | - | xx.bundle | - |
| exclude_files | - | - | xx.framework 目录下 Headers, PrivateHeaders, Modules, Versions, CodeSignature, .DS_Store, Info.plist | - | - | - |
| vendored_frameworks | - | - | xx.framework | xx.framework | - | - |
| vendored_libraries | xx.a | xx.dylib | - | - | - | - |                                                 |     -     |  - |

### Subspec
只支持一层 subspec，每个 target 为一个 subspec，当添加多个 target 到一个 scheme 中，自动判断为生成 subspec。

subspec 中的 name 为 target 名，如果希望 subspec 名字和生成的 framework 名字不同，则可以修改对应 target 的 `PRODUCT_NAME` 和 target 名字不同。

### Todo
1. 支持 IPA 产物并扫码安装

### QA
1. 安装 Gem 环境失败，详细日志提示如下：

	```
/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX10.12.sdk/System/Library/Frameworks/Ruby.framework/Versions/2.0/usr/include/ruby-2.0.0/ruby/ruby.h:24:10: fatal error: 'ruby/config.h' file not found
#include "ruby/config.h"
^
1 error generated.
make: *** [generator.o] Error 1
make failed, exit code 2
```
	解决方法：前往苹果下载中心下载并重装 Command Line Tool，然后重新启动 App 即可。

- 选择了项目无法看到 Scheme，提示 `未找到 Shared Scheme`:

	在 Xcode 中，选择 `Scheme` -> `Manage Schemes...` -> `勾选对应 Scheme 的 Shared 的勾`
