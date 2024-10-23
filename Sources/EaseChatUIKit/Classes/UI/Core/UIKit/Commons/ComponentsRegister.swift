//
//  ComponentsRegister.swift
//  ChatUIKit
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
    
    /// Conversation list view model.
    public var ConversationViewService: ConversationViewModel.Type = ConversationViewModel.self
    
    /// Conversation list page controller
    public var ConversationsController: ConversationListController.Type = ConversationListController.self
    
    //MARK: - About Contact
    /// Contact list page controller.
    public var ContactsController: ContactViewController.Type = ContactViewController.self
    
    /// Contact list view model.
    public var ContactViewService: ContactViewModel.Type = ContactViewModel.self
    
    public var ContactsCell: ContactCell.Type = ContactCell.self
    
    /// Contact detail info of the group.
    public var ContactInfoController: ContactInfoViewController.Type = ContactInfoViewController.self
    
    public var JoinedGroupsController: JoinedGroupsViewController.Type = JoinedGroupsViewController.self
    
    /// New friend request controller.
    public var NewFriendRequestController: NewContactRequestController.Type = NewContactRequestController.self
    
    /// Group detail info view controller.
    public var GroupInfoController: GroupInfoViewController.Type = GroupInfoViewController.self
    
    /// Participants controller of the group.
    public var GroupParticipantController: GroupParticipantsController.Type = GroupParticipantsController.self
    
    /// Remove participants controller of the group.
    public var RemoveGroupParticipantController: GroupParticipantsRemoveController.Type = GroupParticipantsRemoveController.self
    
    //MARK: - About Message
    /// Register customize table view cell method.
    /// - Parameter cellType: Cell's class type.
    public func registerCustomizeCellClass(cellType: MessageCell.Type) {
        if !self.customCellClasses.contains(where: { $0 == cellType }) {
            self.customCellClasses.append(cellType)
        }
    }
        
    public internal(set) var customCellClasses: [MessageCell.Type] = []
    
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
        
    public var MessagesViewModel: MessageListViewModel.Type = MessageListViewModel.self
    
    /// Message cell render entity.
    public var MessageRenderEntity: MessageEntity.Type = MessageEntity.self
    
    /// Message list page controller.
    public var MessageViewController: MessageListController.Type = MessageListController.self
    
    /// Report message controller.
    public var ReportViewController: ReportOptionsController.Type = ReportOptionsController.self
}
