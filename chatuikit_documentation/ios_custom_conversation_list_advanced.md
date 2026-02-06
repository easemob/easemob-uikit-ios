# 会话列表的高级设置

本文介绍如何通过 `Appearance.conversation` 和 `ComponentsRegister` 实现会话列表的高级设置，包括会话条目样式、侧滑菜单、更多操作菜单等。

## 概述

会话列表的定制主要涉及以下两个方面：
- **Appearance.conversation**: 配置行高、侧滑菜单、占位图等视觉样式。
- **ComponentsRegister**: 替换会话列表 Cell、ViewModel 或 Controller。

## 设置会话条目样式

通过 `Appearance.conversation` 可以调整会话列表的基础样式。

```swift
// 设置会话列表行高
Appearance.conversation.rowHeight = 76

// 设置单聊默认头像
Appearance.conversation.singlePlaceHolder = UIImage(named: "my_single_avatar")

// 设置群聊默认头像
Appearance.conversation.groupPlaceHolder = UIImage(named: "my_group_avatar")

// 设置日期格式
Appearance.conversation.dateFormatToday = "HH:mm"
Appearance.conversation.dateFormatOtherDay = "MM/dd"
```

## 设置侧滑菜单

会话列表支持左滑和右滑操作，你可以通过 `Appearance.conversation` 自定义这些操作。

### 左滑菜单 (Swipe Left)

通常用于“置顶”、“免打扰”、“删除”等操作。

```swift
// 配置左滑菜单项
Appearance.conversation.swipeLeftActions = [.mute, .pin, .delete]
```

### 右滑菜单 (Swipe Right)

通常用于“标记已读”、“更多”等操作。

```swift
// 配置右滑菜单项
Appearance.conversation.swipeRightActions = [.more, .read]
```

## 自定义更多操作菜单

当点击会话列表导航栏右侧的“+”按钮时，会弹出一个菜单（例如发起新会话、添加联系人等）。你可以修改 `Appearance.conversation.listMoreActions` 来定制这个菜单。

```swift
// 获取当前菜单
var actions = Appearance.conversation.listMoreActions

// 添加自定义菜单项
let scanAction = ActionSheetItem(title: "扫一扫", type: .normal, tag: "Scan", image: UIImage(named: "scan_icon"))
scanAction.action = { item, _ in
    print("点击了扫一扫")
}
actions.append(scanAction)

// 更新配置
Appearance.conversation.listMoreActions = actions
```

## 注册自定义会话 Cell

如果你需要完全自定义会话条目的 UI（例如增加未读数显示样式、改变布局），可以继承 `ConversationListCell` 并进行注册。

### 1. 创建自定义 Cell

- 可重载方法见下方## 3. ConversationListCell (会话列表Cell)

```swift
class MyConversationCell: ConversationListCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // 自定义 UI 布局
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
```

### 2. 替换注册

```swift
// 告诉 EaseChatUIKit 使用你的自定义 Cell 类
ComponentsRegister.shared.ConversationCell = MyConversationCell.self
//这里如果配合改动数据的话，也需要替换ConversationInfo
ComponentsRegister.shared.ConversationInfo = MyConversationInfo.self
```

这样，`ConversationListController` 在创建列表时就会自动使用你注册的 `MyConversationCell`。

## 替换核心组件

与消息列表类似，你也可以替换会话列表的 ViewModel 或 Controller。

```swift
// 替换会话列表 ViewModel
ComponentsRegister.shared.ConversationViewService = MyConversationViewModel.self

// 替换会话列表 Controller
ComponentsRegister.shared.ConversationsController = MyConversationListController.self
```

## 全局主题色设置

会话列表也会受到全局主题色的影响。

```swift
// 修改主色调（影响所有 UI 组件）
Appearance.primaryHue = 203/360.0
Appearance.secondaryHue = 155/360.0
```


## ConversationAppearance即`Appearance.conversation` 会话列表配置说明表

