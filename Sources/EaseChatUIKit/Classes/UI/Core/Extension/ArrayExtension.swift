//
//  ArrayExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation
/**
 An extension of the Array class that provides additional functionality for ChatroomUIKit.
 
 - Author: ChatroomUIKit Team
 - Version: 1.0.0
 
 - Note: This extension provides the following functionality:
     - `chatroom` property that returns a `Chatroom` instance initialized with the array.
     - `safe` subscript that returns the element at the specified index if it exists, otherwise returns nil.
     - `safe` subscript that returns a slice of the array for the specified range if it exists, otherwise returns nil.
     - `jsonString` function that returns a JSON string representation of the array.
     - `filterDuplicates` function that returns an array with duplicates removed based on a filter condition.
     - `splitToString` function that returns a string with the array elements joined by a delimiter.
 */

// MARK: - ArrayExtension
public extension Array {
    var chat: ChatWrapper<Array<Element>> {
        return ChatWrapper.init(self)
    }
    
    ///数组越界防护
    subscript(safe idx: Index) -> Element? {
        if idx < 0 { return nil }
        return idx < self.endIndex ? self[idx] : nil
    }
    
    subscript(safe range: Range<Int>) -> ArraySlice<Element>? {
        if range.startIndex < 0 { return nil }
        return range.endIndex <= self.endIndex ? self[range.startIndex...range.endIndex]:nil
    }
    
    func jsonString() -> String {
        if (!JSONSerialization.isValidJSONObject(self)) {
            print("无法解析出JSONString")
            return ""
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [])
            return String(data: data, encoding: .utf8) ?? ""
        } catch {
            consoleLogInfo("parser failed: \(error.localizedDescription)", type: .error)
        }
        return ""
    }
    
    
    /// filterDuplicatesElements
    /// - Parameter filter: filter condition
    /// - Returns: result
    func filterDuplicates<E: Equatable>(_ filter: (Element) -> E) -> [Element] {
        var result = [Element]()
        for value in self {
            let key = filter(value)
            if !result.map({filter($0)}).contains(key) {
                result.append(value)
            }
        }
        return result
    }
    
}

public extension ChatWrapper where Base == Array<String> {
    func splitToString(_ delimiter: String) -> String {
        var result = ""
        for (index,text) in base.enumerated() {
            if index == 0 {
                result = text
            } else {
                result += "\(delimiter)\(text)"
            }
        }
        return result
    }
}


