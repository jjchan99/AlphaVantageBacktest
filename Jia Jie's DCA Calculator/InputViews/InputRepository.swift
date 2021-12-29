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
    
    
    
    func createEntryTrigger(for condition: EvaluationCondition) {
       entryTriggers[getKey(for: condition)] = condition
    }
    
    func createEntryTrade(for condition: EvaluationCondition) {
       entryTrade[getKey(for: condition)] = condition
    }
    
   
}
