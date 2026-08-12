//
//  ChatService.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/1.
//

import Foundation


/// The status of ``ChatMessage``.
@objc public enum ChatMessageStatus: UInt {
    case sending
    case succeed
    case failure
    case delivered
    case read
}


public let EaseChatUIKit_alert_message = "chatUIKit_alert_message"

public let EaseChatUIKit_user_card_message = "userCard"

@objc public protocol ChatService: NSObjectProtocol {
    
    /// Bind message changed listener
    /// - Parameter listener: ``ChatResponseListener``
    func bindChatEventsListener(listener: ChatResponseListener)
    
    /// Unbind message changed listener
    /// - Parameter listener: ``ChatResponseListener``
    func unbindChatEventsListener(listener: ChatResponseListener)
    
    /// Send message to someone.
    /// - Parameters:
    ///   - body: ``ChatMessage``
    ///   - completion: Callback, returns message if successful, returns error if failed
    func send(message: ChatMessage,completion: @escaping (ChatError?,ChatMessage?) -> Void)
    
    /// Edit text message content.
    /// - Parameters:
    ///   - messageId: ID of the message.
    ///   - text: Replacement king of ``String``.
    ///   - completion: Callback, returns message if successful, returns error if failed
    func edit(messageId: String,text: String,completion: @escaping (ChatError?,ChatMessage?) -> Void)
    
    /// Recall a message succeed.
    /// - Parameters:
    ///   - messageId: ID of the message.
    ///   - completion: Callback, returns message if successful, returns error if failed
    func recall(messageId: String,completion: @escaping (ChatError?) -> Void)

    /// Remove a message from database.
    /// - Parameter messageId: The id of the message.
    func removeLocalMessage(messageId: String)
    
    /// Remove all of the history messages from database.
    func removeHistoryMessages()
    
    /// Mark a message as already read state.
    /// - Parameter messageId: The id of the message.
    func markMessageAsRead(messageId: String)
    
    /// Mark all of the history messages as already read.
    func markAllMessagesAsRead()
    
    /// Load history messages.
    ///
    /// When loading local history the `messageId` anchor is used; when loading
    /// server history pagination is driven by the opaque `cursor` (``EMCursorResult/cursor``).
    /// - Parameters:
    ///   - messageId: The anchor message id.
    ///   - cursor: The opaque server pagination cursor from the previous page; pass `nil` for the first page (server history only).
    ///   - pageSize: The size number.
    ///   - searchMessage: `true` to fetch a page anchored at `messageId` (used to jump to a searched message).
    ///   - completion: Callback returning the messages and the next server cursor. The cursor is `nil` for local history or anchored searches; a nil/empty next cursor means the server has no more history.
    func loadMessages(start messageId: String,cursor: String?,pageSize: UInt,searchMessage: Bool,completion: @escaping (ChatError?,[ChatMessage],String?) -> Void)
    
    /// Load chat-thread messages from server.
    ///
    /// This method is stateless: the caller owns the pagination cursor and the "no more" flag. SDK 5.0
    /// pages server history with an opaque cursor (``EMCursorResult/cursor``).
    /// - Parameters:
    ///   - conversationId: The id of the ChatThread.
    ///   - cursor: The opaque pagination cursor from the previous page; pass `nil` to load the first page.
    ///   - pageSize: The size number.
    ///   - completion: Callback returning the messages and the next cursor. A nil/empty next cursor means the server has no more history.
    func fetchChatThreadHistoryMessages(conversationId: String, cursor: String?, pageSize: UInt, completion: @escaping (ChatError?,[ChatMessage],String?) -> Void)
    
    
    /// Search message from database.
    /// - Parameters:
    ///   - keyword: Search keyword.
    ///   - pageSize: The size number.
    ///   - userId: The id of the user.
    ///   - completion: Request a callback, returning an array of message objects if successful, or an error if failed
    func searchMessage(keyword: String,pageSize: UInt,userId: String,completion: @escaping (ChatError?,[ChatMessage]) -> Void)
    
    /// Translate the message text.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - completion: Request a callback, returning an array of message objects if successful, or an error if failed
    func translateMessage(message: ChatMessage,completion: @escaping (ChatError?,ChatMessage?) -> Void)
    
    /// Operation reaction api.
    /// - Parameters:
    ///   - reaction: ``String``
    ///   - message: ``ChatMessage``
    ///   - completion: Callback, returns error whether successful error is `nil`, or error occur.
    func reaction(reaction: String, message: ChatMessage, completion: @escaping (ChatError?) -> Void)
    
    /// Stickied a message on top.
    /// - Parameters:
    ///   - messageId: ID of the message.
    ///   - completion: Callback, returns error whether successful error is `nil`, or error occur.
    func pinMessage(messageId: String, completion: @escaping (ChatError?) -> Void)
    
    /// Remove the stickied message.
    /// - Parameters:
    ///   - messageId: ID of the message.
    ///   - completion: Callback, returns error whether successful error is `nil`, or error occur.
    func unpinMessage(messageId: String, completion: @escaping (ChatError?) -> Void)
    
    /// Get all of the stickied messages.
    /// - Parameters:
    ///   - conversationId: ID of the conversation.
    ///   - completion: Callback, returns an array of message objects if successful, or an error if failed
    func pinnedMessages(conversationId: String, completion: @escaping ([ChatMessage]?, ChatError?) -> Void)
}

@objc public protocol ChatResponseListener: NSObjectProtocol {
    
    /// When cmd message received.
    /// - Parameter message: ``ChatMessage``
    func onCMDMessageDidReceived(message: ChatMessage)
    
    /// When message received.
    /// - Parameter message: ``ChatMessage``
    func onMessageDidReceived(message: ChatMessage)
    
    /// When message recalled.
    /// - Parameter recallInfo: ``ChatMessage``
    func onMessageDidRecalled(recallInfo: RecallInfo)
    
    /// When message edited.
    /// - Parameter message: ``ChatMessage``
    func onMessageDidEdited(message: ChatMessage)
    
    /// When status of message changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - status: ``ChatMessageStatus``
    ///   - error: ``ChatError``
    func onMessageStatusDidChanged(message: ChatMessage,status: ChatMessageStatus,error: ChatError?)
    
    /// When status of message attachment changed.
    /// - Parameters:
    ///   - message: ``ChatMessage``
    ///   - error: ``ChatError``
    func onMessageAttachmentStatusChanged(message: ChatMessage,error: ChatError?)
    
    /// When reaction of message changed.
    /// - Parameter changes: ``MessageReactionChange``
    func onMessageReactionChanged(changes: [MessageReactionChange])
    
    /// When message stickied top the method called.
    /// - Parameters:
    ///   - conversationId: ID of the conversation
    ///   - messageId: ID of the message.
    ///   - operation: ``MessagePinOperation``
    ///   - info: ``MessagePinInfo``
    func onMessageStickiedTop(conversationId: String, messageId: String, operation: MessagePinOperation, info: MessagePinInfo)
    
    /// Update messages read state on received channel ack.
    /// - Parameter conversationId: The ID of the conversation.
    func messagesAlreadyRead(conversationId: String)
    
    
    /// When message read receipt received.
    /// - Parameter receipt: ``MessageReadReceipt`` array.
    func messageReadReceiptReceived(receipt: [MessageReadReceipt])
}
