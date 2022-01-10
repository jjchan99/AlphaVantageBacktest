//
//  EvaluationTemplate.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 9/1/22.
//

import Foundation

protocol EvaluationState: AnyObject {
    func perform() -> Bool
    func setContext(context: ContextObject)
}

class ContextObject {
    
    internal init(account: Account, previous: OHLCCloudElement, mostRecent: OHLCCloudElement) {
        self.account = account
        self.previous = previous
        self.mostRecent = mostRecent
    }
    
    var account: Account
    var previous: OHLCCloudElement
    var mostRecent: OHLCCloudElement
}

class MA_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
        self.context = context
    }
    
    func perform() -> Bool {
        switch condition.technicalIndicator {
        case .movingAverage(period: let period):
            switch condition.aboveOrBelow {
            case .priceAbove:
                return context.mostRecent.open > context.mostRecent.movingAverage[period]!
            case .priceBelow:
                return context.mostRecent.open < context.mostRecent.movingAverage[period]!
            }
        default:
            fatalError()
        }
    }
    
    
}

class Test {
    var objectA: EvaluationState!
    
    func test() {
        objectA
    }

}
