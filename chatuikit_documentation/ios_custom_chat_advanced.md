# 消息列表的高级设置

消息列表是聊天界面的核心组件，基于 `MessageListController` 和 `MessageListView` 实现。本文介绍如何通过配置 `Appearance` 和 `ComponentsRegister` 实现消息列表的高级设置。

## 概述

你可以通过以下方式定制消息列表：

- **Appearance.chat**: 用于配置 UI 样式、图标、菜单项等。
- **ComponentsRegister**: 用于注册自定义的消息 Cell 或替换核心组件类。

## `Appearance.chat` 消息列表配置说明表

| 配置项 | 类型 | 默认值 | 说明 | 影响范围 |
|--------|------|--------|------|---------|
| **输入框配置** |
| `maxInputHeight` | CGFloat | 88 | 输入框最大高度限制 | MessageInputBar 高度上限 |
| `inputPlaceHolder` | String | "Aa" | 输入框占位符文本 | MessageInputBar 提示文字 |
| `inputBarCorner` | CornerRadius | .extraSmall | 输入框圆角样式 | MessageInputBar 圆角 |
| **消息气泡样式** |
| `bubbleStyle` | MessageBubbleDisplayStyle | .withArrow | 消息气泡显示样式 | 带箭头气泡(.withArrow) 或 多圆角气泡(.withMultiCorner) |
| `contentStyle` | [MessageContentDisplayStyle] | [.withReply, .withAvatar, .withNickName, .withDateAndTime] | 消息内容显示样式组合 | 控制是否显示回复、头像、昵称、时间等元素 |
| **消息操作菜单** |
| `messageLongPressedActions` | [ActionSheetItemProtocol] | 12个操作项 | 长按消息弹出的操作菜单 | 包含复制、转发、话题、回复、撤回、编辑、多选、置顶、翻译、显示原文、举报、删除 |
| `messageLongPressMenuStyle` | MessageLongPressMenuStyle | .withArrow | 消息长按菜单样式 | 带箭头菜单(.withArrow) 或 ActionSheet(.actionSheet) |
| **翻译功能** |
| `targetLanguage` | LanguageType | .Chinese | 目标翻译语言 | 消息翻译的目标语言 |
| `enableTranslation` | Bool | false | 是否启用翻译功能 | 需从控制台开启后设置为true |
| **举报功能** |
| `reportSelectionTags` | [String] | ["tag1"..."tag9"] | 消息举报类型标签 | 举报消息时的分类标签 |
| `reportSelectionReasons` | [String] | 9个违规原因 | 消息举报原因列表 | 举报消息时的原因选项 |
| **附件菜单配置** |
| `inputExtendActions` | [ActionSheetItemProtocol] | 4个操作项 | 点击"+"按钮弹出的菜单项 | 包含照片、相机、文件、联系人 |
| `messageAttachmentMenuStyle` | MessageAttachmentMenuStyle | .followInput | 附件菜单样式 | 跟随输入框(.followInput) 或 ActionSheet(.actionSheet) |
| **日期时间格式** |
| `dateFormatToday` | String | "HH:mm" | 今天消息的时间格式 | 当天消息显示格式 |
| `dateFormatOtherDay` | String | "yyyy-MM-dd HH:mm" | 其他日期消息的时间格式 | 非当天消息显示格式 |
| **语音消息配置** |
| `audioDuration` | Int | 60 | 录音时长限制（秒） | 最长录音60秒 |
| `receiveAudioAnimationImages` | [UIImage] | 3张图片 | 接收方音频播放动画图片 | 左侧音频播放动画帧 |
| `sendAudioAnimationImages` | [UIImage] | 3张图片 | 发送方音频播放动画图片 | 右侧音频播放动画帧 |
| `newMessageSoundPath` | String | 系统音效路径 | 新消息提示音路径 | 收到新消息的提示音 |
| **文本颜色配置** |
| `receiveTextColor` | UIColor | 深色模式：neutralColor98<br>浅色模式：neutralColor1 | 接收方文本颜色 | 接收消息文本颜色 |
| `sendTextColor` | UIColor | 深色模式：neutralColor1<br>浅色模式：neutralColor98 | 发送方文本颜色 | 发送消息文本颜色 |
| `receiveTranslationColor` | UIColor | 深色模式：neutralColor7<br>浅色模式：neutralColor5 | 接收方翻译文本颜色 | 接收消息翻译文本颜色 |
| `sendTranslationColor` | UIColor | 深色模式：neutralSpecialColor2<br>浅色模式：neutralSpecialColor95 | 发送方翻译文本颜色 | 发送消息翻译文本颜色 |
| **图片/视频消息配置** |
| `imageMessageCorner` | CGFloat | 4 | 图片消息圆角大小 | 图片消息的圆角半径 |
| `imagePlaceHolder` | UIImage? | image_message_placeHolder | 图片消息占位图 | 图片加载中显示的占位图 |
| `videoPlaceHolder` | UIImage? | video_message_placeHolder | 视频消息占位图 | 视频封面占位图 |
| **消息撤回配置** |
| `recallExpiredTime` | UInt | 120 | 消息撤回时限（秒） | 消息发送后可撤回的最长时间 |
| **群组配置** |
| `groupParticipantsLimitCount` | Int | 1000 | 群聊参与者数量上限 | 群成员最大数量 |
| **新消息提醒配置** |
| `moreMessageAlertPosition` | MoreMessagePosition | .center | 新消息提醒位置 | 左侧(.left)、居中(.center)、右侧(.right) |
| **输入状态配置** |
| `enableTyping` | Bool | true | 是否显示对方正在输入状态 | 显示"Typing..."提示 |
| **置顶消息配置** |
| `enablePinMessage` | Bool | true | 是否启用置顶消息功能 | 启用消息置顶功能 |
| **URL预览配置** |
| `titlePreviewPattern` | String | "" | URL预览标题正则表达式 | 提取网页标题的规则 |
| `descriptionPreviewPattern` | String | "" | URL预览描述正则表达式 | 提取网页描述的规则 |
| `imagePreviewPattern` | String | "" | URL预览图片正则表达式 | 提取网页图片的规则 |
| `enableURLPreview` | Bool | true | 是否启用URL预览 | 自动预览消息中的链接 |

