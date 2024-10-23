//
//  LinkRecognizeTextView.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2024/7/10.
//

import UIKit


enum LinkTextViewActiveElement {
    case mention(String)
    case hashtag(String)
    case email(String)
    case url(original: String, trimmed: String)
    case custom(String)
    
    static func create(with activeType: LinkTextViewActiveType, text: String) -> LinkTextViewActiveElement {
        switch activeType {
        case .mention: return mention(text)
        case .hashtag: return hashtag(text)
        case .email: return email(text)
        case .url: return url(original: text, trimmed: text)
        case .custom: return custom(text)
        }
    }
}

public enum LinkTextViewActiveType {
    case mention
    case hashtag
    case url
    case email
    case custom(pattern: String)
    
}

extension LinkTextViewActiveType: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        switch self {
        case .mention: hasher.combine(-1)
        case .hashtag: hasher.combine(-2)
        case .url: hasher.combine(-3)
        case .email: hasher.combine(-4)
        case .custom(let regex): hasher.combine(regex)
        }
    }
}

public func ==(lhs: LinkTextViewActiveType, rhs: LinkTextViewActiveType) -> Bool {
    switch (lhs, rhs) {
    case (.mention, .mention): return true
    case (.hashtag, .hashtag): return true
    case (.url, .url): return true
    case (.email, .email): return true
    case (.custom(let pattern1), .custom(let pattern2)): return pattern1 == pattern2
    default: return false
    }
}



typealias ElementTuple = (range: NSRange, element: LinkTextViewActiveElement, type: LinkTextViewActiveType)

@objc open class LinkRecognizeTextView: UITextView, UITextViewDelegate {
    
    public var clickAction: (() -> Void)?
    
    public var longPressAction: (() -> Void)?
    
    public private(set) var hasURL = false
    
    private var longPress: UILongPressGestureRecognizer?
    private var tap: UITapGestureRecognizer?
    private var mark: Bool = false
    private var isLongPress = false
    
    private var isUpdatingSelection = false
    
    open var selectedTextColor: UIColor = .clear
    
