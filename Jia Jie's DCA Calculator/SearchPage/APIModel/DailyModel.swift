//
//  DailyModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation

struct Daily: Codable {
    var meta: Meta?
    var timeSeries: [String: TimeSeriesDaily]?
    var note: String?
    
    private enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Time Series (Daily)"
        case note = "Note"
    }
}

public struct Meta: Codable {
    var information: String
    var symbol: String
    var lastRefreshed: String
    var outputSize: String
    var timeZone: String
    
    private enum CodingKeys: String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
        case outputSize = "4. Output Size"
        case timeZone = "5. Time Zone"
    }
}

public struct TimeSeriesDaily: Codable {
    var open: String
    var high: String
    var low: String
    var close: String
    var adjustedClose: String
    var volume: String
    var dividendAmount: String
    var splitCoefficient: String
    
    private enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case adjustedClose = "5. adjusted close"
        case volume = "6. volume"
        case dividendAmount = "7. dividend amount"
        case splitCoefficient = "8. split coefficient"
    }
}

extension TimeSeriesDaily: Comparable {
    public static func < (lhs: TimeSeriesDaily, rhs: TimeSeriesDaily) -> Bool {
        return lhs.adjustedClose < rhs.adjustedClose
    }
    
    public static func == (lhs: TimeSeriesDaily, rhs: TimeSeriesDaily) -> Bool {
        return lhs.adjustedClose == rhs.adjustedClose
    }
}