## 枚举类型说明

### MessageAttachmentMenuStyle（附件菜单样式）
| 值 | 说明 |
|----|------|
| `.followInput` | 菜单跟随输入框显示，类似微信 |
| `.actionSheet` | 使用ActionSheet样式，类似iOS系统菜单 |

### MessageLongPressMenuStyle（长按菜单样式）
| 值 | 说明 |
|----|------|
| `.withArrow` | 带箭头的菜单，类似微信消息长按菜单 |
| `.actionSheet` | 使用ActionSheet样式，类似iOS系统菜单 |

### MessageBubbleDisplayStyle（气泡显示样式）
| 值 | 说明 |
|----|------|
| `.withArrow` | 带箭头的气泡样式 |
| `.withMultiCorner` | 多圆角气泡样式（无箭头） |

### MessageContentDisplayStyle（内容显示样式）
| 值 | 说明 |
|----|------|
| `.withReply` | 显示回复内容 |
| `.withAvatar` | 显示用户头像 |
| `.withNickName` | 显示用户昵称 |
| `.withDateAndTime` | 显示日期时间 |
| `.withMessageThread` | 显示消息话题 |
| `.withMessageReaction` | 显示消息表情回应 |

**使用说明：**
- 所有配置项都可以通过修改 `Appearance.chat` 来全局调整
- `contentStyle` 可以组合使用多个样式，例如：`[.withReply, .withAvatar]`
- 图片资源可以通过在 Bundle.main 中提供同名图片来覆盖
- 国际化字符串可以通过在 Bundle.main 的 Localizable.strings 中提供同名 key 来覆盖

## 设置消息气泡和样式

通过 `Appearance.chat` 可以配置消息气泡的全局样式。

```swift
// 设置消息气泡样式：带箭头或无箭头
Appearance.chat.bubbleStyle = .withArrow

// 设置消息内容显示元素：是否显示昵称、头像、时间等
Appearance.chat.contentStyle = [.withReply, .withAvatar, .withNickName, .withDateAndTime]

// 设置发送方和接收方的文本颜色
Appearance.chat.sendTextColor = UIColor.white
Appearance.chat.receiveTextColor = UIColor.black

// 设置输入框圆角
Appearance.chat.inputBarCorner = .extraSmall
```

## 设置头像和昵称

在 iOS UIKit 中，头像和昵称的显示主要由 `Appearance.chat.contentStyle` 控制。

```swift
// 显示头像和昵称
Appearance.chat.contentStyle = [.withAvatar, .withNickName]

// 如果不想显示昵称
Appearance.chat.contentStyle = [.withAvatar]

// 设置头像圆角
Appearance.avatarRadius = .large
```

## 设置长按消息菜单

在消息列表长按消息时弹出的菜单可以通过 `Appearance.chat.messageLongPressedActions` 进行配置。你可以添加自定义的操作项，或者移除默认项。

### 添加/修改菜单项

```swift
// 获取默认的菜单项
var actions = Appearance.chat.messageLongPressedActions

// 创建一个新的菜单项
let customAction = ActionSheetItem(title: "自定义", type: .normal, tag: "CustomTag", image: UIImage(named: "custom_icon"))
customAction.action = { item, message in
    // 处理点击事件
    print("点击了自定义菜单")
}

// 添加到菜单列表
actions.append(customAction)

// 更新配置
Appearance.chat.messageLongPressedActions = actions
```

### 菜单样式

你可以选择长按菜单的展示风格：

```swift
// 类似微信的气泡风格
Appearance.chat.messageLongPressMenuStyle = .withArrow

// iOS 系统 ActionSheet 风格
Appearance.chat.messageLongPressMenuStyle = .actionSheet
```

## 自定义输入区扩展菜单

点击输入框右侧的 `+` 号弹出的扩展菜单可以通过 `Appearance.chat.inputExtendActions` 进行配置。

```swift
// 添加一个新的扩展功能
let fileAction = ActionSheetItem(title: "文件", type: .normal, tag: "File", image: UIImage(named: "file_icon"))
Appearance.chat.inputExtendActions.append(fileAction)
```

## 注册自定义消息 Cell

如果你需要展示自定义类型的消息，或者完全重写现有消息的展示样式，可以使用 `ComponentsRegister` 注册自定义 Cell。

### 1. 创建自定义 Cell

- 这里以红包消息举例

#### 1.根据需求继承`EaseChatUIKit`中的Cell

```Swift
import UIKit
import EaseChatUIKit

class RedPackageCell: CustomMessageCell {

    override func createContent() -> UIView {
        UIView(frame: self.contentView.bounds).backgroundColor(.clear).tag(bubbleTag).backgroundColor(.systemRed)
    }
    
    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
    }
            
        //如果想让气泡尖角改颜色
        override func updateAxis(entity: MessageEntity) {
        super.updateAxis(entity: entity)
        if Appearance.chat.bubbleStyle == .withArrow {
            self.bubbleWithArrow.arrow.image = UIImage(named: self.towards == .left ? "arrow_left": "arrow_right", in: .chatBundle, with: nil)?.withTintColor(self.towards == .left ? .systemRed:.systemRed)
        } else {
            self.bubbleMultiCorners.backgroundColor = .systemRed
        }
    }
}

```

#### 2.根据需求继承`EaseChatUIKit`中的Cell的渲染模型`MessageEntity`，并给定气泡大小，其中`redPackageIdentifier`为红包的自定义消息的event事件

