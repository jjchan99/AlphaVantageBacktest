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
    let record: CKRecord
    let effectiveAfter: String
    var exitTrigger: Int?
    var lm = LedgerManager()
    
    func uploadEntries(completion: @escaping (Bool) -> Void) {
        lm.upload(tb: self) { success in
        completion(success)
        }
    }
    
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
                    guard account.cash > 0 else { continue }
                    if TradeBotAlgorithm.checkNext(condition: condition, previous: previous, latest: latest, bot: self) {
                  
                    account.accumulatedShares += account.decrement(account.cash) / close
                    
                        
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
                  
                        account.accumulatedShares += account.decrement(account.cash) / close
                    
                        
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

