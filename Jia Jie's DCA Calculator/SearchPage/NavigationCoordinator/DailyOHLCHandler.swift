//
//  KeysToDailyOHLC.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 15/11/21.
//

import Foundation

struct DailyOHLCHandler {
    //MARK: DATE IS YYYY_MM_DD
    
    let dictionary: [String: TimeSeriesDaily]
    let daily: Daily
    
    init(daily: Daily) {
        self.daily = daily
        self.dictionary = daily.timeSeries!
    }
    
    private let finalDay: [Int: Int] = [1: 31, 2: 29, 3: 31, 4: 30, 5: 31, 6: 30, 7: 31, 8: 31, 9: 30, 10: 31, 11: 30, 12: 31]
    
    private func constructKey(month: Int, year: Int, day: Int) -> String {
        
        let day: String = day < 10 ? "0\(day)" : "\(day)"
        let month: String = month < 10 ? "0\(month)" : "\(month)"
        
        return "\(year)-\(month)-\(day)"
    }
    
//    private func getMonth(row: Int, inverse: Bool) -> String {
//    let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
//        let idx = inverse ? 11-row : row
//        return monthArray[idx]
//    }
    
    private func lookup(month: Int, year: Int, day: Int, didLookup: (_ stamp: String, _ data: TimeSeriesDaily?) -> ()) -> Bool {
        let key = constructKey(month: month, year: year, day: day)
        let monthEndOHLC = dictionary[key]
        didLookup(key, monthEndOHLC)
        return monthEndOHLC != nil
    }
    
    private func lookupStart(month: Int, year: Int, day: Int, didLookup: (_ stamp: String, _ data: TimeSeriesDaily?) -> ()) -> Bool {
        let key = constructKey(month: month, year: year, day: day)
        let monthEndOHLC = dictionary[key]
        didLookup(key, monthEndOHLC)
        return monthEndOHLC != nil
    }
    
    
    func getMonthlyOHLC() -> [OHLC] {
       
        var array: [OHLC] = []
        let date = Date()
        let calendar = Calendar.current
        var currentMonth: Int = calendar.component(.month, from: date) == 1 ? 12 : calendar.component(.month, from: date) - 1
        var currentYear: Int = calendar.component(.month, from: date) == 1 ? calendar.component(.year, from: date) - 1 : calendar.component(.year, from: date)
        var currentDay = finalDay[currentMonth]!
        
        
        
        var startCurrentMonth: Int = calendar.component(.month, from: date) == 1 ? 12 : calendar.component(.month, from: date) - 1
        var startCurrentYear: Int = calendar.component(.month, from: date) == 1 ? calendar.component(.year, from: date) - 1 : calendar.component(.year, from: date)
        var startCurrentDay: Int = 1
    
        var decrementCounter: Int = 0
//        var incrementCounter: Int = 0
        
        let mostRecentMonth: Int = calendar.component(.month, from: date)
        var mostRecentDay: Int = calendar.component(.day, from: date)
        let mostRecentYear: Int = calendar.component(.year, from: date)
        var mostRecentDayStart: Int = 1
        
        var exitOuterLoop: Bool = false
        while mostRecentDay >= 1 && !exitOuterLoop {
            exitOuterLoop = lookup(month: mostRecentMonth, year: mostRecentYear, day: mostRecentDay) { stamp, data in
                if data == nil {
                    mostRecentDay -= 1
                } else {
                    var exitInnerLoop: Bool = false
                    while startCurrentDay < currentDay && !exitInnerLoop {
                        exitInnerLoop = lookupStart(month: mostRecentMonth, year: mostRecentYear, day: mostRecentDayStart) { startStamp, startData in
                            if startData == nil {
                                incrementDay(&mostRecentDayStart)

                            } else {
//                                print("Received, most recent stamp: \(startStamp). data: \(startData!)")
                                let startOHLC: OHLC = .init(meta: daily.meta!, stamp: stamp, open: startData!.open, high: nil, low: nil, close: data!.close, adjustedClose: data!.adjustedClose, volume: nil, dividendAmount: nil, splitCoefficient: nil)
//                                print("Should be most recent OHLC: stamp: \(startOHLC.stamp) open: \(startOHLC.open) close: \(startOHLC.close)")
                                array.append(startOHLC)
                            }
                        }
                    }
                }
            }
        }
        
            while decrementCounter < finalDay[currentMonth]! - 1 {
                _ = lookup(month: currentMonth, year: currentYear, day: currentDay) { stamp, data in
                    if data == nil {
                        decrementDay(&currentDay)
                        decrementCounter += 1
                    } else {
                        decrement(&currentMonth, &currentYear)
                        decrementCounter = 0
                        
                        
                       
                        
                        var exit: Bool = false
                        while startCurrentDay < currentDay && !exit {
                            exit = lookupStart(month: startCurrentMonth, year: startCurrentYear, day: startCurrentDay) { startStamp, startData in
                                if startData == nil {
                                    incrementDay(&startCurrentDay)

                                } else {
//                                    print("Received, stamp: \(startStamp). data: \(startData!)")
                                    decrement(&startCurrentMonth, &startCurrentYear)
                                    startCurrentDay = 1

                                    let startOHLC: OHLC = .init(meta: daily.meta!, stamp: stamp, open: startData!.open, high: nil, low: nil, close: data!.close, adjustedClose: data!.adjustedClose, volume: nil, dividendAmount: nil, splitCoefficient: nil)
//                                    print("Should be OHLC: stamp: \(startOHLC.stamp) open: \(startOHLC.open) close: \(startOHLC.close)")
                                    array.append(startOHLC)
                                }
                            }
                        }
                        
                        currentDay = finalDay[currentMonth]!
                        
                    }
                }
            }
        
        return array
    }
    
