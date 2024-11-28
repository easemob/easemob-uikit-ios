# 新类型自定义消息Cell

这里以红包消息举例

## 1.根据需求继承`EaseChatUIKit`中的Cell

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


[图示](./red_package_message.jpg)

## 2.根据需求继承`EaseChatUIKit`中的Cell的渲染模型`MessageEntity`，并给定气泡大小，其中`redPackageIdentifier`为红包的自定义消息的event事件

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

## 3.添加发送附件消息的类型


[图示](./send_red_package.jpg)

示例，增加发送红包消息

```Swift
        
        let redPackage = ActionSheetItem(title: "红包".chat.localize, type: .normal,tag: "Red",image: UIImage(named: "photo", in: .chatBundle, with: nil))
        Appearance.chat.inputExtendActions.append(redPackage)
```

## 4.在继承的`MessageListController`处理新增的附件消息类型的点击

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

## 5.给`EaseChatUIKit`中的`MessageListViewModel`增加发送红包消息的方法

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

## 6.将上述继承的对象全部注册进`EaseChatUIKit`，在其初始化后

示例代码

```Swift
        
        ComponentsRegister.shared.MessageRenderEntity = MineMessageEntity.self
        ComponentsRegister.shared.Conversation = MineConversationInfo.self
        ComponentsRegister.shared.MessageViewController = CustomMessageListController.self
        ComponentsRegister.shared.registerCustomizeCellClass(cellType: RedPackageCell.self)
```

- 这里`ComponentsRegister.shared.Conversation = MineConversationInfo.self`是为了修改自定义消息在会话列表中，会话收到新消息时显示的内容这里暂定为显示 "[红包]"，示例代码如下，主要更改在非文本消息类型的else中根据自定义消息的event显示对应的内容

[图示](./red_package_placeholder.jpg)

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
