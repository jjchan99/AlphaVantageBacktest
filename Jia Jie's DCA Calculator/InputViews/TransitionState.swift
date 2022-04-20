//
//  IndexPathStates.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 8/1/22.
//

import SwiftUI

protocol IdxPathState: AnyObject {
    func getCondition() -> EvaluationCondition
    func restoreInputs()
    func setContext(context: InputViewModel)
    func sectionBottomHalfHeader() -> AnyView
    func body() -> AnyView
    func validate() -> Result<Bool, Error>
    var title: String { get }
    var frame: CGRect { get }
}

extension IdxPathState {
    func validate() -> Result<Bool, Error> {
        return .success(true)
    }
}

class MA: IdxPathState {
    private(set) weak var context: InputViewModel!
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
   
    let title: String = "Moving Average"
    
    func getCondition() -> EvaluationCondition {
        let condition = EvaluationCondition(technicalIndicator: .movingAverage(period: context.inputState.getWindow()), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
        let dict = context.getDict()
        
        guard let input = dict["MA"] else { return }
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
    
    func body() -> AnyView {
        return AnyView(v())
    }
    
    struct v: View {
        @EnvironmentObject var context: InputViewModel 
        
    var body: some View {
        Section {
            Picker("Selected", selection: $context.inputState.selectedWindowIdx) {
                    Text("20").tag(0)
                    Text("50").tag(1)
                    Text("100").tag(2)
                    Text("200").tag(3)
                }
            .pickerStyle(SegmentedPickerStyle())
        } header: {
            Text("Select Period")
        }
    }
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        })
    }
    
    func validate() -> Result<Bool, Error> {
        let type = context.repo.getDict(index: context.entry ? context.selectedDictIndex + 2 : context.selectedDictIndex)
        let dict = context.repo.get(dict: type)
        guard let previouslySetCondition = dict["MA"] else {
            return .success(true)
        }
        
        let genericValidation = previouslySetCondition.aboveOrBelow == .priceAbove ? context.inputState.selectedPositionIdx == 1 : context.inputState.selectedPositionIdx == 0
        
        return genericValidation ? .success(true) : .failure(ValidationState.ValidationError.clashingCondition(message: ""))
    }
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.25, width: Dimensions.width, height: Dimensions.height * 0.75)
    
}

class MACrossover: IdxPathState {
    private(set) weak var context: InputViewModel!
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    let title: String = "Moving Average"
    
    func getCondition() -> EvaluationCondition {
        let condition = EvaluationCondition(technicalIndicator: .movingAverageOperation(period1: context.inputState.getWindow(), period2: context.inputState.getAnotherWindow()), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
        let dict = context.getDict()
        
        if let input = dict["MACrossover"] {
            let i = input.technicalIndicator
            switch i {
            case .movingAverageOperation(period1: let period1, period2: let period2):
                print("period1: \(period1), period2: \(period2)")
                context.inputState.set(selectedWindowIdx: context.inputState.getIndex(window: period1), anotherSelectedWindowIdx: context.inputState.getIndex(window: period2)!)
            default:
                fatalError()
            }
        }
        
        if let input2 = dict["MACrossover"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                context.inputState.set(selectedPositionIdx: 1)
            
            case .priceAbove:
                context.inputState.set(selectedPositionIdx: 0)
              
            }
        }
        
        context._sti = 1
     }
    
    func body() -> AnyView {
        return AnyView(v())
    }
    
