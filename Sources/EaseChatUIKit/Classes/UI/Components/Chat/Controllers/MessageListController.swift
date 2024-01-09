import UIKit
import MobileCoreServices
import QuickLook
import AVFoundation

@objc public enum ChatType: UInt {
    case chat
    case group
    case chatroom
    case thread
}

@objcMembers open class MessageListController: UIViewController {
    
    public var filePath = ""
    
    private var chatType = ChatType.chat
    
    public private(set) var profile: EaseProfileProtocol = EaseProfile()
    
    public private(set) lazy var navigation: EaseChatNavigationBar = {
         EaseChatNavigationBar(showLeftItem: true,rightImages: [UIImage(named: "audio_call", in: .chatBundle, with: nil)!,UIImage(named: "video_call", in: .chatBundle, with: nil)!]).backgroundColor(.clear)
    }()
    
    public private(set) lazy var messageContainer: MessageListView = {
        MessageListView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: ScreenHeight-NavigationHeight), mention: self.chatType == .group)
    }()
    
    public private(set) lazy var loadingView: LoadingView = {
        LoadingView(frame: self.view.bounds)
    }()
    
    public private(set) lazy var viewModel: MessageListViewModel = { MessageListViewModel(conversationId: self.profile.id, type: self.chatType) }()
    
    @objc(initWithConversationId:chatType:)
    public required init(conversationId: String,chatType: ChatType = .chat) {
        if let info = EaseChatUIKitContext.shared?.conversationsCache?[conversationId] {
            self.profile = info
        } else {
            self.profile.id = conversationId
        }
        switch chatType {
        case .group,.thread:
            self.chatType = .group
        case .chat:
            self.chatType = .chat
        default:
            self.chatType = .chatroom
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewIsAppearing(_ animated: Bool) {
        super.viewIsAppearing(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
     }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AudioTools.shared.stopPlaying()
        self.messageContainer.messages.forEach { $0.playing = false }
        self.messageContainer.messageList.reloadData()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.theme.neutralColor98
        self.navigation.subtitle = "online"
        self.navigation.title = self.profile.nickname.isEmpty ? self.profile.id:self.profile.nickname
        self.view.addSubViews([self.navigation,self.messageContainer])
        self.navigation.clickClosure = { [weak self] in
            self?.navigationClick(type: $0, indexPath: $1)
        }
        
        self.viewModel.bindDriver(driver: self.messageContainer)
        self.viewModel.addEventsListener(self)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.view.addSubview(self.loadingView)
    }
}

extension MessageListController {
    
    private func navigationClick(type: EaseChatNavigationBarClickEvent,indexPath: IndexPath?) {
        switch type {
        case .back: self.pop()
        case .avatar,.title: self.viewDetail()
        case .rightItems: self.rightItemsAction(indexPath: indexPath)
        default:
            break
        }
    }
    
    private func viewDetail() {
        if let count = self.navigationController?.viewControllers.count {
            if let previous = self.navigationController?.viewControllers[safe: count - 2] {
                if previous is GroupInfoViewController || previous is ContactInfoViewController {
                    self.pop()
                } else {
                    if self.chatType == .chat {
                        let vc = ComponentsRegister.shared.ContactInfoController.init(profile: self.profile)
                        ControllerStack.toDestination(vc: vc)
                    } else {
                        let vc = ComponentsRegister.shared.GroupInfoController.init(group: self.profile.id) { [weak self] id, name in
                            self?.navigation.title = name
                        }
                        ControllerStack.toDestination(vc: vc)
                    }
                }
            } else {
                if self.chatType == .chat {
                    let vc = ComponentsRegister.shared.ContactInfoController.init(profile: self.profile)
                    ControllerStack.toDestination(vc: vc)
                } else {
                    let vc = ComponentsRegister.shared.GroupInfoController.init(group: self.profile.id) { [weak self] id, name in
                        self?.navigation.title = name
                    }
                    ControllerStack.toDestination(vc: vc)
                }
            }
        } else {
            if let presentingVC = self.presentingViewController {
                if presentingVC is GroupInfoViewController || presentingVC is ContactInfoViewController {
                    presentingVC.dismiss(animated: false)
                } else {
                    if self.chatType == .chat {
                        let vc = ComponentsRegister.shared.ContactInfoController.init(profile: self.profile)
                        ControllerStack.toDestination(vc: vc)
                    } else {
                        let vc = ComponentsRegister.shared.GroupInfoController.init(group: self.profile.id) { [weak self] id, name in
                            self?.navigation.title = name
                        }
                        ControllerStack.toDestination(vc: vc)
                    }
                }
            } else {
                if self.chatType == .chat {
                    let vc = ComponentsRegister.shared.ContactInfoController.init(profile: self.profile)
                    ControllerStack.toDestination(vc: vc)
                } else {
                    let vc = ComponentsRegister.shared.GroupInfoController.init(group: self.profile.id) { [weak self] id, name in
                        self?.navigation.title = name
                    }
                    ControllerStack.toDestination(vc: vc)
                }
            }
        }
        
    }
    
    private func rightItemsAction(indexPath: IndexPath?) {
//        switch indexPath?.row {
//        case <#pattern#>:
//            <#code#>
//        default:
//            <#code#>
//        }
    }
    
    private func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }

    
    
}

