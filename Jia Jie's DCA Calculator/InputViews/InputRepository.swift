//
//  InputCRUDManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 29/12/21.
//

import Foundation

class InputRepository: ObservableObject {
    
    @Published private(set) var entryAnd: [String: EvaluationCondition] = [:] { didSet {
        print(entryAnd)
    }}
    
    @Published private(set) var entryOr: [String: EvaluationCondition] = [:] { didSet {
        print(entryOr)
    }}
    
    @Published private(set) var exitAnd: [String: EvaluationCondition] = [:] { didSet {
        print(exitAnd)
    }}
    
    @Published private(set) var exitOr: [String: EvaluationCondition] = [:] { didSet {
        print(exitOr)
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
            return "LT"
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
            return .entryAnd
        case 1:
            return .entryOr
        case 2:
            return .exitAnd
        case 3:
            return .exitOr
        default:
            print("index is: \(index)")
            fatalError()
        }
    }
    
    enum Dict {
        case entryOr, entryAnd, exitOr, exitAnd
    }
    
    func get(dict: Dict) -> [String: EvaluationCondition] {
        switch dict {
        case .entryAnd:
            return entryAnd
        case .entryOr:
            return entryOr
        case .exitAnd:
            return exitAnd
        case .exitOr:
            return exitOr
        }
    }
    
    func getAction(dict: Dict) -> (EvaluationCondition) -> (Void) {
        switch dict {
        case .entryAnd:
            return createEntryAnd
        case .entryOr:
            return createEntryOr
        case .exitAnd:
            return createExitAnd
        case .exitOr:
            return createExitOr
        }
    }
    
    lazy var createExitOr: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       exitOr[getKey(for: condition)] = condition
    }
    
    lazy var createExitAnd: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       exitAnd[getKey(for: condition)] = condition
    }
    
    lazy var createEntryOr: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       entryOr[getKey(for: condition)] = condition
    }
    
    lazy var createEntryAnd: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       entryAnd[getKey(for: condition)] = condition
    }
}




