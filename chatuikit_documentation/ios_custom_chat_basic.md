# 消息列表的基本设置

消息列表是聊天界面的核心组件，基于 `MessageListController` 和 `MessageListView` 实现。本文介绍如何对消息列表和消息条目进行基本设置。

## 概述

在 iOS UIKit 中，基本设置主要通过 `Appearance.chat` 全局配置对象完成，或者通过继承 `MessageListController` 并重写相关方法来实现交互监听。

## 创建消息页

使用 `MessageListController` 的初始化方法即可创建一个标准的消息页面。

```swift
// conversationId: 单聊为对端用户 ID，群聊为群组 ID。
// chatType: .chat (单聊) 或 .group (群聊)
let chatVC = MessageListController(conversationId: "user_id", chatType: .chat)
self.navigationController?.pushViewController(chatVC, animated: true)
```

## 基础 UI 配置

通过 `Appearance.chat` 可以快速调整消息页面的 UI 行为：

| 属性 | 描述 |
| :--- | :--- |
| `bubbleStyle` | 气泡样式：`.withArrow` (带箭头) 或 `.withMultiCorner` (圆角样式)。 |
| `contentStyle` | 内容显示元素：可包含 `.withAvatar`, `.withNickName`, `.withDateAndTime`, `.withReply` 等。 |
| `inputPlaceHolder` | 输入框占位文字。 |
| `messageLongPressMenuStyle` | 长按菜单风格：`.withArrow` (气泡菜单) 或 `.actionSheet` (底部弹窗)。 |
| `messageAttachmentMenuStyle` | 附件菜单风格：`.followInput` (输入框上方) 或 `.actionSheet` (底部弹窗)。 |

示例：
```swift
// 隐藏昵称，只显示头像
Appearance.chat.contentStyle = [.withAvatar, .withDateAndTime]

// 使用系统样式的底部长按菜单
Appearance.chat.messageLongPressMenuStyle = .actionSheet
```

## 设置交互监听

### 方式一：使用 ComponentViewsActionHooker (推荐)

`ComponentViewsActionHooker` 提供了一种无需继承即可拦截点击事件的方式。

```swift
// 监听头像点击
ComponentViewsActionHooker.shared.chat.avatarClicked = { profile in
    print("点击了用户：\(profile.nickname)")
}

// 监听消息气泡点击
ComponentViewsActionHooker.shared.chat.bubbleClicked = { messageEntity in
    print("点击了消息：\(messageEntity.message.messageId)")
}
```

### 方式二：实现 MessageListViewActionEventsDelegate

如果你的类实现了 `MessageListViewActionEventsDelegate`，可以将其添加到 `MessageListView` 的事件处理器中。

```swift
class MyViewController: UIViewController, MessageListViewActionEventsDelegate {
    func onMessageAvatarClicked(profile: ChatUserProfileProtocol) {
        // 处理点击
    }
    
    // ... 实现其他代理方法
}

// 在控制器中添加监听
chatVC.messageContainer.addActionHandler(actionHandler: self)
```

## 消息发送回调

你可以通过 `MessageListController` 监听消息发送的状态或进行发送前的预处理。

```swift
// 建议继承 MessageListController 并重写相关 ViewModel 的行为，或监听消息状态变更通知。
```

## 可重写方法

`MessageListController` 及其组件类中的许多方法都标记为 `open`，你可以通过子类化来深度定制逻辑。
