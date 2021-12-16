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
    var conditions: [EvaluationCondition] = []
    let cashBuyPercentage: Double
    let sharesSellPercentage: Double
    let record: CKRecord
    let effectiveAfter: String
    
    init?(record: CKRecord) {
        let budget = record["budget"] as! Double
        let cash = record["cash"] as! Double
        let accumulatedShares = record["accumulatedShares"] as! Double
        let cashBuyPercentage = record["cashBuyPercentage"] as! Double
        let sharesSellPercentage = record["sharesSellPercentage"] as! Double
        let effectiveAfter = record["effectiveAfter"] as! String
        
        self.budget = budget
        self.account = .init(cash: cash, accumulatedShares: accumulatedShares)
        self.cashBuyPercentage = cashBuyPercentage
        self.sharesSellPercentage = sharesSellPercentage
        self.record = record
        self.effectiveAfter = effectiveAfter
    }
    
    func update() -> Self {
        let record = self.record
        //DO STUFF WITH THE RECORD
        
        return TradeBot(record: record)!
    }
    
    init?(budget: Double, account: Account, conditions: [EvaluationCondition], cashBuyPercentage: Double, sharesSellPercentage: Double, effectiveAfter: String) {
        let record = CKRecord(recordType: "TradeBot")
                record.setValuesForKeys([
                    "budget": budget,
                    "cash": budget,
                    "accumulatedShares": 0,
                    "cashBuyPercentage": cashBuyPercentage,
                    "sharesSellPercentage": sharesSellPercentage,
                    "effectiveAfter": effectiveAfter
                ])
        self.init(record: record)
        self.conditions = conditions
    }


    func getIndicatorValue<T: Comparable>(i: TechnicalIndicators, element: OHLCCloudElement) -> T? {
        switch i {
        case .movingAverage:
            return element.movingAverage as! T?
        case let .RSI(period: _, value: value):
            return value * 100 as! T?
        case let .bollingerBands(percentage: b):
            return element.valueAtPercent(percent: b) as! T?
        case .monthlyPeriodic:
            return DateManager.date(from: element.stamp) as! T?
        }
    }
    
    func getInputValue<T: Comparable>(i: TechnicalIndicators, element: OHLCCloudElement) -> T? {
        switch i {
        case .movingAverage:
            return element.movingAverage as! T?
        case .RSI:
            return element.RSI as! T?
        case .bollingerBands:
            return element.close as! T?
        case .monthlyPeriodic:
            return DateManager.date(from: element.stamp) as! T?
        }
    }
    
    func checkNext(condition: EvaluationCondition, previous: OHLCCloudElement, latest: OHLCCloudElement? = nil) -> Bool {
        let andCondition = condition.andCondition
        for index in andCondition.indices {
            let condition = andCondition[index]
            switch condition.technicalIndicator {
            case .monthlyPeriodic:
        
                var inputValue: Date!
                var xxx: Date!
                
                inputValue = getInputValue(i: condition.technicalIndicator, element: previous)
                xxx = getIndicatorValue(i: condition.technicalIndicator, element: latest!)
                
                return DateManager.checkIfNewMonth(previous: inputValue, next: xxx)
            default:
                var inputValue: Double?
                var xxx: Double?
                
                inputValue = getInputValue(i: condition.technicalIndicator, element: previous)
                xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
                
                guard xxx != nil, inputValue != nil else { return false }
                
                print("Evaluating that the value of \(inputValue!) is \(condition.aboveOrBelow) the \(condition.technicalIndicator) of \(xxx!). I have evaluated this to be \(condition.aboveOrBelow.evaluate(inputValue!, xxx!)).")
                
                if index == andCondition.indices.last {
                   return condition.aboveOrBelow.evaluate(inputValue!, xxx!)
                }
            
                if condition.aboveOrBelow.evaluate(inputValue!, xxx!) {
                   continue
                } else {
                    return false
                }
        }
    }
        switch condition.technicalIndicator {
        case .monthlyPeriodic:
            var inputValue: Date!
            var xxx: Date!
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: previous)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: latest!)
            
            return DateManager.checkIfNewMonth(previous: inputValue, next: xxx)
        default:
            var inputValue: Double?
            var xxx: Double?
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: previous)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
            guard xxx != nil, inputValue != nil else { return false }
            return condition.aboveOrBelow.evaluate(inputValue!, xxx!)
        }
    }

    mutating func evaluate(previous: OHLCCloudElement, latest: OHLCCloudElement) {
        let open = latest.open
       

        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for condition in self.conditions {
//            let inputValue = getInputValue(i: conditions.technicalIndicator, element: previous)
//            let xxx = getIndicatorValue(i: conditions.technicalIndicator, element: previous)
//            guard xxx != nil, inputValue != nil else { continue }
                switch condition.buyOrSell {
                case .buy:
                    if checkNext(condition: condition, previous: previous, latest: latest) {
                    switch condition.technicalIndicator {
                    case .monthlyPeriodic:
                        account.accumulatedShares += account.decrement(MonthlyAdapter.getMonthlyInvestment(cbp: cashBuyPercentage, budget: budget)) / open
                    default:
                    account.accumulatedShares += account.decrement(cashBuyPercentage * account.cash) / open
                    }
                    break
                    }
                case .sell:
                    if checkNext(condition: condition, previous: previous) {
                    account.cash += account.decrement(shares: account.accumulatedShares * sharesSellPercentage) * open
                    break
                    }
                }
            }
    }
}

