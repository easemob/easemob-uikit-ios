import UIKit


@objc public enum AlertStyle: UInt {
    case small
    case large
}

/// An object containing visual configurations for the whole application.
@objcMembers final public class Appearance: NSObject {
            
    /// You can change the width of a single option with ``PageContainerTitleBar`` in the popup container by setting the current property.
    public static var pageContainerTitleBarItemWidth: CGFloat = (ScreenWidth-32)/2.0
    
    /// The size of ``PageContainersDialogController`` constraints.
    public static var pageContainerConstraintsSize = CGSize(width: ScreenWidth, height: ScreenHeight*(3.0/5.0))
    
    /// The size of alert container constraints.``AlertViewController``
    public static var alertContainerConstraintsSize = CGSize(width: ScreenWidth-40, height: ScreenHeight/3.0)
    
    /// The corner radius of the alert view.``AlertView``
    public static var alertStyle: AlertStyle = .large
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the chat room UIKit will also change accordingly. The default value is 203/360.0.
    public static var primaryHue: CGFloat = 203/360.0
    
    /// You can change the primary hue. The default value is 203/360.0.
    /// After the primary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var secondaryHue: CGFloat = 155/360.0
    
    /// You can change the secondary hue. The default value is 155/360.0.
    /// After the secondary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var errorHue: CGFloat = 350/360.0
    
    /// You can change the neutral hue. The default value is 203/360.0.
    /// After the neutral hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the chat room UIKit will also change accordingly.
    public static var neutralHue: CGFloat = 203/360.0
    
    /// You can change the neutral special hue. The default value is 220/360.0.
    /// After the neutral special hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the relevant color series in the chat room UIKit will also change accordingly.
    public static var neutralSpecialHue: CGFloat = 220/360.0
    
    /// The corner radius of the avatar image view of ``ChatInputBar``.
    public static var avatarRadius: CornerRadius = .large
        
    /// ActionSheet row height.
    public static var actionSheetRowHeight: CGFloat = 56
    
    /// The placeholder image of the avatar image view of ``MessageCell``.
    public static var avatarPlaceHolder: UIImage? = UIImage(named: "default_avatar", in: .chatBundle, with: nil)
    
    /// Conversation Component
    public static var conversation = ConversationAppearance()
    
    /// Contact Component
    public static var contact = ContactAppearance()
    
    /// Chat Component
    public static var chat = ChatAppearance()
    
    
}

@objcMembers final public class ConversationAppearance: NSObject {
    
    /// Conversation row height.
    public var rowHeight = CGFloat(76)
    
    /// Menu items that appear after swiping left in a conversation.You can choose to have just some of the features or all of them.``UIContextualActionType``
    public var swipeLeftActions: [UIContextualActionType] = [.mute,.pin,.delete]
    
    /// Menu items that appear after swiping right in a conversation.You can choose to have just some of the features or all of them.``UIContextualActionType``
    public var swipeRightActions: [UIContextualActionType] = [.more,.read]
    
    /// Single chat default place holder of avatar.
    public var singlePlaceHolder = UIImage(named: "single", in: .chatBundle, with: nil)
    
    /// Group chat default place holder of avatar.
    public var groupPlaceHolder = UIImage(named: "group", in: .chatBundle, with: nil)
    
    /// Setting this property changes the date format displayed on conversation last message updated.
    public var dateFormatToday = "HH:mm"
    
    /// Setting this property changes the date format displayed on conversation last message updated.
    public var dateFormatOtherDay = "MMM dd"
    
    /// ActionSheet menu configuration items after clicking more buttons in a single session side sliding menu.
    /// How to use?
    /// `let translate = ActionSheetItem(title: "translate", type: .normal,tag: "Translate")`
    /// `translate.action = { }`
    /// `Appearance.conversation.moreActions.append(translate)`
    public var moreActions: [ActionSheetItemProtocol] = []
    