| 配置项 | 类型 | 默认值 | 说明 | 影响范围 |
|--------|------|--------|------|---------|
| **列表显示配置** |
| `rowHeight` | CGFloat | 76 | 会话列表行高 | ConversationListCell 的高度 |
| **侧滑菜单配置** |
| `swipeLeftActions` | [UIContextualActionType] | [.mute, .pin, .delete] | 左滑菜单项 | 从右向左滑动会话时显示的操作按钮<br>• mute: 免打扰<br>• pin: 置顶<br>• delete: 删除 |
| `swipeRightActions` | [UIContextualActionType] | [.more, .read] | 右滑菜单项 | 从左向右滑动会话时显示的操作按钮<br>• more: 更多<br>• read: 标记已读 |
| **头像占位图配置** |
| `singlePlaceHolder` | UIImage? | single | 单聊默认头像占位图 | 单聊会话无头像时显示的默认图片 |
| `groupPlaceHolder` | UIImage? | group | 群聊默认头像占位图 | 群聊会话无头像时显示的默认图片 |
| **日期格式配置** |
| `dateFormatToday` | String | "HH:mm" | 今天消息的时间格式 | 会话列表中今天消息的显示格式 |
| `dateFormatOtherDay` | String | "MM/dd" | 其他日期消息的时间格式 | 会话列表中非今天消息的显示格式 |
| **扩展菜单配置** |
| `moreActions` | [ActionSheetItemProtocol] | [] (空数组) | 单个会话"更多"菜单项 | 左滑点击"更多"按钮后显示的自定义菜单<br>可通过 append 添加自定义操作 |
| `listMoreActions` | [ActionSheetItemProtocol] | 3个默认操作 | 列表右上角"+"按钮菜单 | 点击会话列表右上角"+"按钮显示的菜单：<br>• 选择联系人(SelectContacts)<br>• 添加联系人(AddContact)<br>• 创建群组(CreateGroup) |

## UIContextualActionType 枚举说明

### 左滑菜单选项 (swipeLeftActions)

| 值 | 图标资源 | 国际化Key | 背景色(深色/浅色) | 说明 |
|----|---------|-----------|------------------|------|
| `.mute` | mute | conversation_right_slide_menu_mute | neutralSpecialColor6 / neutralSpecialColor5 | 开启免打扰 |
| `.unmute` | unmute | conversation_left_slide_menu_unmute | neutralSpecialColor6 / neutralSpecialColor5 | 关闭免打扰 |
| `.pin` | pin | conversation_left_slide_menu_pin | primaryDarkColor / primaryLightColor | 置顶会话 |
| `.unpin` | unpin | conversation_left_slide_menu_unpin | primaryDarkColor / primaryLightColor | 取消置顶 |
| `.delete` | trash | conversation_right_slide_menu_delete | errorColor6 / errorColor5 | 删除会话 |

### 右滑菜单选项 (swipeRightActions)

| 值 | 图标资源 | 国际化Key | 背景色(深色/浅色) | 说明 |
|----|---------|-----------|------------------|------|
| `.more` | more | conversation_right_slide_menu_more | neutralColor6 / neutralColor5 | 更多操作 |
| `.read` | read | conversation_right_slide_menu_read | neutralSpecialColor6 / neutralSpecialColor5 | 标记已读 |

## 默认 listMoreActions 菜单项

| Tag | 标题国际化Key | 图标资源 | 说明 |
|-----|--------------|---------|------|
| `SelectContacts` | new_chat_button_click_menu_selectcontacts | chatWith | 选择联系人发起聊天 |
| `AddContact` | new_chat_button_click_menu_addcontacts | person_add_fill | 添加新联系人 |
| `CreateGroup` | new_chat_button_click_menu_creategroup | create_group | 创建群组 |

## 配置使用示例

