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
    let long: Bool 
    var account: Account
    var conditions: [EvaluationCondition] = []
    let record: CKRecord
    var holdingPeriod: Int?
    
    init?(record: CKRecord) {
        let budget = record["budget"] as! Double
        let cash = record["cash"] as! Double
        let accumulatedShares = record["accumulatedShares"] as! Double
        let holdingPeriod = record["holdingPeriod"] as! Int?
        let long = record["long"] as! Bool
        
        self.account = .init(budget: budget, cash: cash, accumulatedShares: accumulatedShares)
        self.record = record
        self.holdingPeriod = holdingPeriod
        self.long = long
    }
    
    func update() -> Self {
        let record = self.record

        return TradeBot(record: record)!
    }
    
    init?(account: Account, conditions: [EvaluationCondition], holdingPeriod: Int? = nil, long: Bool = true) {
        let record = CKRecord(recordType: "TradeBot")
                record.setValuesForKeys([
                    "budget": account.budget,
                    "cash": account.budget,
                    "accumulatedShares": 0,
                    "long" : long
                ])
            if let holdingPeriod = holdingPeriod {
              record.setValue(holdingPeriod, forKey: "holdingPeriod")
             }
        self.init(record: record)
        self.conditions = conditions
        
        //MARK: EFFECTIVE AFTER IS LATEST OHLC DATE.
    }
}

extension TradeBot {
    
}

struct Account {
    let budget: Double
    var cash: Double
    var accumulatedShares: Double
    
    func longProfit(quote: Double) -> Double {
        let value = (accumulatedShares * quote + cash) - budget
        return value / budget
    }
    
    func shortProfit(quote: Double) -> Double {
        let value = (budget - cash) - (accumulatedShares * quote)
        return value / budget
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
    
    var opposingDescription: String {
        switch self {
        case .priceAbove:
            return "below"
        case .priceBelow:
            return "above"
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

enum EnterOrExit: Int, CustomStringConvertible {
    var description: String {
        switch self {
        case .enter:
            return "enter"
        case .exit:
            return "exit"
        }
    }
    
    var opposingDescription: String {
        switch self {
        case .enter:
            return "exit"
        case .exit:
            return "enter"
        }
    }
    case enter, exit
}

