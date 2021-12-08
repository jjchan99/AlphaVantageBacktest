//
//  TradeBot.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//
import Foundation
import CloudKit
import Foundation

struct TradeBot: CloudKitInterchangeable {

    let budget: Double
    var account: Account
    var conditions: [EvaluationCondition]? { didSet { conditions = oldValue ?? conditions } }
    let cashBuyPercentage: Double
    let sharesSellPercentage: Double
    let record: CKRecord
    
    init?(record: CKRecord) {
        let budget = record["budget"] as! Double
        let cash = record["cash"] as! Double
        let accumulatedShares = record["accumulatedShares"] as! Double
        let cashBuyPercentage = record["cashBuyPercentage"] as! Double
        let sharesSellPercentage = record["sharesSellPercentage"] as! Double
        
        self.budget = budget
        self.account = .init(cash: cash, accumulatedShares: accumulatedShares)
        self.cashBuyPercentage = cashBuyPercentage
        self.sharesSellPercentage = sharesSellPercentage
        self.record = record
    }
    
    func update() -> Self {
        let record = self.record
        //DO STUFF WITH THE RECORD
        
        
        return TradeBot(record: record)!
    }
    
    init?(budget: Double, account: Account, conditions: [EvaluationCondition], cashBuyPercentage: Double, sharesSellPercentage: Double) {
        let record = CKRecord(recordType: "TradeBot")
                record.setValuesForKeys([
                    "budget": budget,
                    "cash": budget,
                    "accumulatedShares": 0,
                    "cashBuyPercentage": cashBuyPercentage,
                    "sharesSellPercentage": sharesSellPercentage
                ])
        self.init(record: record)
        self.conditions = conditions
    }


    func getIndicatorValue(i: TechnicalIndicators, element: OHLCCloudElement) -> Double? {
        switch i {
        case .movingAverage:
            return element.movingAverage
        case let .RSI(period: _, value: value):
            return value
        case let .bollingerBands(percentage: b):
            return element.valueAtPercent(percent: b)
        }
    }
    
    func getInputValue(i: TechnicalIndicators, element: OHLCCloudElement) -> Double? {
        switch i {
        case .movingAverage:
            return element.close
        case .RSI:
            return element.RSI
        case let .bollingerBands(percentage: b):
            return element.close
        }
    }
    
    func checkNext(condition: EvaluationCondition, latest: OHLCCloudElement) -> Bool {
        let inputValue = getInputValue(i: condition.technicalIndicator, element: latest)

        let xxx = getIndicatorValue(i: condition.technicalIndicator, element: latest)
        
        guard xxx != nil, inputValue != nil else { return false }
        
        print("Evaluating that the value of \(inputValue!) is \(condition.aboveOrBelow) the \(condition.technicalIndicator) of \(xxx). I have evaluated this to be \(condition.aboveOrBelow.evaluate(inputValue!, xxx!)). I will now \(condition.buyOrSell).")
        
        if condition.andCondition != nil {
        let nextCondition = condition.andCondition!
            return condition.aboveOrBelow.evaluate(inputValue!, xxx!) && checkNext(condition: nextCondition, latest: latest)
        } else {
            return condition.aboveOrBelow.evaluate(inputValue!, xxx!)
        }
    }

    mutating func evaluate(latest: OHLCCloudElement, previous: OHLCCloudElement) {
        let open = latest.open
       

        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for conditions in self.conditions! {
            let inputValue = getInputValue(i: conditions.technicalIndicator, element: previous)
            let xxx = getIndicatorValue(i: conditions.technicalIndicator, element: latest)
            guard xxx != nil, inputValue != nil else { continue }
                switch conditions.buyOrSell {
                case .buy:
                    if checkNext(condition: conditions, latest: latest) {
                    account.accumulatedShares += account.decrement(cashBuyPercentage * account.cash) / open
                    account.cash = account.cash * (1 - cashBuyPercentage)
                    break
                    }
                case .sell:
                    if checkNext(condition: conditions, latest: latest) {
                    account.cash += account.accumulatedShares * open * sharesSellPercentage
                    account.accumulatedShares = account.accumulatedShares * (1 - sharesSellPercentage)
                    break
                    }
                }
            }
    }
}

final class EvaluationCondition: CloudKitInterchangeable, CustomStringConvertible, CloudChild {
    init?(record: CKRecord) {
        let technicalIndicatorRawValue = record["technicalIndicator"] as! Double
        let aboveOrBelowRawValue = record["aboveOrBelow"] as! Int
        let buyOrSellRawValue = record["buyOrSell"] as! Int
        
        self.technicalIndicator = TechnicalIndicators.build(rawValue: technicalIndicatorRawValue)
        self.aboveOrBelow = AboveOrBelow(rawValue: aboveOrBelowRawValue)!
        self.buyOrSell = BuyOrSell(rawValue: buyOrSellRawValue)!
        self.record = record
    }
    
    convenience init?(technicalIndicator: TechnicalIndicators, aboveOrBelow: AboveOrBelow, buyOrSell: BuyOrSell, andCondition: EvaluationCondition?) {
        let record = CKRecord(recordType: "EvaluationCondition")
                record.setValuesForKeys([
                    "technicalIndicator": technicalIndicator.rawValue,
                    "aboveOrBelow": aboveOrBelow.rawValue,
                    "buyOrSell": buyOrSell.rawValue,
                ])
        self.init(record: record)
        self.andCondition = andCondition
    }
    
    var record: CKRecord
    
    func update() -> EvaluationCondition {
        return self
    }
    
    let technicalIndicator: TechnicalIndicators
    let aboveOrBelow: AboveOrBelow
    let buyOrSell: BuyOrSell
    var andCondition: EvaluationCondition? { didSet { andCondition = oldValue ?? andCondition } }
    
    var description: String {
        "Evaluation conditions: check whether the close price is \(aboveOrBelow) the \(technicalIndicator) ___ (which will be fed in). Then \(buyOrSell)"
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
            return Double(period * 10)
        case let .bollingerBands(percentage: percentage):
            return percentage
        case let .RSI(period: period, value: value):
            return Double(2 * period) + (value)
        }
    }
    
    static func build(rawValue: Double) -> Self {
        if rawValue >= 200 {
            return .movingAverage(period: Int(rawValue) / 10)
        } else if rawValue >= 4 && rawValue <= 29 {
            let period = floor(rawValue) * 0.5
            let value = Int(rawValue) % 2 == 0 ? rawValue - floor(rawValue) : 1
            return .RSI(period: Int(period), value: value)
        } else {
            return .bollingerBands(percentage: rawValue)
        }
    }
}

struct BotTransaction {
    let stamp: String
    let deltaCash: Double
    let deltaShares: Double
    
    let action: BuyOrSell
    let condition: EvaluationCondition
    let price: Double
    let stamped: String
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


