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
    
    /// You can change the hue of the base color, and then change the thirteen UIColor objects of the related color series. The UI components that use the relevant color series in the ease chat UIKit will also change accordingly. The default value is 203/360.0.
    public static var primaryHue: CGFloat = 203/360.0
    
    /// You can change the primary hue. The default value is 203/360.0.
    /// After the primary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the ease chat UIKit will also change accordingly.
    public static var secondaryHue: CGFloat = 155/360.0
    
    /// You can change the secondary hue. The default value is 155/360.0.
    /// After the secondary hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the ease chat UIKit will also change accordingly.
    public static var errorHue: CGFloat = 350/360.0
    
    /// You can change the neutral hue. The default value is 203/360.0.
    /// After the neutral hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the related color series in the ease chat UIKit will also change accordingly.
    public static var neutralHue: CGFloat = 203/360.0
    
    /// You can change the neutral special hue. The default value is 220/360.0.
    /// After the neutral special hue is changed, thirteen UIColor objects of the related color series will be changed. The color of UI components that use the relevant color series in the ease chat UIKit will also change accordingly.
    public static var neutralSpecialHue: CGFloat = 220/360.0
    
    /// EaseChatUIKit‘s language type.
    public static var ease_chat_language = LanguageType.Chinese
    
    /// The corner radius of the avatar image view of ``ChatInputBar``.
    public static var avatarRadius: CornerRadius = .extraSmall
    
    /// Whether hidden user status  image view or not.
    public static var hiddenPresence = false
        
    /// ActionSheet row height.
    public static var actionSheetRowHeight: CGFloat = 56
    
    /// The placeholder image of the avatar image view of ``MessageCell``.
    public static var avatarPlaceHolder: UIImage? = UIImage(chatNamed: "default_avatar")
    
    /// Conversation Component
    public static var conversation = ConversationAppearance()
    
    /// Contact Component
    public static var contact = ContactAppearance()
    
    /// Chat Component
    public static var chat = ChatAppearance()
    
    public static var resourceBundle: Bundle?
}

@objcMembers final public class ConversationAppearance: NSObject {
    
    /// Conversation row height.
    public var rowHeight = CGFloat(76)
    
    /// Menu items that appear after swiping left in a conversation.You can choose to have just some of the features or all of them.``UIContextualActionType``
    public var swipeLeftActions: [UIContextualActionType] = [.mute,.pin,.delete]
    
    /// Menu items that appear after swiping right in a conversation.You can choose to have just some of the features or all of them.``UIContextualActionType``
    public var swipeRightActions: [UIContextualActionType] = [.more,.read]
    
    /// Single chat default place holder of avatar.
    public var singlePlaceHolder = UIImage(chatNamed: "single")
    
    /// Group chat default place holder of avatar.
    public var groupPlaceHolder = UIImage(chatNamed: "group")
    
    /// Setting this property changes the date format displayed on conversation last message updated.
    public var dateFormatToday = "HH:mm"
    
    /// Setting this property changes the date format displayed on conversation last message updated.
    public var dateFormatOtherDay = "MM/dd"
    
    /// ActionSheet menu configuration items after clicking more buttons in a single session side sliding menu.
    /// How to use?
    /// `let translate = ActionSheetItem(title: "translate", type: .normal,tag: "Translate")`
    /// `translate.action = { }`
    /// `Appearance.conversation.moreActions.append(translate)`
    public var moreActions: [ActionSheetItemProtocol] = []
    
    /// Shown menus on ``ConversationListController`` right item clicked.
    lazy public var listMoreActions: [ActionSheetItemProtocol] = {
        [
            ActionSheetItem(title: "new_chat_button_click_menu_selectcontacts".chat.localize, type: .normal, tag: "SelectContacts", image: UIImage(chatNamed: "chatWith")),
            ActionSheetItem(title: "new_chat_button_click_menu_addcontacts".chat.localize, type: .normal, tag: "AddContact", image: UIImage(chatNamed: "person_add_fill")?.withTintColor(UIColor.theme.primaryLightColor)),
            ActionSheetItem(title: "new_chat_button_click_menu_creategroup".chat.localize, type: .normal, tag: "CreateGroup", image: UIImage(chatNamed: "create_group")?.withTintColor(UIColor.theme.primaryLightColor))
        ]
    }()
}