    /// Shown menus on ``ConversationListController`` right item clicked.
    public var listMoreActions: [ActionSheetItemProtocol] = [
        ActionSheetItem(title: "new_chat_button_click_menu_selectcontacts".chat.localize, type: .normal, tag: "SelectContacts", image: UIImage(named: "chatWith", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "new_chat_button_click_menu_addcontacts".chat.localize, type: .normal, tag: "AddContact", image: UIImage(named: "person_add_fill", in: .chatBundle, with: nil)?.withTintColor(UIColor.theme.primaryColor5)),
        ActionSheetItem(title: "new_chat_button_click_menu_creategroup".chat.localize, type: .normal, tag: "CreateGroup", image: UIImage(named: "create_group", in: .chatBundle, with: nil)?.withTintColor(UIColor.theme.primaryColor5))
    ]
}

@objcMembers final public class ChatAppearance: NSObject {
    
    /// The height limit of the input box in ``MessageInputBar``.
    public var maxInputHeight: CGFloat = 88
    
    /// The placeholder text in ``MessageInputBar``.
    public var inputPlaceHolder = "Aa"
    
    /// The corner radius of ``MessageInputBar``.
    public var inputBarCorner: CornerRadius = .extraSmall
    
    /// Message bubble display style.``BubbleDisplayStyle``
    public var bubbleStyle: MessageCell.BubbleDisplayStyle = .withArrow
    
    /// Message content display style.You can use these four styles to combine a style array you want. Bubbles are all provided by default, except for picture messages and video messages.``ContentDisplayStyle``
    public var contentStyle: [MessageCell.ContentDisplayStyle] = [.withReply,.withAvatar,.withNickName,.withDateAndTime]
            
