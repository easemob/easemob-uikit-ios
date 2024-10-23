//
//  ChatEmojiConvertor.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation


/**
 A class that converts emojis in a given NSMutableAttributedString to their corresponding UIImage.
 */
@objc final public class ChatEmojiConvertor: NSObject {

    @objc public static let shared = ChatEmojiConvertor()

    @objc public var emojiMap: Dictionary<String,UIImage> = [:]
    
    @objc public var emojiReactionMap: Dictionary<String,UIImage> = [:]

    @objc public var reactions = [String]()

    @objc public let emojis: [String] = ["😀", "😄", "😉", "😮", "🤪", "😎", "🥱", "🥴", "☺️", "🙁", "😭", "😐", "😇", "😬", "🤓", "😳", "🥳", "😠", "🙄", "🤐", "🥺", "🤨", "😫", "😷", "🤒", "😱", "😘", "😍", "🤢", "👿", "🤬", "😡", "👍", "👎", "👏", "🙌", "🤝", "🙏", "❤️", "💔", "💕", "💩", "💋", "☀️", "🌜", "🌈", "⭐", "🌟", "🎉", "💐", "🎂", "🎁"]
    
    @objc public let oldEmojis: [String:String] = [
        "[):]": "☺️",
        "[:D]": "😄",
        "[;)]": "😉",
        "[:-o]": "😮",
        "[:p]": "😋",
        "[(H)]": "😎",
        "[:@]": "😡",
        "[:s]": "🤐",
        "[:$]": "😳",
        "[:(]": "🙁",
        "[:'(]": "😭",
        "[:|]": "😐",
        "[(a)]": "😇",
        "[8o|]": "😬",
        "[8-|]": "😆",
        "[+o(]": "😱",
        "[<o)]": "🎅",
        "[|-)]": "😴",
        "[*-)]": "😕",
        "[:-#]": "😷",
        "[:-*]": "😯",
        "[^o)]": "😏",
        "[8-)]": "😑",
        "[(|)]": "💖",
        "[(u)]": "💔",
        "[(S)]": "🌜",
        "[(*)]": "🌟",
        "[(#)]": "☀️",
        "[(R)]": "🌈",
        "[({)]": "😍",
        "[(})]": "😘",
        "[(k)]": "💋",
        "[(F)]": "🌹",
        "[(W)]": "🍂",
        "[(D)]": "👍",
        "[(E)]": "😂",
        "[(T)]": "🤗",
        "[(G)]": "👏",
        "[(Y)]": "🤝",
        "[(I)]": "👍",
        "[(J)]": "👎",
        "[(K)]": "👌",
        "[(L)]": "❤️",
        "[(M)]": "💔",
        "[(N)]": "💣",
        "[(O)]": "💩",
        "[(P)]": "🌹",
        "[(U)]": "🙏",
        "[(Z)]": "🎉",
        "[-)]": "🤢",
        "[:-]": "🙄"
    ]
    
    @objc public let reactionEmojis: [String:String] = [
        "emoji_1":"😀",
        "emoji_2":"😟",
        "emoji_3":"😍",
        "emoji_4":"😳",
        "emoji_5":"😎",
        "emoji_6":"😭",
        "emoji_7":"☺️",
        "emoji_8":"🤐",
        "emoji_9":"😴",
        "emoji_10":"😥",
        "emoji_11":"😝",
        "emoji_12":"😡",
        "emoji_13":"😜",
        "emoji_14":"😁",
        "emoji_15":"🤔",
        "emoji_16":"☹️",
        "emoji_17":"😓",
        "emoji_18":"😫",
        "emoji_19":"🤢",
        "emoji_20":"😵",
        "emoji_21":"😊",
        "emoji_22":"🙄",
        "emoji_23":"😠",
        "emoji_24":"😪",
        "emoji_25":"🤥",
        "emoji_26":"😁",
        "emoji_27":"🤡",
        "emoji_28":"🤤",
        "emoji_29":"😱",
        "emoji_30":"🤧",
        "emoji_31":"😐",
        "emoji_32":"😬",
        "emoji_33":"😯",
        "emoji_34":"😧",
        "emoji_35":"🤑",
        "emoji_36":"😂",
        "emoji_37":"🤗",
        "emoji_38":"👏",
        "emoji_39":"🤝",
        "emoji_40":"👍",
        "emoji_41":"👎",
        "emoji_42":"👌",
        "emoji_43":"❤️",
        "emoji_44":"💔",
        "emoji_45":"💣",
        "emoji_46":"💩",
        "emoji_47":"🌹",
        "emoji_48":"🙏",
        "emoji_49":"🎉"
    ]
    
    /**
     Converts the specified ranges of the input attributed string to emoji images using the provided symbol and returns the resulting attributed string.
     
     - Parameters:
         - input: The input attributed string to convert.
         - ranges: The ranges of the input attributed string to convert to emoji images.
         - symbol: The symbol to use for the emoji images.
     
     - Returns: A new attributed string with the specified ranges replaced with emoji images.
     */
    @objc public func convertEmoji(input: NSMutableAttributedString, ranges: [NSRange], symbol: String, imageBounds: CGRect) -> NSMutableAttributedString {
        let text = NSMutableAttributedString(attributedString: input)
        for range in ranges.reversed() {
            if range.location != NSNotFound, range.length != NSNotFound {
                let value = self.emojiMap.isEmpty ? UIImage(named: symbol, in: .chatBundle, with: nil):self.emojiMap[symbol]
                let attachment = NSTextAttachment()
                attachment.image = value
                attachment.bounds = imageBounds
                text.replaceCharacters(in: range, with: NSAttributedString(attachment: attachment))
            }
        }
        return text
    }
}
