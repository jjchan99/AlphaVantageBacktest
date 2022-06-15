//
//  ExitTriggerManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/12/21.
//

import Foundation
import Combine

struct HoldingPeriodManager {
    
    static func entryTriggered(tb: TradeBot, context: ContextObject) -> [EvaluationCondition] {
        var copy = tb.conditions
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: context.mostRecent.stamp), value: abs(tb.holdingPeriod!))
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let exitTrigger = EvaluationCondition(technicalIndicator: .holdingPeriod(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
        for (index, condition) in tb.conditions.enumerated() where condition.technicalIndicator == .holdingPeriod(value: 99999999) {
             copy[index] = exitTrigger
        }
        
        return copy
    }
    
    static func resetPosition(tb: TradeBot) -> [EvaluationCondition] {
        var copy = tb.conditions
        for (index, condition) in tb.conditions.enumerated() {
                guard condition.enterOrExit == .exit else { continue }
                switch condition.technicalIndicator {
                case .holdingPeriod:
                    copy[index].technicalIndicator = .holdingPeriod(value: 99999999)
                default:
                    break
                }
            }
        return copy
    }
    
}