```Swift
import UIKit
import EaseChatUIKit

final class MineMessageEntity: MessageEntity {
    
    override func customSize() -> CGSize {
        if let body = self.message.body as? ChatCustomMessageBody {
            switch body.event {
            case EaseChatUIKit_user_card_message:
                return CGSize(width: self.historyMessage ? ScreenWidth-32:limitBubbleWidth, height: contactCardHeight)
            case EaseChatUIKit_alert_message:
                let label = UILabel().numberOfLines(0).lineBreakMode(.byWordWrapping)
                label.attributedText = self.convertTextAttribute()
                let size = label.sizeThatFits(CGSize(width: ScreenWidth-32, height: 9999))
                return CGSize(width: ScreenWidth-32, height: size.height+50)
            case redPackageIdentifier:
                return CGSize(width: limitBubbleWidth, height: limitBubbleWidth*(5/3.0))
            default:
                return .zero
            }
            
        } else {
            return .zero
        }
    }

    
}


```

#### 3.添加发送附件消息的类型

示例，增加发送红包消息

```Swift
        
        let redPackage = ActionSheetItem(title: "红包".chat.localize, type: .normal,tag: "Red",image: UIImage(named: "photo", in: .chatBundle, with: nil))
        Appearance.chat.inputExtendActions.append(redPackage)
```

#### 4.在继承的`MessageListController`处理新增的附件消息类型的点击

示例代码
```Swift
class CustomMessageListController: MessageListController {
    
    override func handleAttachmentAction(item: any ActionSheetItemProtocol) {
        switch item.tag {
        case "File": self.selectFile()
        case "Photo": self.selectPhoto()
        case "Camera": self.openCamera()
        case "Contact": self.selectContact()
        case "Red": self.redPackageMessage()
        default:
            break
        }
    }
    
    private func redPackageMessage() {
        self.viewModel.sendRedPackageMessage()
    }

}

let redPackageIdentifier = "redPackage"

```

#### 5.给`EaseChatUIKit`中的`MessageListViewModel`增加发送红包消息的方法

```Swift
extension MessageListViewModel {
    func sendRedPackageMessage() {
        var ext = Dictionary<String,Any>()
        ext["something"] = "发红包"
        let json = EaseChatUIKitContext.shared?.currentUser?.toJsonObject() ?? [:]
        ext.merge(json) { _, new in
            new
        }
        let chatMessage = ChatMessage(conversationID: self.to, body: ChatCustomMessageBody(event: redPackageIdentifier, customExt: ["money": "20", "name": "张三","message": "恭喜发财大吉大利"]), ext: ext)
        self.driver?.showMessage(message: chatMessage)
        self.chatService?.send(message: chatMessage) { [weak self] error, message in
            if error == nil {
                if let message = message {
                    self?.driver?.updateMessageStatus(message: message, status: .succeed)
                }
            } else {
                consoleLogInfo("send text message failure:\(error?.errorDescription ?? "")", type: .error)
                if let message = message {
                    self?.driver?.updateMessageStatus(message: message, status: .failure)
                }
            }
        }
    }
    
    
}

```

#### 6.将上述继承的对象全部注册进`EaseChatUIKit`，在其初始化后

示例代码

```Swift
        
        ComponentsRegister.shared.MessageRenderEntity = MineMessageEntity.self
        ComponentsRegister.shared.Conversation = MineConversationInfo.self
        ComponentsRegister.shared.MessageViewController = CustomMessageListController.self
        //redPackageIdentifier 为Cell的唯一标识，也是环信自定义消息的时间类型
        ComponentsRegister.shared.registerCustomCellClasses(cellType: RedPackageCell.self,identifier: redPackageIdentifier)
```

- 这里`ComponentsRegister.shared.Conversation = MineConversationInfo.self`是为了修改自定义消息在会话列表中，会话收到新消息时显示的内容这里暂定为显示 "[红包]"，示例代码如下，主要更改在非文本消息类型的else中根据自定义消息的event显示对应的内容
```Swift
import UIKit
import EaseChatUIKit


final class MineConversationInfo: ConversationInfo {
    
    override func contentAttribute() -> NSAttributedString {
        guard let message = self.lastMessage else { return NSAttributedString() }
        var text = NSMutableAttributedString()
        
        let from = message.from
        let mentionText = "Mentioned".chat.localize
        let user = EaseChatUIKitContext.shared?.userCache?[from]
        var nickName = user?.remark ?? ""
        if nickName.isEmpty {
            nickName = user?.nickname ?? ""
        }
        if nickName.isEmpty {
            nickName = from
        }
        if message.body.type == .text {
            var result = message.showType
            for (key,value) in ChatEmojiConvertor.shared.oldEmojis {
                result = result.replacingOccurrences(of: key, with: value)
            }
            text.append(NSAttributedString {
                AttributedText(result).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyLarge)
            })
            let string = text.string as NSString
            for symbol in ChatEmojiConvertor.shared.emojis {
                if string.range(of: symbol).location != NSNotFound {
                    let ranges = text.string.chat.rangesOfString(symbol)
                    text = ChatEmojiConvertor.shared.convertEmoji(input: text, ranges: ranges, symbol: symbol,imageBounds: CGRect(x: 0, y: -3, width: 16, height: 16))
                    text.addAttribute(.font, value: UIFont.theme.bodyLarge, range: NSMakeRange(0, text.length))
                    text.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSMakeRange(0, text.length))
                }
            }
            if self.mentioned {
                let showText = NSMutableAttributedString {
                    AttributedText("[\(mentionText)] ").foregroundColor(Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5).font(Font.theme.bodyMedium)
                    AttributedText(nickName + ": ").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5)
                }
                
                let show = NSMutableAttributedString(attributedString: text)
                show.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5, range: NSRange(location: 0, length: show.length))
                show.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: show.length))
                showText.append(show)
                return showText
            } else {
                let showText = NSMutableAttributedString {
                    AttributedText(message.chatType != .chat ? nickName + ": ":"").foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(Font.theme.bodyMedium)
                }
                showText.append(text)
                showText.addAttribute(.foregroundColor, value: Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor6, range: NSRange(location: 0, length: showText.length))
                showText.addAttribute(.font, value: UIFont.theme.bodyMedium, range: NSRange(location: 0, length: showText.length))
                return showText
            }
        } else {
            var content = message.showContent
            if let body = message.body as? ChatCustomMessageBody,body.event == redPackageIdentifier {
                content = "[红包]"
            }
            let showText = NSMutableAttributedString {
                AttributedText((message.chatType == .chat ? content:(nickName+":"+content))).foregroundColor(Theme.style == .dark ? UIColor.theme.neutralColor6:UIColor.theme.neutralColor5).font(UIFont.theme.bodyMedium)
            }
            return showText
        }
    }

}

```


