//
//  DataExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation
/**
 An extension of `Data` that provides a computed property `chatroom` of type `Chatroom<Self>`.
 */
public extension Data {
    
    var chat: ChatWrapper<Self> {
        return ChatWrapper.init(self)
    }
}

/**
 An extension of `Chatroom` that provides two methods to convert the base `Data` object to a dictionary or an array of dictionaries.
 */
public extension ChatWrapper where Base == Data {
    
    /**
     Converts the base `Data` object to a dictionary.
     
     - Returns: A dictionary of type `[String: Any]` if the conversion is successful, otherwise `nil`.
     */
    func toDictionary() -> Dictionary<String,Any>? {
        var dic: Dictionary<String,Any>?
        do {
            dic = try JSONSerialization.jsonObject(with: base, options: .allowFragments) as? Dictionary<String,Any>
        } catch {
            consoleLogInfo("parser failed: \(error.localizedDescription)", type: .error)
        }
        return dic
    }
    
    /**
     Converts the base `Data` object to an array of dictionaries.
     
     - Returns: An array of dictionaries of type `[String: Any]` if the conversion is successful, otherwise `nil`.
     */
    func toDictionaryArray() -> [Dictionary<String,Any>]? {
        var dic: [Dictionary<String,Any>]?
        do {
            dic = try JSONSerialization.jsonObject(with: base, options: .allowFragments) as? [Dictionary<String,Any>]
        } catch {
            consoleLogInfo("parser failed: \(error.localizedDescription)", type: .error)
        }
        return dic
    }
}
