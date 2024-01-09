//
//  TextEditorView.swift
//  AgoraChat-Demo
//
//  Created by 朱继超 on 2023/7/25.
//  Copyright © 2023 easemob. All rights reserved.
//

import UIKit

/// 自适应输入框
///
/// 支持：
/// 1. 自适应高度
/// 2. 设置 placeholder
/// 3. 输入文字统计(需设置最大显示数量)
open class TextEditorView: UIView {
    public var contentInset: UIEdgeInsets = .init(top: 8, left: 8, bottom: 8, right: 8) {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    public var textCountInset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    // MARK: - Placeholder

    public var placeholderAttributedText: NSAttributedString? {
        didSet {
            placeholderLabel.attributedText = placeholderAttributedText
        }
    }

    public var placeholderTextColor: UIColor = .gray {
        didSet {
            placeholderLabel.textColor = placeholderTextColor
        }
    }

    public var placeholderFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            placeholderLabel.font = placeholderFont
        }
    }

    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }

    /// 占位 text 行数
    public var placeholderNumberOfLines: UInt = 0 {
        didSet {
            placeholderLabel.numberOfLines = Int(placeholderNumberOfLines)
        }
    }

    /// 输入范围最小高度， 注意: 表示实际 textView 文本高度。
    public var minHeight: CGFloat = 32
    /// 最长文本数量，默认值为nil,表示不受限制但同时会影藏数量 label
    public var maxTextCount: UInt? {
        didSet {
            if let maxCount = maxTextCount {
                textCountLabel.text = "\(textView.text.count)" + "/\(maxCount)"
            }
            setNeedsUpdateConstraints()
        }
    }

    /// 是否影藏字数统计， 默认false.
    public var isHiddenTextCountLabel: Bool = false {
        didSet {
            setNeedsUpdateConstraints()
        }
    }

    /// 输入字数改变闭包，可以在这里设置textCount样式
    public var textCountChanged: (_ textCountLabel: UILabel, _ textCount: Int) -> Void = { _, _ in
    } {
        didSet {
            setNeedsUpdateConstraints()
            isNeedsUpdateTextCountLabel = true
        }
    }

    /// 输入文字改变闭包（不包含正在输入的高亮部分）
    public var textDidChanged: (_ text: String) -> Void = { _ in }
    /// 高度改变，是否允许滑动。默认允许滑动
    public var heightDidChangedShouldScroll: (_ height: CGFloat) -> Bool = { _ in true }

    // MARK: - Private Property

    private var lastText: String = ""
    private var isNeedsUpdateTextCountLabel: Bool = false
    public let textCountLabel = UILabel()
    public let textView = UITextView()
    private var placeholderLabel = UILabel()
    private var textViewBottomLayoutConstraint: NSLayoutConstraint?
    private var textCountLabelTopLayoutConstraint: NSLayoutConstraint?

    override open var intrinsicContentSize: CGSize {
        let size = textSize()
        var height = size.height > minHeight ? size.height : minHeight
        if !textCountLabel.isHidden {
            height += textCountInset.top + textCountInset.bottom
            height += textCountLabel.intrinsicContentSize.height
        }

        height += contentInset.top + contentInset.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setupTextView()
        setupTextCountLabel()
        setupPlaceholderLabel()
        backgroundColor = .white
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.isHidden = !textView.text.isEmpty
        checkTextChanged()
        checkTextCountChanged()
        if isNeedsUpdateTextCountLabel {
            setNeedsUpdateConstraints()
            updateConstraintsIfNeeded()
            isNeedsUpdateTextCountLabel = false
        }
    }

    override open func updateConstraints() {
        let selfConstraints = constraints
        // 更新约束
        selfConstraints.first(where: { $0.identifier == Key.textCountLabelRightLayoutConstraintIdentifier })!.constant = -textCountInset.right
        selfConstraints.first(where: { $0.identifier == Key.textCountLabelBottomLayoutConstraintIdentifier })!.constant = -(textCountInset.bottom + contentInset.bottom)
        textCountLabelTopLayoutConstraint?.constant = textCountInset.top
        textCountLabel.constraints.first(where: { $0.identifier == Key.textCountLabelHeightLayoutConstraintConstant })!.constant = textCountLabel.intrinsicContentSize.height

        selfConstraints.first(where: { $0.identifier == Key.textViewTopLayoutConstraintIdentifier })!.constant = contentInset.top
        textViewBottomLayoutConstraint?.constant = -contentInset.bottom
        selfConstraints.first(where: { $0.identifier == Key.textViewLeftLayoutConstraintIdentifier })!.constant = contentInset.left
        selfConstraints.first(where: { $0.identifier == Key.textViewRightLayoutConstraintIdentifier })!.constant = -contentInset.right

        // 影藏字数统计
        var _isHiddenTextCountLabel = self.isHiddenTextCountLabel
        if maxTextCount == nil {
            _isHiddenTextCountLabel = true
        }
        textCountLabel.isHidden = _isHiddenTextCountLabel

        textCountLabelTopLayoutConstraint?.isActive = !_isHiddenTextCountLabel

        textViewBottomLayoutConstraint?.isActive = _isHiddenTextCountLabel

        super.updateConstraints()
    }
}

// MARK: - Private Method

