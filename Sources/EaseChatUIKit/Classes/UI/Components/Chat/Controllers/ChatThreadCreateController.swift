//
//  ChatThreadCreateController.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/1/24.
//

import UIKit
import MobileCoreServices
import QuickLook
import AVFoundation

@objcMembers open class ChatThreadCreateController: UIViewController {
    
    public private(set) var message = ChatMessage()
    
    //Thread id empty represents creating a new thread,constructing the first message, and then entering the chat thread send the first message.
    public private(set) lazy var viewModel: ChatThreadViewModel = {
        ChatThreadViewModel(chatThread: nil)
    }()
    
    public private(set) lazy var entity: MessageEntity = {
        let entity = ComponentsRegister.shared.MessageRenderEntity.init()
        entity.state = .succeed
        entity.historyMessage = true
        entity.message = self.message
        _ = entity.content
        _ = entity.bubbleSize
        _ = entity.height
        return entity
    }()
    
    public private(set) lazy var navigation: ChatNavigationBar = {
        ChatNavigationBar(showLeftItem: true,textAlignment: .left,hiddenAvatar: true)
    }()
    
    public private(set) lazy var messageHeader: UITableView = {
        UITableView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.messageHeight()+20), style: .plain).dataSource(self).dataSource(self).separatorStyle(.none).backgroundColor(.clear).tableFooterView(UIView()).rowHeight(self.messageHeight())
    }()
    
    public private(set) lazy var messageContainer: MessageListView = {
        MessageListView(frame: CGRect(x: 0, y: self.navigation.frame.maxY, width: self.view.frame.width, height: self.view.frame.height-NavigationHeight), mention: false)
    }()
    
    public required init(message: ChatMessage) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
        _ = self.entity
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.messageContainer.inputBar.hiddenInput()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.addSubViews([self.navigation,self.messageContainer,self.messageHeader])
        self.setupTitle()
        self.navigation.clickClosure = { [weak self] in
            if $0 == .back {
                consoleLogInfo("\($1?.row ?? 0)", type: .debug)
                self?.pop()
            }
        }
        self.messageContainer.addActionHandler(actionHandler: self)
        Theme.registerSwitchThemeViews(view: self)
        self.switchTheme(style: Theme.style)
        self.messageContainer.inputBar.show()
    }
    
    open func setupTitle() {
        if let group = ChatGroup(id: self.message.conversationId) {
            var showTitle = ""
            if self.message.body.type == .text {
                showTitle = self.message.showContent
            } else {
                showTitle = self.message.showType + self.message.showContent
            }
            if showTitle.count > 16 {
                showTitle = showTitle.chat.subStringTo(16)
            }
            self.navigation.subtitle = "#"+(group.groupName.isEmpty ? group.groupId:group.groupName)
            self.navigation.title = showTitle
        }
    }
    
    @objc open func pop() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true)
        }
    }
    
    open func createChatThread(text: String,type: MessageCellStyle,extensionInfo: Dictionary<String,Any> = [:] ) {
        ChatClient.shared().threadManager?.createChatThread(self.navigation.titleLabel.text ?? "", messageId: self.message.messageId, parentId: self.message.conversationId, completion: { [weak self] chatThread, error in
            guard let `self` = self else { return  }
            if error == nil,let thread = chatThread {
                self.viewModel = ChatThreadViewModel(chatThread: thread)
                if let firstMessage = self.viewModel.constructMessage(text: text, type: type, extensionInfo: extensionInfo) {
                    self.toChatThread(thread: thread, firstMessage: firstMessage)
                }
            } else {
                consoleLogInfo("create chat thread error:\(error?.errorDescription ?? "")", type: .error)
                self.pop()
            }
        })
        
    }
    
    open func messageHeight() -> CGFloat {
        var height = CGFloat(0)
        if self.message.body.type == .text || self.message.body.type == .image || self.message.body.type == .video {
            height = self.entity.bubbleSize.height+30
        } else {
            height = 62
        }
        return height
    }
    
    open func toChatThread(thread: GroupChatThread,firstMessage: ChatMessage) {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: false)
            DispatchQueue.main.asyncAfter(wallDeadline: .now()+0.25) {
                let vc = ChatThreadViewController(chatThread: thread,firstMessage: firstMessage,parentMessageId: self.message.messageId)
                ControllerStack.toDestination(vc: vc)
            }
        } else {
            self.dismiss(animated: false) {
                let vc = ChatThreadViewController(chatThread: thread,firstMessage: firstMessage,parentMessageId: self.message.messageId)
                ControllerStack.toDestination(vc: vc)
            }
        }
    }
    
    /**
     Opens the audio dialog for recording and sending voice messages.
     
     This method stops any currently playing audio, presents a custom audio recording view, and sends the recorded audio message using the view model's `sendMessage` method.
     
     - Note: The audio recording view is an instance of `MessageAudioRecordView` and is presented as a custom dialog using `DialogManager.shared.showCustomDialog`.
     - Note: The recorded audio message is sent as a text message with the file path of the recorded audio and the duration of the recording as extension information.
     */
    @objc open func audioDialog() {
        self.messageContainer.inputBar.hiddenInput()
        AudioTools.shared.stopPlaying()
        let audioView = MessageAudioRecordView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 200+BottomBarHeight)) { [weak self] url, duration in
            UIViewController.currentController?.dismiss(animated: true)
            self?.createChatThread(text: url.path, type: .voice, extensionInfo: ["duration":duration])
            
        } trashClosure: {
            
        }

        DialogManager.shared.showCustomDialog(customView: audioView,dismiss: false)
    }
    
    @objc open func attachmentDialog() {
        self.messageContainer.inputBar.hiddenInput()
        DialogManager.shared.showActions(actions: Appearance.chat.inputExtendActions) { [weak self] item in
            self?.handleAttachmentAction(item: item)
        }
    }
    
    @objc open func handleAttachmentAction(item: ActionSheetItemProtocol) {
        switch item.tag {
        case "File": self.selectFile()
        case "Photo": self.selectPhoto()
        case "Camera": self.openCamera()
        case "Contact": self.selectContact()
        default:
            break
        }
    }
    
    /**
     Opens the photo library and allows the user to select a photo.
     
     - Note: This method checks if the photo library is available on the device. If it is not available, an alert is displayed to the user.
     */
    @objc open func selectPhoto() {
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
    
    @objc open func openCamera() {
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
    
    /**
     Opens a document picker to allow the user to select a file.
     
     The document picker supports various file types including content, text, source code, images, PDFs, Keynote files, Word documents, Excel spreadsheets, PowerPoint presentations, and generic data files.
     
     - Note: The selected file will be handled by the `UIDocumentPickerDelegate` methods implemented in the `MessageListController`.
     */
    @objc open func selectFile() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: ["public.content", "public.text", "public.source-code", "public.image", "public.jpeg", "public.png", "com.adobe.pdf", "com.apple.keynote.key", "com.microsoft.word.doc", "com.microsoft.excel.xls", "com.microsoft.powerpoint.ppt","public.data"], in: .open)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }
    
    /**
     Selects a contact and shares their information.

     - Parameters:
         - None

     - Returns: None
     */
    @objc open func selectContact() {
        let vc = ComponentsRegister.shared.ContactsController.init(headerStyle: .shareContact)
        vc.confirmClosure = { profiles in
            vc.dismiss(animated: true) {
                if let user = profiles.first {
                    DialogManager.shared.showAlert(title: "Share Contact".chat.localize, content: "Share Contact".chat.localize+"`\(user.nickname.isEmpty ? user.id:user.nickname)`?", showCancel: true, showConfirm: true) { [weak self] _ in
                        self?.createChatThread(text: EaseChatUIKit_user_card_message, type: .contact, extensionInfo: ["uid":user.id,"avatar":user.avatarURL,"nickname":user.nickname])
                    }
                    
                }
            }
        }
        self.present(vc, animated: true)
    }
    
}

