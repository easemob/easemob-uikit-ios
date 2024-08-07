//
//  LinkRecognizeTextView.swift
//  EaseChatUIKit
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
    
    public private(set) var hasURL = false
    
    lazy var activeElements = [LinkTextViewActiveType: [ElementTuple]]()
    
    fileprivate var selectedElement: ElementTuple?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(gesture:))))
    }
    
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
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    
    //MARK: - Handle UI Responder touches
//    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        if onTouch(touch) { return }
//        super.touchesBegan(touches, with: event)
//    }
    
    func onTouch(_ touch: UITouch) -> Bool {
        let location = touch.location(in: self)
        var avoidSuperCall = false
        
        switch touch.phase {
        case .began, .moved, .regionEntered, .regionMoved:
            if let element = element(at: location) {
                switch element.element {
                case .url(let url, let trimmed): touchURL(urlString: url)
                default: break
                }
                selectedElement = element
                avoidSuperCall = false
            } else {
                selectedElement = nil
            }
        case .ended, .regionExited:
            guard let selectedElement = selectedElement else { return avoidSuperCall }
            
            switch selectedElement.element {
            case .url(let url, _): touchURL(urlString: url)
            default: break
            }
            avoidSuperCall = false
        case .cancelled:
            selectedElement = nil
        case .stationary:
            break
        @unknown default:
            break
        }
        
        return avoidSuperCall
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