    private func decrement(_ month: inout Int, _ year: inout Int) {
        month = month == 1 ? 12 : month - 1
        year = month == 12 ? year - 1 : year
    }
    
    private func decrementDay(_ day: inout Int) {
        day -= 1
    }
    
    private func incrementDay(_ day: inout Int) {
        day += 1
    }
}

struct OHLC {
    let meta: Meta
    let stamp: String
    let open: String
    let high: String?
    let low: String?
    let close: String
    let adjustedClose: String
    let volume: String?
    let dividendAmount: String?
    let splitCoefficient: String?
    
    static func == (lhs: OHLC, rhs: OHLC) -> Bool {
        return lhs.stamp == rhs.stamp && lhs.meta.symbol == rhs.meta.symbol
    }
    
    func green() -> Bool {
        return close > open
    }
    
    func range() -> Double {
        return Double(high!)! - Double(low!)!
    }
}

extension DailyOHLCHandler {
    func returnPickerData(_ data: [OHLC]) -> (yearArray: [String], monthArray: [ArraySlice<String>]) {
        var dict: [String: ArraySlice<String>] = [:]
        
        var numberOfMonthsRemaining = data.count
        
        guard numberOfMonthsRemaining != 0 else { fatalError() }
        
        let first_yyyyMMdd = data.first!.stamp
        
        let mostRecentDate = formatter.date(from: first_yyyyMMdd)
        guard mostRecentDate != nil else {
            fatalError()
        }
        
        let monthIndex = Calendar.current.component(.month, from: mostRecentDate!)
        var yearIndex = Calendar.current.component(.year, from: mostRecentDate!)
//        print("Most recent date is: \(first_yyyyMMdd)")
//        print("Oldest date is \(String(describing: sortedData().last))")
        
        //PART 2
        var yearArray: [String] = []
        var monthArray: [ArraySlice<String>] = []
        
        let numberOfWholeYears = abs(numberOfMonthsRemaining/12)
        
        //FOR THE MOST RECENT YEAR
        let final = formatter.date(from: data.last!.stamp)!
        let start = Calendar.current.component(.year, from: final) == yearIndex ? Calendar.current.component(.month, from: final) - 1 : 0
        let slice = sliceFromIndex(index: monthIndex, start: start)
        let yearToString = "\(yearIndex)"
        dict[yearToString] = slice
        numberOfMonthsRemaining -= monthIndex
        
        yearArray.append(yearToString)
        monthArray.append(slice)
        
        if numberOfWholeYears > 0 {
        yearIndex -= 1
        } else {
            return (yearArray, monthArray)
        }
        
        
        for idx in 0...numberOfWholeYears {
            if numberOfMonthsRemaining == 0 { break }
            
            let index: Int = numberOfMonthsRemaining >= 12 ? 12 : numberOfMonthsRemaining
            
            if idx != numberOfWholeYears {
            let slice = sliceFromIndex(index: index)
            let yearToString = "\(yearIndex)"
                
            dict[yearToString] = slice
                
            yearArray.append(yearToString)
            monthArray.append(slice)
                
            } else {
            let slice = sliceFromIndex(index: index, inverse: true)
            let yearToString = "\(yearIndex)"
            dict[yearToString] = slice
                
            yearArray.append(yearToString)
            monthArray.append(slice)
            }

            numberOfMonthsRemaining -= index
            yearIndex -= 1
        }
        
        //MARK: DICT IS FOR TESTING PURPOSES
//        print("1999: \(dict["1999"]!)")
//        print("2021: \(dict["2021"]!)")
//        print("2005: \(dict["2005"]!)")
//
//        monthArray.forEach { element in
//            print("count: \(element.count), value: \(element)")
//        }
        
        if yearArray.count == 0 || monthArray.count == 0 {
            fatalError()
        }
        return (yearArray, monthArray)
    }
    
    private func sliceFromIndex(index: Int, inverse: Bool = false, start: Int = 0) -> ArraySlice<String> {
        var monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        var index = index
        if start != 0 {
            for _ in 0..<start {
                monthArray.remove(at: 0)
                index -= 1
            }
        }
            if !inverse {
                return monthArray[..<index]
            }
            else {
                return monthArray.suffix(index)
            }
    }
}


