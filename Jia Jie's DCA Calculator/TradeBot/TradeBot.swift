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
    var exitTrigger: Int?
    
    init?(record: CKRecord) {
        let budget = record["budget"] as! Double
        let cash = record["cash"] as! Double
        let accumulatedShares = record["accumulatedShares"] as! Double
        let cashBuyPercentage = record["cashBuyPercentage"] as! Double
        let sharesSellPercentage = record["sharesSellPercentage"] as! Double
        let effectiveAfter = record["effectiveAfter"] as! String
        let exitTrigger = record["exitTrigger"] as! Int
        
        self.budget = budget
        self.account = .init(cash: cash, accumulatedShares: accumulatedShares)
        self.cashBuyPercentage = cashBuyPercentage
        self.sharesSellPercentage = sharesSellPercentage
        self.record = record
        self.effectiveAfter = effectiveAfter
        self.exitTrigger = exitTrigger
    }
    
    func update(effectiveAfter: String?, cash: Double? = nil, accumulatedShares: Double? = nil) -> Self {
        let record = self.record
        
        //MARK: SCENARIO 1: UPDATING EFFECTIVE AFTER
        if let effectiveAfter = effectiveAfter {
            record["effectiveAfter"] = effectiveAfter
        }
        
        //MARK: SCENARIO 2: BUYING/SELLING - REQUIRES UPDATES IN ACCOUNT AND TRANSACTION HISTORY.
        if let cash = cash, let accumulatedShares = accumulatedShares {
            record["cash"] = cash
            record["accumulatedShares"] = accumulatedShares
        }
        
        return TradeBot(record: record)!
    }
    
    init?(budget: Double, account: Account, conditions: [EvaluationCondition], cashBuyPercentage: Double, sharesSellPercentage: Double, effectiveAfter: String, exitTrigger: Int? = nil) {
        let record = CKRecord(recordType: "TradeBot")
                record.setValuesForKeys([
                    "budget": budget,
                    "cash": budget,
                    "accumulatedShares": 0,
                    "cashBuyPercentage": cashBuyPercentage,
                    "sharesSellPercentage": sharesSellPercentage,
                    "effectiveAfter": effectiveAfter
                ])
            if let exitTrigger = exitTrigger {
              record.setValue(exitTrigger, forKey: "exitTrigger")
             }
        self.init(record: record)
        self.conditions = conditions
        
        //MARK: EFFECTIVE AFTER IS LATEST OHLC DATE.
    }
    
    func checkNext(condition: EvaluationCondition, previous: OHLCCloudElement, latest: OHLCCloudElement, bot: TradeBot) -> Bool {
        if TradeBotAlgorithm.performCheck(condition: condition, previous: previous, latest: latest, bot: bot) {
        for index in condition.andCondition.indices {
            let condition = condition.andCondition[index]
            if TradeBotAlgorithm.performCheck(condition: condition, previous: previous, latest: latest, bot: bot) {
                continue
            } else {
                return false
            }
        }
        return true
        } else {
            return false
        }
    }

    mutating func evaluate(previous: OHLCCloudElement, latest: OHLCCloudElement, didEvaluate: @escaping (Bool) -> Void) {
        let close = latest.close
       

        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for condition in self.conditions {
//            let inputValue = getInputValue(i: conditions.technicalIndicator, element: previous)
//            let xxx = getIndicatorValue(i: conditions.technicalIndicator, element: previous)
//            guard xxx != nil, inputValue != nil else { continue }
                switch condition.buyOrSell {
                case .buy:
                    guard account.cash >= 1 else { continue }
                    if checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    switch condition.technicalIndicator {
                    case .monthlyPeriodic:
                        account.accumulatedShares += account.decrement(MonthlyAdapter.getMonthlyInvestment(cbp: cashBuyPercentage, budget: budget)) / close
                    default:
                        account.accumulatedShares += account.decrement(cashBuyPercentage * account.cash) / close
                    }
                        
                        if exitTrigger != nil {
                            print("entry triggered on \(latest.stamp)")
                            let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest.stamp), value: exitTrigger!)
                            let dateString = DateManager.string(fromDate: date)
                            let withoutNoise = DateManager.removeNoise(fromString: dateString)
                            let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
                            conditions.append(exitTrigger)
                            CloudKitUtility.saveChild(child: exitTrigger, for: self) { completion in
                                didEvaluate(completion)
                        }
                        }
                    break
                    }
                case .sell:
                    guard account.accumulatedShares > 0 else { continue }
                    if checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    account.cash += account.decrement(shares: account.accumulatedShares * sharesSellPercentage) * close
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
    
    func profit(quote: Double, budget: Double) -> Double {
        (accumulatedShares * quote + cash) - budget
    }

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
         monthlyPeriodic,
         stopOrder(value: Double),
         profitTarget(value: Double),
         exitTrigger(value: Int)

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
        case .stopOrder(value: let value):
            return "stop order initiates at \(value)"
        case .profitTarget(value: let value):
            return "stop order initiates when profit is at \(value)"
        case .exitTrigger(value: let value):
            return "exiting on \(value)"
        }
    }

    var rawValue: Double {
        switch self {
        case let .movingAverage(period: period):
            return Double(period)
        case let .bollingerBands(percentage: percentage):
            return percentage
        case let .RSI(period: period, value: value):
            return Double(2 * period) + (value)
        case .monthlyPeriodic:
            return 69
        case .stopOrder(value: let value):
            return value + 1000000
        case .profitTarget(value: let value):
            return value + 2
        case .exitTrigger(value: let value):
            return Double(value)
        }
    }
    
    static func build(rawValue: Double) -> Self {
        
        switch rawValue {
        case let x where x >= 10000000:
            return exitTrigger(value: Int(rawValue))
            
        case let x where x >= 1000000:
            return .stopOrder(value: rawValue - 1000000)
            
        case let x where x >= 50:
            return .movingAverage(period: Int(rawValue))
            
        case let x where x == 69:
            return .monthlyPeriodic
            
        case let x where x >= 4 && x <= 29:
            let period = floor(rawValue) * 0.5
            let value = Int(rawValue) % 2 == 0 ? rawValue - floor(rawValue) : 1
            return .RSI(period: Int(period), value: value)
       
        case let x where x >= 2:
            return .profitTarget(value: rawValue - 2)
       
        default:
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

