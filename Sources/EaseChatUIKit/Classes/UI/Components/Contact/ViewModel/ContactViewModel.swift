//
//  ContactViewModel.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/21.
//

import UIKit

/// Bind service and driver
@objc open class ContactViewModel: NSObject {
    
    public private(set) var ignoreContacts: [String] = []
    
    @objc public var viewContact: ((ChatUserProfileProtocol) -> Void)?
    
    public var notifySelf = false
    
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Array<Dictionary<String,Any>>>()) private var newFriends
    
    
    /// ``ContactViewModel`` init method.
    ///   -  ignoreIds: Array of contact ids that already exist in the group.
    @objc(ignoreIds:)
    public required init(ignoreIds: [String] = []) {
        self.ignoreContacts = ignoreIds
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(addFriendRefreshList), name: Notification.Name("New Friend Chat"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadAllContacts), name: Notification.Name(rawValue: cache_update_notification), object: nil)
    }
    
    public private(set) weak var driver: IContactListDriver?
        
    public private(set) var service: ContactServiceProtocol?
    
    public private(set) var multiService: MultiDeviceService?
        
    /// Bind UI driver and service
    /// - Parameters:
    ///   - driver: The object of conform``IContactListDriver``.
    @objc(bindWithDriver:)
    open func bind(driver: IContactListDriver) {
        self.driver = driver
        if self.service == nil {
            self.service = ContactServiceImplement()
        }
        if self.multiService == nil {
            self.multiService = MultiDeviceServiceImplement()
        }
        self.service?.unbindContactEventListener(listener: self)
        self.service?.bindContactEventListener(listener: self)
        self.multiService?.unbindMultiDeviceListener(listener: self)
        self.multiService?.bindMultiDeviceListener(listener: self)
        self.driver?.addActionHandler(actionHandler: self)
        self.loadAllContacts()
    }
    
    /// Register to monitor when certain emergencies occur
    /// - Parameter listener: ``ContactEmergencyListener``
    @objc public func registerEventsListener(_ listener: ContactEmergencyListener) {
        if self.service == nil {
            self.service = ContactServiceImplement()
        }
        self.service?.registerEmergencyListener(listener: listener)
    }
    
    /// When you don’t want to listen to the registered events above, you can use this method to clear the registration.
    /// - Parameter listener: ``ContactEmergencyListener``
    @objc public func unregisterEventsListener(_ listener: ContactEmergencyListener) {
        if self.service == nil {
            self.service = ContactServiceImplement()
        }
        self.service?.unregisterEmergencyListener(listener: listener)
    }
    
    @objc open func addFriendRefreshList() {
        self.service?.contacts(completion: { [weak self] error, contacts in
            if error == nil {
                if let infos = self?.filterContacts(contacts: contacts) {
                    self?.driver?.refreshList(infos: infos)
                    if infos.count < 7 {
                        self?.requestDisplayInfos(ids: infos.map({ $0.id }))
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.3) {
                        self?.notifySelf = false
                    }
                }
            } else {
                self?.driver?.occurError()
                consoleLogInfo("loadAllContacts error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    @objc open func loadAllContacts() {
        if self.notifySelf {
            return
        }
        self.service?.contacts(completion: { [weak self] error, contacts in
            if error == nil {
                if let infos = self?.filterContacts(contacts: contacts) {
                    self?.driver?.refreshList(infos: infos)
                    if infos.count < 7 {
                        self?.requestDisplayInfos(ids: infos.map({ $0.id }))
                    }
                    DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.3) {
                        self?.notifySelf = false
                    }
                }
            } else {
                self?.driver?.occurError()
                consoleLogInfo("loadAllContacts error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    @objc open func filterContacts(contacts: [Contact]) -> [ChatUserProfileProtocol] {
        var users = [Contact]()
        if self.ignoreContacts.isEmpty {
            users.append(contentsOf: contacts)
        } else {
            for contact in contacts {
                if !self.ignoreContacts.contains(where: { $0 == contact.userId }) {
                    users.append(contact)
                }
            }
        }
        let infos = users.map({
            let profile = ChatUserProfile()
            profile.id = $0.userId
            profile.nickname = ChatUIKitContext.shared?.userCache?[$0.userId]?.nickname ?? ""
            profile.avatarURL = ChatUIKitContext.shared?.userCache?[$0.userId]?.avatarURL ?? ""
            var remark = $0.remark ?? ""
            if remark.isEmpty {
                remark = ChatUIKitContext.shared?.userCache?[$0.userId]?.remark ?? ""
            }
            profile.remark = remark
            ChatUIKitContext.shared?.userCache?[$0.userId]?.remark = remark
            return profile
        })
        self.notifySelf = true
        ChatUIKitContext.shared?.updateCaches(type: .user, profiles: infos)
        return infos
    }
    
    @objc open func notifyCleanNewFriendRequestBadge() {
        let oldFriends = self.newFriends[saveIdentifier] ?? [Dictionary<String,Any>]()
        var friends = [Dictionary<String,Any>]()
        for friend in oldFriends {
            let requestInfo: [String:Any] = ["userId":friend["userId"] ?? "","timestamp":friend["timestamp"] ?? Date().timeIntervalSince1970*1000,"groupApply":friend["groupApply"] ?? 0,"read":1]
            friends.append(requestInfo)
        }
        
        self.newFriends[saveIdentifier]?.removeAll()
        self.newFriends[saveIdentifier] = friends
        if let implement = self.service as? ContactServiceImplement {
            implement.handleResult(error: nil, type: .cleanFriendBadge, operatorId: ChatUIKitContext.shared?.currentUserId ?? "")
        }
    }
}

extension ContactViewModel: ContactEventsResponse {
    public func friendRequestDidAgree(by userId: String) {
        self.processFriendDidAgree(userId: userId)
    }
    
    @objc open func processFriendDidAgree(userId: String) {
        let profile = ChatUserProfile()
        profile.id = userId
        self.driver?.appendThenRefresh(info: profile)
    }
    
    public func friendRequestDidDecline(by userId: String) {
        self.processFriendRequestDidDecline(userId: userId)
    }
    
    @objc open func processFriendRequestDidDecline(userId: String) {
        
    }
    
    public func friendshipDidRemove(by userId: String) {
        self.processFriendshipDidRemove(userId: userId)
    }
    
    @objc open func processFriendshipDidRemove(userId: String) {
        let profile = ChatUserProfile()
        profile.id = userId
        self.driver?.remove(info: profile)
    }
    
    public func friendshipDidAddSuccessful(by userId: String) {
        self.processFriendshipDidAddSuccessful(userId: userId)
    }
    
    @objc open func processFriendshipDidAddSuccessful(userId: String) {
        self.addContact(userId: userId)
    }
    
    public func friendRequestDidReceive(by userId: String) {
        self.processFriendRequestDidReceive(userId: userId)
    }
    
    @objc open func processFriendRequestDidReceive(userId: String) {
        let requestInfo: [String:Any] = ["userId":userId,"timestamp":Date().timeIntervalSince1970*1000,"groupApply":0,"read":0]
        var exist = self.newFriends[saveIdentifier]
        if exist == nil {
            self.newFriends[saveIdentifier] = [requestInfo]
        } else {
            if exist?.first(where: { $0["userId"] as? String == userId }) == nil {
                exist?.append(requestInfo)
                self.newFriends[saveIdentifier] = exist
            }
        }
        if let index = Appearance.contact.listHeaderExtensionActions.firstIndex(where: { $0.featureIdentify == "NewFriendRequest" }) {
            let item = Appearance.contact.listHeaderExtensionActions[index]
            item.showBadge = true
            let unreadCount = self.newFriends[saveIdentifier]?.filter({ $0["read"] as? Int == 0 }).count ?? 0
            item.numberCount = UInt(unreadCount)
            self.driver?.refreshHeader(info: item)
        }
    }
}

extension ContactViewModel: MultiDeviceListener {
    
    public func onContactsEventDidChanged(event: MultiDeviceEvent, userId: String, extension info: String) {
        self.contactEventDidChanged(event: event, userId: userId, extension: info)
    }
    
    @objc open func contactEventDidChanged(event: MultiDeviceEvent, userId: String, extension info: String) {
        switch event {
        case .contactAccept:
            self.addContact(userId: userId)
        case .contactRemove:
            let profile = ChatUserProfile()
            profile.id = userId
            self.driver?.remove(info: profile)
        default:
            break
        }
    }
    
    @objc open func addContact(userId: String) {
        self.newFriends[saveIdentifier]?.removeAll { ($0["userId"] as? String) ?? "" == userId }
        
        if let item = Appearance.contact.listHeaderExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
            let unreadCount = self.newFriends[saveIdentifier]?.filter { $0["read"] as? Int == 0 }.count ?? 0
            item.numberCount = UInt(unreadCount)
            self.driver?.refreshHeader(info: item)
        }
        self.addFriendRefreshList()
    }
    
}

extension ContactViewModel: ContactListActionEventsDelegate {
    public func onContactListScroll(indexPath: IndexPath) {
        
    }
    
    public func onContactListOccurErrorWhenFetchServer() {
        self.loadAllContacts()
    }
    
    public func onContactListEndScrollNeededDisplayInfos(ids: [String]) {
        self.requestDisplayInfos(ids: ids)
    }
    
    @objc open func requestDisplayInfos(ids: [String]) {
        if ChatUIKitContext.shared?.userProfileProvider != nil {
            Task(priority: .background) { [weak self] in
                guard let `self` = self else { return }
                let profiles = await ChatUIKitContext.shared?.userProfileProvider?.fetchProfiles(profileIds: ids) ?? []
                self.cacheProfiles(profiles: profiles)
                DispatchQueue.main.async {
                    self.driver?.refreshProfiles(infos: profiles)
                }
            }
        }
        if ChatUIKitContext.shared?.userProfileProviderOC != nil {
            ChatUIKitContext.shared?.userProfileProviderOC?.fetchProfiles(profileIds: ids, completion: {[weak self] profiles in
                self?.cacheProfiles(profiles: profiles)
                self?.driver?.refreshProfiles(infos: profiles)
            })

        }
    }
    
    @objc open func cacheProfiles(profiles: [ChatUserProfileProtocol]) {
        for profile in profiles {
            ChatUIKitContext.shared?.userCache?[profile.id]?.nickname = profile.nickname
            ChatUIKitContext.shared?.userCache?[profile.id]?.remark = profile.remark
            ChatUIKitContext.shared?.userCache?[profile.id]?.avatarURL = profile.avatarURL
        }
    }
    
    public func didSelected(indexPath: IndexPath, profile: ChatUserProfileProtocol) {
         self.viewContact?(profile)
    }
    
}
