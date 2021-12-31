//
//  InputCRUDManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 29/12/21.
//

import Foundation

class InputRepository: ObservableObject {
    
    @Published private(set) var entryTriggers: [String: EvaluationCondition] = [:] { didSet {
        Log.queue(action: "set entry triggers")
    }}
    
    @Published private(set) var entryTrade: [String: EvaluationCondition] = [:]
    
    func getKey(for condition: EvaluationCondition) -> String {
        switch condition.technicalIndicator {
        case .movingAverage:
            return "MA"
        case .bollingerBands:
            return "BB"
        case .RSI:
            return "RSI"
        case .stopOrder:
            return "stopOrder"
        case .exitTrigger:
            return "exitTrigger"
        case .profitTarget:
            return "profitTarget"
        }
    }
    
    func getDict(index: Int) -> InputRepository.Dict {
        switch index {
        case 0:
            return .entryTriggers
        case 1:
            return .entryTrade
        default:
            fatalError()
        }
    }
    
    enum Dict {
        case entryTriggers, entryTrade
    }
    
    func get(dict: Dict) -> [String: EvaluationCondition] {
        switch dict {
        case .entryTriggers:
            return entryTriggers
        case .entryTrade:
            return entryTrade
        }
    }
    
    func getAction(dict: Dict) -> (EvaluationCondition) -> (Void) {
        switch dict {
        case .entryTriggers:
            return createEntryTrigger
        case .entryTrade:
            return createEntryTrade
        }
    }
    
    
    lazy var createEntryTrigger: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       entryTriggers[getKey(for: condition)] = condition
    }
    
    lazy var createEntryTrade: (EvaluationCondition) -> (Void) = { [unowned self] condition in
       entryTrade[getKey(for: condition)] = condition
    }
    
   
}
