//
//  EvaluationTemplate.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 9/1/22.
//

import Foundation

protocol EvaluationState: AnyObject {
    func perform() -> Bool
    func setContext(context: [String: Any])
}

class MA_EVState: EvaluationState {
    
    typealias T = Double
    private(set) var context: [String: Any]!
    
    func setContext(context: [String: Any]) {
        self.context = context
    }
    
    private func targetValue() -> Double {
        
    }
    
    private func getTicker() -> OHLCCloudElement {
        for item in context where item is OHLCCloudElement {
            let item = item as! OHLCCloudElement
            return item
        }
    }
    
    private func currentValue(window: Int) -> Double {
        for item in context where item is EvaluationCondition {
            let item = item as! EvaluationCondition
            switch item.technicalIndicator {
            case .movingAverage(period: let period):
                return getTicker().movingAverage[period]!
            default:
                fatalError()
            }
        }
        fatalError()
    }
    
    func perform() -> Bool {
        
    }
    
}

class Context {
    var objectA: EvaluationState!
    
    func test() {
        objectA.perform()
    }

}
