//
//  ContactViewModel.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/21.
//

import UIKit

/// Bind service and driver
@objc open class ContactViewModel: NSObject {
    
    public private(set) var ignoreContacts: [String] = []
    
    @objc public var viewContact: ((EaseProfileProtocol) -> Void)?
    
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Double>()) private var newFriends
    
    private weak var provider_OC: EaseProfileProviderOC?
    
    private var provider: EaseProfileProvider?
    
    /// ``ContactViewModel`` init method.
    /// - Parameter providerOC: Only available in Objective-C language.
    ///   -  ignoreIds: Array of contact ids that already exist in the group.
    @objc(initWithProviderOC:ignoreIds:)
    public required init(providerOC: EaseProfileProviderOC?,ignoreIds: [String] = []) {
        self.provider_OC = providerOC
        self.ignoreContacts = ignoreIds
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(addContact), name: NSNotification.Name("New Friend Chat"), object: nil)
    }
    
    /// ``ContactViewModel`` init method.
    /// - Parameter providerOC: Only available in Swift language.
    ///   - ignoreIds: Array of contact ids that already exist in the group.
    public required init(provider: EaseProfileProvider?,ignoreIds: [String] = []) {
        self.provider = provider
        self.ignoreContacts = ignoreIds
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(addContact), name: NSNotification.Name("New Friend Chat"), object: nil)
    }
    
    public private(set) weak var driver: IContactListDriver?
        
    public private(set) var service: ContactServiceProtocol? = ContactServiceImplement()
    
    public private(set) var multiService: MultiDeviceService?  = MultiDeviceServiceImplement()
        
    /// Bind UI driver and service
    /// - Parameters:
    ///   - driver: The object of conform``IContactListDriver``.
    @objc(bindWithDriver:)
    open func bind(driver: IContactListDriver) {
        self.driver = driver
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
        self.service?.registerEmergencyListener(listener: listener)
    }
    
    /// When you don’t want to listen to the registered events above, you can use this method to clear the registration.
    /// - Parameter listener: ``ContactEmergencyListener``
    @objc public func unregisterEventsListener(_ listener: ContactEmergencyListener) {
        self.service?.unregisterEmergencyListener(listener: listener)
    }
    
    @objc open func loadAllContacts() {
        self.service?.contacts(completion: { [weak self] error, contacts in
            if error == nil {
                self?.driver?.refreshList(infos: self?.filterContacts(contacts: contacts) ?? [])
            } else {
                self?.driver?.occurError()
                consoleLogInfo("loadAllContacts error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    @objc open func filterContacts(contacts: [Contact]) -> [EaseProfileProtocol] {
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
            let profile = EaseProfile()
            profile.id = $0.userId
            profile.nickname = EaseChatUIKitContext.shared?.contactsCache?[$0.userId]?.nickname ?? ""
            profile.avatarURL = EaseChatUIKitContext.shared?.contactsCache?[$0.userId]?.avatarURL ?? ""
            return profile
        })
        return infos
    }
}

extension ContactViewModel: ContactEventsResponse {
    public func friendRequestDidAgree(by userId: String) {
        self.processFriendDidAgree(userId: userId)
    }
    
    @objc open func processFriendDidAgree(userId: String) {
        let profile = EaseProfile()
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
        let profile = EaseProfile()
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
        self.newFriends[userId] = Date().timeIntervalSince1970
        if let index = Appearance.contact.listHeaderExtensionActions.firstIndex(where: { $0.featureIdentify == "NewFriendRequest" }) {
            let item = Appearance.contact.listHeaderExtensionActions[index]
            item.showBadge = true
            item.numberCount = UInt(self.newFriends.count)
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
            let profile = EaseProfile()
            profile.id = userId
            self.driver?.remove(info: profile)
        default:
            break
        }
    }
    
    @objc open func addContact(userId: String) {
        if self.newFriends.count > 0,let _ = self.newFriends[userId] {
            self.newFriends.removeValue(forKey: userId)
        }
        if let item = Appearance.contact.listHeaderExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
            if item.numberCount > 1 {
                item.numberCount -= 1
            }
            self.driver?.refreshHeader(info: item)
        }
        self.loadAllContacts()
    }
    
}

extension ContactViewModel: ContactListActionEventsDelegate {
    public func onContactListScroll(indexPath: IndexPath) {
        
    }
    
    public func onContactListOccurErrorWhenFetchServer() {
        self.loadAllContacts()
    }
    
    public func onContactListEndScrollNeededDisplayInfos(ids: [String]) {
        if self.provider_OC != nil {
            let infoMap_OC = [2:ids]
            self.provider_OC?.fetchProfiles(profilesMap: infoMap_OC, completion: { [weak self] profiles in
                for profile in profiles {
                    EaseChatUIKitContext.shared?.contactsCache?[profile.id] = profile
                }
                self?.driver?.refreshProfiles(infos: profiles)
            })
        }
        if self.provider != nil {
            let infoMap = [EaseProfileProviderType.contact:ids]
            Task(priority: .background) {
                let profiles = await self.provider?.fetchProfiles(profilesMap: infoMap) ?? []
                for profile in profiles {
                    EaseChatUIKitContext.shared?.contactsCache?[profile.id] = profile
                }
                DispatchQueue.main.async {
                    self.driver?.refreshProfiles(infos: profiles)
                }
            }
        }
    }
    
    
    public func didSelected(indexPath: IndexPath, profile: EaseProfileProtocol) {
         self.viewContact?(profile)
    }
    
}