extension ChatThreadCreateController: MessageListViewActionEventsDelegate {
    public func onMessageContentLongPressed(cell: MessageCell) { }
    
    public func onMessageListLoadMore() {
        
    }
    
    public func onMoreMessagesClicked() {
        
    }
    
    public func onMessageMultiSelectBarClicked(operation: MessageMultiSelectedBottomBarOperation) {
        
    }
    
    public func onMessageListPullRefresh() { }
    
    public func onMessageReplyClicked(message: MessageEntity) { }
    
    public func onMessageContentClicked(message: MessageEntity) { }
    
    
    public func onMessageAvatarClicked(profile: ChatUserProfileProtocol) { }
    
    public func onMessageAvatarLongPressed(profile: ChatUserProfileProtocol) { }
    
    public func onInputBoxEventsOccur(action type: MessageInputBarActionType, attributeText: NSAttributedString?) {
        if type == .send {
            if let text = attributeText?.toString() {
                self.createChatThread(text: text,type: .text)
            }
        }
        if type == .attachment {
            self.attachmentDialog()
        }
    }
    
    public func onFailureMessageRetrySend(entity: MessageEntity) { }
    
    public func onMessageVisible(entity: MessageEntity) { }
    
    public func onMessageTopicClicked(entity: MessageEntity) { }
    