```swift
// 示例1: 自定义侧滑菜单
Appearance.conversation.swipeLeftActions = [.pin, .delete]
Appearance.conversation.swipeRightActions = [.read]

// 示例2: 自定义行高
Appearance.conversation.rowHeight = 80

// 示例3: 自定义日期格式
Appearance.conversation.dateFormatToday = "HH:mm"
Appearance.conversation.dateFormatOtherDay = "yyyy/MM/dd"

// 示例4: 添加自定义"更多"菜单项
let translateAction = ActionSheetItem(
    title: "翻译", 
    type: .normal, 
    tag: "Translate",
    image: UIImage(systemName: "character.bubble")
)
translateAction.action = { [weak self] item in
    // 实现翻译功能
    print("执行翻译操作")
}
Appearance.conversation.moreActions.append(translateAction)

// 示例5: 自定义列表右上角菜单
let scanAction = ActionSheetItem(
    title: "扫一扫", 
    type: .normal, 
    tag: "Scan",
    image: UIImage(systemName: "qrcode.viewfinder")
)
Appearance.conversation.listMoreActions.append(scanAction)

// 示例6: 替换默认头像
Appearance.conversation.singlePlaceHolder = UIImage(named: "my_default_avatar")
Appearance.conversation.groupPlaceHolder = UIImage(named: "my_group_avatar")

// 示例7: 完全自定义列表菜单
Appearance.conversation.listMoreActions = [
    ActionSheetItem(
        title: "新建单聊", 
        type: .normal, 
        tag: "NewChat",
        image: UIImage(systemName: "message")
    ),
    ActionSheetItem(
        title: "新建群聊", 
        type: .normal, 
        tag: "NewGroup",
        image: UIImage(systemName: "person.3")
    ),
    ActionSheetItem(
        title: "扫一扫", 
        type: .normal, 
        tag: "Scan",
        image: UIImage(systemName: "qrcode")
    )
]
```

## 侧滑菜单动态状态说明

**重要特性：** 侧滑菜单项会根据会话状态自动切换：

```swift
// 免打扰状态切换
if info.doNotDisturb {
    // 显示 .unmute（取消免打扰）
} else {
    // 显示 .mute（开启免打扰）
}

// 置顶状态切换
if info.pinned {
    // 显示 .unpin（取消置顶）
} else {
    // 显示 .pin（置顶会话）
}

// 未读状态
if info.unreadCount > 0 {
    // 显示 .read（标记已读）
} else {
    // 不显示 .read
}
```

## 资源覆盖说明

### 可覆盖的图片资源（通过 Bundle.main）

| 资源名称 | 用途 | 默认位置 |
|---------|------|---------|
| `single` | 单聊默认头像 | singlePlaceHolder |
| `group` | 群聊默认头像 | groupPlaceHolder |
| `mute` | 免打扰图标 | 左滑菜单 |
| `unmute` | 取消免打扰图标 | 左滑菜单 |
| `pin` | 置顶图标 | 左滑菜单 |
| `unpin` | 取消置顶图标 | 左滑菜单 |
| `trash` | 删除图标 | 左滑菜单 |
| `more` | 更多图标 | 右滑菜单 |
| `read` | 已读图标 | 右滑菜单 |
| `chatWith` | 选择联系人图标 | 列表菜单 |
| `person_add_fill` | 添加联系人图标 | 列表菜单 |
| `create_group` | 创建群组图标 | 列表菜单 |
| `empty` | 空列表占位图 | 空状态视图 |
| `bell_slash` | 免打扰标识 | Cell昵称旁 |

### 可覆盖的国际化资源（通过 Bundle.main 的 Localizable.strings）

| Key | 默认值(英文) | 用途 |
|-----|------------|------|
| `conversation_right_slide_menu_more` | More | 更多按钮 |
| `conversation_right_slide_menu_read` | Read | 标记已读按钮 |
| `conversation_right_slide_menu_delete` | Delete | 删除按钮 |
| `conversation_right_slide_menu_mute` | Mute | 免打扰按钮 |
| `conversation_left_slide_menu_pin` | Pin | 置顶按钮 |
| `conversation_left_slide_menu_unpin` | Unpin | 取消置顶按钮 |
| `conversation_left_slide_menu_unmute` | Unmute | 取消免打扰按钮 |
| `new_chat_button_click_menu_selectcontacts` | Select Contacts | 选择联系人 |
| `new_chat_button_click_menu_addcontacts` | Add Contact | 添加联系人 |
| `new_chat_button_click_menu_creategroup` | Create Group | 创建群组 |
| `Mentioned` | Mentioned | @提醒标识 |
| `Search` | Search | 搜索按钮文字 |
| `Chats` | Chats | 导航栏标题 |
| `Refreshing...` | Refreshing... | 下拉刷新提示 |

