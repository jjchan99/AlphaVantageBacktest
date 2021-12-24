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
    var monthlyBudget: Double? = nil
    var account: Account
    var conditions: [EvaluationCondition] = []
    let record: CKRecord
    let effectiveAfter: String
    var exitTrigger: Int?
    
    init?(record: CKRecord) {
        let budget = record["budget"] as! Double
        let cash = record["cash"] as! Double
        let accumulatedShares = record["accumulatedShares"] as! Double
        let effectiveAfter = record["effectiveAfter"] as! String
        let exitTrigger = record["exitTrigger"] as! Int?
        
        self.budget = budget
        self.account = .init(cash: cash, accumulatedShares: accumulatedShares)
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
    
    init?(budget: Double, account: Account, conditions: [EvaluationCondition], effectiveAfter: String, exitTrigger: Int? = nil) {
        let record = CKRecord(recordType: "TradeBot")
                record.setValuesForKeys([
                    "budget": budget,
                    "cash": budget,
                    "accumulatedShares": 0,
                    "effectiveAfter": effectiveAfter
                ])
            if let exitTrigger = exitTrigger {
              record.setValue(exitTrigger, forKey: "exitTrigger")
             }
        self.init(record: record)
        self.conditions = conditions
        
        //MARK: EFFECTIVE AFTER IS LATEST OHLC DATE.
    }

    mutating func evaluate(previous: OHLCCloudElement, latest: OHLCCloudElement, didEvaluate: @escaping (Bool) -> Void) {
        let close = latest.close
       
        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for condition in self.conditions {
                switch condition.buyOrSell {
                case .buy:
                    guard account.cash >= 1 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    switch condition.technicalIndicator {
                    case .monthlyPeriodic:
                        account.accumulatedShares += account.decrement(monthlyBudget!) / close
                    default:
                        account.accumulatedShares += account.decrement(account.cash) / close
                    }
                        
                    switch exitTrigger {
                        case .some(exitTrigger) where exitTrigger! >= 0:
                        let newCondition = ExitTriggerManager.orUpload(latest: latest.stamp, exitAfter: exitTrigger!, tb: self) {
                            Log.queue(action: "This should be on a background thread")
                            didEvaluate(true)
                        }
                        self.conditions.append(newCondition)
                        case .some(exitTrigger) where exitTrigger! < 0:
                        self.conditions = ExitTriggerManager.andUpload(latest: latest.stamp, exitAfter: abs(exitTrigger!), tb: self) {
                            Log.queue(action: "This should be on a background thread")
                            didEvaluate(true)
                        }
                        default:
                          break
                    }
                    
                    break
                    }
                case .sell:
                    guard account.accumulatedShares > 0 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    account.cash += account.decrement(shares: account.accumulatedShares) * close
                        
                        switch exitTrigger {
                        case .some(exitTrigger) where exitTrigger! >= 0:
                            self.conditions = ExitTriggerManager.resetOrExitTrigger(tb: self) {
                            didEvaluate(true)
                    }
                        case .some(exitTrigger) where exitTrigger! < 0:
                        self.conditions = ExitTriggerManager.resetAndExitTrigger(tb: self) {
                            didEvaluate(true)
                         }
                        default:
                            break
                        }
                        
                    break
                    }
                }
            }
    }
}

extension TradeBot {
    mutating func backtest(previous: OHLCCloudElement, latest: OHLCCloudElement, didEvaluate: @escaping (Bool) -> Void) {
        let close = latest.close
       
        //MARK: CONDITION SATISFIED, INVEST 10% OF CASH
        for condition in self.conditions {
                switch condition.buyOrSell {
                case .buy:
                    guard account.cash >= 1 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    switch condition.technicalIndicator {
                    case .monthlyPeriodic:
                        account.accumulatedShares += account.decrement(monthlyBudget!) / close
                    default:
                        account.accumulatedShares += account.decrement(account.cash) / close
                    }
                        
                    switch exitTrigger {
                        case .some(exitTrigger) where exitTrigger! >= 0:
                        let newCondition = ExitTriggerManager.orUpload(latest: latest.stamp, exitAfter: exitTrigger!, tb: self, backtest: true) {
                            Log.queue(action: "This should be on a background thread")
                            didEvaluate(true)
                        }
                        self.conditions.append(newCondition)
                        case .some(exitTrigger) where exitTrigger! < 0:
                        self.conditions = ExitTriggerManager.andUpload(latest: latest.stamp, exitAfter: abs(exitTrigger!), tb: self, backtest: true) {
                            Log.queue(action: "This should be on a background thread")
                            didEvaluate(true)
                        }
                        default:
                          break
                    }
                    
                    break
                    }
                case .sell:
                    guard account.accumulatedShares > 0 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                    account.cash += account.decrement(shares: account.accumulatedShares) * close
                        
                        switch exitTrigger {
                        case .some(exitTrigger) where exitTrigger! >= 0:
                            self.conditions = ExitTriggerManager.resetOrExitTrigger(tb: self, backtest: true) {
                            didEvaluate(true)
                    }
                        case .some(exitTrigger) where exitTrigger! < 0:
                        self.conditions = ExitTriggerManager.resetAndExitTrigger(tb: self, backtest: true) {
                            didEvaluate(true)
                         }
                        default:
                            break
                        }
                        
                    break
                    }
                }
            }
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

