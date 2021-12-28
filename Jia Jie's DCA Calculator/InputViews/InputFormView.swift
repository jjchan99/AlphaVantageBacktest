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
    
    @Published private(set) var entryInputs: [String: EvaluationCondition] = [:] { didSet {
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

struct InputCustomizationView: View {
    @EnvironmentObject var vm: InputViewModel
    @State private var isPresented: Bool = false 
    @State var long: Bool = true
    @State var isActive : Bool = false
    
    var body: some View {
        NavigationView {
                Form {
                    Section {
                        Picker("Selected", selection: $long) {
                            Text("Go long").tag(true)
                            Text("Go short").tag(false)
                        }.pickerStyle(SegmentedPickerStyle())
                        .frame(width: 0.985 * vm.width)
                    } header: {
                       Text("Indicate your position")
                    }
                    Section {
                        List {
                            
                        ForEach(Array(vm.entryInputs.keys), id: \.self) { key in
                            HStack {
                                Text(key)
                            Spacer()
                                Button("Edit") {
                                    isPresented = true
                                }
                                .sheet(isPresented: $isPresented) {
                                    PopupView(shouldPopToRootView: self.$isActive, titleIdx: 0, frame: 0, entryForm: false)
                                }
                            }
                        }

                    }
                    
                    NavigationLink(isActive: $isActive) {
                        SelectorView(rootIsActive: self.$isActive)
                            .navigationTitle("Hello friend")
                    } label: {
                        HStack {
                        Image(systemName: "plus.circle")
                        Text("Add entry trigger")
                        }
                    }
                    .isDetailLink(false)
                    } header: {
                        Text("Your entry triggers")
                    }
                    
                }
            .navigationTitle("Entry strategy")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