## 注意事项

1. **侧滑菜单顺序**：数组中的顺序决定按钮从右到左（左滑）或从左到右（右滑）的显示顺序
2. **动态状态**：`.mute`/`.unmute` 和 `.pin`/`.unpin` 会根据会话状态自动切换
3. **扩展性**：`moreActions` 和 `listMoreActions` 支持动态添加自定义菜单项
4. **资源覆盖**：所有图片和国际化字符串都可以通过 Bundle.main 覆盖
5. **配置时机**：应在应用启动时配置 `Appearance.conversation`，确保全局生效
6. **主题适配**：侧滑菜单按钮颜色会自动适配深色/浅色主题

## 与 ConversationListController 的配合使用

```swift
class MyConversationListController: ConversationListController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 处理自定义菜单项的点击事件
        // 在 rightActions(indexPath:) 中处理 listMoreActions 的 tag
    }
    
    override func rightActions(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            DialogManager.shared.showActions(actions: Appearance.conversation.listMoreActions) { item in
                switch item.tag {
                case "SelectContacts": 
                    self.selectContact()
                case "AddContact": 
                    self.addContact()
                case "CreateGroup": 
                    self.createGroup()
                case "Scan":
                    // 处理自定义的扫一扫功能
                    self.showScanner()
                default:
                    break
                }
            }
        default:
            break
        }
    }
    
    func showScanner() {
        // 实现扫码功能
    }
}
```

**配置建议：** 在 AppDelegate 或 SceneDelegate 中统一配置 `Appearance.conversation`，确保整个应用的会话列表样式一致。

## 1. ConversationListController (会话列表控制器)

| 方法名 | 方法签名 | 返回类型 | 作用描述 |
|--------|---------|---------|---------|
| **UI组件创建方法** |
| `createNavigationBar()` | `@objc open func createNavigationBar() -> ChatNavigationBar` | ChatNavigationBar | 创建导航栏<br>默认：无左侧按钮，右侧显示"+"按钮 |
| `createSearchBar()` | `@objc open func createSearchBar() -> UIButton` | UIButton | 创建搜索按钮<br>显示"Search"文字和搜索图标 |
| `createList()` | `@objc open func createList() -> ConversationList` | ConversationList | 创建会话列表视图<br>自动适配tabBar高度 |
| **生命周期方法** |
| `viewWillAppear(_:)` | `open override func viewWillAppear(_ animated: Bool)` | Void | 视图即将显示<br>更新头像、隐藏导航栏、设置窗口背景色 |
| `viewWillDisappear(_:)` | `open override func viewWillDisappear(_ animated: Bool)` | Void | 视图即将消失<br>可添加自定义清理逻辑 |
| `viewDidLoad()` | `open override func viewDidLoad()` | Void | 视图加载完成<br>绑定ViewModel、设置事件回调、注册主题切换 |
| **导航和交互方法** |
| `navigationClick(type:indexPath:)` | `@objc open func navigationClick(type: ChatNavigationBarClickEvent, indexPath: IndexPath?)` | Void | 处理导航栏点击事件<br>包含返回按钮和右侧按钮点击 |
| `pop()` | `@objc open func pop()` | Void | 返回上一页<br>如果有导航控制器则pop，否则dismiss |
| `toChat(indexPath:info:)` | `@objc open func toChat(indexPath: IndexPath, info: ConversationInfo)` | Void | 进入聊天页面<br>创建MessageViewController并跳转 |
| `searchAction()` | `@objc open func searchAction()` | Void | 执行搜索操作<br>显示SearchConversationsController |
| `rightActions(indexPath:)` | `@objc open func rightActions(indexPath: IndexPath)` | Void | 处理右侧"+"按钮点击<br>显示"选择联系人"、"添加联系人"、"创建群组"菜单 |
| **联系人和群组操作方法** |
| `selectContact()` | `@objc open func selectContact()` | Void | 选择联系人<br>显示联系人列表，选中后跳转聊天 |
| `chatToContact(profile:)` | `@objc open func chatToContact(profile: ChatUserProfileProtocol)` | Void | 与指定联系人聊天<br>如果会话存在则跳转，否则创建新会话 |
| `createChat(profile:type:info:)` | `@objc open func createChat(profile: ChatUserProfileProtocol, type: ChatConversationType, info: String)` | Void | 创建会话并跳转<br>支持单聊和群聊，缓存用户/群组信息 |
| `addContact()` | `@objc open func addContact()` | Void | 添加联系人<br>显示对话框输入contactID，调用SDK添加好友 |
| `createGroup()` | `@objc open func createGroup()` | Void | 创建群组<br>显示联系人选择器，选择成员后创建群聊 |
| `create(profiles:)` | `@objc open func create(profiles: [ChatUserProfileProtocol])` | Void | 创建群组会话<br>拼接群名称（前3个成员昵称），调用SDK创建群组 |
| **主题切换** |
| `switchTheme(style:)` | `open func switchTheme(style: ThemeStyle)` | Void | 切换主题样式<br>更新视图、搜索框、导航栏、列表背景色 |
| **头像更新** |
| `updateAvatarURL(_:)` | `@MainActor @objc(updateWithAvatarURL:) public func updateAvatarURL(_ url: String)` | Void | 更新导航栏头像<br>用于刷新当前用户头像显示 |

