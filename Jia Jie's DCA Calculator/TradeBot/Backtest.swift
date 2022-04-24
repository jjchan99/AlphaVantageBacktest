//
//  Backtest.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 23/12/21.
//

import Foundation

struct Backtest {
    
    static func from(date: String, daily: Daily, bot: TradeBot) {
        let technicalManager = OHLCTechnicalManager()
        let context: ContextObject = .init(account: bot.account, tb: bot)
        var algo: TBTemplateMethod = bot.holdingPeriod == nil ? TBAlgorithmDefault(context: context) : TBAlgorithmHoldingPeriod(context: context)
        var value = daily
        let sorted = value.sorted!
        var previous: OHLCCloudElement?
        
        for idx in 0..<sorted.count - 1 {
            let idx = sorted.count - 1 - idx
            let OHLC = technicalManager.addOHLCCloudElement(key: sorted[idx].key, value: sorted[idx].value)
            
            if previous != nil && sorted[idx].key > date {
                algo.context = context.updateTickers(previous: previous!, mostRecent: OHLC)
                algo.templateMethod()
            }
            
            previous = OHLC
        }
    }
}
