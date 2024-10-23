//
//  ReportOptionsController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/9/12.
//

import UIKit

@objc open class ReportOptionsController: UIViewController {
    
    public private(set) var items: [Bool] = []
    
    public private(set) var reportMessage: ChatMessage = ChatMessage()
    
    public private(set) var selectIndex = 0
    
    private var reportClosure: ((ChatError?) -> Void)?
    
    lazy var optionsList: UITableView = {
        UITableView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: Appearance.pageContainerConstraintsSize.height - 60 - 50 - BottomBarHeight), style: .grouped).separatorStyle(.none).rowHeight(54).tableFooterView(UIView()).delegate(self).dataSource(self).registerCell(ReportOptionCell.self, forCellReuseIdentifier: "ReportOptionCell").backgroundColor(.clear)
    }()
    
    lazy var cancel: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: 16, y: Appearance.pageContainerConstraintsSize.height - 60 - 40  - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).layerProperties(UIColor.theme.neutralColor7, 1).textColor(UIColor.theme.neutralColor3, .normal).title("report_button_click_menu_button_cancel".chat.localize, .normal).font(UIFont.theme.headlineSmall).cornerRadius(Appearance.avatarRadius).addTargetFor(self, action: #selector(cancelAction), for: .touchUpInside)
    }()
    
    lazy var confirm: UIButton = {
        UIButton(type: .custom).frame(CGRect(x: self.cancel.frame.maxX+12, y: Appearance.pageContainerConstraintsSize.height - 60 - 40  - BottomBarHeight, width: (self.view.frame.width-44)/2.0, height: 40)).title("barrage_long_press_menu_report".chat.localize, .normal).textColor(UIColor.theme.neutralColor98, .normal).backgroundColor(UIColor.theme.primaryLightColor).cornerRadius(Appearance.avatarRadius).addTargetFor(self, action: #selector(report), for: .touchUpInside)
    }()
    
    /// Init method
    /// - Parameter message: Reported message.
    @objc public required convenience init(message: ChatMessage,completion: @escaping (ChatError?) -> Void) {
        self.init()
        self.reportClosure = completion
        self.reportMessage = message
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.items = Appearance.chat.reportSelectionReasons.map({ $0 == "violation_reason_1".chat.localize })
        self.view.backgroundColor(.clear)
        self.view.addSubViews([self.optionsList,self.cancel,self.confirm])
        self.switchTheme(style: Theme.style)
    }

}

extension ReportOptionsController: UITableViewDelegate,UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "Violation options".chat.localize
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Appearance.chat.reportSelectionReasons.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ReportOptionCell") as? ReportOptionCell
        if cell == nil {
            cell = ReportOptionCell(style: .default, reuseIdentifier: "ReportOptionCell")
        }
        cell?.selectionStyle = .none
        cell?.refresh(select: self.items[safe: indexPath.row] ?? false,title: Appearance.chat.reportSelectionReasons[safe: indexPath.row] ?? "")
        return cell ?? ReportOptionCell()
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
        self.items.removeAll()
        self.items = Array(repeating: false, count: Appearance.chat.reportSelectionReasons.count)
        self.items[indexPath.row] = true
        self.selectIndex = indexPath.row
        self.optionsList.reloadData()
    }
    
    @objc open func report() {
        ChatClient.shared().chatManager?.reportMessage(withId: self.reportMessage.messageId, tag: Appearance.chat.reportSelectionTags[safe: self.selectIndex] ?? "", reason: Appearance.chat.reportSelectionReasons[safe: self.selectIndex] ?? "",completion: { [weak self] error in
            self?.reportClosure?(error)
        })
        
    }
    
    @objc open func cancelAction() {
        self.reportClosure?(nil)
        self.dismiss(animated: true)
    }
}

extension ReportOptionsController: ThemeSwitchProtocol {
    public func switchTheme(style: ThemeStyle) {
        self.optionsList.reloadData()
    }
    
}
