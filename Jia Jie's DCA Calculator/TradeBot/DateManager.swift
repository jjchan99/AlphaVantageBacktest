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
        return formatter.date(from: from)!
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
    }
    
    
}