    struct v: View {
    @EnvironmentObject var context: InputViewModel
    var body: some View {
        Section {
            Picker("Selected", selection: $context.inputState.selectedWindowIdx) {
                    Text("20").tag(0)
                    Text("50").tag(1)
                    Text("100").tag(2)
                    Text("200").tag(3)
                }
            .pickerStyle(SegmentedPickerStyle())
        } header: {
            Text("Select First Period")
        }
        Section {
            Picker("Selected", selection: $context.inputState.anotherSelectedWindowIdx) {
                    Text("20").tag(0)
                    Text("50").tag(1)
                    Text("100").tag(2)
                    Text("200").tag(3)
                }
            .pickerStyle(SegmentedPickerStyle())
        } header: {
            Text("Select Second Period")
        }
        .onAppear {
            if !context.selector {
                context.indexPathState.restoreInputs()
            }
        }
        .onDisappear {
            context.inputState.reset()
        }
    }
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Group {
            Text("Enter when 1st period crosses") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("2nd period")
        })
    }
    
    func validate() -> Result<Bool, Error> {
        let type = context.repo.getDict(index: context.entry ? context.selectedDictIndex + 2 : context.selectedDictIndex)
        let dict = context.repo.get(dict: type)
        
        guard context.inputState.selectedWindowIdx != context.inputState.anotherSelectedWindowIdx else {
            return .failure(ValidationState.ValidationError.clashingCondition(message: "Welcome to Chick-fil-a can I get uhh"))
        }
        
        guard let previouslySetCondition = dict["MACrossover"] else {
            return .success(true)
        }
        
        let genericValidation = previouslySetCondition.aboveOrBelow == .priceAbove ? context.inputState.selectedPositionIdx == 1 : context.inputState.selectedPositionIdx == 0
        
        return genericValidation ? .success(true) : .failure(ValidationState.ValidationError.clashingCondition(message: "Wendy's"))
    }
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.25, width: Dimensions.width, height: Dimensions.height * 0.75)
}

class BB: IdxPathState {
    private(set) weak var context: InputViewModel!
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    let title: String = "Bollinger Bands®"
    
    func getCondition() -> EvaluationCondition {
        let condition = EvaluationCondition(technicalIndicator: .bollingerBands(percentage: context.inputState.selectedPercentage * 0.01), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
   
    func restoreInputs() {
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
    func body() -> AnyView {
        return AnyView(v())
    }
    
    struct v: View {
        @EnvironmentObject var context: InputViewModel
    var body: some View {
        Section {
            Slider(value: $context.inputState.selectedPercentage, in: 0...100)
        } header: {
            Text("Set threshold: \(context.inputState.selectedPercentage, specifier: "%.0f")%")
        }
    }
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        })
    }
    
    func validate() -> Result<Bool, Error> {
        let type = context.repo.getDict(index: context.entry ? context.selectedDictIndex + 2 : context.selectedDictIndex)
        let dict = context.repo.get(dict: type)
        guard let previouslySetCondition = dict["BB"] else {
            return .success(true)
        }
        
        let genericValidation = previouslySetCondition.aboveOrBelow == .priceAbove ? context.inputState.selectedPositionIdx == 1 : context.inputState.selectedPositionIdx == 0
        
        switch previouslySetCondition.technicalIndicator {
        case .bollingerBands(percentage: let percentage):
            switch previouslySetCondition.aboveOrBelow {
            case .priceAbove:
                return context.inputState.selectedPercentage < percentage * 100 && genericValidation ? .success(true) : .failure(ValidationState.ValidationError.clashingCondition(message: "Conditional clash: Set threshold below \(percentage * 100)"))
            case .priceBelow:
                return context.inputState.selectedPercentage > percentage * 100 && genericValidation ? .success(true) : .failure(ValidationState.ValidationError.clashingCondition(message: "Conditional clash: Set threshold above \(percentage * 100)"))
            }
        default:
            break
        }
        return .success(true)
    }
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.45, width: Dimensions.width, height: Dimensions.height * 0.55)
}

class RSI: IdxPathState {
    private(set) weak var context: InputViewModel!
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    let title: String = "Relative Strength Index"
    
