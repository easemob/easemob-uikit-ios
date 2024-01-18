//
//  ChatEmojiConvertor.swift
//  EaseChatUIKit
//
//  Created by 朱继超 on 2023/8/30.
//

import Foundation


/**
 A class that converts emojis in a given NSMutableAttributedString to their corresponding UIImage.
 
 - Author: ChatroomUIKit
 - Version: 1.0.0
 */
@objc final public class ChatEmojiConvertor: NSObject {

    @objc public static let shared = ChatEmojiConvertor()

    @objc var emojiMap: Dictionary<String,UIImage> = [:]

    @objc let emojis: [String] = ["😀", "😄", "😉", "😮", "🤪", "😎", "🥱", "🥴", "☺️", "🙁", "😭", "😐", "😇", "😬", "🤓", "😳", "🥳", "😠", "🙄", "🤐", "🥺", "🤨", "😫", "😷", "🤒", "😱", "😘", "😍", "🤢", "👿", "🤬", "😡", "👍", "👎", "👏", "🙌", "🤝", "🙏", "❤️", "💔", "💕", "💩", "💋", "☀️", "🌜", "🌈", "⭐", "🌟", "🎉", "💐", "🎂", "🎁"]
    
    @objc let oldEmojis: [String:String] = [
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