//MARK: - MessageListDriverEventsListener
extension MessageListController: MessageListDriverEventsListener {
    public func onMessageWillSendFillExtensionInfo() -> Dictionary<String, Any> {
        //Insert extension info before sending message.
        [:]
    }
    
    
    private func filterMessageActions(message: ChatMessage) -> [ActionSheetItemProtocol] {
        var messageActions = Appearance.chat.messageLongPressedActions
        if message.body.type != .text {
            messageActions.removeAll { $0.tag == "Copy" }
            messageActions.removeAll { $0.tag == "Edit" }
        } else {
            if message.direction != .send {
                messageActions.removeAll { $0.tag == "Edit" }
            } else {
                if message.status != .succeed {
                    messageActions.removeAll { $0.tag == "Edit" }
                }
            }
        }
        if message.direction != .send {
            messageActions.removeAll { $0.tag == "Recall" }
        } else {
            let duration = UInt(abs(Double(Date().timeIntervalSince1970) - Double(message.timestamp/1000)))
            if duration > Appearance.chat.recallExpiredTime {
                messageActions.removeAll { $0.tag == "Recall" }
            }
        }
        return messageActions
    }
    
    public func onMessageBubbleLongPressed(message: ChatMessage) {
        DialogManager.shared.showMessageActions(actions: self.filterMessageActions(message: message)) { [weak self] item in
            self?.processMessage(item: item, message: message)
        }
    }
    
    private func processMessage(item: ActionSheetItemProtocol,message: ChatMessage) {
        UIViewController.currentController?.dismiss(animated: true)
        switch item.tag {
        case "Copy":
            self.viewModel.processMessage(operation: .copy, message: message, edit: "")
        case "Edit":
            self.editAction(message: message)
        case "Reply":
            self.viewModel.processMessage(operation: .reply, message: message)
        case "Recall":
            self.viewModel.processMessage(operation: .recall, message: message)
        case "Delete":
            self.viewModel.processMessage(operation: .delete, message: message)
        case "Report":
            self.reportAction(message: message)
        default:
            item.action?(item,message)
            break
        }
    }
    
    private func editAction(message: ChatMessage) {
        if let body = message.body as? ChatTextMessageBody {
            let editor = MessageEditor(content: body.text) { text in
                self.viewModel.processMessage(operation: .edit, message: message, edit: text)
                UIViewController.currentController?.dismiss(animated: true)
            }
            DialogManager.shared.showCustomDialog(customView: editor,dismiss: true)
        }
    }
    
