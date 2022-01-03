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
    
    static func orUpload(latest: String, exitAfter: Int, tb: TradeBot) -> EvaluationCondition {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
        
        return exitTrigger
    }
    
    static func resetOrExitTrigger(tb: TradeBot) -> [EvaluationCondition] {
        var copy = tb.conditions
        for (index, condition) in tb.conditions.enumerated() {
                guard condition.enterOrExit == .exit else { continue }
                switch condition.technicalIndicator {
                case .exitTrigger:
                    copy.remove(at: index)
                default:
                    break
                }
            }
        return copy
    }
    
    static func resetAndExitTrigger(tb: TradeBot) -> [EvaluationCondition] {
        var copy = tb.conditions
        let group = DispatchGroup()
        for (outerIndex, conditions) in tb.conditions.enumerated() {
            guard conditions.enterOrExit == .exit else { continue }
            for (index, andConditions) in conditions.andCondition.enumerated() {
                switch andConditions.technicalIndicator {
                case .exitTrigger:
                    group.enter()
            
                    
                    copy[outerIndex].andCondition[index].technicalIndicator = .exitTrigger(value: 99999999)
                default:
                    break
            }
            }
        }
      
        return copy
    }
    
    
    static func andUpload(latest: String, exitAfter: Int, tb: TradeBot) -> [EvaluationCondition] {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
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
