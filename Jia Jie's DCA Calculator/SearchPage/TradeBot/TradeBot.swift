//
//  TradeBot.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//
import Foundation
import CloudKit

enum TechnicalIndicators: Hashable, CustomStringConvertible {

    case movingAverage(period: Int),
         bollingerBands(percentage: Double),
         RSI(period: Int, value: Double)

    var description: String {
        switch self {
        case let .movingAverage(period: period):
            return ("\(period) day moving average")
        case let .bollingerBands(percentage: percentage):
            return ("\(percentage)%B")
        case let .RSI(period: period, value: value):
            return "\(period) period RSI value of \(value)"
        }
    }

    var rawValue: Double {
        switch self {
        case let .movingAverage(period: period):
            return Double(period)
        case let .bollingerBands(percentage: percentage):
            return percentage
        case let .RSI(period: period, value: value):
            return 69
        }
    }

}

import Foundation

struct TradeBot: CloudKitInterchangeable {

    let budget: Double
    var account: Account
    let conditions: [EvaluationCondition]
    let cashBuyPercentage: Double = 1
    let sharesSellPercentage: Double = 1
    
    init?(record: CKRecord) {
        
    }

    enum AboveOrBelow: Int, CustomStringConvertible {
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

    enum BuyOrSell: Int, CustomStringConvertible {
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

    func getIndicatorValue(i: TechnicalIndicators, element: OHLCCloudElement) -> Double {
        switch i {
        case .movingAverage:
            return element.movingAverage
        case .RSI:
            return element.RSI!
        case let .bollingerBands(percentage: b):
            return element.valueAtPercent(percent: b)!
        }
    }

    mutating func evaluate(latest: OHLCCloudElement) {
        let close = latest.close

        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for conditions in self.conditions {
            let xxx = getIndicatorValue(i: conditions.technicalIndicator, element: latest)

            if conditions.aboveOrBelow.evaluate(close, xxx) {
                switch conditions.buyOrSell {
                case .buy:
                    print("Evaluating that the closing price of \(close) is \(conditions.aboveOrBelow) the \(conditions.technicalIndicator) of \(xxx). I have evaluated this to be true. I will now \(conditions.buyOrSell).")
                    account.accumulatedShares += account.decrement(cashBuyPercentage * account.cash) / close
                    account.cash = account.cash * (1 - cashBuyPercentage)
                case .sell:
                    print("Evaluating that the closing price of \(close) is \(conditions.aboveOrBelow) the \(conditions.technicalIndicator) of \(xxx). I have evaluated this to be true. I will now \(conditions.buyOrSell).")
                    account.cash += account.accumulatedShares * close * sharesSellPercentage
                    account.accumulatedShares = account.accumulatedShares * (1 - sharesSellPercentage)
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
