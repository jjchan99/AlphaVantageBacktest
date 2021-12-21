//
//  ExitTriggerManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/12/21.
//

import Foundation
struct ExitTriggerManager {
    
    static func orUpload(latest: String, exitAfter: Int, tb: TradeBot, completion: @escaping () -> Void) {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
//        conditions.append(exitTrigger)
        CloudKitUtility.saveChild(child: exitTrigger, for: tb) { success in
            completion()
        }
    }
    
    static func andUpload(latest: String, exitAfter: Int, tb: TradeBot, completion: @escaping () -> Void) {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        for conditions in tb.conditions {
            let group = DispatchGroup()
            guard conditions.buyOrSell == .sell else { continue }
//            conditions.andCondition.append(exitTrigger)
            let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
            for andConditions in conditions.andCondition where andConditions.technicalIndicator == .exitTrigger(value: 99999999) {
                group.enter()
                let record = andConditions.update(newCondition: exitTrigger)
                CloudKitUtility.update(item: record) { success in
                    group.leave()
                }
            }
        }
    }
    
}