    /// ActionSheet data source of the message being long pressed.``ActionSheetItemProtocol``
    public var messageLongPressedActions: [ActionSheetItemProtocol] = [
        ActionSheetItem(title: "barrage_long_press_menu_copy".chat.localize, type: .normal,tag: "Copy",image: UIImage(named: "message_action_copy", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "barrage_long_press_menu_edit".chat.localize, type: .normal,tag: "Edit",image: UIImage(named: "message_action_edit", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "barrage_long_press_menu_reply".chat.localize, type: .normal,tag: "Reply",image: UIImage(named: "message_action_reply", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "barrage_long_press_menu_delete".chat.localize, type: .normal,tag: "Delete",image: UIImage(named: "message_action_delete", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "barrage_long_press_menu_recall".chat.localize, type: .normal,tag: "Recall",image: UIImage(named: "message_action_recall", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "barrage_long_press_menu_report".chat.localize, type: .normal,tag: "Report",image: UIImage(named: "message_action_report", in: .chatBundle, with: nil))
    ]
    
//        /// The mirror type of the language code of LanguageType.``LanguageType``
//        public var targetLanguage: LanguageType = .English
    
    /// The label for message reporting types.
    public var reportSelectionTags: [String] = ["tag1","tag2","tag3","tag4","tag5","tag6","tag7","tag8","tag9"]
    
    /// The label for message reporting reason.
    public var reportSelectionReasons: [String] = ["violation_reason_1".chat.localize,"violation_reason_2".chat.localize,"violation_reason_3".chat.localize,"violation_reason_4".chat.localize,"violation_reason_5".chat.localize,"violation_reason_6".chat.localize,"violation_reason_7".chat.localize,"violation_reason_8".chat.localize,"violation_reason_9".chat.localize]
    
//        /// Replace the emoji resource.``ChatEmojiConvertor``
//        /// - Parameters:
//        ///   Emoji map in key-value format, where the key can only be any of the following and value is a UIImage instance.
//        public var emojiMap: Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    /// A menu item pops up when you click the `+` button on the input box
    public var inputExtendActions: [ActionSheetItemProtocol] = [
        ActionSheetItem(title: "input_extension_menu_photo".chat.localize, type: .normal,tag: "Photo",image: UIImage(named: "photo", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "input_extension_menu_camera".chat.localize, type: .normal,tag: "Camera",image: UIImage(named: "camera_fill", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "input_extension_menu_file".chat.localize, type: .normal,tag: "File",image: UIImage(named: "file", in: .chatBundle, with: nil)),
        ActionSheetItem(title: "input_extension_menu_contact".chat.localize, type: .normal,tag: "Contact",image: UIImage(named: "person_single_fill", in: .chatBundle, with: nil))
    ]
    
    /// Setting this property changes the date format displayed within a single session.
    public var dateFormatToday = "HH:mm"
    
    /// Setting this property changes the date format displayed within a single session.
    public var dateFormatOtherDay = "yyyy-MM-dd HH:mm"
    
    /// Record audio limitation.
    public var audioDuration = 60
    
    /// The resource image of the audio animation played after the recipient of the audio message clicks
    public var receiveAudioAnimationImages = [
        UIImage(named: Theme.style == .dark ? "audio_play_left_dark01":"audio_play_left_light01", in: .chatBundle, with: nil)!,
        UIImage(named: Theme.style == .dark ? "audio_play_left_dark02":"audio_play_left_light02", in: .chatBundle, with: nil)!,
        UIImage(named: Theme.style == .dark ? "audio_play_left_dark03":"audio_play_left_light03", in: .chatBundle, with: nil)!
    ]
    
    /// The resource image of the audio animation played after the sender of the audio message clicks
    public var sendAudioAnimationImages = [
        UIImage(named: Theme.style == .dark ? "audio_play_right_dark01":"audio_play_right_light01", in: .chatBundle, with: nil)!,
        UIImage(named: Theme.style == .dark ? "audio_play_right_dark02":"audio_play_right_light02", in: .chatBundle, with: nil)!,
        UIImage(named: Theme.style == .dark ? "audio_play_right_dark03":"audio_play_right_light03", in: .chatBundle, with: nil)!
    ]
    
    /// The bubble color of the recipient of the message.
    public var receiveBubbleColor = Theme.style == .dark ? UIColor.theme.primaryColor2:UIColor.theme.primaryColor95
    
    /// The bubble color of the sender of the message.
    public var sendBubbleColor = Theme.style == .dark ? UIColor.theme.primaryColor6:UIColor.theme.primaryColor5
    
    /// The color of the recipient of the text message.
    public var receiveTextColor = Theme.style == .light ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    
    /// The color of the sender of the text message.
    public var sendTextColor = Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    
    /// The corner of the image message.
    public var imageMessageCorner = CGFloat(4)
    
    /// Default placeholder image for picture messages.
    public var imagePlaceHolder = UIImage(named: "image_message_placeHolder", in: .chatBundle, with: nil)
    
    /// Default placeholder image for video messages.
    public var videoPlaceHolder = UIImage(named: "video_message_placeHolder", in: .chatBundle, with: nil)
    
    /// The maximum time limit for message withdrawal needs to be adjusted from the console before adjusting this configuration of the client.
    var recallExpiredTime = UInt(120)
    
    /// New message tone audio path
    var newMessageSoundPath = "/System/Library/Audio/UISounds/sms-received1.caf"
    
    var groupParticipantsLimitCount = 1000
    
}

/// Contact Module
@objcMembers final public class ContactAppearance: NSObject {
    
    /// Contact row height.
    public var rowHeight = CGFloat(54)
    
    /// Header of contact list list row height.
    public var headerRowHeight = CGFloat(54)
    
    /// The header items of the contact list.
    public var listHeaderExtensionActions: [ContactListHeaderItemProtocol] = [
        ContactListHeaderItem(featureIdentify: "NewFriendRequest", featureName: "New Request", featureIcon: nil),
        ContactListHeaderItem(featureIdentify: "GroupChats", featureName: "Joined Groups", featureIcon: nil)
    ]
    
    /// The contact info header extension items.
    public var detailExtensionActionItems: [ContactListHeaderItemProtocol] = [ContactListHeaderItem(featureIdentify: "Chat", featureName: "Chat".chat.localize, featureIcon: UIImage(named: "chatTo", in: .chatBundle, with: nil))]
    
    /// ActionSheet menu configuration items after clicking more buttons in a single session side sliding menu.
    /// How to use?
    /// `let translate = ActionSheetItem(title: "translate", type: .normal,tag: "Translate")`
    /// `translate.action = { }`
    /// `Appearance.conversation.moreActions.append(translate)`
    public var moreActions: [ActionSheetItemProtocol] = [ActionSheetItem(title: "contact_details_extend_button_delete".chat.localize, type: .destructive, tag: "contact_delete")]
}
