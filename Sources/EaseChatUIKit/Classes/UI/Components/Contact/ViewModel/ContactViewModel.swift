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
    public func bind(driver: IContactListDriver) {
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
    
    @objc public func loadAllContacts() {
        self.service?.contacts(completion: { [weak self] error, contacts in
            if error == nil {
                self?.driver?.refreshList(infos: self?.filterContacts(contacts: contacts) ?? [])
            } else {
                self?.driver?.occurError()
                consoleLogInfo("loadAllContacts error:\(error?.errorDescription ?? "")", type: .error)
            }
        })
    }
    
    private func filterContacts(contacts: [Contact]) -> [EaseProfileProtocol] {
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
        let profile = EaseProfile()
        profile.id = userId
        self.driver?.appendThenRefresh(info: profile)
    }
    
    public func friendRequestDidDecline(by userId: String) {
        
    }
    
    public func friendshipDidRemove(by userId: String) {
        let profile = EaseProfile()
        profile.id = userId
        self.driver?.remove(info: profile)
    }
    
    public func friendshipDidAddSuccessful(by userId: String) {
        self.newFriends.removeValue(forKey: userId)
        self.addContact()
    }
    
    public func friendRequestDidReceive(by userId: String) {
        self.newFriends[userId] = Date().timeIntervalSince1970
        if let index = Appearance.contact.listExtensionActions.firstIndex(where: { $0.featureIdentify == "NewFriendRequest" }) {
            let item = Appearance.contact.listExtensionActions[index]
            item.showBadge = true
            item.numberCount = UInt(self.newFriends.count)
            self.driver?.refreshHeader(info: item)
        }
    }
    
    
}

extension ContactViewModel: MultiDeviceListener {
    
    public func onContactsEventDidChanged(event: MultiDeviceEvent, userId: String, extension info: String) {
        switch event {
        case .contactAccept:
            if self.newFriends.count > 0 {
                self.newFriends.removeValue(forKey: userId)
            }
            self.addContact()
        case .contactRemove:
            let profile = EaseProfile()
            profile.id = userId
            self.driver?.remove(info: profile)
        default:
            break
        }
    }
    
    @objc private func addContact() {
        if let item = Appearance.contact.listExtensionActions.first(where: { $0.featureIdentify == "NewFriendRequest" }) {
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
