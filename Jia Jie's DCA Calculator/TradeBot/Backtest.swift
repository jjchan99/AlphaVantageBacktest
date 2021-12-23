//
//  Backtest.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 23/12/21.
//

import Foundation

struct Backtest {
    
    static func from(date: String, daily: Daily, bot: TradeBot) {
        let technicalManager = OHLCTechnicalManager(window: 200)
        var bot = bot
        var value = daily
        let sorted = value.sorted!
        var previous: OHLCCloudElement?
        
        for idx in 0..<sorted.count - 1 {
            let idx = sorted.count - 1 - idx
            let OHLC = technicalManager.addOHLCCloudElement(key: sorted[idx].key, value: sorted[idx].value)
            
            if previous != nil && sorted[idx].key > date {
                bot.evaluate(previous: previous!, latest: OHLC) { success in

                }
            }
            
            previous = OHLC
        }
    }
}
