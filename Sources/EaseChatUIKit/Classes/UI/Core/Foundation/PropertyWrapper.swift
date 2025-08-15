//
//  PropertyWrapper.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2023/11/13.
//

import Foundation


@propertyWrapper public struct UserDefault<T> {
    
    let key: String
    let defaultValue: T

    public init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    public var wrappedValue: T {
        get {
            return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

@propertyWrapper
public struct AtomicUnfairLock<T> {
    private var value: T
    private var lock = os_unfair_lock()
    
    // 初始化时设置初始值
    public init(wrappedValue: T) {
        self.value = wrappedValue
    }
    
    // 包装的属性值，自动处理加锁解锁
    public var wrappedValue: T {
        mutating get {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            return value
        }
        set {
            os_unfair_lock_lock(&lock)
            defer { os_unfair_lock_unlock(&lock) }
            value = newValue
        }
    }
    
    /// 原子性修改操作
    /// - Parameter transform: 对值进行修改的闭包
    public mutating func modify(_ transform: (inout T) -> Void) {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        transform(&value)
    }
    
    /// 原子性读取并处理值
    /// - Parameter transform: 处理值的闭包，返回处理结果
    /// - Returns: 处理结果
    public mutating func withValue<U>(_ transform: (T) -> U) -> U {
        os_unfair_lock_lock(&lock)
        defer { os_unfair_lock_unlock(&lock) }
        return transform(value)
    }
}