### 2. 注册 Cell

- cell注册

```swift
// 替换默认的文本消息 Cell
ComponentsRegister.shared.ChatTextMessageCell = MyCustomMessageCell.self

对应的`ChatImageMessageCell`&`ChatGIFMessageCell`&`ChatAudioMessageCell`&`ChatVideoMessageCell`&`ChatFileMessageCell`&`ChatContactMessageCell`&`ChatAlertCell`&`ChatLocationCell`&`ChatCombineCell` 跟文本消息一致
// 或者注册全新的自定义消息类型 Cell
// 假设你有一个自定义消息类型，Identifier 为 "CustomEvent"
ComponentsRegister.shared.registerCustomCellClasses(cellType: MyCustomMessageCell.self, identifier: "CustomEvent")
```

- cell业务方法信息以及重载

#### 1. MessageCell (基础消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| **UI组件创建方法** |
| `createCheckbox()` | `@objc open func createCheckbox() -> UIImageView` | 创建多选框图标 | UIImageView | 无参数 |
| `createAvatar()` | `@objc open func createAvatar() -> ImageView` | 创建头像视图 | ImageView | 无参数 |
| `createNickName()` | `@objc open func createNickName() -> UILabel` | 创建昵称标签 | UILabel | 无参数 |
| `createReplyContent()` | `@objc open func createReplyContent() -> MessageReplyView` | 创建回复内容视图 | MessageReplyView | 无参数 |
| `createBubbleWithArrow()` | `@objc open func createBubbleWithArrow() -> MessageBubbleWithArrow` | 创建带箭头的气泡 | MessageBubbleWithArrow | 无参数 |
| `createBubbleMultiCorners()` | `@objc open func createBubbleMultiCorners() -> MessageBubbleMultiCorner` | 创建多圆角气泡 | MessageBubbleMultiCorner | 无参数 |
| `statusView()` | `@objc open func statusView() -> UIImageView` | 创建状态图标视图 | UIImageView | 无参数 |
| `createMessageDate()` | `@objc open func createMessageDate() -> UILabel` | 创建消息时间标签 | UILabel | 无参数 |
| `createTopicView()` | `@objc open func createTopicView() -> MessageTopicView` | 创建话题视图 | MessageTopicView | 无参数 |
| `createReactionView()` | `@objc open func createReactionView() -> MessageReactionView` | 创建表情回应视图 | MessageReactionView | 无参数 |
| **核心方法** |
| `refresh(entity:)` | `@objc(refreshWithEntity:) open func refresh(entity: MessageEntity)` | 刷新Cell数据显示 | Void | entity: 消息实体对象 |
| `updateAxis(entity:)` | `@objc(updateAxisWithEntity:) open func updateAxis(entity: MessageEntity)` | 更新子视图布局坐标 | Void | entity: 消息实体对象 |
| `clickAction(gesture:)` | `@objc open func clickAction(gesture: UITapGestureRecognizer)` | 处理点击手势 | Void | gesture: 点击手势识别器 |
| `longPressAction(gesture:)` | `@objc open func longPressAction(gesture: UILongPressGestureRecognizer)` | 处理长按手势 | Void | gesture: 长按手势识别器 |
| `switchTheme(style:)` | `open func switchTheme(style: ThemeStyle)` | 切换主题样式 | Void | style: 主题样式枚举 |

#### 2. TextMessageCell (文本消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> LinkRecognizeTextView` | 创建文本内容视图 | LinkRecognizeTextView | 无参数，支持链接识别 |
| `createEditSymbol()` | `@objc open func createEditSymbol() -> UIButton` | 创建编辑标识按钮 | UIButton | 显示"Edited"标记 |
| `createTranslationContainer()` | `@objc open func createTranslationContainer() -> TranslateTextView` | 创建翻译容器视图 | TranslateTextView | 无参数 |
| `createTranslation()` | `@objc open func createTranslation() -> UILabel` | 创建翻译内容标签 | UILabel | 无参数 |
| `createTranslateSymbol()` | `@objc open func createTranslateSymbol() -> UIButton` | 创建翻译标识按钮 | UIButton | 显示"Translated"标记 |
| `createPreviewContent()` | `@objc open func createPreviewContent() -> URLPreviewResultView` | 创建URL预览视图 | URLPreviewResultView | 用于链接预览 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新文本消息显示 | Void | 包含编辑、翻译、URL预览逻辑 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 调用onThemeChanged() |
| `onThemeChanged()` | `open func onThemeChanged()` | 主题变化时更新UI | Void | 处理链接颜色、选中颜色等 |

#### 3. ImageMessageCell (图片消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> ImageView` | 创建图片内容视图 | ImageView | 带圆角的图片视图 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新图片消息显示 | Void | 处理本地/远程图片加载 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新背景色和边框 |

#### 4. VideoMessageCell (视频消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> ImageView` | 创建视频封面视图 | ImageView | 显示视频缩略图 |
| `createPlay()` | `@objc open func createPlay() -> UIImageView` | 创建播放按钮图标 | UIImageView | 居中显示的播放图标 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新视频消息显示 | Void | 加载视频缩略图、控制播放按钮显隐 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新背景色和边框 |

#### 5. AudioMessageCell (语音消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> UIView` | 创建语音内容视图 | UIView | 返回AudioMessageView实例 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新语音消息显示 | Void | 显示已读/未读红点 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新红点颜色 |

#### 6. FileMessageCell (文件消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> UIView` | 创建文件内容视图 | UIView | 返回FileMessageView实例 |
| `refresh(entity:)` | `public override func refresh(entity: MessageEntity)` | 刷新文件消息显示 | Void | 调用FileMessageView的refresh |