## 2. ConversationList (会话列表视图)

| 方法名 | 方法签名 | 返回类型 | 作用描述 |
|--------|---------|---------|---------|
| **数据请求方法** |
| `requestDisplayInfo()` | `@objc open func requestDisplayInfo()` | Void | 请求显示信息<br>在滚动结束时，获取可见会话的昵称和头像数据 |
| **主题切换** |
| `switchTheme(style:)` | `public func switchTheme(style: ThemeStyle)` | Void | 切换主题样式<br>更新背景色并刷新列表 |

### IConversationListDriver 协议方法（继承自UITableView）

| 方法名 | 方法签名 | 返回类型 | 作用描述 |
|--------|---------|---------|---------|
| `occurError()` | `public func occurError()` | Void | 发生错误时调用<br>显示错误状态的空视图 |
| `refreshList(infos:)` | `public func refreshList(infos: [ConversationInfo])` | Void | 刷新会话列表<br>清空现有数据，加载新数据，更新索引映射 |
| `refreshProfiles(infos:)` | `public func refreshProfiles(infos: [ChatUserProfileProtocol])` | Void | 刷新用户信息<br>更新会话列表中的昵称、备注、头像 |
| `swipeMenuOperation(info:type:)` | `public func swipeMenuOperation(info: ConversationInfo, type: UIContextualActionType)` | Void | 侧滑菜单操作<br>处理已读、免打扰、取消免打扰、删除操作 |
| `appendThenRefresh(infos:)` | `public func appendThenRefresh(infos: [ConversationInfo])` | Void | 追加数据并刷新<br>用于加载更多会话 |
| `showNew(info:)` | `public func showNew(info: ConversationInfo)` | Void | 显示新会话<br>插入到列表顶部并滚动到顶部 |

## 3. ConversationListCell (会话列表Cell)