    public func onMessageReactionClicked(reaction: MessageReaction?, entity: MessageEntity) { }
    
    
}

extension ChatThreadCreateController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatThreadCreateHeaderCell") as? ChatHistoryCell
        if cell == nil {
            cell = ChatHistoryCell(reuseIdentifier: "ChatThreadCreateHeaderCell", message: self.message)
        }
        cell?.selectionStyle = .none
        cell?.refresh(entity: self.entity)
        return cell ?? UITableViewCell()
    }
    
}

//MARK: - UIImagePickerControllerDelegate&UINavigationControllerDelegate
extension ChatThreadCreateController:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.processImagePickerData(info: info)
        picker.dismiss(animated: true, completion: nil)
    }
    
    /**
     Processes the data received from the image picker.
     
     - Parameters:
         - info: A dictionary containing the information about the selected media.
     */
    @objc open func processImagePickerData(info: [UIImagePickerController.InfoKey : Any]) {
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
            self.createChatThread(text: fileURL.path, type: .video, extensionInfo: ["duration":duration])
        } else {
            if let imageURL = info[.imageURL] as? URL {
                let fileName = imageURL.lastPathComponent
                let fileURL = URL(fileURLWithPath: MediaConvertor.filePath()+"/\(fileName)")
                do {
                    let image = UIImage(contentsOfFile: imageURL.path)
                    try image?.jpegData(compressionQuality: 1)?.write(to: fileURL)
                } catch {
                    consoleLogInfo("write image error:\(error.localizedDescription)", type: .error)
                }
                self.createChatThread(text: fileURL.path, type: .image)
            } else {
                guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
                let correctImage = image.fixOrientation()
                let fileName = "\(Int(Date().timeIntervalSince1970)).jpeg"
                let fileURL = URL(fileURLWithPath: MediaConvertor.filePath()+"/\(fileName)")
                do {
                    try correctImage.jpegData(compressionQuality: 1)?.write(to: fileURL)
                } catch {
                    consoleLogInfo("write camera fixOrientation image error:\(error.localizedDescription)", type: .error)
                }
                self.createChatThread(text: fileURL.path, type: .image)
            }
        }
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
//MARK: - UIDocumentPickerDelegate
extension ChatThreadCreateController: UIDocumentPickerDelegate {
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        self.documentPickerOpenFile(controller: controller,urls: urls)
        
    }
    
    @objc open func documentPickerOpenFile(controller: UIDocumentPickerViewController,urls: [URL]) {
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
                self.createChatThread(text: fileURL.path, type: .file)
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

//MARK: - ThemeSwitchProtocol
extension ChatThreadCreateController: ThemeSwitchProtocol {
    
    public func switchTheme(style: ThemeStyle) {
        self.navigation.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
        self.view.backgroundColor = style == .dark ? UIColor.theme.neutralColor1:UIColor.theme.neutralColor98
    }
    
}



