//
//  ComponentsRegister.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/9/1.
//

import UIKit


/// An object containing UI components that are used through the EaseChatUIKit SDK.
@objcMembers public class ComponentsRegister: NSObject {
    
    public static var shared = ComponentsRegister()
    
    //MARK: - About Conversation
    public var Conversation: ConversationInfo.Type = ConversationInfo.self
    
    public var ConversationCell: ConversationListCell.Type = ConversationListCell.self
    
    public var ConversationSearchResultCell: ConversationSearchCell.Type = ConversationSearchCell.self
    
//    public var ConversationViewService: ConversationViewModel.Type = ConversationViewModel.self
    
    /// Conversation list page controller
    public var ConversationsController: ConversationListController.Type = ConversationListController.self
    
    public var SearchConversationController: SearchConversationsController.Type = SearchConversationsController.self
    
    //MARK: - About Contact
    /// Contact list page controller.
    public var ContactsController: ContactViewController.Type = ContactViewController.self
    
    public var ContactsCell: ContactCell.Type = ContactCell.self
    
    public var ContactInfoController: ContactInfoViewController.Type = ContactInfoViewController.self
    
    public var JoinedGroupsController: JoinedGroupsViewController.Type = JoinedGroupsViewController.self
    
    public var NewFriendRequestController: NewContactRequestController.Type = NewContactRequestController.self
    
    public var GroupInfoController: GroupInfoViewController.Type = GroupInfoViewController.self
    
    public var GroupParticipantController: GroupParticipantsController.Type = GroupParticipantsController.self
    
    public var RemoveGroupParticipantController: GroupParticipantsRemoveController.Type = GroupParticipantsRemoveController.self
    
    //MARK: - About Message
    /// Register custom table view cell method.
    /// - Parameter identify: Cell's reuse identifier.
    public func registerCellIdentifier(identify: String) {
        if !self.customIdentifiers.contains(identify) {
            self.customIdentifiers.append(identify)
        }
    }
    
    public internal(set) var customIdentifiers: [String] = []
    
    public var ChatCustomMessageCell: CustomMessageCell.Type = CustomMessageCell.self
    
    public var ChatTextMessageCell: TextMessageCell.Type = TextMessageCell.self
    
    public var ChatImageMessageCell: ImageMessageCell.Type = ImageMessageCell.self
    
    public var ChatAudioMessageCell: AudioMessageCell.Type = AudioMessageCell.self
    
    public var ChatVideoMessageCell: VideoMessageCell.Type = VideoMessageCell.self
    
    public var ChatFileMessageCell: FileMessageCell.Type = FileMessageCell.self
    
    public var ChatContactMessageCell: ContactCardCell.Type = ContactCardCell.self
    
    public var ChatAlertCell: AlertMessageCell.Type = AlertMessageCell.self
    
    public var ChatLocationCell: LocationMessageCell.Type = LocationMessageCell.self
    
    public var ChatCombineCell: CombineMessageCell.Type = CombineMessageCell.self
    
    /// Message cell render entity.
    public var MessageRenderEntity: MessageEntity.Type = MessageEntity.self
    
    /// Message list page controller.
    public var MessageViewController: MessageListController.Type = MessageListController.self
    
    /// Report message controller.
    public var ReportViewController: ReportOptionsController.Type = ReportOptionsController.self
}
