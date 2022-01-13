//
//  InputCRUDManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 29/12/21.
//

import Foundation

class InputRepository: ObservableObject {
    
    @Published private(set) var entryTriggers: [String: EvaluationCondition] = [:] { didSet {
        print(entryTriggers)
    }}
    
    @Published private(set) var entryTrade: [String: EvaluationCondition] = [:]
    
    @Published private(set) var exitTriggers: [String: EvaluationCondition] = [:]
    
    @Published private(set) var exitTrade: [String: EvaluationCondition] = [:]
    
   
    
    func getKey(for condition: EvaluationCondition) -> String {
        switch condition.technicalIndicator {
        case .movingAverage:
            return "MA"
        case .bollingerBands:
            return "BB"
        case .RSI:
            return "RSI"
        case .lossTarget:
            return "LL"
        case .holdingPeriod:
            return "HP"
        case .profitTarget:
            return "PT"
        case .movingAverageOperation:
            return "MACrossover"
        }
    }
    
    func getDict(index: Int) -> InputRepository.Dict {
        switch index {
        case 0:
            return .entryTriggers
        case 1:
            return .entryTrade
        case 2:
            return .exitTriggers
        case 3:
            return .exitTrade
        default:
            fatalError()
        }
    }
    
    enum Dict {
        case entryTriggers, entryTrade, exitTriggers, exitTrade
    }
    
    func get(dict: Dict) -> [String: EvaluationCondition] {
        switch dict {
        case .entryTriggers:
            return entryTriggers
        case .entryTrade:
            return entryTrade
        case .exitTriggers:
            return exitTriggers
        case .exitTrade:
            return exitTrade
        }
    }
    
    func getAction(dict: Dict) -> (EvaluationCondition) -> (Void) {
        switch dict {
        case .entryTriggers:
            return createEntryTrigger
        case .entryTrade:
            return createEntryTrade
        case .exitTriggers:
            return createExitTrigger
        case .exitTrade:
            return createExitTrade
        }
    }
    
    lazy var createExitTrigger: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       exitTriggers[getKey(for: condition)] = condition
    }
    
    lazy var createExitTrade: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       exitTrade[getKey(for: condition)] = condition
    }
    
    lazy var createEntryTrigger: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       entryTriggers[getKey(for: condition)] = condition
    }
    
    lazy var createEntryTrade: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       entryTrade[getKey(for: condition)] = condition
    }
}

struct InputValidation {

    
    enum ValidationError: Error {
        case clashingCondition
    }
    
    static func validate(_ first: EvaluationCondition?, _ second: EvaluationCondition) -> Result<Bool, Error> {
        guard let first = first else { return .success(true) }
        guard first.aboveOrBelow != second.aboveOrBelow else {
            return .failure(ValidationError.clashingCondition)
        }
        if _validate(first, second) {
            return .success(true)
        } else {
            return .failure(ValidationError.clashingCondition)
        }
    }
    
    private static func _validate(_ first: EvaluationCondition, _ second: EvaluationCondition) -> Bool {
        
        switch (first.technicalIndicator, second.technicalIndicator) {
        case (.bollingerBands(percentage: let percentB), .bollingerBands(percentage: let percentBB)):
            if first.aboveOrBelow == .priceAbove {
                guard percentB >= percentBB else { return false }
            } else {
                guard percentBB >= percentB else { return false }
            }
        case (.RSI(period: let period, value: let value), .RSI(period: let period2, value: let value2)):
            if first.aboveOrBelow == .priceAbove {
                guard value > value2 else { return false }
            } else {
                guard value2 > value else { return false }
            }
        default:
            break
        }
        return true
    }
    
    
   
}

