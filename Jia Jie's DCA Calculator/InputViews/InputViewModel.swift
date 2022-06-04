//
//  InputViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 30/12/21.
//

import Foundation
import SwiftUI

class InputViewModel: ObservableObject {
    var factory = BotFactory() { didSet { print("Factory set: \(factory.evaluationConditions)")}}
    let symbol: String = "TSLA"
    let width: CGFloat = .init(375).wScaled()
    let height: CGFloat = .init(50).hScaled()
    var bot: TradeBot = BotAccountCoordinator.specimen()
    @Published var frame: CGRect = CGRect(x: 0, y: 0, width: 0, height: 0)
    
    //MARK: - STATE CONTAINERS
    var repo = InputRepository()
    
    @Published var inputState = InputState()
    
    private(set) var indexPathState: IdxPathState! {
        didSet {
            print("indexPathState changed to \(indexPathState)")
        }
    }
    
    @Published var validationState = ValidationState()
    
    private func transitionState(state: IdxPathState) {
        self.indexPathState = state
        state.setContext(context: self)
        self.frame = state.frame
    }
    
    init() {
        print("I'm sticking to my integrity")
    }
    
    @Published var entry: Bool = true
    @Published var selector: Bool = false
    @Published var selectedDictIndex: Int = 0
    @Published var _sti: Int = 0 { didSet {
        selectedTabIndex = _sti
    }}
    
    @Published var selectedTabIndex: Int = 0 {
        willSet {
        if newValue == 1 {
            transitionState(key: "MACrossover")
        } else if newValue == 0 {
            transitionState(key: "MA")
        } else {
            fatalError()
        }
            if selector {
                inputState.reset()
            }
        }
    }
    
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
    let keysAtSection0: [String] = ["MA", "BB" , "RSI"]
    let keysAtSection1: [String] = ["PT", "LT" , "HP"]
    let description: [String] = ["The stock's captured average change over a specified window", "The stock's upper and lower deviations", "Signals about bullish and bearish price momentum"]
    
    let titlesSection2: [String] = ["Profit Target", "Loss Limit", "Define holding period"]
    let descriptionSection2: [String] = ["Based on your account's net worth less invested funds", "Based on your account's net worth less invested funds", "Number of days to close a position when entry is triggered"]
    
    var entryTitleFrame: [[String]] {
        return [titles, []]
    }
    
    var exitTitleFrame: [[String]] {
        return [titles, titlesSection2]
    }
    
    var entryDescriptionFrame: [[String]] {
        return [description, []]
    }
    
    var exitDescriptionFrame: [[String]] {
        return [description, descriptionSection2]
    }
   
    
    //MARK: - INDEXPATH OPERATIONS
    func updateValidationState() {
       let validation = indexPathState.validate()
       switch validation {
       case .success:
           validationState.set(validationState: true)
       case .failure(let error):
           let error = error as! ValidationState.ValidationError
           validationState.set(validationState: false, validationMessage: error.message())
       }
    }
    
    func actionOnSet() {
       
        let condition = indexPathState.getCondition()
        let dict = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        let action = repo.getAction(dict: dict)
        action(condition)
        
    }
    
    func compileConditions() -> TradeBot {
        //RESET
        factory = BotFactory()
        
        for (_ , conditions) in repo.entryOr {
            var copy = conditions
            for (_, andCondition) in repo.entryAnd {
                //DO SOMETHING ABOUT IT
                copy.andCondition.append(andCondition)
        }
            
        factory = factory
            .addCondition(copy)
            
    }
        
        for (_ , conditions) in repo.exitOr {
            var copy = conditions
            for (_, andCondition) in repo.exitAnd {
                //DO SOMETHING ABOUT IT
                copy.andCondition.append(andCondition)
                factory = factory
                    .addCondition(copy)
        }
    }
        return factory.build()
    }
    
    func build(completion: @escaping () -> Void) {
        let tb = compileConditions()
        if tb.conditions.count == 0 {
            fatalError()
        }
        BotAccountCoordinator.upload(tb: tb) {
            completion()
        }
    }
    
    func resetInputs() {
        inputState.reset()
    }
    //MARK: - RESTORATION OPERATIONS
    
    func restoreInputs() {
        indexPathState.restoreInputs()
    }
    
    func getDict() -> [String: EvaluationCondition] {
        let dictType = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        let dict = repo.get(dict: dictType)
        return dict
    }
    
    func getEnterOrExit() -> EnterOrExit {
        return entry ? .enter : .exit
    }
    
}

extension InputViewModel {
    func transitionState(condition: EvaluationCondition?) {
        guard let condition = condition else { return }
        let key = repo.getKey(for: condition)
        switch key {
        case "MA":
            transitionState(state: MA())
        case "BB":
            transitionState(state: BB())
        case "RSI":
            transitionState(state: RSI())
        case "LT":
            transitionState(state: LT())
        case "HP":
            transitionState(state: HP())
        case "PT":
            transitionState(state: PT())
        case "MACrossover":
            transitionState(state: MACrossover())
        default:
            fatalError()
        }
    }
    
    func transitionState(key: String) {
        switch key {
        case "MA":
            transitionState(state: MA())
        case "BB":
            transitionState(state: BB())
        case "RSI":
            transitionState(state: RSI())
        case "PT":
            transitionState(state: PT())
        case "LT":
            transitionState(state: LT())
        case "HP":
            transitionState(state: HP())
        case "MACrossover":
            transitionState(state: MACrossover())
        default:
            fatalError()
        }
    }
}

extension InputViewModel {
    static func keyTitle(condition: EvaluationCondition) -> String {
        switch condition.technicalIndicator {
        case .movingAverage(period: let period):
            return "Close \(condition.aboveOrBelow) \(period) day moving average"
        case .profitTarget(value: let value):
            let value = value * 100
            return "Profit exceeds \(Int(value))%"
        case .RSI(period: let period, value: let value):
            return "\(period) period RSI \(condition.aboveOrBelow) \(value * 100)"
        case .bollingerBands(percentage: let percentage):
            let formatted = (percentage * 100).twoDecimalPlaceString
            return "Close \(condition.aboveOrBelow) \(formatted) percent B"
        case .movingAverageOperation(period1: let period1, period2: let period2):
            return "\(period1) day moving average \(condition.aboveOrBelow) \(period2) day moving average"
        case .lossTarget(value: let value):
            let value = value * 100
            return "Loss does not exceed \(Int(value))%"
        case .holdingPeriod(value: let value):
            return "Exit trade \(value) days after entry trigger"
        }
    }
}
