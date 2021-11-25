//
//  MonthlySeriesModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 12/9/21.
//

import Foundation

struct TimeSeriesMonthlyAdjusted: Codable {
    var metaData: Meta
    var data: [String: Data]
    
    private enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case data = "Monthly Adjusted Time Series"
    }
    
    internal struct Data: Codable {
        var open: String
        var high: String
        var low: String
        var close: String
        var adjustedClose: String
        var volume: String
        var dividendAmount: String
        
        private enum CodingKeys: String, CodingKey {
            case open = "1. open"
            case high = "2. high"
            case low = "3. low"
            case close = "4. close"
            case adjustedClose = "5. adjusted close"
            case volume = "6. volume"
            case dividendAmount = "7. dividend amount"
        }
    }

    internal struct Meta: Codable {
        var information: String
        var symbol: String
        var lastRefreshed: String
        var timeZone: String
        
        private enum CodingKeys: String, CodingKey {
            case information = "1. Information"
            case symbol = "2. Symbol"
            case lastRefreshed = "3. Last Refreshed"
            case timeZone = "4. Time Zone"
        }
    }
}

extension TimeSeriesMonthlyAdjusted {
    
    func sortedData() -> [Dictionary<String, TimeSeriesMonthlyAdjusted.Data>.Element] {
        let sortedData = self.data.sorted {
            $0.key > $1.key
        }
        return sortedData
    }
    
    func returnPickerData(sortedData: [Dictionary<String, TimeSeriesMonthlyAdjusted.Data>.Element]) throws -> (yearArray: [String], monthArray: [ArraySlice<String>]) {
        var dict: [String: ArraySlice<String>] = [:]
        
        var numberOfMonthsRemaining = self.data.count
        
        guard numberOfMonthsRemaining != 0 else { throw conversionError.emptyDataSet }
        
        let first_yyyyMMdd = sortedData[0].0
        
        let mostRecentDate = formatter.date(from: first_yyyyMMdd)
        guard mostRecentDate != nil else {
            throw conversionError.dateConversion
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
        let slice = sliceFromIndex(index: monthIndex)
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
            throw conversionError.emptyDataSet
        }
        return (yearArray, monthArray)
    }
}

fileprivate func sliceFromIndex(index: Int, inverse: Bool = false) -> ArraySlice<String> {
        let monthArray = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
        if !inverse { return monthArray[0..<index] } else { return monthArray.suffix(index) }
}
