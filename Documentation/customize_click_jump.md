# 拦截主要页面点击跳转事件

## 1.会话列表页面

你可以继承`ConversationListController`并赋值注册到`ComponentsRegister.shared.ConversationsController`中，然后即可重载如下想要拦截的点击事件方法。

| 方法名    |   用途    | 是否可重载 |
| -------- | -------- | -------- |
| `createNavigationBar`    | 导航栏创建方法 | 是     |
| `createSearchBar`        | 搜索框创建方法 | 是     |
| `createList`             | 会话列表创建方法 | 是     |
| `navigationClick`        | 导航点击方法     | 是     |
| `pop`                    | 页面返回方法     | 是     |
| `toChat`                 | 跳转聊天方法     | 是     |
| `searchAction`           | 搜索框点击方法     | 是     |
| `rightActions`           | 导航右侧按钮点击方法     | 是     |
| `selectContact`          | 跳转选择联系人页面方法     | 是     |
| `chatToContact`          | 跳转聊天页面指定联系人聊天方法     | 是     |
| `createChat`             | 根据类型创建对应类型会话开始聊天方法     | 是     |
| `addContact`             | 唤起添加联系人弹窗方法     | 是     |
| `createGroup`            | 创建群组跳转选择群成员页面方法     | 是     |
| `create`                 | 创建群组方法     | 是     |

## 2.聊天页面

你可以继承`MessageListController`并赋值注册到`ComponentsRegister.shared.MessageViewController`中，然后即可重载如下想要拦截的点击事件方法。

| 方法名    |   用途    | 是否可重载 |
| -------- | -------- | -------- |
| `createNavigation`    | 创建导航栏方法     | 是     |
| `createLoading`    | 创建Loading页面方法     | 是     |
| `navigationClick`    | 导航栏所有点击方法     | 是     |
| `viewDetail`   | 查看联系人或群组详情页面     | 是     |
| `rightItemsAction`    | 导航右侧按钮点击方法     | 是     |
| `pop`   | 是     | 页面返回上一级方法     |
| `messageWillSendFillExtensionInfo`    | 消息即将发送前可添加扩展信息方法     | 是     |
| `filterMessageActions`    | 过滤长按后弹出菜单上菜单项的方法     | 是     |
| `showMessageLongPressedDialog`   | 显示消息长按后的菜单     | 是     |
| `processMessage`  | 处理消息长按后弹窗点击事件     | 是     |
| `editAction`    | 点击消息长按后菜单中的编辑后弹出编辑弹窗方法     | 是     |
| `reportAction`    | 点击消息长按后菜单中的举报按钮弹出举报弹窗的方法     | 是     |
| `messageAttachmentLoading`    | 图片视频以及附件消息点击后是否需要显示loading页面方法     | 是     |
| `messageBubbleClicked`    | 消息气泡点击方法     | 是     |
| `viewContact`   | 查看联系人页面    | 是     |
| `messageAvatarClick`   | 消息头像点击     | 是     |
| `audioDialog`  | 显示录制音频弹窗     |      |
| `mentionAction`    | 群聊中输入框中输入@符号触发事件     | 是     |
| `attachmentDialog`    | 显示发送图片视频以及文件消息的弹窗    | 是     |
| `selectFile`    | 选择文件     | 是     |
| `selectPhoto`    | 打开相册选择照片     | 是     |
| `openCamera`    | 打开相机拍摄视频照片     | 是     |
| `selectContact`   | 选择联系人发送卡片     | 是     |
| `openFile`   | 打开选择文件     | 是     |
| `processImagePicker是`   | 处理点击选择图片以及视频发送消息方法     | 是     |
| `documentPickerOpenFile`   | 打开文件选择器的方法     | 是     |

## 3.联系人页面

你可以继承`ContactViewController`并赋值注册到`ComponentsRegister.shared.ContactsController`中，然后即可重载如下想要拦截的点击事件方法。

| 方法名    |   用途    | 是否可重载 |
| -------- | -------- | -------- |
| `createNavigation`    | 创建导航栏方法     | 是     |
| `navigationClick`    | 导航栏所有点击方法     | 是     |
| `viewContact`   | 查看联系人详情页面     | 是     |
| `rightItemsAction`    | 导航右侧按钮点击方法     | 是     |
| `pop`   | 页面返回上一级方法     |   是   |
| `setupTitle`    | 设置不同类型联系人页面导航标题     | 是     |
| `receiveContactHeaderAction`    | 是     | 是     |
| `searchAction`    | 点击搜索框     | 是     |
| `addContact`    | 添加联系人弹窗     | 是     |
| `confirmAction`    | 导航右侧文本按钮点击事件     | 是     |
| `viewNewFriendRequest`   | 查看新好友请求页面     | 是     |
| `viewJoinedGroups`   | 查看加入的群组列表页面     | 是     |
