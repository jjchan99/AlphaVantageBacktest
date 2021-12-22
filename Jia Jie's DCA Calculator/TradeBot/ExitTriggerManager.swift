//
//  ExitTriggerManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/12/21.
//

import Foundation
struct ExitTriggerManager {
    
    static func orUpload(latest: String, exitAfter: Int, tb: TradeBot, completion: @escaping () -> Void) -> EvaluationCondition {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
//        conditions.append(exitTrigger)
        CloudKitUtility.saveChild(child: exitTrigger, for: tb) { success in
            completion()
        }
        return exitTrigger
    }
    
    static func andUpload(latest: String, exitAfter: Int, tb: TradeBot, completion: @escaping () -> Void) -> [EvaluationCondition] {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let group = DispatchGroup()
        var copy = tb.conditions
        
        for (outerIndex, conditions) in tb.conditions.enumerated() {
            guard conditions.buyOrSell == .sell else { continue }
//            conditions.andCondition.append(exitTrigger)
            for (index, andConditions) in conditions.andCondition.enumerated() where andConditions.technicalIndicator == .exitTrigger(value: 99999999) {
                let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
                group.enter()
                let record = andConditions.update(newCondition: exitTrigger)
                CloudKitUtility.update(item: record) { success in
                    group.leave()
                }
                group.notify(queue: .global()) {
                    completion()
                }
                
                copy[outerIndex].andCondition[index] = exitTrigger
            }
        }
        
        return copy
    }
    
}
