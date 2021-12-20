//
//  DateManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/12/21.
//

import Foundation

struct DateManager {
    
    static private let formatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd"
        return format
    }()
    
    static func date(from: String) -> Date {
        let date = formatter.date(from: from)
        return date!
    }
    
    static func addDaysToDate(fromDate: Date) -> Date {
        let nextDate = Calendar.current.date(byAdding: .day, value: 10, to: fromDate)
        return nextDate!
    }
    
    static func checkIfNewMonth(previous: Date, next: Date) -> Bool {
        let previousMonth = Calendar.current.component(.month, from: previous)
        let nextMonth = Calendar.current.component(.month, from: next)
        return nextMonth != previousMonth
    }
    
    static func monthComponent(from: String) -> Int {
        let date = date(from: from)
        let year = Calendar.current.component(.year, from: date)
        let month = Calendar.current.component(.month, from: date)
        let day = Calendar.current.component(.day, from: date)
        return month
    }
    
    static func removeNoise(fromString: String) -> String {
        let bad: Set<Character> = ["-"]
        var copy = fromString
        copy.removeAll() { bad.contains($0) }
        return copy
    }
    
    static func addNoise(fromString: String) -> String {
        var copy = fromString
        copy.insert("-", at: copy.index(copy.startIndex, offsetBy: 4))
        copy.insert("-", at: copy.index(copy.startIndex, offsetBy: 7))
        return copy
    }
    
    static func string(fromDate: Date) -> String {
        let day = Calendar.current.component(.day, from: fromDate)
        let year = Calendar.current.component(.year, from: fromDate)
        let month = Calendar.current.component(.month, from: fromDate)
        return constructKey(month: month, year: year, day: day)
    }
    
    static private func constructKey(month: Int, year: Int, day: Int) -> String {
        
        let day: String = day < 10 ? "0\(day)" : "\(day)"
        let month: String = month < 10 ? "0\(month)" : "\(month)"
        
        return "\(year)-\(month)-\(day)"
    }
    
}