#### 7. LocationMessageCell (位置消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> UIView` | 创建位置内容视图 | UIView | 空白视图，需自定义实现 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新位置消息显示 | Void | 包含收发消息UI区分 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 空实现，可自定义 |

#### 8. CustomMessageCell (自定义消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> UIView` | 创建自定义内容视图 | UIView | 空白视图，需自定义实现 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新自定义消息显示 | Void | 包含收发消息UI区分 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 空实现，可自定义 |

#### 9. ContactCardCell (联系人卡片Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> UIView` | 创建联系人卡片视图 | UIView | 返回ContactCardView实例 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新联系人卡片显示 | Void | 调用ContactCardView的refresh |

#### 10. CombineMessageCell (合并消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> CombineMessageView` | 创建合并消息视图 | CombineMessageView | 显示聊天记录摘要 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新合并消息显示 | Void | 调用CombineMessageView的refresh |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 空实现，可自定义 |

#### 11. GIFMessageCell (GIF消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createContent()` | `@objc open func createContent() -> GIFAnimatedImageView` | 创建GIF动画视图 | GIFAnimatedImageView | 支持GIF动画播放 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新GIF消息显示 | Void | 加载并播放GIF动画 |
| `switchTheme(style:)` | `open override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新背景色和边框 |

#### 12. AlertMessageCell (提醒消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `clickAction(gesture:)` | `open override func clickAction(gesture: UITapGestureRecognizer)` | 处理点击手势 | Void | 仅当有threadId时响应 |
| `refresh(entity:)` | `open override func refresh(entity: MessageEntity)` | 刷新提醒消息显示 | Void | 显示时间和提醒内容 |
| `switchTheme(style:)` | `public override func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新时间文字颜色 |

#### 13. ChatHistoryCell (聊天历史Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(entity:)` | `@objc open func refresh(entity: MessageEntity)` | 刷新聊天历史显示 | Void | 支持图片、视频、文本消息显示 |
| `switchTheme(style:)` | `public func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新昵称、分隔线、日期颜色 |

#### 14. ChatThreadCell (话题Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(chatThread:)` | `open func refresh(chatThread: EaseChatThread)` | 刷新话题信息显示 | Void | chatThread: 话题对象 |
| `renderMessageContent(message:)` | `open func renderMessageContent(message: ChatMessage?) -> NSAttributedString` | 渲染消息内容 | NSAttributedString | message: 最新消息对象 |
| `switchTheme(style:)` | `public func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新各元素颜色 |

#### 15. PinnedMessageCell (置顶消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(entity:)` | `@objc open func refresh(entity: PinnedMessageEntity)` | 刷新置顶消息显示 | Void | entity: 置顶消息实体 |
| `removeAction()` | `@objc open func removeAction()` | 移除按钮点击 | Void | 显示确认移除按钮 |
| `confirmRemoveAction()` | `@objc open func confirmRemoveAction()` | 确认移除按钮点击 | Void | 触发移除回调 |
| `switchTheme(style:)` | `public func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新容器和按钮颜色 |

#### 16. ForwardTargetCell (转发目标Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(info:keyword:forward:)` | `open func refresh(info: ChatUserProfileProtocol, keyword: String, forward state: ForwardTargetState)` | 刷新转发目标显示 | Void | info: 用户信息<br>keyword: 搜索关键词<br>state: 转发状态 |
| `highlightKeywords(keyword:in:)` | `func highlightKeywords(keyword: String, in string: String) -> NSAttributedString` | 高亮关键词 | NSAttributedString | 搜索结果关键词高亮 |
| `actionClick()` | `@objc open func actionClick()` | 发送按钮点击 | Void | 触发转发回调 |

#### 17. ReactionDetailCell (表情回应详情Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(reaction:)` | `@objc open func refresh(reaction: MessageReaction)` | 刷新表情回应显示 | Void | reaction: 表情回应对象 |

#### 18. ReactionUserCell (表情回应用户Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `createCheckbox()` | `@objc open func createCheckbox() -> UIImageView` | 创建多选框 | UIImageView | 无参数 |
| `createAvatar()` | `@objc open func createAvatar() -> ImageView` | 创建头像视图 | ImageView | 无参数 |
| `createNickName()` | `@objc open func createNickName() -> UILabel` | 创建昵称标签 | UILabel | 无参数 |
| `refresh(profile:)` | `@objc open func refresh(profile: ChatUserProfileProtocol)` | 刷新用户信息显示 | Void | profile: 用户信息对象 |

#### 19. ReportOptionCell (举报选项Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(select:title:)` | `@objc open func refresh(select: Bool, title: String)` | 刷新举报选项显示 | Void | select: 是否选中<br>title: 选项标题 |
| `switchTheme(style:)` | `open func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新选中/未选中图标颜色 |

#### 20. SearchHistoryMessageCell (搜索历史消息Cell)

| 方法名 | 方法签名 | 说明 | 返回类型 | 参数说明 |
|--------|---------|------|---------|---------|
| `refresh(message:info:keyword:)` | `func refresh(message: ChatMessage, info: ChatUserProfileProtocol, keyword: String)` | 刷新搜索结果显示 | Void | message: 消息对象<br>info: 用户信息<br>keyword: 搜索关键词 |
| `highlightKeywords(keyword:in:)` | `func highlightKeywords(keyword: String, in string: String) -> NSAttributedString` | 高亮关键词 | NSAttributedString | 搜索结果关键词高亮 |
| `switchTheme(style:)` | `public func switchTheme(style: ThemeStyle)` | 切换主题 | Void | 更新会话名称颜色 |

## 重载方法使用示例

```swift
// 示例1: 自定义文本消息Cell的内容视图
class MyTextMessageCell: TextMessageCell {
    override func createContent() -> LinkRecognizeTextView {
        let textView = super.createContent()
        textView.font = UIFont.systemFont(ofSize: 16)
        return textView
    }
}

// 示例2: 自定义图片消息Cell的刷新逻辑
class MyImageMessageCell: ImageMessageCell {
    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        // 添加自定义水印
        self.content.layer.borderWidth = 2
        self.content.layer.borderColor = UIColor.red.cgColor
    }
}

