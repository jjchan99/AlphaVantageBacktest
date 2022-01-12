//
//  ExitTriggerManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/12/21.
//

import Foundation
import Combine

struct ExitTriggerManager {
    static var subs = Set<AnyCancellable>()
    
    static func orUpload(tb: TradeBot, context: ContextObject) -> [EvaluationCondition] {
        var copy = tb.conditions
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: context.mostRecent.stamp), value: abs(tb.exitTrigger!))
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
        for (index, condition) in tb.conditions.enumerated() where condition.technicalIndicator == .exitTrigger(value: 99999999) {
             copy[index] = exitTrigger
        }
        
        return copy
    }
    
    static func resetOrExitTrigger(tb: TradeBot) -> [EvaluationCondition] {
        var copy = tb.conditions
        for (index, condition) in tb.conditions.enumerated() {
                guard condition.enterOrExit == .exit else { continue }
                switch condition.technicalIndicator {
                case .exitTrigger:
                    copy[index].technicalIndicator = .exitTrigger(value: 99999999)
                default:
                    break
                }
            }
        return copy
    }
    
    static func resetAndExitTrigger(tb: TradeBot) -> [EvaluationCondition] {
        var copy = tb.conditions
     
        for (outerIndex, conditions) in tb.conditions.enumerated() {
            guard conditions.enterOrExit == .exit else { continue }
            for (index, andConditions) in conditions.andCondition.enumerated() {
                switch andConditions.technicalIndicator {
                case .exitTrigger:
                    copy[outerIndex].andCondition[index].technicalIndicator = .exitTrigger(value: 99999999)
                default:
                    break
            }
            }
        }
      
        return copy
    }
    
    
    static func andUpload(tb: TradeBot, context: ContextObject) -> [EvaluationCondition] {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: context.mostRecent.stamp), value: abs(tb.exitTrigger!))
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
     
        var copy = tb.conditions
        
        for (outerIndex, conditions) in tb.conditions.enumerated() {
            guard conditions.enterOrExit == .exit else { continue }
//            conditions.andCondition.append(exitTrigger)
            for (index, andConditions) in conditions.andCondition.enumerated() where andConditions.technicalIndicator == .exitTrigger(value: 99999999) {
        
                copy[outerIndex].andCondition[index].technicalIndicator = .exitTrigger(value: Int(withoutNoise)!)
            }
        }
        
        return copy
    }
    
}
