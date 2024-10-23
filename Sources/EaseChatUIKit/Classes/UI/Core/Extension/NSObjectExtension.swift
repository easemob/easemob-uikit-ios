//
//  NSObjectExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/8/31.
//

import Foundation
import ObjectiveC.runtime

/// An extension to NSObject that provides utility methods for working with subclasses and class names.
public extension NSObject {
    
    /// Returns an array of all subclasses of the class.
    ///
    /// - Returns: An array of all subclasses of the class.
    class func allSubclasses() -> [AnyClass] {
        var count: UInt32 = 0
        let classes = objc_copyClassList(&count)!
        var subclasses = [AnyClass]()
        
        for i in 0..<Int(count) {
            let currentClass: AnyClass = classes[i]
            if class_getSuperclass(currentClass) == self {
                subclasses.append(currentClass)
            }
        }
        
        return subclasses
    }
    
    /// Returns the name of the class as a string.
    ///
    /// - Returns: The name of the class as a string.
    var swiftClassName: String? {
        let className = type(of: self).description().components(separatedBy: ".").last
        return  className
    }
    
}



