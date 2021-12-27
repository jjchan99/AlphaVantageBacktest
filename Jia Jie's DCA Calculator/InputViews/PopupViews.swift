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
    @State private var percentB: Double = 0
    @State private var isPresented = false
    @State private var selected = 1
    let selectedColor: Color = Color.yellow
    @State private var selectedWindowIdx: Int = 0
    @State private var selectedPositionIdx: Int = 0
    @State private var isOn = false
    
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
                    
                }
                .buttonStyle(.borderedProminent)
            Button("Set") {
                vm.inputs["movingAverage"] = EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], buyOrSell: .buy, andCondition: [])
            }
            .buttonStyle(.borderedProminent)
            
            }
            
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
//                Slider(value: $percentB, in: 0...100)
//                Text("\(percentB, specifier: "%.1f")")
                movingAverageBody()
                Spacer()

                }
                .navigationTitle(vm.titleFrame[frame][titleIdx])
            
        }
    }
}