// 示例3: 完全自定义消息Cell
class OrderMessageCell: CustomMessageCell {
    override func createContent() -> UIView {
        // 创建订单卡片视图
        let orderView = OrderCardView(frame: .zero)
        return orderView
    }
    
    override func refresh(entity: MessageEntity) {
        super.refresh(entity: entity)
        // 解析订单数据并显示
        if let orderData = parseOrderData(entity.message) {
            (self.content as? OrderCardView)?.showOrder(orderData)
        }
    }
}
```

**重要说明：**
1. 所有带 `@objc` 标记的方法都可以被 Objective-C 调用
2. 带 `open` 关键字的方法可以在子类中重载
3. `createXXX()` 系列方法用于创建自定义UI组件
4. `refresh()` 方法用于更新Cell显示内容
5. `switchTheme()` 方法用于适配主题切换

## 替换核心组件

1.如果你需要深度定制消息列表的逻辑（例如 ViewModel 或 Controller），可以替换注册表中的类。

```swift
// 替换消息列表 ViewModel
ComponentsRegister.shared.MessagesViewModel = MyMessageListViewModel.self

// 替换消息列表 Controller
ComponentsRegister.shared.MessageViewController = MyMessageListController.self
```
2. 如果你想替换`MessageListView`,请同上继承注册`MessageListController`后重载``createMessageContainer()`方法，返回自定义的`MessageListView`实例,注意要参看`MessageListView`中实现`IMessageListViewDriver`协议中的方法，以及相关键盘交互以及UI交互以及UI事件分发等。




## 业务逻辑重载

### MessageListController

| 方法名 | 作用 | 参数说明 |
|--------|------|---------|
| `createNavigation()` | 创建并返回导航栏 | 返回 ChatNavigationBar 实例 |
| `rightImages()` | 定义导航栏右侧图标 | 返回图标数组（话题、置顶消息） |
| `createMessageContainer()` | 创建消息列表容器视图 | 返回 MessageListView 实例 |
| `createLoading()` | 创建加载视图 | 返回 LoadingView 实例 |
| `processFollowInputAttachmentAction()` | 处理输入框附件按钮跟随样式的行为 | 配置附件菜单项的点击事件 |
| `setupNavigation()` | 设置导航栏的标题、头像等信息 | 根据用户资料配置导航栏 |
| `showPinnedMessages()` | 显示置顶消息列表 | 加载并展示置顶消息容器 |
| `navigationClick(type:indexPath:)` | 处理导航栏点击事件 | type: 事件类型, indexPath: 索引路径 |
| `viewDetail()` | 查看聊天详情（联系人/群组信息） | 根据聊天类型跳转到详情页 |
| `rightItemsAction(indexPath:)` | 处理导航栏右侧按钮点击 | indexPath: 按钮索引 |
| `viewTopicList()` | 查看话题列表 | 跳转到话题列表页面 |
| `pop()` | 返回上一页 | 执行页面返回操作 |
| `otherPartyTypingText()` | 对方正在输入提示 | 显示输入状态提示 |
| `performTypingTask()` | 执行输入状态任务 | 清除输入状态提示 |
| `forwardMessages(messages:)` | 转发多条消息（合并转发） | messages: 要转发的消息数组 |
| `forwardMessage(message:)` | 转发单条消息 | message: 要转发的消息 |
| `deleteMessages(messages:)` | 删除多条消息 | messages: 要删除的消息数组 |
| `filterSelectedMessages()` | 过滤已选中的消息 | 返回选中的消息数组 |
| `enterTopic(threadId:message:)` | 进入话题详情 | threadId: 话题ID, message: 消息对象 |
| `messageWillSendFillExtensionInfo()` | 消息发送前填充扩展信息 | 返回扩展信息字典 |
| `filterMessageActions(message:)` | 过滤消息长按菜单项 | message: 消息实体，返回可用的菜单项 |
| `showMessageLongPressedDialog(cell:)` | 显示消息长按对话框 | cell: 消息Cell |
| `showMessageLongPressedMenuWithArrow(cell:items:header:)` | 显示带箭头的长按菜单 | cell: 消息Cell, items: 菜单项, header: 头部视图 |
| `showMessageLongPressedMenuActionSheet(cell:items:header:)` | 显示ActionSheet样式的长按菜单 | cell: 消息Cell, items: 菜单项, header: 头部视图 |
| `feedback(with:)` | 触觉反馈 | style: 反馈样式 |
| `showAllReactionsController(message:)` | 显示所有表情回应选择器 | message: 消息实体 |
| `showReactionDetailsController(message:)` | 显示表情回应详情 | message: 消息实体 |
| `processMessage(item:message:)` | 处理消息操作 | item: 操作项, message: 消息对象 |
| `multiSelect(message:)` | 进入多选模式 | message: 初始选中的消息 |
| `toCreateThread(message:)` | 创建话题 | message: 关联的消息 |
| `editAction(message:)` | 编辑消息 | message: 要编辑的消息 |
| `reportAction(message:)` | 举报消息 | message: 要举报的消息 |
| `messageAttachmentLoading(loading:)` | 消息附件加载状态 | loading: 是否正在加载 |
| `messageBubbleClicked(message:)` | 消息气泡点击事件 | message: 消息实体 |
| `viewHistoryMessages(entity:)` | 查看历史消息 | entity: 合并消息实体 |
| `viewAlertDetail(message:)` | 查看提醒消息详情 | message: 提醒消息 |
| `viewContact(body:)` | 查看联系人名片 | body: 自定义消息体 |
| `messageAvatarClick(user:)` | 消息头像点击 | user: 用户资料 |
| `audioDialog()` | 显示录音对话框 | 弹出录音视图 |
| `mentionAction()` | @提及功能 | 选择要@的成员 |
| `attachmentDialog()` | 显示附件菜单 | 弹出附件选择菜单 |
| `handleAttachmentAction(item:)` | 处理附件操作 | item: 附件操作项 |
| `selectPhotoWithPHPicker()` | 使用PHPicker选择照片 | 打开系统相册 |
| `selectPhoto()` | 选择照片（旧API） | 使用UIImagePickerController |
| `openCamera()` | 打开相机 | 拍照或录像 |
| `selectFile()` | 选择文件 | 打开文件选择器 |
| `selectContact()` | 选择联系人 | 分享联系人名片 |
| `openFile()` | 打开文件预览 | 使用QuickLook预览 |
| `processImagePickerData(info:)` | 处理图片选择器数据 | info: 选择的媒体信息 |
| `documentPickerOpenFile(controller:urls:)` | 处理文档选择器结果 | controller: 选择器, urls: 文件URLs |