    open override var selectedRange: NSRange {
        didSet {
            guard !isUpdatingSelection else { return }
            isUpdatingSelection = true
            defer { isUpdatingSelection = false }
            
            if self.selectedRange.length > 0 {
                self.setSelectedTextBackgroundColor(self.selectedTextColor)
            } else {
                if self.attributedText != nil {
                    self.setSelectedTextBackgroundColor(self.selectedTextColor)
                }
            }
        }
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.delegate = self
        addLongPress()
        addTap()
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopMenuIfNeeded), name: Notification.Name("ChangePopMenuIfNeeded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPopMenuIfNeeded), name: Notification.Name("ShowPopMenuIfNeeded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markedClickTextView), name: Notification.Name("ClickPopMenuInTextView"), object: nil)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        self.delegate = self
        addLongPress()
        addTap()
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopMenuIfNeeded), name: Notification.Name("ChangePopMenuIfNeeded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showPopMenuIfNeeded), name: Notification.Name("ShowPopMenuIfNeeded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(markedClickTextView), name: Notification.Name("ClickPopMenuInTextView"), object: nil)
    }
    
    @objc private func markedClickTextView() {
        self.mark = true
    }
    
    @objc private func hidePopMenuIfNeeded() {
        if !self.mark {
            self.selectedRange = NSMakeRange(0, 0)
        }
    }
    
    @objc private func showPopMenuIfNeeded() {
        self.mark = false
        if self.selectedRange.length > 0 {
            showPopMenu(with: self)
        }
    }
    
    private func addLongPress() {
        if self.longPress == nil {
            self.longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPress))
            self.longPress?.minimumPressDuration = 0.3
            if let longPress = self.longPress {
                self.addGestureRecognizer(longPress)
            }
        }
    }
    
    private func addTap() {
        self.isLongPress = false
        if self.tap == nil {
            self.tap = UITapGestureRecognizer(target: self, action: #selector(textViewTapped(gesture:)))
            if let tap = self.tap {
                self.addGestureRecognizer(tap)
            }
        }
    }
    
    @objc private func onLongPress() {
        if Appearance.chat.messageLongPressMenuStyle == .withArrow {
            self.isLongPress = true
            self.selectedRange = NSMakeRange(0, 0)
            self.perform(#selector(selectAll(_:)), with: nil)
        } else {
            self.isLongPress = true
            self.longPressAction?()
        }
    }
    
    open override func selectAll(_ sender: Any?) {
        super.selectAll(sender)
    }
    
    func setSelectedTextBackgroundColor(_ color: UIColor) {
        guard let attributedText = self.attributedText else { return }
        
        let mutableAttributedText = NSMutableAttributedString(attributedString: attributedText)
        
        if let selectedRange = self.selectedTextRange {
            let start = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
            let length = self.offset(from: selectedRange.start, to: selectedRange.end)
            let range = NSRange(location: start, length: length)
            
            mutableAttributedText.addAttribute(.backgroundColor, value: color, range: range)
        }
        
        // 保存当前的选择范围
        let currentSelectedRange = self.selectedRange
        
        // 更新 attributedText
        self.attributedText = mutableAttributedText
        
        // 恢复选择范围
        self.selectedRange = currentSelectedRange
    }
    
    @objc private func textViewTapped(gesture: UITapGestureRecognizer) {
        self.isLongPress = false
        self.selectedRange = NSMakeRange(0, 0)
        if !self.hasURL {
            self.clickAction?()
            return
        }
        let location = gesture.location(in: self)
        
        switch gesture.state {
        case .began,.ended:
            if let element = element(at: location) {
                switch element.element {
                case .url(let url, _): touchURL(urlString: url)
                default: break
                }
                selectedElement = element
            } else {
                selectedElement = nil
            }
        case  .cancelled, .changed, .failed:
            selectedElement = nil
        case .possible:
            break
        @unknown default:
            break
        }
        
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedRange.length < textView.text.count {
            // Assuming SJPopMenu.menu().hideMenu() is a valid method
            MessageLongPressMenu.shared.hiddenMenu()
            return
        }
        showPopMenu(with: textView)
    }
    
    private func showPopMenu(with textView: UITextView) {
        if textView.selectedRange.location == 0 && textView.selectedRange.length == textView.text.count {
            // Assuming self.showTextMenu is a valid closure
            self.showTextMenu?(CGRect.zero, CGRect.zero, textView.selectedRange, true)
        } else {
            let startRect = textView.caretRect(for: textView.selectedTextRange!.start)
            let endRect = textView.caretRect(for: textView.selectedTextRange!.end)
            
            self.showTextMenu?(startRect, endRect, textView.selectedRange, false)
        }
    }
    
    // Assuming there is a closure like this
    var showTextMenu: ((CGRect, CGRect, NSRange, Bool) -> Void)?
    
    lazy var activeElements = [LinkTextViewActiveType: [ElementTuple]]()
    
    fileprivate var selectedElement: ElementTuple?

    
    @objc open func tapAction(gesture: UITapGestureRecognizer) {
        if !self.hasURL {
            self.clickAction?()
        }
        let location = gesture.location(in: self)
        guard let element = element(at: location) else { return }
        switch element.element {
        case .url(let url, _): touchURL(urlString: url)
        default: break
        }
    }
    
    func createURLElements(from text: String, range: NSRange, maximumLength: Int?) -> ([ElementTuple], String) {
        let type = LinkTextViewActiveType.url
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return ([],text)
        }
        let matches = detector.matches(in: text, options: [], range: NSRange(location: 0, length: text.count))
        self.hasURL = matches.count == 1
        var elements: [ElementTuple] = []
        for result in matches {
            if let url = result.url {
                let urlString = url.absoluteString
                if range.length > 0 {
                    let trimmedWord = urlString.trim(to: urlString.count)
                    let element = LinkTextViewActiveElement.url(original: urlString, trimmed: trimmedWord)
                    elements.append((result.range, element, type))
                }
            }
        }
        
        return (elements, text)
    }
    
    fileprivate func element(at location: CGPoint) -> ElementTuple? {
        guard textStorage.length > 0 else {
            return nil
        }
        
        let correctLocation = location
        let boundingRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: 0, length: textStorage.length), in: textContainer)
        guard boundingRect.contains(correctLocation) else {
            return nil
        }
        
        let index = layoutManager.glyphIndex(for: correctLocation, in: textContainer)
        
        for element in activeElements.map({ $0.1 }).joined() {
            if index >= element.range.location && index <= element.range.location + element.range.length {
                return element
            }
        }
        
        return nil
    }
    
    /// use regex check all link ranges
    func parseTextAndExtractActiveElements(_ attrString: NSAttributedString) {
        var textString = attrString.string
        var textLength = textString.utf16.count
        var textRange = NSRange(location: 0, length: textLength)
        
        let tuple = self.createURLElements(from: textString, range: textRange, maximumLength: attrString.length)
        let urlElements = tuple.0
        let finalText = tuple.1
        textString = finalText
        textLength = textString.utf16.count
        textRange = NSRange(location: 0, length: textLength)
        self.activeElements[.url] = urlElements
    }
    
    func touchURL(urlString: String) {
        var urlString = urlString.lowercased()
        if self.isLongPress {
            return
        }
        if !urlString.hasPrefix("http://"), !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        } else {
            if urlString.hasPrefix("http://") {
                urlString.insert("s", at: 4)
            }
        }
        if let validateURL = URL(string: urlString) {
            UIApplication.shared.open(validateURL)
        }
    }
}

