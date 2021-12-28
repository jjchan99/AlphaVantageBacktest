//
//  PopupViews.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

struct PopupView: View {
    @EnvironmentObject var vm: InputViewModel
    var titleIdx: Int 
    var frame: Int
    @State private var selectedWindowIdx: Int = 0
    @State private var selectedPositionIdx: Int = 0
    @State private var selectedPercentage: Double = 0
    @Environment(\.presentationMode) var presentationMode
    
    var window: [Int] = [20, 50, 100, 200]
    var position: [AboveOrBelow] = [.priceAbove, .priceBelow]
    
    @ViewBuilder func rsiBody() -> some View {
        Text("HELLO WORLD!!!!")
    }
    
    func actionOnSet() {
        switch frame {
        case 0:
            switch titleIdx {
            case 0:
                vm.setValue(key: "movingAverage", value: EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!, entry: true)
            case 1:
                vm.setValue(key: "bb", value: EvaluationCondition(technicalIndicator: .bollingerBands(percentage: selectedPercentage * 0.01), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!, entry: true)
            case 2:
                vm.setValue(key: "RSI", value: EvaluationCondition(technicalIndicator: .RSI(period: window[selectedWindowIdx], value: selectedPercentage), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!, entry: true)
            default:
                fatalError()
          
            }
        case 1:
            switch titleIdx {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            default:
                fatalError()
            }
        default:
            fatalError()
        }
        presentationMode.wrappedValue.dismiss()
    }
    
    @ViewBuilder func formBottomHalf() -> some View {
        HStack {
        Text("Step 2. Enter when price is...")
                .padding()
        Spacer()
        }
        Picker("Selected", selection: $selectedPositionIdx) {
            Text("Above").tag(0)
            Text("Below").tag(1)
        }.pickerStyle(SegmentedPickerStyle())
        .frame(width: 0.985 * vm.width)
        
        Text("You have opted for a \(selectedPositionIdx == 0 ? "short" : "long") strategy")
        
        HStack {
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
        Button("Set") {
            actionOnSet()
        }
        .buttonStyle(.borderedProminent)
        
        }
    }
    
    @ViewBuilder func movingAverageBody() -> some View {
        VStack {
            HStack {
            Text("Step 1. Select window")
                .padding()
                Spacer()
            }
                Picker("Selected", selection: $selectedWindowIdx) {
                    Text("20").tag(0)
                    Text("50").tag(1)
                    Text("100").tag(2)
                    Text("200").tag(3)
                }.pickerStyle(SegmentedPickerStyle())
                .frame(width: 0.985 * vm.width)
           formBottomHalf()
        }
    }
    
    func restoreInputs() {
        switch frame {
        case 0:
            switch titleIdx {
            case 0:
                restoreMA()
            case 1:
                restoreBB()
            case 2:
                restoreRSI()
            default:
                fatalError()
                
            }
        case 1:
            switch titleIdx {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            default:
                fatalError()
            }
        default:
            fatalError()
            
        }
    }
    
    func restoreMA() {
        if let input = vm.entryInputs["movingAverage"] {
            let i = input.technicalIndicator
            switch i {
            case .movingAverage(period: let period):
                selectedWindowIdx = window.firstIndex(of: period)!
            default:
                fatalError()
            }
        }
        
        if let input2 = vm.entryInputs["movingAverage"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                selectedPositionIdx = 1
            case .priceAbove:
                selectedPositionIdx = 0
            }
        }
    }
    
    func restoreBB() {
        if let input = vm.entryInputs["bb"] {
            let i = input.technicalIndicator
            switch i {
            case .bollingerBands(percentage: let percentage):
                selectedPercentage = percentage * 100
            default:
                fatalError()
            }
        }
        
        if let input2 = vm.entryInputs["bb"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                selectedPositionIdx = 1
            case .priceAbove:
                selectedPositionIdx = 0
            }
        }
    }
        
    func restoreRSI() {
            if let input = vm.entryInputs["RSI"] {
                let i = input.technicalIndicator
                switch i {
                case .RSI(period: let period, value: let percentage):
                    selectedPercentage = percentage
                    selectedWindowIdx = window.firstIndex(of: period)!
                default:
                    fatalError()
                }
            }
        }
    
    @ViewBuilder func bbBody() -> some View {
        VStack {
            Slider(value: $selectedPercentage, in: 0...100)
            Text("\(selectedPercentage, specifier: "%.1f")")
        formBottomHalf()
        }
    }
    
    @ViewBuilder func form() -> some View {
        switch frame {
        case 0:
            switch titleIdx {
            case 0:
                movingAverageBody()
            case 1:
                bbBody()
            case 2:
                rsiBody()
            default:
                fatalError()
          
            }
        case 1:
            switch titleIdx {
            case 0:
                movingAverageBody()
            case 1:
                movingAverageBody()
            case 2:
                movingAverageBody()
            default:
                fatalError()
            }
        default:
            fatalError()
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
//                Slider(value: $percentB, in: 0...100)
//                Text("\(percentB, specifier: "%.1f")")
                form()
                Spacer()

                }
                .navigationTitle(vm.titleFrame[frame][titleIdx])
            
        }
        .onAppear {
            restoreInputs()
        }
    }
}


