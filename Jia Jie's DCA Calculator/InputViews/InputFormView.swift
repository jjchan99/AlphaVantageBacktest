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
    var bot: TradeBot = BotAccountCoordinator.specimen()
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
    let description: [String] = ["The stock's captured average change over a specified window", "The stock's upper and lower deviations", "Signals about bullish and bearish price momentum"]
    
    let titlesSection2: [String] = ["Profit/Loss Target", "Setup Price", "Define holding period"]
    let descriptionSection2: [String] = ["Your account's net worth less invested funds", "Constrain orders based on a targeted price", "Automatically close a position after x days"]
    
    var titleFrame: [[String]] {
        return [titles, titlesSection2]
    }
    
    func setValue(key: String, value: EvaluationCondition, entry: Bool) {

        switch value.technicalIndicator {
        case .RSI:
            if entry {
            guard exitInputs["RSI"]?.aboveOrBelow != value.aboveOrBelow else { return }
            } else {
            guard entryInputs["RSI"]?.aboveOrBelow != value.aboveOrBelow else { return }
            }
        case .bollingerBands:
            if entry {
            guard exitInputs["bb"]?.aboveOrBelow != value.aboveOrBelow else { return }
            } else {
            guard entryInputs["bb"]?.aboveOrBelow != value.aboveOrBelow else { return }
            }
        case .movingAverage:
            if entry {
            guard exitInputs["movingAverage"]?.aboveOrBelow != value.aboveOrBelow else { return }
            } else {
            guard entryInputs["movingAverage"]?.aboveOrBelow != value.aboveOrBelow else { return }
            }
        case .stopOrder:
            if entry {
            guard exitInputs["stopOrder"]?.aboveOrBelow != value.aboveOrBelow else { return }
            } else {
            guard entryInputs["stopOrder"]?.aboveOrBelow != value.aboveOrBelow else { return }
            }
        default:
            break
        }
        
        if entry {
           entryInputs[key] = value
        } else {
           exitInputs[key] = value
        }
    }
    
    private(set) var entryInputs: [String: EvaluationCondition] = [:] { didSet {
        print(entryInputs)
    }}
    
    private(set) var exitInputs: [String: EvaluationCondition] = [:] { didSet {
        print(exitInputs)
    }}
    
    func sendToAndPool(conditions: EvaluationCondition) {
        switch conditions.technicalIndicator {
        case .movingAverage:
            break
        case .exitTrigger:
            break
        case .RSI:
            break
        case .bollingerBands:
            break
        case .profitTarget:
            break
        case .stopOrder:
            break
        }
    }
    
    func sendToOrPool(conditions: EvaluationCondition) {
        switch conditions.technicalIndicator {
        case .movingAverage:
            break
        case .exitTrigger:
            break
        case .RSI:
            break
        case .bollingerBands:
            break
        case .profitTarget:
            break
        case .stopOrder:
            break
        }
    }
    
    var _enterInputs: [String: EvaluationCondition] {
        var copy: [String: EvaluationCondition] = [:]
        for conditions in bot.conditions where conditions.enterOrExit == .enter {
            for andConditions in conditions.andCondition where conditions.andCondition.count > 0 {
                switch andConditions.technicalIndicator {
            case .movingAverage:
                    break
            case .exitTrigger:
                    break
            case .RSI:
                    break
            case .bollingerBands:
                    break
            case .profitTarget:
                    break
            case .stopOrder:
                    break
                }
            }
        
            switch conditions.technicalIndicator {
            case .movingAverage:
                copy["movingAverage"] = conditions
            case .exitTrigger:
                copy["exitTrigger"] = conditions
            case .RSI:
                copy["RSI"] = conditions
            case .bollingerBands:
                copy["bb"] = conditions
            case .profitTarget:
                copy["profitTarget"] = conditions
            case .stopOrder:
                copy["stopOrder"] = conditions
            }
            
           
        }
        return copy
    }
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