    private func reportAction(message: ChatMessage) {
        DialogManager.shared.showReportDialog(message: message) { error in
            
        }
    }
    
    public func onMessageAttachmentLoading(loading: Bool) {
        if loading {
            self.loadingView.startAnimating()
        } else {
            self.loadingView.stopAnimating()
        }
    }
    
    public func onMessageBubbleClicked(message: ChatMessage) {

        switch message.body.type {
        case .file,.video,.image:
            if let body = message.body as? ChatFileMessageBody {
                self.filePath = body.localPath ?? ""
            }
            self.openFile()
        case .custom:
            if let body = message.body as? ChatCustomMessageBody {
                self.viewContact(body: body)
            }
        default:
            break
        }
    }
    
    public func viewContact(body: ChatCustomMessageBody) {
        var userId = body.customExt?["userId"] as? String
        if userId == nil {
            userId = body.customExt?["uid"] as? String
        }
        let avatarURL = body.customExt?["avatar"] as? String
        let nickname = body.customExt?["nickname"] as? String
        if body.event == EaseChatUIKit_user_card_message {
            let profile = EaseProfile()
            profile.id = userId ?? ""
            profile.nickname = nickname ?? profile.id
            profile.avatarURL = avatarURL ?? ""
            let vc = ComponentsRegister.shared.ContactInfoController.init(profile: profile)
            ControllerStack.toDestination(vc: vc)
        }
    }
    
    public func onMessageAvatarClicked(user: EaseProfileProtocol) {
        if user.id == EaseChatUIKitContext.shared?.currentUserId ?? "" {
            return
        }
        let vc = ComponentsRegister.shared.ContactInfoController.init(profile: user)
        ControllerStack.toDestination(vc: vc)
    }
    
    public func onInputBoxEventsOccur(action type: MessageInputBarActionType, attributeText: NSAttributedString?) {
        switch type {
        case .audio: self.audioDialog()
        case .mention:  self.mentionAction()
        case .attachment: self.attachmentDialog()
        default:
            break
        }
    }
    
    private func audioDialog() {
        AudioTools.shared.stopPlaying()
        let audioView = MessageAudioRecordView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200)) { [weak self] url, duration in
            UIViewController.currentController?.dismiss(animated: true)
            self?.viewModel.sendMessage(text: url.path, type: .voice, extensionInfo: ["duration":duration])
        } trashClosure: {
            
        }

        DialogManager.shared.showCustomDialog(customView: audioView,dismiss: false)
    }
    
    private func mentionAction() {
        let vc = ComponentsRegister.shared.GroupParticipantController.init(groupId: self.profile.id, operation: .mention)
        vc.mentionClosure = { [weak self] in
            self?.viewModel.updateMentionIds(profile: $0, type: .add)
        }
        self.present(vc, animated: true)
    }
    
    private func attachmentDialog() {
        DialogManager.shared.showActions(actions: Appearance.chat.inputExtendActions) { [weak self] item in
            self?.handleAttachmentAction(item: item)
        }
    }
    
    private func handleAttachmentAction(item: ActionSheetItemProtocol) {
        switch item.tag {
        case "File": self.selectFile()
        case "Photo": self.selectPhoto()
        case "Camera": self.openCamera()
        case "Contact": self.selectContact()
        default:
            break
        }
    }
    
    private func selectPhoto() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            DialogManager.shared.showAlert(title: "permissions disable".chat.localize, content: "photo_disable".chat.localize, showCancel: false, showConfirm: true) { _ in
                
            }
            return
        }
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    private func openCamera() {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            DialogManager.shared.showAlert(title: "permissions disable".chat.localize, content: "camera_disable".chat.localize, showCancel: false, showConfirm: true) { _ in
                
            }
            return
        }
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        imagePicker.videoMaximumDuration = 20
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    private func selectFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content", "public.text", "public.source-code", "public.image", "public.jpeg", "public.png", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt","public.data"], in: .open)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    private func selectContact() {
        let vc = ComponentsRegister.shared.ContactsController.init(headerStyle: .shareContact,provider: nil)
        vc.confirmClosure = { profiles in
            vc.dismiss(animated: true) {
                if let user = profiles.first {
                    DialogManager.shared.showAlert(title: "Share Contact".chat.localize, content: "Share Contact".chat.localize+"`\(user.nickname.isEmpty ? user.id:user.nickname)`?", showCancel: true, showConfirm: true) { [weak self] _ in
                        self?.viewModel.sendMessage(text: EaseChatUIKit_user_card_message, type: .contact,extensionInfo: ["uid":user.id,"avatar":user.avatarURL,"nickname":user.nickname])
                    }
                    
                }
            }
        }
        self.present(vc, animated: true)
    }
    
    private func openFile() {
        let previewController = QLPreviewController()
        previewController.dataSource = self
        self.navigationController?.pushViewController(previewController, animated: true)
    }
}