| 方法名 | 方法签名 | 返回类型 | 作用描述 |
|--------|---------|---------|---------|
| **UI组件创建方法** |
| `createAvatar()` | `@objc open func createAvatar() -> ImageView` | ImageView | 创建头像视图<br>尺寸：50x50，圆角可配置 |
| `createNickName()` | `@objc open func createNickName() -> UIButton` | UIButton | 创建昵称按钮<br>用UIButton支持富文本显示免打扰图标 |
| `createDate()` | `@objc open func createDate() -> UILabel` | UILabel | 创建日期标签<br>显示最后一条消息的时间 |
| `createContent()` | `@objc open func createContent() -> UILabel` | UILabel | 创建消息内容标签<br>显示最后一条消息的预览 |
| `createBadge()` | `@objc open func createBadge() -> UILabel` | UILabel | 创建未读徽章<br>显示未读消息数量（最多99+） |
| `createDot()` | `@objc open func createDot() -> UIView` | UIView | 创建免打扰红点<br>免打扰模式下显示小红点代替数字徽章 |
| `createSeparatorLine()` | `@objc open func createSeparatorLine() -> UIView` | UIView | 创建分隔线<br>位于Cell底部 |
| **数据刷新方法** |
| `refresh(info:)` | `@objc(refreshWithInfo:) open func refresh(info: ConversationInfo)` | Void | 刷新Cell显示<br>更新头像、昵称、内容、时间、未读数、置顶状态、免打扰状态 |
| **布局方法** |
| `layoutSubviews()` | `open override func layoutSubviews()` | Void | 布局子视图<br>动态计算徽章宽度（1位数/2位数/3位数以上） |
| **主题切换** |
| `switchTheme(style:)` | `public func switchTheme(style: ThemeStyle)` | Void | 切换主题样式<br>更新昵称、内容、日期、徽章、红点、分隔线颜色 |

## 4. ConversationInfo (会话信息模型)

| 方法名 | 方法签名 | 返回类型 | 作用描述 |
|--------|---------|---------|---------|
| **内容转换方法** |
| `contentAttribute()` | `@objc open func contentAttribute() -> NSAttributedString` | NSAttributedString | 转换消息内容为富文本<br>处理：文本/emoji/提及(@)标记/群聊昵称前缀/免打扰状态 |
| `convertMessage(message:)` | `open func convertMessage(message: ChatMessage) -> MessageEntity` | MessageEntity | 转换ChatMessage为MessageEntity<br>用于消息显示渲染 |
| `convertStatus(message:)` | `open func convertStatus(message: ChatMessage) -> ChatMessageStatus` | ChatMessageStatus | 转换消息状态<br>将SDK状态映射为UI状态（发送中/成功/失败/送达/已读） |
| `toJsonObject()` | `open func toJsonObject() -> Dictionary<String, Any>?` | Dictionary<String, Any>? | 转换为JSON对象<br>用于数据序列化（默认返回空字典） |

## 使用示例