@objcMembers final public class ChatAppearance: NSObject {
    
    /// The height limit of the input box in ``MessageInputBar``.
    public var maxInputHeight: CGFloat = 88
    
    /// The placeholder text in ``MessageInputBar``.
    public var inputPlaceHolder = "Aa"
    
    /// The corner radius of ``MessageInputBar``.
    public var inputBarCorner: CornerRadius = .extraSmall
    
    /// Message bubble display style.``MessageBubbleDisplayStyle``
    public var bubbleStyle: MessageBubbleDisplayStyle = .withArrow
    
    /// Message content display style.You can use these four styles to combine a style array you want. Bubbles are all provided by default, except for picture messages and video messages.``MessageContentDisplayStyle``
    public var contentStyle: [MessageContentDisplayStyle] = [.withReply,.withAvatar,.withNickName,.withDateAndTime]
            
    /// ActionSheet data source of the message being long pressed.``ActionSheetItemProtocol``
    lazy public var messageLongPressedActions: [ActionSheetItemProtocol] = {
        [
            ActionSheetItem(title: "barrage_long_press_menu_copy".chat.localize, type: .normal,tag: "Copy",image: UIImage(chatNamed: "message_action_copy")),
            ActionSheetItem(title: "barrage_long_press_menu_forward".chat.localize, type: .normal,tag: "Forward",image: UIImage(chatNamed: "message_action_forward")),
            ActionSheetItem(title: "barrage_long_press_menu_topic".chat.localize, type: .normal,tag: "Topic",image: UIImage(chatNamed: "message_action_topic")),
            ActionSheetItem(title: "barrage_long_press_menu_reply".chat.localize, type: .normal,tag: "Reply",image: UIImage(chatNamed: "message_action_reply")),
            ActionSheetItem(title: "barrage_long_press_menu_recall".chat.localize, type: .normal,tag: "Recall",image: UIImage(chatNamed: "message_action_recall")),
            ActionSheetItem(title: "barrage_long_press_menu_edit".chat.localize, type: .normal,tag: "Edit",image: UIImage(chatNamed: "message_action_edit")),
            ActionSheetItem(title: "barrage_long_press_menu_multi_select".chat.localize, type: .normal,tag: "MultiSelect",image: UIImage(chatNamed: "message_action_multi_select")),
            ActionSheetItem(title: "barrage_long_press_menu_pin".chat.localize, type: .normal,tag: "Pin",image: UIImage(chatNamed: "message_action_pin")),
            ActionSheetItem(title: "barrage_long_press_menu_translate".chat.localize, type: .normal,tag: "Translate",image: UIImage(chatNamed: "message_action_translation")),
            ActionSheetItem(title: "barrage_long_press_menu_show_original_text".chat.localize, type: .normal,tag: "OriginalText",image: UIImage(chatNamed: "message_action_translation")),
            ActionSheetItem(title: "barrage_long_press_menu_report".chat.localize, type: .normal,tag: "Report",image: UIImage(chatNamed: "message_action_report")),
            ActionSheetItem(title: "barrage_long_press_menu_delete".chat.localize, type: .normal,tag: "Delete",image: UIImage(chatNamed: "message_action_delete"))
        ]
    }()
    
    /// The mirror type of the language code of LanguageType.``LanguageType``
    public var targetLanguage: LanguageType = .Chinese
    
    /// You need to enable the translation function from the console first, and then set this property to true to experience the translation function.
    public var enableTranslation = false
    
    /// The label for message reporting types.
    public var reportSelectionTags: [String] = ["tag1","tag2","tag3","tag4","tag5","tag6","tag7","tag8","tag9"]
    
