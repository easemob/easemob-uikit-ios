# 会话列表页面介绍

`ConversationListController` 用于展示当前用户的所有会话，包含单聊和群组聊天（不包括聊天室），并且提供会话搜索、删除、置顶和免打扰功能。

## 页面组件

会话列表页面通过 `ConversationListController` 实现，由标题栏、搜索栏和会话列表组成。

### 标题栏

会话列表页面与聊天页面、联系人列表页面、群详情页面、联系人详情页面的标题栏均使用 `ChatNavigationBar`。详见 [设置标题栏](chatuikit_titlebar.html)。

### 会话搜索栏

会话搜索栏通过 `UIButton` 实现简单的点击触发，点击后跳转到 `SearchConversationsController` 进行搜索。关于自定义，详见 `ConversationListController#createSearchBar`方法。

### 会话列表

建议你在首次下载、卸载后重装应用等本地数据库无数据情况下拉取服务端会话列表。

会话列表组件 `ConversationList` 实现按会话中最新一条消息的时间的倒序显示所有会话，包括：
- 通过标题栏右侧的加号创建的本地会话。
- 两个用户之间发送消息后创建的单聊会话。
- 群组中发送消息后创建的群组会话。

在会话列表中，置顶的会话排在列表最上方。

会话条目组件 `ConversationCell` 实现单条会话展示，包括会话名称、最新一条消息、最新一条消息的时间以及置顶和免打扰状态等。

- **会话名称和头像**：对于单聊, 会话名称为对端用户的昵称，若对端用户未设置昵称则展示对方用户 ID；会话头像是对方头像，若未设置则使用默认头像。对于群聊，会话名称为当前群组的名称或者群组 ID，头像为默认头像。
- **点击会话**：点击单个会话条目，跳转到会话详情页面。
- **长按会话**：左右滑单个会话条目显示会话操作弹窗，默认实现会话免打扰、会话置顶、会话标记已读和会话删除操作。

## 创建会话列表页面

单群聊 UIKit 提供 `ConversationListController`，作为根控制器或 push到导航栈中 或present 使用。

示例如下：

```swift
import UIKit
import EaseChatUIKit

        let vc = EaseChatUIKit.ComponentsRegister.shared.ConversationsController.init()
        ControllerStack.toDestination(vc: vc)
```
