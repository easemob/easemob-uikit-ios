//
//  ChatDataSyncListener.swift
//  EaseChatUIKit
//
//  Created by yangzilong on 2026/07/02.
//

import Foundation

/// A unified listener for data synchronization, dispatched by ``ChatUIKitClient``.
///
/// Only listeners whose ``interestedSyncType`` is contained in the SDK-reported sync type receive the
/// start/finish callbacks; ``onChatDatabaseOpened()`` is delivered to every listener because the local
/// database open makes all cached data queryable.
@objc public protocol ChatDataSyncListener: NSObjectProtocol {
    
    /// The data type this listener cares about, e.g. `.conversations` or `.contacts`.
    var interestedSyncType: DataSyncType { get }
    
    /// The local database has been opened.
    @objc optional func onChatDatabaseOpened()
    
    /// A synchronization for ``interestedSyncType`` has started.
    @objc optional func onChatDataSyncStart(type: DataSyncType)
    
    /// A synchronization for ``interestedSyncType`` has finished.
    /// - Parameter error: The error information. It is nil when the synchronization succeeded.
    @objc optional func onChatDataSyncFinished(error: ChatError?,type: DataSyncType)
}
