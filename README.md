# EaseChatUIKit for iOS

# 单群聊 UIKit

本产品主要旨在给用户打造一个良好体验的单群聊UIKit。主要为用户解决直接集成SDK繁琐，复杂度高，部分api体验不好（在用户侧开发者来看）等问题。致力于打造集成简单，自由度高，流程简单，文档说明足够详细的单群聊UIKit产品。

# 示例演示

在本项目中，“Example”文件夹中有一个最佳实践演示项目，供您构建自己的业务能力。

如需体验EaseChatUIKit的功能，您可以扫描以下二维码试用demo。

![Demo](./Documentation/demo.png)

# 单群聊 UIKit 指南

## 简介

本指南介绍了 EaseChatUIKit 框架在 iOS 开发中的概述和使用示例，并描述了该 UIKit 的各个组件和功能，使开发人员能够很好地了解 UIKit 并有效地使用它。

## 目录

- [前置开发环境要求](#前置开发环境要求)
- [安装](#安装)
- [文档](#文档)
- [结构](#结构)
- [快速开始](#快速开始)
- [注意事项](#注意事项)
- [进阶用法](#进阶用法)
- [自定义](#自定义)
- [业务流程图](#业务流程图)
- [Api时序图](#Api时序图)
- [设计指南](#设计指南)
- [贡献](#贡献)
- [许可证](#许可证)

# 前置开发环境要求

- Xcode 14.0及以上版本
- 最低支持系统：iOS 13.0
- 请确保您的项目已设置有效的开发者签名

# 安装

您可以使用 CocoaPods 安装 EaseChatUIKit 作为 Xcode 项目的依赖项。

## CocoaPods

在podfile中添加如下依赖

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '13.0'

target 'YourTarget' do
  use_frameworks!

  pod 'EaseChatUIKit'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
```

然后cd到终端下podfile所在文件夹目录执行

```
    pod install
```

>⚠️Xcode15编译报错 ```Sandbox: rsync.samba(47334) deny(1) file-write-create...```

> 解决方法: Build Setting里搜索 ```ENABLE_USER_SCRIPT_SANDBOXING```把```User Script Sandboxing```改为```NO```


# 结构

### EaseChatUIKit 基本项目结构

```
Classes
├─ Service // 基础服务组件。
│ ├─ Client //单群聊UIKit 用户主要初始化、登录、缓存等使用Api。
│ ├─ Protocol // 业务协议。
│ │ ├─ ConversationService // 会话协议。包含对会话的各种处理操作等。
│ │ ├─ ContactService // 联系人协议。包含后续的联系人增删等操作。
│ │ ├─ ChatService // 聊天协议。包含对消息的各种处理操作等。
│ │ ├─ UserService // 用户登录协议。包含用户登录以及socket连接状态变更等。
│ │ ├─ MultiService // 多设备通知协议。包含单群聊、会话、联系人、成员变更等。
│ │ └─ GroupService // 实现群聊管理协议。包括加入和离开群组以及群组信息的编辑等。
│ └─ Implement // 上面对应协议的实现组件。
│
└─ UI // 基本UI组件，不带业务。
    ├─ Resource // 图像或本地化文件。
    ├─ Component // 包含具体业务的UI模块。 单群聊UIKit中的一些功能性UI组件。
    │ ├─ Chat // 所有聊天视图的容器。
    │ ├─ Contact // 联系人、群组及其详情等容器。
    │ └─ Conversation // 会话列表容器。
    └─ Core
       ├─ UIKit // 一些常见的UIKit组件和自定义组件以及一些UI相关的工具类。
       ├─ Foundation // 日志以及一些音频转换工具类。
       ├─ Theme // 主题相关组件，包括颜色、字体、换肤协议及其组件。
       └─ Extension // 一些方便的系统类扩展。
```

# 文档

## [文档](/Documentation/EaseChatUIKit.doccarchive)

您可以在 Xcode 中打开“EaseChatUIKit.doccarchive”文件来查看其中的文件或将此文件部署到您的主页。

另外，您可以右键单击该文件以显示包内容并将其中的所有文件复制到一个文件夹中。 然后将此文件夹拖到“terminal”应用程序中并运行以下命令将其部署到本地IP地址上。

```bash
python3 -m http.server 8080
```

部署完成后，您可以在浏览器中访问 http://yourlocalhost:8080/documentation/EaseChatUIKit   其中`yourlocalhost`是您的本地IP地址。 或者，您可以将此文件夹部署在外部网络地址上。

## Appearance

[Appearance](https://github.com/easemob/UIKit_Chatroom_ios/blob/dev/Documentation/Appearance.md) 即加载UI前的可配项配置类

## ComponentRegister

[ComponentRegister](https://github.com/easemob/UIKit_Chatroom_ios/blob/dev/Documentation/ComponentRegister.md).即可继承进行定制的 UI 组件。

## ComponentViewsActionHooker

[ComponentViewsActionHooker](https://github.com/easemob/UIKit_Chatroom_ios/blob/dev/Documentation/ComponentViewsActionHooker.md)

所有可拦截的点击事件容器

# 快速开始

本指南提供了不同 EaseChatUIKit 组件的多个使用示例。 请参阅“示例”文件夹以获取显示各种用例的详细代码片段和项目。

参考以下步骤在 Xcode 中创建一个 iOS 平台下的App，创建设置如下：

* Product Name 填入EaseChatUIKitQuickStart。
* Organization Identifier 设为 您的identifier。
* User Interface 选择 Storyboard。
* Language 选择 你的常用开发语言。

### 第一步：初始化EaseChatUIKit

```swift
import EaseChatUIKit

@UIApplicationMain
class AppDelegate：UIResponder，UIApplicationDelegate {

     var window：UIWindow？


     func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         // 您可以在应用程序加载时或使用之前初始化 EaseChatUIKit。
         // 需要传入App Key。
         // 获取App Key，请访问
         // https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E8%8E%B7%E5%8F%96%E7%8E%AF%E4%BF%A1%E5%8D%B3%E6%97%B6%E9%80%9A%E8%AE%AF-im-%E7%9A%84%E4%BF%A1%E6%81%AF
         let error = EaseChatUIKitClient.shared.setup（appKey: "Appkey"）
     }
}
```

### 第2步：登录

``` Swift
public final class YourAppUser: NSObject, EaseProfileProtocol {

    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id]]
    }

    public var userId: String = <#T##String#>

    public var nickname: String = "Jack"

    public var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"

}
// 使用当前用户对象符合`EaseProfileProtocol`协议的用户信息登录EaseChatUIKit。
// token生成参见快速开始中登录步骤中链接。
// 需要从您的应用服务器获取token。 您也可以使用控制台生成的临时Token登录。
// 在控制台生成用户和临时用户 token，请参见
// https://docs-im-beta.easemob.com/product/enable_and_configure_IM.html#%E5%88%9B%E5%BB%BA-im-%E7%94%A8%E6%88%B7。
  EaseChatUIKitClient.shared.login(user: YourAppUser(), token: ExampleRequiredConfig.chatToken) { error in 
 }
```

### 第三步：创建聊天页面

```Swift
        // 在Console中创建一个新用户，将这个用id复制后传入下面构造方法参数中，跳转页面即可。
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: <#刚创建用户的id#>, chatType: .chat)
        //或者push或者present都可
        ControllerStack.toDestination(vc: vc)

```

# 进阶用法

以下是进阶用法的三个示例。

## 1.初始化单群聊UIKit
相比于上面快速开始的单群聊UIKit初始化这里多了ChatOptions的参数，主要是对SDK中是否打印log以及是否自动登录，是否默认使用用户属性的开关配置。
```Swift
let error = EaseChatUIKitClient.shared.setup(
    with: "Your appkey",
    option: EaseChatUIKitInitialOptions.ChatOptions()
)
```

## 2.登录

```Swift
public final class YourAppUser: NSObject, EaseProfileProtocol {

    public func toJsonObject() -> Dictionary<String, Any>? {
        ["ease_chat_uikit_info":["nickname":self.nickname,"avatarURL":self.avatarURL,"userId":self.id]]
    }

    public var userId: String = <#T##String#>

    public var nickname: String = "Jack"

    public var avatarURL: String = "https://accktvpic.oss-cn-beijing.aliyuncs.com/pic/sample_avatar/sample_avatar_1.png"

}
// 使用当前用户对象符合`EaseProfileProtocol`协议的用户信息登录EaseChatUIKit。
// token生成参见快速开始中登录步骤中链接。
 EaseChatUIKitClient.shared.login(user: YourAppUser(), token: ExampleRequiredConfig.chatToken) { error in 
 }
```
## 3.会话列表页面

## 4.联系人页面

## 5.初始化聊天页面

```swift
        // 在Console中创建一个新用户，将这个用id复制后传入下面构造方法参数中，跳转页面即可。
        let vc = ComponentsRegister.shared.MessageViewController.init(conversationId: <#刚创建用户的id#>, chatType: .chat)
        //或者push或者present都可
        ControllerStack.toDestination(vc: vc)
```

## 4.监听EaseChatUIKit事件和错误

您可以调用`registerRoomEventsListener`方法来侦听 EaseChatUIKit 事件和错误。

```swift
EaseChatUIKitClient.shared.registerRoomEventsListener(self)
```

# 自定义

## 1.修改可配置项

下面展示如何更改弹幕区域的整体单元格布局风格以及如何创建ChatroomView。

```swift
// 可以通过设置属性来改变弹幕区域的整体单元格布局风格。
Appearance.messageDisplayStyle = .hideUserIdentity
// 创建ChatroomView，传入布局参数、底部工具栏扩展按钮模型协议数组等参数。
let roomView = EaseChatUIKitClient.shared.launchRoomView(roomId: "聊天室 ID",frame: <#T##CGRect#>)
self.view.addSubView(roomView)
```

详情请参见[Appearance](./Documentation/Appearance.md)。

## 2.自定义组件

下面展示如何自定义礼物弹幕视图cell。

```swift
class CustomGiftMessageViewCell: GiftMessageCell {
    lazy var redDot: UIView = {
        UIView().backgroundColor(.red).cornerRadius(.large)
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(redDot)
    }

    override func refresh(item: GiftEntityProtocol) {
        super.refresh(item: item)
        self.redDot.isHidden = item.selected
    }
}
//在EaseChatUIKit中注册继承原有类的自定义类来替换原来的类。
//在创建ChatroomView或使用其他UI组件之前调用此方法。
ComponentsRegister.shared.GiftMessageViewCell = CustomGiftMessageViewCell.self
```

详情请参见[ComponentsRegister](./Documentation/ComponentRegister.md)

## 3.切换原创或自定义主题
- 切换到 EaseChatUIKit 附带的浅色或深色主题。在初始化单群聊UIKit视图之前切换主题切换主题即可更改默认主题，在视图使用中也可以切换由开发者判断系统当前主题后切换你想对应的主题即可。

```swift
Theme.switchTheme(style: .dark)
// 或
Theme.switchTheme(style: .light)
```

- 切换到自定义主题。

```swift
/**
如何定制主题？

自定义主题时，需要参考设计文档的主题色定义以下五种主题色的色相值。

EaseChatUIKit 中的所有颜色都是使用 HSLA 颜色模型定义的，该模型是一种使用色调、饱和度、亮度和 alpha 表示颜色的方式。

H（Hue）：色相，颜色的基本属性，是色轮上从0到360的一个度数。0是红色，120是绿色，240是蓝色。

S（饱和度）：饱和度是颜色的强度和纯度。 饱和度越高，颜色越鲜艳； 饱和度越低，颜色越接近灰色。 饱和度以百分比值表示，范围从 0% 到 100%。 0% 表示灰度，100% 表示全色。

L（明度）：明度是颜色的亮度或暗度。 亮度越高，颜色越亮； 亮度越低，颜色越深。 亮度以百分比值表示，范围从 0% 到 100%。 0% 表示黑色，100% 表示白色。

A（Alpha）：Alpha是颜色的透明度。 值 1 表示完全不透明，0 表示完全透明。

通过调整HSLA模型的各个分量的值，您可以实现精确的色彩控制。
  */
Appearance.primaryHue = 191/360.0
Appearance.secondaryHue = 210/360.0
Appearance.errorHue = 189/360.0
Appearance.neutralHue = 191/360.0
Appearance.neutralSpecialHue = 199/360.0
Theme.switchTheme(style: .custom)
```

# 业务流程图
下图展示了业务请求和回调的整个逻辑。
![业务逻辑整体流程图](/Documentation/BusinessFlowchart.png)

# Api时序图

下图是Example项目中最佳实践的API调用时序图。

![APIUML](/Documentation/Api.png)

# 设计指南

如果您对设计指南和细节有任何疑问，您可以在 Figma 设计稿中添加评论并提及我们的设计师 Stevie Jiang。

参见[设计图](https://www.figma.com/community/file/1322495388317476706/chatroom-uikit)。

请参阅[UI设计指南](https://docs-im-beta.easemob.com/uikit/EaseChatUIKit/ios/design_guide.html)

# 贡献

欢迎贡献和反馈！ 对于任何问题或改进建议，您可以提出问题或提交拉取请求。

## 作者

zjc19891106, [984065974@qq.com](mailto:984065974@qq.com)

## 许可证

EaseChatUIKit 可在 MIT 许可下使用。 有关详细信息，请参阅许可证文件。
