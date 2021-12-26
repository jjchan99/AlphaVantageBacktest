//
//  TradeBotAlgorithm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 19/12/21.
//

import Foundation
struct TradeBotAlgorithm {
    
    private static func performCheck(condition: EvaluationCondition, previous: OHLCCloudElement, latest: OHLCCloudElement, bot: TradeBot) -> (outcome: Bool, description: String) {
        var inputValue: Double?
        var xxx: Double?
        
        switch condition.technicalIndicator {
        case .monthlyPeriodic:
    
            var inputValue: Date!
            var xxx: Date!
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: latest)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
            let description: String = "It is a new month"
            let outcome = DateManager.checkIfNewMonth(previous: inputValue, next: xxx)
            
            return (outcome, description)
        case .movingAverage, .RSI:
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: latest)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
        case .profitTarget:
            
            inputValue = bot.account.profit(quote: latest.close, budget: bot.budget)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
        case .exitTrigger:
            
            var inputValue: String!
            var xxx: String!
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: latest)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
            let description: String = "The date is \(inputValue). Exit date is \(xxx). Condition is \(inputValue > xxx)."
            guard xxx != nil, inputValue != nil else { return
                    (false, "")
            }
               
            let outcome = inputValue > xxx
            return (outcome, description)
        
        default:
            
            inputValue = getInputValue(i: condition.technicalIndicator, element: latest)
            xxx = getIndicatorValue(i: condition.technicalIndicator, element: previous)
            
        }
        
        guard xxx != nil, inputValue != nil else { return
            (false, "")
        }
        
        let outcome = condition.aboveOrBelow.evaluate(inputValue!, xxx!)
        let description: String = "The value of \(inputValue!) is \(condition.aboveOrBelow) the \(condition.technicalIndicator) of \(xxx!). Condition is \(condition.aboveOrBelow.evaluate(inputValue!, xxx!))."
        
        return (outcome, description)
    }
    
    //MARK: SCENARIO 1: INDICATORS BASED ON OPEN. ELEMENT IS ALWAYS MOST RECENT. SECNARIO 2: INDICATORS BASED ON CLOSE. ELEMENT IS PREVIOUS FOR INDICATORS. ELEMENT IS MOST RECENT FOR PRICE INPUT (USING OPEN).
    
    //MARK: UPDATED THOUGHTS: You are currently comparing most recent open to previous close, and buying on most recent close. You have options:
    // 1 - Compare previous close to previous close. Buy on most recent open (lagging indicator, results only published at end of day based on API. Check again?)
    // 2 - Compare most recent close to most recent close. Buy on most recent close (only 90% realistic as MOC orders need leeway)
    // 3 - Compare previous close to previous close. Buy on most recent close (Simulate MOC order).
    // Conclusion: Depends on aim. Realism: Option 1, 3, and current. User satisfaction (result publishing): Option 2.
    // Current and option 3 is not much different. Current option feels inherently "More live". (Recency of input value) and hence current option is better.
    // Alternative: Compare most recent open to most recent open, buy on most recent close. (Change indicator parameter as 'open'). Again, slight advantage is recency. (Recency of indicator value from previous to most recent).
    static func getInputValue<T: Comparable>(i: TechnicalIndicators, element: OHLCCloudElement) -> T? {
        switch i {
        case .movingAverage:
            return element.movingAverage as! T?
        case .RSI:
            return element.RSI as! T?
        case .bollingerBands:
            return element.open as! T?
        case .monthlyPeriodic:
            return DateManager.date(from: element.stamp) as! T?
        case .stopOrder:
            //MARK: INPUT: LATEST OPEN
            return element.open as! T?
        case .profitTarget:
            return nil
        case .exitTrigger:
            return element.stamp as! T?
        }
    }
    
    //MARK: INDICATOR VALUE IS ALWAYS PREVIOUS
    static func getIndicatorValue<T: Comparable>(i: TechnicalIndicators, element: OHLCCloudElement) -> T? {
        switch i {
        case .movingAverage:
            return element.movingAverage as! T?
        case let .RSI(period: _, value: value):
            return value * 100 as! T?
        case let .bollingerBands(percentage: b):
            return element.valueAtPercent(percent: b) as! T?
        case .monthlyPeriodic:
            return DateManager.date(from: element.stamp) as! T?
        case .stopOrder(let value):
            return value as! T?
        case .profitTarget(value: let value):
            return value as! T?
        case .exitTrigger(value: let value):
            return DateManager.addNoise(fromString: "\(value)") as! T?
        }
    }
    
    static func checkNext(condition: EvaluationCondition, previous: OHLCCloudElement, latest: OHLCCloudElement, bot: TradeBot) -> Bool {
        var description: String = ""
        let check = performCheck(condition: condition, previous: previous, latest: latest, bot: bot)
        if check.outcome {
            description.append(check.description)
        for index in condition.andCondition.indices {
            let condition = condition.andCondition[index]
            
            let check = performCheck(condition: condition, previous: previous, latest: latest, bot: bot)
            if check.outcome
            {
                description.append("\n\(check.description)")
                continue
            } else {
                return false
            }
        }
            
        bot.lm.append(description: description, latest: latest, bot: bot, condition: condition)
        return true
        } else {
            return false
        }
    }
}