struct EvaluationCondition: CloudKitInterchangeable, CustomStringConvertible, CloudChild {
    
    init?(record: CKRecord) {
        let technicalIndicatorRawValue = record["technicalIndicator"] as! Double
        let aboveOrBelowRawValue = record["aboveOrBelow"] as! Int
        let buyOrSellRawValue = record["buyOrSell"] as! Int
        
        self.technicalIndicator = TechnicalIndicators.build(rawValue: technicalIndicatorRawValue)
        self.aboveOrBelow = AboveOrBelow(rawValue: aboveOrBelowRawValue)!
        self.buyOrSell = BuyOrSell(rawValue: buyOrSellRawValue)!
        self.record = record
    }
    
    init?(technicalIndicator: TechnicalIndicators, aboveOrBelow: AboveOrBelow, buyOrSell: BuyOrSell, andCondition: [EvaluationCondition]) {
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
        let record = self.record
        //DO STUFF WITH THE RECORD
        
        return .init(record: record)!
    }
    
    let technicalIndicator: TechnicalIndicators
    let aboveOrBelow: AboveOrBelow
    let buyOrSell: BuyOrSell
    var andCondition: [EvaluationCondition] = []
    
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
    
    mutating func decrement(shares: Double) -> Double {
        accumulatedShares -= shares
        return shares
    }
    
    func netWorth(quote: Double) -> Double {
        return accumulatedShares * quote + cash
    }
}

struct TransactionHistory {
    var latest: Double
    var previous: Double
    var evaluations: [String]
    var previousCash: Double
    var newCash: Double
    var previousShares: Double
    var newShares: Double
    var action: BuyOrSell
}

enum TechnicalIndicators: Hashable, CustomStringConvertible {

    case movingAverage(period: Int),
         bollingerBands(percentage: Double),
         RSI(period: Int, value: Double),
         monthlyPeriodic

    var description: String {
        switch self {
        case let .movingAverage(period: period):
            return ("\(period) day moving average")
        case let .bollingerBands(percentage: percentage):
            return ("\(percentage)%B")
        case let .RSI(period: period, value: value):
            return "\(period) period RSI value of \(value)"
        case .monthlyPeriodic:
            return "monthly end investment"
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
        case let .monthlyPeriodic:
            return 69
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

struct MonthlyAdapter {
    
    //MARK: Where Budget = Initial Investment
    
    static func getMonthlyInvestment(cbp: Double, budget: Double) -> Double {
        return cbp * budget
    }
    
    static func monthlyInvestmentToCbp(monthlyInvestment: Double, budget: Double) -> Double {
        return monthlyInvestment / budget
    }
    
}

