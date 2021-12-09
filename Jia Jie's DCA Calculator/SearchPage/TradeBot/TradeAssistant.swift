//
//  TradeAssistant.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/12/21.
//

import Foundation
struct TradeAssistant {
    private static func getQuote(symbol: String, completion: @escaping(Double) -> Void) {
        //IMPLEMENT FETCH QUOTE
    }
    
    static func sell(quote: Double, cash: Double, accumulatedShares: Double, percent: Double = 1) -> (cash: Double, accumulatedShares: Double) {
        let newCash = accumulatedShares * quote * percent + cash
        let newAccumulatedShares = accumulatedShares * (1 - percent)
        return ((newCash, newAccumulatedShares))
    }
    
    static func buy(quote: Double, cash: Double, accumulatedShares: Double, percent: Double = 1) -> (cash: Double, accumulatedShares: Double) {
        let newAccumulatedShares = ( ( cash * percent ) / quote ) + accumulatedShares
        let newCash = cash * (1 - percent)
        return ((newCash, newAccumulatedShares))
    }
}
