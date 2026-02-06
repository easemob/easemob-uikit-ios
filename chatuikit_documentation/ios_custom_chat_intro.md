# 聊天页面介绍

环信单群聊 UIKit 提供 `MessageListController` 方便用户快速集成聊天页面和自定义聊天页面。该页面提供如下功能：

- 发送和接收消息, 包括文本、表情、图片、语音、视频、文件和名片消息。
- 对消息进行复制、引用、撤回、删除、编辑、重新发送和审核。
- 清除本地消息。

## 页面组件

聊天页面通过 `MessageListController` 实现，由标题栏、消息列表和底部输入框组成。

### 标题栏

聊天页面与会话列表页面、通讯录页面、群详情页面和联系人详情页面的标题栏均使用 `ChatNavigationBar`。详见 [设置标题栏](chatuikit_custom_titlebar.html)。

### 消息列表

消息列表 `MessageListView` 用于展示发送和接收的消息，以及对消息进行操作：

- **发送和接收消息**：包括文本、表情、图片、语音、视频、文件和名片等消息。
- **消息操作**：对消息进行复制、引用、撤回、删除、编辑、重新发送、举报、翻译、转发、多选、置顶操作。

消息条目 `MessageCell` 实现单条消息展示，包括展示消息内容的消息气泡、对端用户头像或群头像、消息时间等。

### 底部输入框

消息底部输入框 `MessageInputBar` 实现各类消息的输入和发送以及表情等功能，包括两部分：

- 底部输入菜单：输入和发送文本和语音消息、添加表情以及扩展功能等。
- 消息扩展菜单 `MessageInputExtensionView`：发送附件类型消息，例如，图片、视频、文件以及自定义类型消息（如名片消息）等。

## 创建聊天页面

- 使用 `MessageListController`

单群聊 UIKit 提供 `MessageListController` 页面，实例化并 push 到导航控制器即可，示例代码如下：

```swift
// conversationId: 单聊会话为对端用户 ID，群聊会话为群组 ID。
// chatType：单聊为 .chat，群聊为 .group。
let chatController = MessageListController(conversationId: "conversationId", chatType: .chat)
self.navigationController?.pushViewController(chatController, animated: true)
```
