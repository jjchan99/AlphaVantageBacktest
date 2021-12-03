//
//  TradeBot.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//

enum TechnicalIndicators: Hashable, CustomStringConvertible {
    case movingAverage(period: Int),
         bollingerBands(lowerBounds: Double, upperBounds: Double),
         RSI(period: Int, value: Double)
    
    var description: String {
        switch self {
        case let .movingAverage(period: period):
            return ("\(period) day moving average")
        case let .bollingerBands(lowerBounds: lower, upperBounds: upper):
            return "bollinger band with lower bound \(lower) and upper bound \(upper)"
        case let .RSI(period: period, value: value):
            return "\(period) period RSI value of \(value)"
        }
    }
}

import Foundation

struct TradeBot {
    
    let budget: Double
    var account: Account
    let conditions: [EvaluationCondition]
    let cashBuyPercetange: Double = 1
    let sharesSellPercetange: Double = 1
    var database: TradeBotDatabase
    
    enum AboveOrBelow: CustomStringConvertible {
        case priceAbove, priceBelow
        
        var description: String {
        switch self {
        case .priceAbove:
            return "above"
        case .priceBelow:
            return "below"
        }
        }
        
        func evaluate(_ price: Double, _ technicalIndicator: Double) -> Bool {
            switch self {
            case .priceAbove:
                return price > technicalIndicator
            case .priceBelow:
                return price < technicalIndicator
            }
        }
    }
    
    enum BuyOrSell: CustomStringConvertible {
        var description: String {
            switch self {
            case .buy:
                return "buy"
            case .sell:
                return "sell"
            }
        }
        case buy, sell
    }
    
    mutating func evaluate(latest: OHLC) {
        let close = Double(latest.close)!
        
        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        
        for conditions in self.conditions {
            if conditions.aboveOrBelow.evaluate(close, database.technicalIndicators[conditions.technicalIndicator]!.last!) {
                switch conditions.buyOrSell {
                case .buy:
                    print("Evaluating that the closing price of \(close) is \(conditions.aboveOrBelow) the \(conditions.technicalIndicator) of \(database.technicalIndicators[conditions.technicalIndicator]!.last!). I have evaluated this to be true. I will now \(conditions.buyOrSell).")
                    account.accumulatedShares += account.decrement(cashBuyPercetange * account.cash) / close
                    account.cash = account.cash * (1 - cashBuyPercetange)
                case .sell:
                    print("Evaluating that the closing price of \(close) is \(conditions.aboveOrBelow) the \(conditions.technicalIndicator) of \(database.technicalIndicators[conditions.technicalIndicator]!.last!). I have evaluated this to be true. I will now \(conditions.buyOrSell).")
                    account.cash += account.accumulatedShares * close * sharesSellPercetange
                    account.accumulatedShares = account.accumulatedShares * (1 - sharesSellPercetange)
                }
            } else {
                    
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
