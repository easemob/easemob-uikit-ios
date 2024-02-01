# 主要页面回调事件监听

IMSDK回调事件的监听以及UI触发事件的监听均在各自的ViewModel中

## 1.会话列表

你可以继承`ConversationViewModel`并赋值注册到`ComponentsRegister.shared.ConversationViewService`中，然后即可重载如下想要拦截的监听方法。

| 方法名 | 用途 | 是否可重载 |
| -------- | -------- | -------- |
| `loadExistLocal是IfEmptyFetchServer`    | 拉取会话列表出现错误时回调方法，此方法会重新获取会话列表     | 是     |
| `pin`    | 会话列表左滑后点击置顶按钮后触发回调  | 是     |
| `unpin`    | 会话列表左滑后点击取消置顶按钮后触发回调     | 是     |
| `mute`    | 会话列表左滑后点击禁言按钮后触发回调     | 是     |
| `unmute`    | 会话列表左滑后点击取消禁言按钮后触发回调     | 是     |
| `delete`    | 会话列表左滑后点击删除按钮后触发回调     | 是     |
| `read`    | 会话列表左滑后点击已读按钮后触发回调     | 是     |
| `conversationDidSelected`    | 会话列表点击后回调     | 是     |
| `conversationLongPressed`    | 会话列表长按后回调     | 是     |
| `moreAction`   | 会话列表右滑后点击`...`回调     | 是     |
| `conversationLastMessageUpdate`   | 会话列表中会话最后一条消息更新时回调     | 是     |
| `playNewMessageSound`   | 收到新消息时播放音频方法     | 是     |
| `conversationMessageAlreadyReadOnOtherDevice`   | 会话中消息在其它设备上已读     | 是     |
| `conversationEventDidChanged`   | 对会话的多设备操作时间发生变更回调     | 是     |
| `mapper`  | 映射`ConversationInfo`对象方法     | 是     |


## 2.消息列表

你可以继承`MessageListViewModel`并赋值注册到`ComponentsRegister.shared.MessagesViewModel`中，然后即可重载如下想要拦截的监听方法。

| 方法名 | 用途 | 是否可重载 |
| -------- | -------- | -------- |
| `messageDidReceived`    | 收到新消息回调     | 是     |
| `messageDidRecalled`    | 收到消息撤回回调     | 是     |
| `onMessageDidEdited`    | 收到消息被编辑回调     | 是     |
| `messageStatusChanged`    | 收到消息状态发生变更回调     | 是     |
| `messageAttachmentStatusChanged`    | 收到消息附件状态变更回调     | 是     |

UI事件的回调见自定拦截主要页面点击事件


## 3.联系人列表

你可以继承`ContactViewModel`并赋值注册到`ComponentsRegister.shared.ContactViewService`中，然后即可重载如下想要拦截的监听方法。

| 方法名 | 用途 | 是否可重载 |
| -------- | -------- | -------- |
| `processFriendDidAgree`    | 收到添加联系人对方同意回调     | 是     |
| `processFriendRequestDidDecline`   | 收到添加联系人对方拒绝回调     | 是     |
| `processFriendshipDidRemove`    | 收到好友关系被移除回调     | 是     |
| `processFriendshipDidAddSuccessful`    | 收到好友关系添加成功回调     | 是     |
| `processFriendRequestDidReceive`    | 收到添加好友申请回调     | 是     |
| `contactEventDidChanged`    | 联系人多设备事件变更回调     | 是     |
