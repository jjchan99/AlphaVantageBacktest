//
//  DateIndicatorModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 27/10/21.
//

import Foundation

protocol MonthSpecified {
    var month: String { get }
}

struct DateIndicator<T: MonthSpecified> {
    
    let selectedIndex: Int
    let mostRecentDate: String
    let result: [T]
    
    init(selectedIndex: Int, result: [T]) {
        self.selectedIndex = selectedIndex
        self.mostRecentDate = result.last!.month
        self.result = result
    }
    
    private func getMonth(row: Int, inverse: Bool) -> String {
    let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        let idx = inverse ? 11-row : row
        return monthArray[idx]
    }
    
    func showDate() -> String {
        let date = formatter.date(from: result[selectedIndex].month)
        let month = Calendar.current.component(.month, from: date!)
        let monthTitle = getMonth(row: month - 1, inverse: false)
        let year = Calendar.current.component(.year, from: date!)
        return "\(monthTitle) \(year)"
    }
    
//    func showDate() -> String {
//        let mostRecent = formatter.date(from: mostRecentDate)
//        let monthIndexMostRecent = Calendar.current.component(.month, from: mostRecent!)
//        let yearIndexMostRecent = Calendar.current.component(.year, from: mostRecent!)
//        let numberOfYears = count - monthIndexMostRecent == 0 ? 0 : Int(floor(Double((12 + count - monthIndexMostRecent) / 12)))
//        let isLastYear: Bool = numberOfYears > 0 ? selectedIndex + 1 <= (count - (monthIndexMostRecent)) % 12 : false
//        let remainingMonthsInLastYear = (((count - monthIndexMostRecent) % 12) - 1)
//
//        let monthToDisplay: String = isLastYear ? getMonth(row: remainingMonthsInLastYear - selectedIndex, inverse: true) : getMonth(row: (selectedIndex - remainingMonthsInLastYear - 1) % 12, inverse: false)
//        let idkWhatToCallThis: Int = Int(floor(Double(((count - monthIndexMostRecent) - (selectedIndex + 1)) / 12))) + 1
//
//        let year: Int = selectedIndex + 1 > count - monthIndexMostRecent ? yearIndexMostRecent : yearIndexMostRecent - idkWhatToCallThis
//        return "\(monthToDisplay) \(year)"
//    }
    
    
}

