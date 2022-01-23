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
    
    @Published private(set) var entryTrade: [String: EvaluationCondition] = [:] { didSet {
        print(entryTrade)
    }}
    
    @Published private(set) var exitTriggers: [String: EvaluationCondition] = [:] { didSet {
        print(exitTriggers)
    }}
    
    @Published private(set) var exitTrade: [String: EvaluationCondition] = [:] { didSet {
        print(exitTrade)
    }}
    
    
    
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

    
    public enum ValidationError: Error {
        case clashingCondition(message: String)
        
        func message() -> String {
            switch self {
            case .clashingCondition(message: let message):
                return message
            }
        }
    }
    
    static func validate(_ first: EvaluationCondition?, _ second: EvaluationCondition) -> Result<Bool, Error> {
        guard let first = first else { return .success(true) }
        guard first.aboveOrBelow != second.aboveOrBelow else {
            return .failure(ValidationError.clashingCondition(message: "asdasd"))
        }
//        if _validate(first, second) {
//            return .success(true)
//        } else {
//            return .failure(ValidationError.clashingCondition)
//        }
        return .success(true)
    }
}