//MARK: - UIImagePickerControllerDelegate&UINavigationControllerDelegate
extension MessageListController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String
        if mediaType == kUTTypeMovie as String {
            guard let videoURL = info[.mediaURL] as? URL else { return }
            guard let url = MediaConvertor.videoConvertor(videoURL: videoURL) else { return }
            let fileName = url.lastPathComponent
            let fileURL = URL(fileURLWithPath: MediaConvertor.filePath()+"/\(fileName)")
            if FileManager.default.fileExists(atPath: url.path) {
                do {
                    try Data(contentsOf: url).write(to: fileURL)
                } catch {
                    consoleLogInfo("write video error:\(error.localizedDescription)", type: .error)
                }
            }
            let duration = AVURLAsset(url: fileURL).duration.value 
            self.viewModel.sendMessage(text: fileURL.path, type: .video,extensionInfo: ["duration":duration])
        } else {
            if let imageURL = info[.imageURL] as? URL {
                let fileName = imageURL.lastPathComponent
                let fileURL = URL(fileURLWithPath: MediaConvertor.filePath()+"/\(fileName)")
                do {
                    let image = UIImage(contentsOfFile: fileURL.path)?.fixOrientation()
                    try image?.jpegData(compressionQuality: 1)?.write(to: fileURL)
                } catch {
                    consoleLogInfo("write fixOrientation image error:\(error.localizedDescription)", type: .error)
                }
                self.viewModel.sendMessage(text: fileURL.path, type: .image)
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK: - UIDocumentPickerDelegate
extension MessageListController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.open {
            guard let selectedFileURL = urls.first else {
                return
            }
            if selectedFileURL.startAccessingSecurityScopedResource() {
                let fileURL = URL(fileURLWithPath: MediaConvertor.filePath()+"/\(selectedFileURL.lastPathComponent)")
                do {
                    try Data(contentsOf: selectedFileURL).write(to: fileURL)
                } catch {
                    consoleLogInfo("write file error:\(error.localizedDescription)", type: .error)
                }
                self.viewModel.sendMessage(text: fileURL.path, type: .file)
                selectedFileURL.stopAccessingSecurityScopedResource()
            } else {
                DialogManager.shared.showAlert(title: "permissions disable".chat.localize, content: "file_disable".chat.localize, showCancel: false, showConfirm: true) { _ in
                    
                }
            }
        }
        
    }
    
    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        
    }
    
}

extension MessageListController: QLPreviewControllerDataSource {
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }
    
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        let fileURL = URL(fileURLWithPath: self.filePath)
        return fileURL as QLPreviewItem
    }
    
    
}
//MARK: - ThemeSwitchProtocol
extension MessageListController: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        var images = [UIImage(named: "audio_call", in: .chatBundle, with: nil)!,UIImage(named: "video_call", in: .chatBundle, with: nil)!]
        if style == .light {
            images = images.map({ $0.withTintColor(UIColor.theme.neutralColor3) })
        }
        self.navigation.updateRightItems(images: images)
    }
    
}
