//
//  InputForm.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 17/12/21.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    var factory = BotFactory() { didSet { print("Factory set: \(factory.evaluationConditions)")}}
    let symbol: String = "TSLA"
    let width: CGFloat = .init(375).wScaled()
    let height: CGFloat = .init(50).hScaled()
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
    let description: [String] = ["The stock's captured average change over a specified window", "The stock's upper and lower deviations", "Signals about bullish and bearish price momentum"]
    
    let titlesSection2: [String] = ["Profit/Loss Target", "Setup Price", "Define holding period"]
    let descriptionSection2: [String] = ["Your account's net worth less invested funds", "Constrain orders based on a targeted price", "Automatically close a position after x days"]
    
    var titleFrame: [[String]] {
        return [titles, titlesSection2]
    }
    
    var buyInputs: [String: EvaluationCondition] = [:] { didSet {
        print(buyInputs)
    }}
}

struct InputMenuView: View {
    
    @EnvironmentObject var vm: InputViewModel
    var body: some View {
        GridStack(rows: 3, columns: 3) { row, col in
            HStack {
           
            }
        }
    }
}

struct InputCustomizationView: View {
    @EnvironmentObject var vm: InputViewModel
    @State private var isPresented: Bool = false { didSet {print("LEO GURA!!!!")}}
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section {
                        List(0..<vm.titles.count, id: \.self) { idx in
                            Button() {
                                isPresented = true
                            } label: {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                VStack(alignment: .leading) {
                                    Text(vm.titles[idx])
                                        .font(.caption.bold())
                                    Text(vm.description[idx])
                                        .font(.caption2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .opacity(0.3)
                            }
                            .frame(height: 0.1 * Dimensions.height)
                            }
                            .sheet(isPresented: $isPresented) {
                                PopupView(titleIdx: idx, frame: 0)
                            }
                            .foregroundColor(.black)
                            
                        }
                    } header: {
                        Text("Trading Indicators")
                    }
                    Section {
                        List(0..<vm.titlesSection2.count, id: \.self) { idx in
                            Button() {
                                isPresented = true
                            } label: {
                            HStack {
                                Image(systemName: "dollarsign.circle")
                                VStack(alignment: .leading) {
                                    Text(vm.titlesSection2[idx])
                                        .font(.caption.bold())
                                    Text(vm.descriptionSection2[idx])
                                        .font(.caption2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .opacity(0.3)
                            }
                            .frame(height: 0.1 * Dimensions.height)
                            }
                            .sheet(isPresented: $isPresented) {
                                PopupView(titleIdx: idx, frame: 1)
                            }
                            .foregroundColor(.black)
                            
                        }
                    } header: {
                        Text("Custom targets")
                    }
                   
                }
            }
            .navigationTitle("Entry strategy")
        }
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    @ViewBuilder let content: (Int, Int) -> Content

    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row in
                HStack {
                    ForEach(0..<columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
}
