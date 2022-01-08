//
//  IndexPathStates.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 8/1/22.
//

protocol IdxPathState: AnyObject {
    func getCondition() -> EvaluationCondition
    func restoreInputs()
    func setContext(context: InputViewModel)
}

class MA: IdxPathState {
    private(set) weak var context: InputViewModel?
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func getCondition() -> EvaluationCondition {
        guard let context = context else { fatalError() }
        let condition = EvaluationCondition(technicalIndicator: .movingAverage(period: context.inputState.getWindow()), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
        guard let context = context else { fatalError() }
        let dict = context.getDict()
        
        guard let input = dict["MA"] else { fatalError() }
            let i = input.technicalIndicator
            switch i {
            case .movingAverage(period: let period):
                context.inputState.set(selectedWindowIdx: context.inputState.getIndex(window: period))
            default:
                fatalError()
            }
        
        
        guard let input2 = dict["MA"] else { fatalError() }
            let i2 = input2.aboveOrBelow
            switch i2 {
            case .priceBelow:
                context.inputState.set(selectedPositionIdx: 1)
            case .priceAbove:
                context.inputState.set(selectedPositionIdx: 0)
            }
     }
}

class MACrossover: IdxPathState {
    private(set) weak var context: InputViewModel?
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func getCondition() -> EvaluationCondition {
        guard let context = context else { fatalError() }
        let condition = EvaluationCondition(technicalIndicator: .movingAverageOperation(period1: context.inputState.getWindow(), period2: context.inputState.getAnotherWindow()), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
        guard let context = context else { fatalError() }
        let dict = context.getDict()
        
        if let input = dict["MAOperation"] {
            let i = input.technicalIndicator
            switch i {
            case .movingAverageOperation(period1: let period1, period2: let period2):
                context.inputState.set(selectedWindowIdx: context.inputState.getIndex(window: period1), anotherSelectedWindowIdx: context.inputState.getIndex(window: period2)!)
            default:
                fatalError()
            }
        }
        
        if let input2 = dict["MAOperation"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                context.inputState.set(selectedPositionIdx: 1)
            
            case .priceAbove:
                context.inputState.set(selectedPositionIdx: 0)
              
            }
        }
     }
}

class BB: IdxPathState {
    private(set) weak var context: InputViewModel?
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func getCondition() -> EvaluationCondition {
        guard let context = context else { fatalError() }
        let condition = EvaluationCondition(technicalIndicator: .bollingerBands(percentage: context.inputState.selectedPercentage * 0.01), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
        guard let context = context else { fatalError() }
        let dict = context.getDict()
        
        if let input = dict["BB"] {
            let i = input.technicalIndicator
            switch i {
            case .bollingerBands(percentage: let percentage):
                context.inputState.set(selectedPercentage: percentage * 100)
            default:
                fatalError()
            }
        }
        
        if let input2 = dict["BB"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                context.inputState.set(selectedPositionIdx: 1)
            case .priceAbove:
                context.inputState.set(selectedPositionIdx: 0)
            }
        }
     }
}

class RSI: IdxPathState {
    private(set) weak var context: InputViewModel?
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func getCondition() -> EvaluationCondition {
        guard let context = context else { fatalError() }
        let condition = EvaluationCondition(technicalIndicator: .RSI(period: context.inputState.stepperValue, value: context.inputState.selectedPercentage), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
        guard let context = context else { fatalError() }
        let dict = context.getDict()
        
        if let input = dict["RSI"] {
                let i = input.technicalIndicator
                switch i {
                case .RSI(period: let period, value: let percentage):
                    context.inputState.set(selectedPercentage: percentage, stepperValue: period)
                default:
                    fatalError()
                }
            }
        
        if let input2 = dict["RSI"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                context.inputState.set(selectedPositionIdx: 1)
            case .priceAbove:
                context.inputState.set(selectedPositionIdx: 0)
            }
        }
     }
}


