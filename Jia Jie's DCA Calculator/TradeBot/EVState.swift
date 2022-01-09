//
//  EvaluationTemplate.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 9/1/22.
//

import Foundation

protocol EvaluationState {
    associatedtype T: Comparable
    func targetValue() -> T
    func currentValue() -> T
    func setContext(context: TradeBot)
}

class MA_EVState: EvaluationState {
    
    typealias T = Double
    
    private(set) var context: TradeBot!
    
    func setContext(context: TradeBot) {
        self.context = context
    }
    
    func targetValue() -> Double {
        
    }
    
    func currentValue() -> Double {
        
    }
}
