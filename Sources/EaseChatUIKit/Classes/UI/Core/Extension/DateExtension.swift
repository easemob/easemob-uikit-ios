//
//  DateExtension.swift
//  ChatUIKit
//
//  Created by 朱继超 on 2020/12/17.
//

import Foundation
import UIKit

/// Extension for Date class to add Chatroom functionality
public extension Date {
    
    /// Returns a Chatroom instance for the current date
    var chat:ChatWrapper<Self> {
        return ChatWrapper.init(self)
    }
}

/// Extension for Chatroom class where the base is of type Date
public extension ChatWrapper where Base == Date {
    
    /// Returns the date string in the format "yyyy-MM-dd"
    var dateString: String {
        let formmat = DateFormatter()
        formmat.dateFormat = "yyyy-MM-dd"
        return formmat.string(from: base)
    }
    
    /// Adds a given number of hours to the current date
    /// - Parameter num: The number of hours to add
    mutating func addHours(_ num: Int) {
        base.addTimeInterval(TimeInterval(60.0 * 60.0 * CGFloat(num)))
    }
    
    /// Returns a future date based on the current date with the given year, month and day
    /// - Parameters:
    ///   - year: The number of years to add to the current date
    ///   - month: The number of months to add to the current date
    ///   - day: The number of days to add to the current date
    /// - Returns: The future date
    func futureDate(_ year: Int = 0,_ month: Int = 0,_ day: Int = 0) -> Base {
        let current = Date()
        let calendar = Calendar(identifier: .gregorian)
        var comps:DateComponents?
        comps = calendar.dateComponents([.year,.month,.day], from: current)
        comps?.year = year
        comps?.month = month
        comps?.day = day
        return calendar.date(byAdding: comps!, to: current) ?? Date()
    }
    
    /// Returns the date string in the given format
    /// - Parameter formatter: The date formatter string
    /// - Returns: The date string
    func dateString(_ formatter: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let fmt = DateFormatter()
        fmt.timeZone = TimeZone.current
        let newDate = base
        fmt.locale = .current
        fmt.dateFormat = formatter
        return fmt.string(from: newDate)
    }
    
    /// Compares the current date with another date and returns the result
    /// - Parameter otherDate: The date to compare with
    /// - Returns: 0 if the dates are the same, 1 if the current date is ascending, 2 if the current date is descending
    func compareToDate(_ otherDate: Date) -> Int {
        let resultDic: [ComparisonResult: Int] = [.orderedSame: 0, .orderedAscending: 1, .orderedDescending: 2]
        return resultDic[base.compare(otherDate)] ?? 0
    }
    
    func compareDays() -> Int {
        Calendar.current.dateComponents([.day], from: Date(),to: base).day ?? 0
    }
    
    func compareYears() -> Int {
        Calendar.current.dateComponents([.year], from: Date(),to: base).day ?? 0
    }
}