private extension TextEditorView {
    func setupTextView() {
        textView.backgroundColor = .clear
        textView.text = lastText
        textView.font = UIFont.systemFont(ofSize: 14)
        textView.textContainerInset = .zero // 去除默认上下 8 距离
        textView.textContainer.lineFragmentPadding = 0 // 去掉 默认5
        textView.showsVerticalScrollIndicator = false
        textView.autoresizingMask = .flexibleHeight
        textView.showsHorizontalScrollIndicator = false
        textView.isScrollEnabled = true
        textView.delegate = self
        addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textViewBottomLayoutConstraint = textView.bottomAnchor.constraint(equalTo: bottomAnchor)

        let topConstraint = textView.topAnchor.constraint(equalTo: topAnchor)
        topConstraint.identifier = Key.textViewTopLayoutConstraintIdentifier
        let leftConstraint = textView.leftAnchor.constraint(equalTo: leftAnchor)
        leftConstraint.identifier = Key.textViewLeftLayoutConstraintIdentifier
        let rightConstraint = textView.rightAnchor.constraint(equalTo: rightAnchor)
        rightConstraint.identifier = Key.textViewRightLayoutConstraintIdentifier
        let constraints = [
            topConstraint,
            textViewBottomLayoutConstraint!,
            leftConstraint,
            rightConstraint
        ]
        NSLayoutConstraint.activate(constraints)
    }

    func setupTextCountLabel() {
        let label = textCountLabel
        label.backgroundColor = .clear
        label.numberOfLines = 1
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor(red: 153.0/255.0, green: 153.0/255.0, blue: 153.0/255.0, alpha: 1)
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        textCountLabelTopLayoutConstraint = label.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: textCountInset.top)
        let rightConstraint = label.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: -textCountInset.right)
        rightConstraint.identifier = Key.textCountLabelRightLayoutConstraintIdentifier
        let bottomConstraint = label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -(textCountInset.bottom + contentInset.bottom))
        bottomConstraint.identifier = Key.textCountLabelBottomLayoutConstraintIdentifier
        let heightConstraint = label.heightAnchor.constraint(equalToConstant: 20)
        heightConstraint.identifier = Key.textCountLabelHeightLayoutConstraintConstant
        textViewBottomLayoutConstraint?.isActive = false // 注意设置 false 相等移除
        NSLayoutConstraint.activate([textCountLabelTopLayoutConstraint!, rightConstraint, bottomConstraint, heightConstraint])
        checkTextCountChanged()
    }

    func setupPlaceholderLabel() {
        placeholderLabel.numberOfLines = Int(placeholderNumberOfLines)
        placeholderLabel.font = placeholderFont
        placeholderLabel.textColor = placeholderTextColor
        placeholderLabel.attributedText = placeholderAttributedText
        placeholderLabel.backgroundColor = .clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)

        let leftConstraint = placeholderLabel.leftAnchor.constraint(equalTo: textView.leftAnchor, constant: 0)
        let rightConstraint = placeholderLabel.rightAnchor.constraint(equalTo: textView.rightAnchor, constant: 0)
        let topConstraint = placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 0)
        let bottomConstraint = placeholderLabel.bottomAnchor.constraint(lessThanOrEqualTo: textView.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([leftConstraint, rightConstraint, topConstraint, bottomConstraint])
    }

    func textSize() -> CGSize {
        let rect = textView.attributedText.boundingRect(with: CGSize(width: ScreenWidth-66, height: Appearance.chat.maxInputHeight), options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil)
        return rect.size
    }

    func checkTextChanged() {
        guard let newText = textView.text, newText != lastText else {
            return
        }
        lastText = newText

        textDidChanged(newText)
        let height = intrinsicContentSize.height
        let isScroll = heightDidChangedShouldScroll(height)
        
        textView.isScrollEnabled = isScroll
        textView.showsVerticalScrollIndicator = isScroll
    }

    func checkTextCountChanged() {
        if let maxCount = maxTextCount {
            textCountLabel.text = "\(textView.text.count)" + "/\(maxCount)"
        }
        textCountChanged(textCountLabel, textView.text.count)
    }
}

extension TextEditorView {
    enum Key {
        static let textCountLabelRightLayoutConstraintIdentifier = "textCountLabelRightLayoutConstraintIdentifier"
        static let textCountLabelBottomLayoutConstraintIdentifier = "textCountLabelBottomLayoutConstraintIdentifier"
        static let textCountLabelHeightLayoutConstraintConstant = "textCountLabelHeightLayoutConstraintConstant"

        // static let textCountLabelTopLayoutConstraintIdentifier = "textCountLabelTopLayoutConstraintIdentifier"

        // static let textViewBottomLayoutConstraintIdentifier = "textViewBottomLayoutConstraintIdentifier1111"
        static let textViewTopLayoutConstraintIdentifier = "textViewTopLayoutConstraintIdentifier"
        static let textViewLeftLayoutConstraintIdentifier = "textViewLeftLayoutConstraintIdentifier"
        static let textViewRightLayoutConstraintIdentifier = "textViewRightLayoutConstraintIdentifier"
    }
}

extension TextEditorView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        if let markedRange = textView.markedTextRange, !markedRange.isEmpty {
            /// 输入高亮部分，
            placeholderLabel.isHidden = true
            return
        }

        let textCount = textView.text.count
        if let maxCount = maxTextCount, let text = textView.text {
            if textCount > maxCount {
                let endIndex = text.index(text.startIndex, offsetBy: Int(maxCount))
                textView.text = String(text[text.startIndex ..< endIndex])
            }
        }
        checkTextCountChanged()
        invalidateIntrinsicContentSize()
        placeholderLabel.isHidden = !textView.text.isEmpty
        checkTextChanged()
    }
}