    /// The label for message reporting reason.
    lazy public var reportSelectionReasons: [String] = {
        ["violation_reason_1".chat.localize,"violation_reason_2".chat.localize,"violation_reason_3".chat.localize,"violation_reason_4".chat.localize,"violation_reason_5".chat.localize,"violation_reason_6".chat.localize,"violation_reason_7".chat.localize,"violation_reason_8".chat.localize,"violation_reason_9".chat.localize]
    }()
    
//        /// Replace the emoji resource.``ChatEmojiConvertor``
//        /// - Parameters:
//        ///   Emoji map in key-value format, where the key can only be any of the following and value is a UIImage instance.
//        public var emojiMap: Dictionary<String,UIImage> = Dictionary<String,UIImage>()
    
    /// A menu item pops up when you click the `+` button on the input box
    lazy public var inputExtendActions: [ActionSheetItemProtocol] = {
        [
            ActionSheetItem(title: "input_extension_menu_photo".chat.localize, type: .normal,tag: "Photo",image: UIImage(chatNamed: "photo")),
            ActionSheetItem(title: "input_extension_menu_camera".chat.localize, type: .normal,tag: "Camera",image: UIImage(chatNamed: "camera_fill")),
            ActionSheetItem(title: "input_extension_menu_file".chat.localize, type: .normal,tag: "File",image: UIImage(chatNamed: "file")),
            ActionSheetItem(title: "input_extension_menu_contact".chat.localize, type: .normal,tag: "Contact",image: UIImage(chatNamed: "person_single_fill"))
        ]
    }()
    
    /// Setting this property changes the date format displayed within a single session.
    public var dateFormatToday = "HH:mm"
    
    /// Setting this property changes the date format displayed within a single session.
    public var dateFormatOtherDay = "yyyy-MM-dd HH:mm"
    
    /// Record audio limitation.
    public var audioDuration = 60
    
    /// The resource image of the audio animation played after the recipient of the audio message clicks
    public var receiveAudioAnimationImages = [
        UIImage(chatNamed: Theme.style == .dark ? "audio_play_left_dark01":"audio_play_left_light01")!,
        UIImage(chatNamed: Theme.style == .dark ? "audio_play_left_dark02":"audio_play_left_light02")!,
        UIImage(chatNamed: Theme.style == .dark ? "audio_play_left_dark03":"audio_play_left_light03")!
    ]
    
    /// The resource image of the audio animation played after the sender of the audio message clicks
    public var sendAudioAnimationImages = [
        UIImage(chatNamed: Theme.style == .dark ? "audio_play_right_dark01":"audio_play_right_light01")!,
        UIImage(chatNamed: Theme.style == .dark ? "audio_play_right_dark02":"audio_play_right_light02")!,
        UIImage(chatNamed: Theme.style == .dark ? "audio_play_right_dark03":"audio_play_right_light03")!
    ]
    /// The color of the recipient of the text message.
    public var receiveTextColor: UIColor {
        get {
            Theme.style == .dark ? UIColor.theme.neutralColor98:UIColor.theme.neutralColor1
        }
        set {}
    }
    
    /// The color of the sender of the text message.
    public var sendTextColor: UIColor {
        get {
            Theme.style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        }
        set {}
    }
        
    /// The color of the recipient of the text message.
    public var receiveTranslationColor: UIColor {
        get {
            Theme.style == .dark ? UIColor.theme.neutralColor7:UIColor.theme.neutralColor5
        }
        set {}
    }
    
    /// The color of the sender of the text message.
    public var sendTranslationColor: UIColor {
        get {
            Theme.style == .dark ? UIColor.theme.neutralSpecialColor2:UIColor.theme.neutralSpecialColor95
        }
        set {}
    }
    

    /// The corner of the image message.
    public var imageMessageCorner = CGFloat(4)
    
    /// Default placeholder image for picture messages.
    public var imagePlaceHolder = UIImage(chatNamed: "image_message_placeHolder")
    
    /// Default placeholder image for video messages.
    public var videoPlaceHolder = UIImage(chatNamed: "video_message_placeHolder")
    
    /// The maximum time limit for message withdrawal needs to be adjusted from the console before adjusting this configuration of the client.
    public var recallExpiredTime = UInt(120)
    
    /// New message tone audio path
    public var newMessageSoundPath = "/System/Library/Audio/UISounds/sms-received1.caf"
    