### MessageListView

| 方法名 | 作用 | 参数说明 |
|--------|------|---------|
| `refreshPreviewResult(entity:)` | 刷新URL预览结果 | entity: 消息实体 |
| `scrollToBottom()` | 滚动到底部 | 平滑滚动到消息列表底部 |

**说明：** MessageListView 作为视图类，主要提供的是协议方法的实现，可复写的 open 方法较少。大部分逻辑通过实现 `IMessageListViewDriver` 协议来提供，这些协议方法在内部调用，通常不需要直接复写。

### MessageListViewModel

| 方法名 | 作用 | 参数说明 |
|--------|------|---------|
| `bindDriver(driver:searchMessageId:)` | 绑定视图驱动器 | driver: 视图驱动, searchMessageId: 搜索消息ID |
| `bindPinContainerDriver(driver:)` | 绑定置顶消息容器驱动器 | driver: 置顶容器驱动 |
| `loadSearchMessage()` | 加载搜索消息 | 根据消息ID加载上下文消息 |
| `loadMessages()` | 加载历史消息 | 下拉加载更多消息 |
| `sendMessage(text:type:extensionInfo:)` | 发送消息 | text: 消息内容/路径, type: 消息类型, extensionInfo: 扩展信息 |
| `constructMessage(text:type:extensionInfo:)` | 构造消息对象 | text: 消息内容, type: 消息类型, extensionInfo: 扩展信息 |
| `updateMentionIds(profile:type:)` | 更新@提及列表 | profile: 用户资料, type: 添加/删除 |
| `processMessage(operation:message:edit:)` | 处理消息操作 | operation: 操作类型, message: 消息, edit: 编辑文本 |
| `fetchPinnedMessages()` | 获取置顶消息 | 从服务器获取置顶消息列表 |
| `showPinnedMessages()` | 显示置顶消息 | 返回置顶消息实体数组 |
| `pin(message:)` | 置顶消息 | message: 要置顶的消息 |
| `pinAlert(info:operation:)` | 置顶提醒消息 | info: 置顶信息, operation: 置顶/取消置顶 |
| `translateMessage(message:)` | 翻译消息 | message: 要翻译的消息 |
| `showOriginalText(message:)` | 显示原文 | message: 消息对象 |
| `editMessage(message:content:)` | 编辑消息 | message: 消息, content: 新内容 |
| `copyMessage(message:)` | 复制消息 | message: 要复制的消息 |
| `replyMessage(message:)` | 回复消息 | message: 要回复的消息 |
| `recallMessage(message:)` | 撤回消息 | message: 要撤回的消息 |
| `recallAction(message:)` | 撤回动作处理 | message: 被撤回的消息 |
| `deleteMessage(message:)` | 删除消息 | message: 要删除的消息 |
| `deleteMessages(messages:)` | 删除多条消息 | messages: 要删除的消息数组 |
| `notifyUnreadCountChanged()` | 通知未读数变化 | 发送未读数变化通知 |
| `messageTopicClicked(entity:)` | 消息话题点击 | entity: 消息实体 |
| `messageReactionClicked(reaction:entity:)` | 消息表情回应点击 | reaction: 回应表情, entity: 消息实体 |
| `operationReaction(emoji:message:)` | 操作表情回应 | emoji: 表情, message: 消息 |
| `messageVisibleMark(entity:)` | 消息可见标记 | entity: 可见的消息实体 |
| `retrySendMessage(entity:)` | 重试发送消息 | entity: 发送失败的消息 |
| `onMessageBubbleClicked(message:)` | 消息气泡点击处理 | message: 消息实体 |
| `audioMessagePlay(message:)` | 音频消息播放 | message: 音频消息实体 |
| `downloadMessageAttachment(message:)` | 下载消息附件 | message: 消息实体 |
| `cacheImage(message:)` | 缓存图片 | message: 图片消息 |
| `cacheFrame(attachMessage:)` | 缓存视频帧 | attachMessage: 视频消息 |
| `messageAvatarLongPressed(profile:)` | 消息头像长按 | profile: 用户资料 |
| `processInputEvents(action:attributeText:)` | 处理输入事件 | action: 输入动作, attributeText: 富文本 |
| `notifyTypingState()` | 通知输入状态 | 发送正在输入的通知 |
| `willSendMessage(attributeText:)` | 即将发送消息 | attributeText: 输入的富文本 |
| `messageDidReceived(message:)` | 收到消息 | message: 接收到的消息 |
| `messageDidRecalled(recallInfo:)` | 消息被撤回 | recallInfo: 撤回信息 |
| `messageDidEdited(message:)` | 消息被编辑 | message: 编辑后的消息 |
| `messageStatusChanged(message:status:error:)` | 消息状态变化 | message: 消息, status: 状态, error: 错误 |
| `messageAttachmentStatusChanged(message:error:)` | 附件状态变化 | message: 消息, error: 错误 |
| `messageReactionChanged(changes:)` | 表情回应变化 | changes: 变化数组 |

---

**覆盖方式说明：**

所有这些方法都声明为 `open`，可以在子类中通过以下方式覆盖：

```swift
override open func methodName(parameters) -> ReturnType {
    // 自定义实现
    super.methodName(parameters) // 可选：调用父类实现
}
```

## 资源替换

- 在 Bundle.main 中添加相应资源（图片、国际化字符串）即可覆盖默认资源。


### 1. Chat/Cells 图片和国际化资源表

