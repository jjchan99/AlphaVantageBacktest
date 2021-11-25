//
//  IntradayAPI.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation

struct Intraday: Codable {
    var meta: Meta?
    var timeSeries: [String: TimeSeries]?
    var note: String?
    
    private enum CodingKeys: String, CodingKey {
        case meta = "Meta Data"
        case timeSeries = "Time Series (5min)"
        case note = "Note"
    }
    
    internal struct Meta: Codable {
        var information: String
        var symbol: String
        var lastRefreshed: String
        var interval: String
        var outputSize: String
        var timeZone: String
        
        private enum CodingKeys: String, CodingKey {
            case information = "1. Information"
            case symbol = "2. Symbol"
            case lastRefreshed = "3. Last Refreshed"
            case interval = "4. Interval"
            case outputSize = "5. Output Size"
            case timeZone = "6. Time Zone"
        }
    }
    
    internal struct TimeSeries: Codable {
        var open: String
        var high: String
        var low: String
        var close: String
        var volume: String
        
        private enum CodingKeys: String, CodingKey {
            case open = "1. open"
            case high = "2. high"
            case low = "3. low"
            case close = "4. close"
            case volume = "5. volume"
        }
    }
}
