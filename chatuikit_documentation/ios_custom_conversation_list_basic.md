# 会话列表的基本设置

本文介绍如何对 `ConversationListController` 进行基本设置，包括 UI 样式、侧滑操作及事件监听。

## 概述

会话列表的定制主要通过以下方式实现：
- **Appearance.conversation**: 配置行高、占位图、侧滑动作等。
- **ComponentsRegister**: 继承注册后重载业务逻辑等。

## 基础 UI 配置

通过 `Appearance.conversation` 可以快速调整会话列表的外观：

| 属性 | 描述 |
| :--- | :--- |
| `rowHeight` | 会话条目的行高，默认为 76。 |
| `singlePlaceHolder` | 单聊会话的默认头像占位图。 |
| `groupPlaceHolder` | 群聊会话的默认头像占位图。 |
| `dateFormatToday` | 当天消息的时间显示格式，如 "HH:mm"。 |
| `dateFormatOtherDay` | 非当天消息的时间显示格式，如 "MM/dd"。 |

示例：
```swift
// 修改行高
Appearance.conversation.rowHeight = 80

// 修改时间格式
Appearance.conversation.dateFormatToday = "HH:mm:ss"
```

## 设置侧滑操作

会话列表默认支持侧滑操作。你可以通过以下属性配置侧滑菜单中显示的按钮：

```swift
// 默认配置左滑显示的按钮
Appearance.conversation.swipeLeftActions = [.mute, .pin, .delete]

// 默认配置右滑显示的按钮
Appearance.conversation.swipeRightActions = [.more, .read]
```

## 设置事件监听



### 监听UI事件 ConversationListActionEventsDelegate

```Swift
     //调用下面方法       
    func addActionHandler(actionHandler: ConversationListActionEventsDelegate) {} 
        
```

```Swift
        
        let vc = EaseChatUIKit.ComponentsRegister.shared.ConversationsController.init()
                
        vc.conversationList.addActionHandler(actionHandler: self)
```

### 监听ViewModel业务处理逻辑以及最后一条消息与未读数更新等
```Swift
@objc public protocol ConversationEmergencyListener: NSObjectProtocol {
    
    /// You'll receive the result on conversation service request successful or failure.
    /// - Parameters:
    ///   - error: .Success ``ChatError`` is nil.
    ///   - type: ``ConversationEmergencyType``
    func onResult(error: ChatError?,type: ConversationEmergencyType)
    
    /// The last message of conversation changes.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - info: ``ConversationInfo``
    func onConversationLastMessageUpdate(message: ChatMessage,info: ConversationInfo)
    
    /// You'll receive the result on some conversation last message update.
    /// - Parameter unreadCount: Total unread count.
    func onConversationsUnreadCountUpdate(unreadCount: UInt)
}
```

```Swift
    
        let vc = EaseChatUIKit.ComponentsRegister.shared.ConversationsController.init()
        vc.viewModel?.registerEventsListener(listener: self)
```

## 默认会话操作

UIKit 默认实现了以下会话管理功能：
- **置顶/取消置顶**：改变会话在列表中的排序。
- **免打扰**：设置后不再接收该会话的推送通知。
- **标记已读**：一键清除未读数。
- **删除会话**：从本地及服务端（可选）删除会话记录。

## 空页面设置

当没有会话时，`ConversationList` 会显示一个空状态页面。你可以通过覆盖相关资源或自定义 View 来改变它。

```swift
// 会话列表内部使用 EmptyStateView 展示空状态。
```
