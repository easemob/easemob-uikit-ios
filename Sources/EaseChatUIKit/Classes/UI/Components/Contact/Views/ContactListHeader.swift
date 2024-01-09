//
//  ContactListHeader.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/11/20.
//

import UIKit

@objc open class ContactListHeader: UITableView {
        
    @UserDefault("EaseChatUIKit_contact_new_request", defaultValue: Dictionary<String,Double>()) private var newFriends
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        self.isScrollEnabled = false
        self.tableFooterView(UIView()).dataSource(self).delegate(self).separatorStyle(.none).rowHeight(Appearance.contact.headerRowHeight).registerCell(ContactListHeaderCell.self, forCellReuseIdentifier: "ContactListHeaderCell").showsVerticalScrollIndicator(false)
        self.refresh()
    }

    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc public func refresh() {
        for item in Appearance.contact.listExtensionActions {
            if item.featureIdentify == "NewFriendRequest" {
                item.showBadge = !self.newFriends.isEmpty
                item.showNumber = !self.newFriends.isEmpty
                item.numberCount = UInt(self.newFriends.count)
            }
        }
        self.reloadData()
    }
}

extension ContactListHeader: UITableViewDelegate,UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Appearance.contact.listExtensionActions.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ContactListHeaderCell") as? ContactListHeaderCell else { return ContactListHeaderCell(style: .default, reuseIdentifier: "ContactListHeaderCell") }
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        if let item = Appearance.contact.listExtensionActions[safe: indexPath.row] {
            cell.refresh(item: item)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let item = Appearance.contact.listExtensionActions[safe: indexPath.row] {
            Appearance.contact.listExtensionActions[safe: indexPath.row]?.actionClosure?(item)
        }
    }
}