```swift
// 示例1: 自定义会话列表控制器
class MyConversationListController: ConversationListController {
    
    // 自定义导航栏
    override func createNavigationBar() -> ChatNavigationBar {
        let nav = super.createNavigationBar()
        nav.title = "我的聊天"
        return nav
    }
    
    // 自定义搜索栏
    override func createSearchBar() -> UIButton {
        let search = super.createSearchBar()
        search.backgroundColor = .systemGray6
        return search
    }
    
    // 自定义进入聊天逻辑
    override func toChat(indexPath: IndexPath, info: ConversationInfo) {
        // 添加埋点统计
        print("进入会话：\(info.id)")
        super.toChat(indexPath: indexPath, info: info)
    }
    
    // 自定义右侧菜单
    override func rightActions(indexPath: IndexPath) {
        // 显示自定义菜单
        let alert = UIAlertController(title: "操作", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "扫一扫", style: .default, handler: { _ in
            // 实现扫码功能
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        self.present(alert, animated: true)
    }
    
    // 自定义创建群组逻辑
    override func create(profiles: [ChatUserProfileProtocol]) {
        // 先验证群成员数量
        guard profiles.count >= 2 else {
            print("至少需要2个成员")
            return
        }
        super.create(profiles: profiles)
    }
}

// 示例2: 自定义会话列表Cell
class MyConversationListCell: ConversationListCell {
    
    // 自定义头像样式
    override func createAvatar() -> ImageView {
        let avatar = super.createAvatar()
        avatar.layer.borderWidth = 2
        avatar.layer.borderColor = UIColor.systemBlue.cgColor
        return avatar
    }
    
    // 自定义未读徽章样式
    override func createBadge() -> UILabel {
        let badge = super.createBadge()
        badge.backgroundColor = .systemRed
        badge.font = .boldSystemFont(ofSize: 12)
        return badge
    }
    
    // 自定义刷新逻辑
    override func refresh(info: ConversationInfo) {
        super.refresh(info: info)
        
        // 添加VIP标识
        if info.id.hasPrefix("vip_") {
            let vipIcon = UIImageView(image: UIImage(systemName: "crown.fill"))
            vipIcon.tintColor = .systemYellow
            vipIcon.frame = CGRect(x: 50, y: 10, width: 20, height: 20)
            self.contentView.addSubview(vipIcon)
        }
    }
}

// 示例3: 自定义会话信息内容显示
class MyConversationInfo: ConversationInfo {
    
    // 自定义内容属性转换
    override func contentAttribute() -> NSAttributedString {
        guard let message = self.lastMessage else {
            return NSAttributedString(string: "暂无消息")
        }
        
        // 自定义草稿显示
        if let draft = getDraft(conversationId: self.id), !draft.isEmpty {
            return NSMutableAttributedString {
                AttributedText("[草稿] ").foregroundColor(.systemRed).font(.systemFont(ofSize: 14, weight: .bold))
                AttributedText(draft).foregroundColor(.systemGray).font(.systemFont(ofSize: 14))
            }
        }
        
        return super.contentAttribute()
    }
    
    // 自定义消息状态转换
    override func convertStatus(message: ChatMessage) -> ChatMessageStatus {
        let status = super.convertStatus(message: message)
        
        // 添加自定义逻辑：标记重要消息
        if message.ext?["important"] as? Bool == true {
            print("这是一条重要消息")
        }
        
        return status
    }
    
    private func getDraft(conversationId: String) -> String? {
        // 从本地缓存获取草稿
        return UserDefaults.standard.string(forKey: "draft_\(conversationId)")
    }
}

// 示例4: 扩展ConversationList功能
extension ConversationList {
    
    // 添加自定义刷新逻辑
    func customRefresh() {
        // 显示加载动画
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        activityIndicator.center = self.center
        self.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        // 请求数据
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
        }
    }
}
```

## 重要说明

### 1. **ConversationListController 扩展点**
- **导航定制**：重载 `createNavigationBar()` 自定义导航栏样式
- **搜索定制**：重载 `createSearchBar()` 自定义搜索框
- **交互定制**：重载 `toChat()`、`rightActions()` 等改变默认行为
- **业务逻辑**：重载 `create()`、`addContact()` 添加验证或埋点

### 2. **ConversationList 职责**
- 作为 `UITableView` 的子类，主要处理列表显示和交互
- 实现 `IConversationListDriver` 协议，作为ViewModel的驱动层
- 处理侧滑菜单、下拉刷新、数据刷新等UI操作

### 3. **ConversationListCell 定制**
- **UI组件创建**：所有 `create*()` 方法都可重载
- **刷新逻辑**：重载 `refresh(info:)` 添加自定义显示
- **布局调整**：重载 `layoutSubviews()` 改变元素位置

### 4. **ConversationInfo 数据处理**
- **内容转换**：`contentAttribute()` 是最重要的方法，决定消息预览显示
- **状态映射**：`convertStatus()` 可添加自定义状态逻辑
- **扩展属性**：可添加自定义属性（草稿、标签等）

### 5. **协议和代理模式**
- `ConversationListActionEventsDelegate`: UI事件回调
- `IConversationListDriver`: ViewModel驱动接口
- 通过协议实现解耦，方便测试和扩展

### 6. **资源覆盖**
以下图片和国际化资源可通过 Bundle.main 覆盖：
- 图片：empty, bell_slash, add, search, more, read, trash, mute, pin, unpin, unmute
- 国际化：Search, Chats, Mentioned, conversation_right_slide_menu_*, conversation_left_slide_menu_*

### 7. **主题适配**
所有类都实现了 `ThemeSwitchProtocol`，支持深色/浅色模式切换，重载时需考虑主题兼容性。
