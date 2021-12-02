//
//  TradeBot.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//

enum TechnicalIndicators: Hashable {
    case movingAverage(period: Int),
         bollingerBands(lowerBounds: Double, upperBounds: Double),
         RSI(value: Double)
}

import Foundation

struct TradeBot {
    
    let budget: Double
    var account: Account
    let conditions: [EvaluationCondition]
    
    enum AboveOrBelow {
        case priceAbove, priceBelow
        
        func evaluate(_ price: Double, _ technicalIndicator: Double) -> Bool {
            switch self {
            case .priceAbove:
                return price > technicalIndicator
            case .priceBelow:
                return price < technicalIndicator
            }
        }
    }
    
    enum BuyOrSell {
        case buy, sell
    }
    
    var database: TradeBotDatabase
    
    mutating func evaluate(latest: OHLC) {
        let close = Double(latest.close)!
        
        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        
        for conditions in self.conditions {
            if conditions.aboveOrBelow.evaluate(close, database.technicalIndicators[conditions.technicalIndicator]!.last!) {
                switch conditions.buyOrSell {
                case .buy:
                    account.accumulatedShares += account.decrement(0.1 * account.cash) / close
                case .sell:
                    account.cash += account.accumulatedShares * close
                }
            }
        }
    }
    
    struct EvaluationCondition {
        let technicalIndicator: TechnicalIndicators
        let aboveOrBelow: AboveOrBelow
        let buyOrSell: BuyOrSell
    }
    
 
}

struct Account {
    var cash: Double
    var accumulatedShares: Double
    
    mutating func decrement(_ amount: Double) -> Double {
        cash -= amount
        return amount
    }
}

struct TradeBotDatabase {
    var technicalIndicators: [TechnicalIndicators: [Double]]
}
