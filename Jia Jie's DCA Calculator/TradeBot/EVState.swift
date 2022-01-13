//
//  EvaluationTemplate.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 9/1/22.
//

import Foundation

protocol EvaluationState {
    func perform() -> Bool
    func setContext(context: ContextObject)
}

class ContextObject {
    
    internal init(account: Account, tb: TradeBot) {
        self.account = account
        self.tb = tb
    }
    
    var lm = LedgerManager()
    var account: Account
    var tb: TradeBot
    
    func updateTickers(previous: OHLCCloudElement, mostRecent: OHLCCloudElement) {
        self.previous = previous
        self.mostRecent = mostRecent
    }
    
    private(set) var previous: OHLCCloudElement!
    private(set) var mostRecent: OHLCCloudElement!
}

struct MA_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
        
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

struct BB_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
       
    }
    
    func perform() -> Bool {
        switch condition.technicalIndicator {
        case .bollingerBands(percentage: let percent):
            switch condition.aboveOrBelow {
            case .priceAbove:
                return context.mostRecent.open > context.mostRecent.valueAtPercent(percent: percent)! && context.mostRecent.open < context.mostRecent.upperBollingerBand!
            case .priceBelow:
                return context.mostRecent.open < context.mostRecent.valueAtPercent(percent: percent)! && context.mostRecent.open > context.mostRecent.lowerBollingerBand!
            }
        default:
            fatalError()
        }
    }
}

struct MAOperation_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
        
    }
    
    func perform() -> Bool {
        switch condition.technicalIndicator {
        case .movingAverageOperation(period1: let p1, period2: let p2):
            switch condition.aboveOrBelow {
            case .priceAbove:
                return context.mostRecent.movingAverage[p1]! > context.mostRecent.movingAverage[p2]!
            case .priceBelow:
                return context.mostRecent.movingAverage[p1]! < context.mostRecent.movingAverage[p2]!
            }
        default:
            fatalError()
        }
    }
}

struct RSI_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
        
    }
    
    func perform() -> Bool {
        switch condition.technicalIndicator {
        case .RSI(period: let period, value: let value):
            switch condition.aboveOrBelow {
            case .priceAbove:
                return context.mostRecent.open > context.mostRecent.RSI[period]!
            case .priceBelow:
                return context.mostRecent.open < context.mostRecent.RSI[period]!
            }
        default:
            fatalError()
        }
    }
}

struct PT_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
        
    }
    
    func perform() -> Bool {
        switch condition.technicalIndicator {
        case .profitTarget(value: let target):
            switch condition.aboveOrBelow {
            case .priceAbove:
                return context.account.longProfit(quote: context.mostRecent.close) > target
            case .priceBelow:
                return context.account.longProfit(quote: context.mostRecent.close) > target
            }
        default:
            fatalError()
        }
    }
}

struct HP_EVState: EvaluationState {
  
    typealias T = Double
    private(set) var context: ContextObject!
    var condition: EvaluationCondition!
    
    func setContext(context: ContextObject) {
        
    }
    
    func perform() -> Bool {
        switch condition.technicalIndicator {
        case .holdingPeriod(value: let value):
            switch condition.aboveOrBelow {
            case .priceAbove:
                return context.mostRecent.stamp > DateManager.addNoise(fromString: "\(value)")
            case .priceBelow:
                return context.mostRecent.stamp < DateManager.addNoise(fromString: "\(value)")
            }
        default:
            fatalError()
        }
    }
}

struct EVStateFactory {
    static func getEVState(condition: EvaluationCondition) -> EvaluationState {
        switch condition.technicalIndicator {
        case .movingAverage(period: let period):
            return MA_EVState()
        case .bollingerBands(percentage: let percentage):
            return BB_EVState()
        case .RSI(period: let period, value: let value):
            return RSI_EVState()
        case .lossTarget(value: let value):
            return PT_EVState()
        case .profitTarget(value: let value):
            return PT_EVState()
        case .holdingPeriod(value: let value):
            return HP_EVState()
        case .movingAverageOperation(period1: let period1, period2: let period2):
            return MAOperation_EVState()
        }
    }
}

struct EvaluationAlgorithm {
    
    private static func checkCondition(context: ContextObject, condition: EvaluationCondition) -> Bool {
        let state: EvaluationState = EVStateFactory.getEVState(condition: condition)
        return state.perform()
    }
    
    static func check(context: ContextObject, condition: EvaluationCondition, passed: (EvaluationCondition) -> Void) -> Bool {
        if checkCondition(context: context, condition: condition) {
            for andConditions in condition.andCondition {
                if checkCondition(context: context, condition: andConditions) {
                    passed(condition)
                    continue
                } else {
                    return false
                }
            }
        } else {
            return false
        }
        passed(condition)
        return true
    }
}

protocol TBTemplateMethod {
    var context: ContextObject { get }
    func templateMethod()
    func entrySuccess()
    func exitSuccess()
    func hook()
}

extension TBTemplateMethod {
    func templateMethod() {
        
        let passed: (EvaluationCondition) -> Void = { condition in
            context.lm.append(description: "Passed", context: self.context, condition: condition)
        }
        
        for condition in context.tb.conditions {
            if EvaluationAlgorithm.check(context: context, condition: condition, passed: passed) {
          context.account.cash == 0 ? exitSuccess() : entrySuccess()
          condition.enterOrExit == .enter ? hook() : hook2()
            break
        } else {
          continue
        }
        }
    }
   
    func hook() {
        
    }
    
    func hook2() {
        
    }
    
    func entrySuccess() {
        context.account.accumulatedShares += context.account.decrement(context.tb.long ? context.account.cash : context.account.budget) / context.mostRecent.close
    }
    
    func exitSuccess() {
        context.account.cash += context.account.decrement(shares: context.account.accumulatedShares) * context.mostRecent.close
    }
}

struct TBAlgorithmHoldingPeriod: TBTemplateMethod {
    var context: ContextObject
    
    func hook() {
        let holdingPeriod = context.tb.holdingPeriod
        switch holdingPeriod {
            case holdingPeriod where holdingPeriod! >= 0:
            context.tb.conditions = ExitTriggerManager.orUpload(tb: context.tb, context: context)
            case holdingPeriod where holdingPeriod! < 0:
            context.tb.conditions = ExitTriggerManager.andUpload(tb: context.tb, context: context)
            default:
              break
        }
    }
    
    func hook2() {
        let holdingPeriod = context.tb.holdingPeriod
        switch holdingPeriod {
            case holdingPeriod where holdingPeriod! >= 0:
            context.tb.conditions = ExitTriggerManager.resetOrExitTrigger(tb: context.tb)
            case holdingPeriod where holdingPeriod! < 0:
            context.tb.conditions = ExitTriggerManager.resetAndExitTrigger(tb: context.tb)
            default:
              break
        }
    }
}

struct TBAlgorithmDefault: TBTemplateMethod {
    var context: ContextObject
    
    
}
