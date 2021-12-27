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
    @Environment(\.presentationMode) var presentationMode
    
    var window: [Int] = [20, 50, 100, 200]
    var position: [AboveOrBelow] = [.priceAbove, .priceBelow]
    
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
            HStack {
            Text("Step 2. Buy when price is...")
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
                vm.buyInputs["movingAverage"] = EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], buyOrSell: .buy, andCondition: [])
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            
            }
            
        }
    }
    
    @ViewBuilder func form() -> some View {
        switch frame {
        case 0:
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
            if let input = vm.buyInputs["movingAverage"] {
                let i = input.technicalIndicator
                switch i {
                case .movingAverage(period: let period):
                    selectedWindowIdx = window.firstIndex(of: period)!
                default:
                    fatalError()
                }
            }
            
            if let input2 = vm.buyInputs["movingAverage"] {
                let i = input2.aboveOrBelow
                switch i {
                case .priceBelow:
                    selectedPositionIdx = 1
                case .priceAbove:
                    selectedPositionIdx = 0
                }
            }
            
        }
    }
}
