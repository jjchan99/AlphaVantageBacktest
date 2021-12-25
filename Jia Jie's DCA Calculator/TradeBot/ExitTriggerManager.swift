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
    
    static func orUpload(latest: String, exitAfter: Int, tb: TradeBot, backtest: Bool = false, completion: @escaping () -> Void) -> EvaluationCondition {
        let date = DateManager.addDaysToDate(fromDate: DateManager.date(from: latest), value: exitAfter)
        let dateString = DateManager.string(fromDate: date)
        let withoutNoise = DateManager.removeNoise(fromString: dateString)
        let exitTrigger = EvaluationCondition(technicalIndicator: .exitTrigger(value: Int(withoutNoise)!), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
//        conditions.append(exitTrigger)
        if !backtest {
        CloudKitUtility.saveChild(child: exitTrigger, for: tb) { success in
            completion()
        }
        }
        
        return exitTrigger
    }
    
    static func resetOrExitTrigger(tb: TradeBot, backtest: Bool = false, completion: @escaping () -> Void) -> [EvaluationCondition] {
        var copy = tb.conditions
        for (index, condition) in tb.conditions.enumerated() {
                guard condition.buyOrSell == .sell else { continue }
                switch condition.technicalIndicator {
                case .exitTrigger:
                    if !backtest {
                    CloudKitUtility.delete(item: condition)
                        .sink { _ in
                            
                        } receiveValue: { success in
                            completion()
                        }
                        .store(in: &subs)
                    }
                    copy.remove(at: index)
                default:
                    break
                }
            }
        return copy
    }
    
    static func resetAndExitTrigger(tb: TradeBot, backtest: Bool = false, completion: @escaping () -> Void) -> [EvaluationCondition] {
        var copy = tb.conditions
        let group = DispatchGroup()
        for (outerIndex, conditions) in tb.conditions.enumerated() {
            guard conditions.buyOrSell == .sell else { continue }
            for (index, andConditions) in conditions.andCondition.enumerated() {
                switch andConditions.technicalIndicator {
                case .exitTrigger:
                    group.enter()
                let exitTrigger: EvaluationCondition = .init(technicalIndicator: .exitTrigger(value: 99999999), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
                
                if !backtest {
                let record = andConditions.update(newCondition: exitTrigger)
                CloudKitUtility.update(item: record) { success in
                    print("Reset and exit trigger")
                    group.leave()
                }
                }
                    
                copy[outerIndex].andCondition[index] = exitTrigger
                default:
                    break
            }
            }
        }
        group.notify(queue: .global()) {
            completion()
        }
        
        return copy
    }
    
    
    static func andUpload(latest: String, exitAfter: Int, tb: TradeBot, backtest: Bool = false, completion: @escaping () -> Void) -> [EvaluationCondition] {
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
                
                
                if !backtest {
                group.enter()
                let record = andConditions.update(newCondition: exitTrigger)
                 CloudKitUtility.update(item: record) { success in
                    group.leave()
                } }
                
                copy[outerIndex].andCondition[index] = exitTrigger
            }
        }
        
        group.notify(queue: .global()) {
            completion()
        }
        
        return copy
    }
    
}