| 类别 | 资源类型 | 覆盖方式 |
|------|---------|---------|
| video_message_play | 图片资源 | 在 Bundle.main 中添加同名图片 `video_message_play` |
| thread_more | 图片资源 | 在 Bundle.main 中添加同名图片 `thread_more` |
| reaction_trash | 图片资源 | 在 Bundle.main 中添加同名图片 `reaction_trash` |
| uncheck | 图片资源 | 在 Bundle.main 中添加同名图片 `uncheck` |
| check | 图片资源 | 在 Bundle.main 中添加同名图片 `check` |
| text_message_edited | 图片资源 | 在 Bundle.main 中添加同名图片 `text_message_edited` |
| text_message_translated | 图片资源 | 在 Bundle.main 中添加同名图片 `text_message_translated` |
| select | 图片资源 | 在 Bundle.main 中添加同名图片 `select` |
| unselect | 图片资源 | 在 Bundle.main 中添加同名图片 `unselect` |
| No Messages | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `No Messages` |
| Send | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Send` |
| Sent | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Sent` |
| Remove | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Remove` |
| Confirm Remove | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Confirm Remove` |
| Edited | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Edited` |
| Translated | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Translated` |

### 2. Chat/Views 图片和国际化资源表

| 类别 | 资源类型 | 覆盖方式 |
|------|---------|---------|
| audio_message_icon_show_left | 图片资源 | 在 Bundle.main 中添加同名图片 `audio_message_icon_show_left` |
| audio_message_icon_show_right | 图片资源 | 在 Bundle.main 中添加同名图片 `audio_message_icon_show_right` |
| reaction_all | 图片资源 | 在 Bundle.main 中添加同名图片 `reaction_all` |
| file_message_icon | 图片资源 | 在 Bundle.main 中添加同名图片 `file_message_icon` |
| mic_on | 图片资源 | 在 Bundle.main 中添加同名图片 `mic_on` |
| trash | 图片资源 | 在 Bundle.main 中添加同名图片 `trash` |
| send_audio | 图片资源 | 在 Bundle.main 中添加同名图片 `send_audio` |
| edit_bar_status | 图片资源 | 在 Bundle.main 中添加同名图片 `edit_bar_status` |
| audio | 图片资源 | 在 Bundle.main 中添加同名图片 `audio` |
| attachment | 图片资源 | 在 Bundle.main 中添加同名图片 `attachment` |
| attachmentSelected | 图片资源 | 在 Bundle.main 中添加同名图片 `attachmentSelected` |
| emojiKeyboard | 图片资源 | 在 Bundle.main 中添加同名图片 `emojiKeyboard` |
| textKeyboard | 图片资源 | 在 Bundle.main 中添加同名图片 `textKeyboard` |
| message_select_bottom_forward | 图片资源 | 在 Bundle.main 中添加同名图片 `message_select_bottom_forward` |
| more_messages | 图片资源 | 在 Bundle.main 中添加同名图片 `more_messages` |
| pinned_messages | 图片资源 | 在 Bundle.main 中添加同名图片 `pinned_messages` |
| Chat History | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Chat History` |
| input_extension_menu_contact | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `input_extension_menu_contact` |
| remaining | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `remaining` |
| Record | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Record` |
| Recording | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Recording` |
| Play | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Play` |
| Playing | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Playing` |
| Editing | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Editing` |
| new messages | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `new messages` |
| Pin Messages | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Pin Messages` |
| Sticky Message | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Sticky Message` |

### 3. MessageListController 图片和国际化资源表

| 类别 | 资源类型 | 覆盖方式 |
|------|---------|---------|
| message_action_topic | 图片资源 | 在 Bundle.main 中添加同名图片 `message_action_topic` |
| pinned_messages | 图片资源 | 在 Bundle.main 中添加同名图片 `pinned_messages` |
| No pinned messages | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `No pinned messages` |
| Typing... | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Typing...` |
| Please select greater than one message. | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Please select greater than one message.` |
| barrage_long_press_menu_delete | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `barrage_long_press_menu_delete` |
| messages | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `messages` |
| permissions disable | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `permissions disable` |
| photo_disable | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `photo_disable` |
| camera_disable | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `camera_disable` |
| Share Contact | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `Share Contact` |
| to | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `to` |
| file_disable | 国际化资源 | 在 Bundle.main 的 Localizable.strings 中添加 key 为 `file_disable` |

**覆盖说明：**
- **图片资源**：所有图片通过 `UIImage(chatNamed:)` 方法加载，在 Bundle.main 中放置同名图片文件即可覆盖
- **国际化资源**：所有字符串通过 `.chat.localize` 扩展方法加载，在 Bundle.main 的对应语言目录下的 Localizable.strings 文件中添加相同 key 的翻译即可覆盖
- **亮色暗色模式图片会自动根据对应指定的颜色渲染**:如果需要改变颜色请先改变对应Appearance中hue值，详请参看`Appearance.neutralHue`&`Appearance.neutralSpecialHue`,其他对应图片需要查看对应组件的ThemeSwitchProtocol扩展里实现
  - 例如：`audio_message_icon_show_left` 和 `audio_message_icon_show_right` 会根据当前系统的亮色或暗色模式自动渲染为黑色或白色图标，无需分别提供两套图片资源,`AudioMessageView`为例，示例如下:
  ```Swift
              extension AudioMessageView: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        if self.towards == .left {
            self.audioIcon.image = UIImage(chatNamed: "audio_message_icon_show_left")?.withTintColor(style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralSpecialColor5)
            self.audioIcon.animationImages = Appearance.chat.receiveAudioAnimationImages
        } else {
            self.audioIcon.image = UIImage(chatNamed: "audio_message_icon_show_right")?.withTintColor(style == .dark ? UIColor.theme.neutralSpecialColor6:UIColor.theme.neutralColor98)
            self.audioIcon.animationImages = Appearance.chat.sendAudioAnimationImages
        }
    }
}

  ```
- **不需要亮暗色模式，则默认可以设置亮色模式即可**: 只改动亮色模式相关hue即可