    func getCondition() -> EvaluationCondition {
        
        let condition = EvaluationCondition(technicalIndicator: .RSI(period: context.inputState.stepperValue, value: context.inputState.selectedPercentage * 0.01), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
      
        let dict = context.getDict()
        
        if let input = dict["RSI"] {
                let i = input.technicalIndicator
                switch i {
                case .RSI(period: let period, value: let percentage):
                    context.inputState.set(selectedPercentage: percentage * 100, stepperValue: period)
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
    func body() -> AnyView {
        return AnyView(v())
    }
    
    struct v: View {
        @EnvironmentObject var context: InputViewModel
    var body: some View {
        Section {
            
            Slider(value: $context.inputState.selectedPercentage, in: 0...100)
      
        } header: {
            Text("RSI threshold: \(context.inputState.selectedPercentage, specifier: "%.0f")%")
        }
        
        Section {
            HStack {
                Stepper("", value: $context.inputState.stepperValue, in: 2...14)
            Spacer()
            }
        } header: {
            Text("Period: \(context.inputState.stepperValue)")
        }
    }
    }
    
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        })
    }
    
    func validate() -> Result<Bool, Error> {
        let type = context.repo.getDict(index: context.entry ? context.selectedDictIndex + 2 : context.selectedDictIndex)
        let dict = context.repo.get(dict: type)
        guard let previouslySetCondition = dict["RSI"] else {
            return .success(true)
        }
        
        let genericValidation = previouslySetCondition.aboveOrBelow == .priceAbove ? context.inputState.selectedPositionIdx == 1 : context.inputState.selectedPositionIdx == 0
        
        switch previouslySetCondition.technicalIndicator {
        case .RSI(period: _, value: let percentage):
            switch previouslySetCondition.aboveOrBelow {
            case .priceAbove:
                return context.inputState.selectedPercentage < percentage * 100 && genericValidation ?
                    .success(true) :
                    .failure(ValidationState.ValidationError.clashingCondition(message: "Conditional clash: Set threshold below \(percentage * 100)"))
            case .priceBelow:
                return context.inputState.selectedPercentage > percentage * 100 && genericValidation ?
                    .success(true) :
                    .failure(ValidationState.ValidationError.clashingCondition(message: "Conditional clash: Set threshold above \(percentage * 100)"))
            }
        default:
            break
        }
        return .success(true)
    }
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.35, width: Dimensions.width, height: Dimensions.height * 0.65)
    
}

class HP: IdxPathState {
    private(set) weak var context: InputViewModel!
    
    func getCondition() -> EvaluationCondition {
        EvaluationCondition(technicalIndicator: .holdingPeriod(value: context.inputState.stepperValue), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
    }
    
    func restoreInputs() {
        let dict = context.getDict()
    }
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        })
    }
    
    func body() -> AnyView {
        return AnyView(v())
    }
    
    var title: String = "Define Holding Period"
    
    
    struct v: View {
    @EnvironmentObject var context: InputViewModel
        var body: some View {
    Section {
        HStack {
        Text("\(context.inputState.stepperValue)")
        Stepper("", value: $context.inputState.stepperValue, in: 2...14)
        }
    } header: {
        Text("Enter number of days")
    }
        }
    }
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.65, width: Dimensions.width, height: Dimensions.height * 0.35)
}

class PT: IdxPathState {
    private(set) weak var context: InputViewModel!
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func getCondition() -> EvaluationCondition {
        EvaluationCondition(technicalIndicator: .profitTarget(value: context.inputState.selectedPercentage * 0.01), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
    }
    
    func restoreInputs() {
        let dict = context.getDict()
        
        if let input = dict["PT"] {
            let i = input.technicalIndicator
            switch i {
            case .profitTarget(value: let percentage):
                context.inputState.set(selectedPercentage: percentage * 100)
            default:
                fatalError()
            }
        }
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Text(""))
    }
    
    func body() -> AnyView {
        AnyView(
           v()
        )
    }
    
    struct v: View {
        @EnvironmentObject var context: InputViewModel
        var body: some View {
            Section {
                Slider(value: $context.inputState.selectedPercentage, in: 0...100)
            } header: {
                Text("Set threshold: \(Int(context.inputState.selectedPercentage))%")
            }
        }
    }
    
    var title: String = "Profit Target"
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.65, width: Dimensions.width, height: Dimensions.height * 0.35)
    
}

class LT: IdxPathState {
    private(set) weak var context: InputViewModel!
    
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    func getCondition() -> EvaluationCondition {
        EvaluationCondition(technicalIndicator: .lossTarget(value: context.inputState.selectedPercentage * 0.01), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
    }

    
    func restoreInputs() {
        let dict = context.getDict()
        
        if let input = dict["PT"] {
            let i = input.technicalIndicator
            switch i {
            case .profitTarget(value: let percentage):
                context.inputState.set(selectedPercentage: percentage * 100)
            default:
                fatalError()
            }
        }
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Text(""))
    }
    
    func body() -> AnyView {
        AnyView(
           v()
        )
    }
    
    struct v: View {
        @EnvironmentObject var context: InputViewModel
        var body: some View {
            Section {
                Slider(value: $context.inputState.selectedPercentage, in: 0...100)
            } header: {
                Text("Set threshold: \(Int(context.inputState.selectedPercentage))%")
            }
        }
    }
    
    var title: String = "Loss Limit"
    
    var frame: CGRect = CGRect(x: 0, y: Dimensions.height * 0.65, width: Dimensions.width, height: Dimensions.height * 0.35)
}