    /// The maximum number of participants in the group chat.
    public var groupParticipantsLimitCount = 1000
    
    /// Commonly used reaction emoticon responses
    public var commonReactions = ["👍", "❤️", "😄", "😱", "😡", "🎉"]
    
    /// Commonly used reaction emoticon responses map.
    public var commonReactionMap = ["👍":UIImage(chatNamed: "👍"), "❤️":UIImage(chatNamed: "❤️"), "😄":UIImage(chatNamed: "😄"), "😱":UIImage(chatNamed: "😱"), "😡":UIImage(chatNamed: "😡"), "🎉":UIImage(chatNamed: "🎉")]
    
    /// The alert position on received lots of messages.
    public var moreMessageAlertPosition = MoreMessagePosition.center
    
    /// Whether show the typing status or not on other party input text.
    public var enableTyping = true
    
    /// Whether enable pin message function or not
    public var enablePinMessage = true
    
    /// URL preview feature regular title expression.
    public var titlePreviewPattern = ""
    
    /// URL preview feature regular description expression.
    public var descriptionPreviewPattern = ""
    
    /// URL preview feature regular image expression.
    public var imagePreviewPattern = ""
    
    /// Whether enable URL preview or not.
    public var enableURLPreview = true
    
    /// Choose to show the message long press menu style.
    public var messageLongPressMenuStyle: MessageLongPressMenuStyle = .withArrow
    
    /// Choose to show the message attachment menu style.
    public var messageAttachmentMenuStyle: MessageAttachmentMenuStyle = .followInput
    
}

@objc public enum MessageAttachmentMenuStyle: UInt8 {
    case followInput //A menu that follows the input box,like WeChat.
    case actionSheet //A menu with an actionSheet,like iOS system ``UIActionSheet``.
}

@objc public enum MessageLongPressMenuStyle: UInt8 {
//    case system //A system menu,like iMessage.
    case withArrow //A menu with an arrow,like we-chat message long press menu.
    case actionSheet //A menu with an actionSheet,like iOS system ``UIActionSheet``.
}

/// Contact Module
@objcMembers final public class ContactAppearance: NSObject {
    
    /// Contact row height.
    public var rowHeight = CGFloat(60)
    
    /// Header of contact list list row height.
    public var headerRowHeight = CGFloat(60)
    
    /// The header items of the contact list.
    lazy public var listHeaderExtensionActions: [ContactListHeaderItemProtocol] = {
        [
            ContactListHeaderItem(featureIdentify: "NewFriendRequest", featureName: "New Request".chat.localize, featureIcon: nil),
            ContactListHeaderItem(featureIdentify: "GroupChats", featureName: "Joined Groups".chat.localize, featureIcon: nil)
        ]
    }()
    
    /// The contact info header extension items.
    lazy public var detailExtensionActionItems: [ContactListHeaderItemProtocol] = {
        [ContactListHeaderItem(featureIdentify: "Chat", featureName: "Chat".chat.localize, featureIcon: UIImage(chatNamed: "chatTo")),ContactListHeaderItem(featureIdentify: "SearchMessages", featureName: "SearchMessages".chat.localize, featureIcon: UIImage(chatNamed: "search_history_messages"))]
    }()
//    ,ContactListHeaderItem(featureIdentify: "AudioCall", featureName: "AudioCall".chat.localize, featureIcon: UIImage(chatNamed: "voice_call")),ContactListHeaderItem(featureIdentify: "VideoCall", featureName: "VideoCall".chat.localize, featureIcon: UIImage(chatNamed: "video_call"))
    
    /// ActionSheet menu configuration items after clicking more buttons in a single session side sliding menu.
    /// How to use?
    /// `let translate = ActionSheetItem(title: "translate", type: .normal,tag: "Translate")`
    /// `translate.action = { }`
    /// `Appearance.conversation.moreActions.append(translate)`
    lazy public var moreActions: [ActionSheetItemProtocol] = {
        [ActionSheetItem(title: "contact_details_extend_button_delete".chat.localize, type: .destructive, tag: "contact_delete")]
    }()
    
    /// Whether enable block some contact or not.
    public var enableBlock = true
}
