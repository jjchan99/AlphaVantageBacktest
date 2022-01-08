//
//  IndexPathStates.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 8/1/22.
//

import SwiftUI

protocol IdxPathState: View {
    func getCondition() -> EvaluationCondition
    func restoreInputs()
}

struct MA: IdxPathState {
    @EnvironmentObject var context: InputViewModel<MA>
    
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
    
    @ViewBuilder func sectionBottomHalfHeader() -> some View {
        Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        }
    }
}

struct MACrossover: IdxPathState {
    @EnvironmentObject var context: InputViewModel<MACrossover>
    
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
    
    @ViewBuilder func sectionBottomHalfHeader() -> some View {
        Group {
          Text("Enter when 1st period crosses") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
          Text("2nd period")
        }
    }
}

struct BB: IdxPathState {
    @EnvironmentObject var context: InputViewModel<BB>
    
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
    
    var body: some View {
        Section {
            Slider(value: $context.inputState.selectedPercentage, in: 0...100)
        } header: {
            Text("Set threshold: \(context.inputState.selectedPercentage, specifier: "%.0f")%")
        }
    }
    
    @ViewBuilder func sectionBottomHalfHeader() -> some View {
        Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        }
    }
}

struct RSI: IdxPathState {
    @EnvironmentObject var context: InputViewModel<RSI>
    
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
    
    @ViewBuilder func sectionBottomHalfHeader() -> some View {
        Group {
            Text("Enter when ticker") +
            Text(" \(context.inputState.selectedPositionIdx == 0 ? "above" : "below") ").foregroundColor(.red) +
            Text("indicator")
        }
    }
}


