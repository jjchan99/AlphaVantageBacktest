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
    var title: String { get }
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
    }
    }
    
    func sectionBottomHalfHeader() -> AnyView {
        AnyView(Group {
            Text("Enter when 1st period crosses") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("2nd period")
        })
    }
    
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
    
}

class RSI: IdxPathState {
    private(set) weak var context: InputViewModel!
    func setContext(context: InputViewModel) {
        self.context = context
    }
    
    let title: String = "Relative Strength Index"
    
    func getCondition() -> EvaluationCondition {
        
        let condition = EvaluationCondition(technicalIndicator: .RSI(period: context.inputState.stepperValue, value: context.inputState.selectedPercentage), aboveOrBelow: context.inputState.getPosition(), enterOrExit: context.getEnterOrExit(), andCondition: [])!
        return condition
    }
    
    func restoreInputs() {
      
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
    func body() -> AnyView {
        return AnyView(v())
    }
    
    struct v: View {
        @EnvironmentObject var context: InputViewModel
    var body: some View {
        Section {
            
            Slider(value: $context.inputState.selectedPercentage, in: 0...1)
      
        } header: {
            Text("RSI threshold: \(context.inputState.selectedPercentage * 100, specifier: "%.0f")%")
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
    
}

class HP: IdxPathState {
    private(set) weak var context: InputViewModel!
    
    func getCondition() -> EvaluationCondition {
        EvaluationCondition(technicalIndicator: .exitTrigger(value: 99999999), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
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
    TextField("Enter number of days", text: Binding(
        get: { String(context.inputState.stepperValue) },
        set: { context.inputState.stepperValue = Int($0) ?? 0 }
    ))
            .textFieldStyle(.plain)
        .frame(width: 0.2 * Dimensions.width)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                Button {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                } label: {
                    Text("Done")
                }
                Spacer()
                }
            }
        }
        .keyboardType(.numberPad)
        .padding()
    } header: {
        Text("Enter number of days")
    }
        }
    }
}


