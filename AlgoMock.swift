//
//  AlgoMock.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 16/1/22.
//

import Foundation
struct AlgoMock {
    static func timeSeries() -> Daily {
        return Daily(meta: nil, timeSeries: mockTimeSeries, note: nil, sorted: nil)
    }
    
    static var mockTimeSeries: [String: TimeSeriesDaily] = [
        "2022-01-01" : .init(open: "25", high: "30", low: "20", close: "22", volume: "44")
    ]
    
    static func tb() -> TradeBot {
        return TradeBot(account: account(), conditions: [], holdingPeriod: 10)!
    }
}
