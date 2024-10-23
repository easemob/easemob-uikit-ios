//
//  DispatchExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation

// MARK: - DispatchQueueOnce
public extension DispatchQueue {
    
    private static var _onceTracker = [String]()
    
    /// GCD DispatchOnce
    /// - Parameters:
    ///   - token: token string
    ///   - block: callBack
    /// - Returns: Void
    class func once(token: String, block: () -> ()) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        if _onceTracker.contains(token) {
            return
        }
        _onceTracker.append(token)
        block()
    }
    
    /// 异步执行 @escaping () throws -> T 中任务后通知主线程
    /// - Parameters:
    ///   - work: 要执行的任务
    ///   - mainSuccess: 成功回到主线程
    ///   - mainError: 回到主线程报错
    func asyncTaskBackMainQueue<T>(
        work: @escaping () throws -> T,
        mainSuccess: @escaping (T) -> Void,
        mainError: @escaping (Error) -> Void) {
        async {
            do {
                let result = try work()
                DispatchQueue.main.async {
                    mainSuccess(result)
                }
            } catch {
                DispatchQueue.main.async {
                    mainError(error)
                }
            }
        }
    }
    /// 延时异步执行 @escaping () throws -> T 中任务后通知主线程
    /// - Parameters:
    ///   - work: 要执行的任务
    ///   - mainSuccess: 成功回到主线程
    ///   - mainError: 回到主线程报错
    ///   - deadline: 延时秒数
    func asyncTaskBackMainQueueAfter<T>(
        delay: TimeInterval,
        work: @escaping () throws -> T,
        mainSuccess: @escaping (T) -> Void,
        mainError: @escaping (Error) -> Void) {
        asyncAfter(deadline: .now() + delay) {
            do {
                let result = try work()
                DispatchQueue.main.async {
                    mainSuccess(result)
                }
            } catch {
                DispatchQueue.main.async {
                    mainError(error)
                }
            }
        }
    }
}
