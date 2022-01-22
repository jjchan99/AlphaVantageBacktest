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
    
    //MARK: - STATE CONTAINERS
    var repo = InputRepository()
    @Published var inputState = InputState()
    var indexPathState: IdxPathState!
    @Published var validationState = ValidationState()
    
    private func transitionState(state: IdxPathState) {
        self.indexPathState = state
        state.setContext(context: self)
    }
    
    init() {
        print("I'm sticking to my integrity")
    }
    
    @Published var entry: Bool = true
    @Published var selectedDictIndex: Int = 0
    @Published var selectedTabIndex: Int = 0 { willSet {
        if newValue == 1 {
            transitionState(key: "MAOperation")
        } else if newValue == 0 {
            transitionState(key: "MA")
        } else {
            fatalError()
        }
    }}
    
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
    let keysAtSection0: [String] = ["MA", "BB" , "RSI"]
    let keysAtSection1: [String] = ["PT", "LT" , "HP"]
    let description: [String] = ["The stock's captured average change over a specified window", "The stock's upper and lower deviations", "Signals about bullish and bearish price momentum"]
    
    let titlesSection2: [String] = ["Profit Target", "Loss Target", "Define holding period"]
    let descriptionSection2: [String] = ["Your account's net worth less invested funds", "Your account's net worth less invested funds", "Number of days to close a position when entry is triggered"]
    
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
    func validate(condition: EvaluationCondition, action: ((EvaluationCondition) -> (Void))?) -> Bool {
        
        let previouslySetTriggerCondition = entry ? repo.exitTriggers[repo.getKey(for: condition)] : repo.entryTriggers[repo.getKey(for: condition)]
        let previouslySetTradeCondition = entry ? repo.exitTrade[repo.getKey(for: condition)] : repo.entryTrade[repo.getKey(for: condition)]
        
        let validationResult = InputValidation.validate(previouslySetTriggerCondition, condition)
        let validationResult2 = InputValidation.validate(previouslySetTradeCondition, condition)
        
        switch (validationResult, validationResult2) {
        case (.success, .success):
            if let action = action {
                action(condition)
            }
            return true
        default:
            validationState.set(validationMessage: previouslySetTriggerCondition?.validationMessage ?? previouslySetTradeCondition!.validationMessage)
            return false
        }
    }
    
    func updateValidationState() -> Bool {
       let condition = indexPathState.getCondition()
       return validate(condition: condition, action: nil)
    }
    
    func actionOnSet() {
        let condition = indexPathState.getCondition()
        let dict = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        let action = repo.getAction(dict: dict)
        action(condition)
    }
    
    func compile() {
        for (key , conditions) in repo.entryTriggers {
            for (_, andCondition) in repo.entryTrade {
                //DO SOMETHING ABOUT IT
        }
    }
    }
    
    func build() {
        compile()
        for (_, condition) in repo.entryTriggers {
            factory = factory
                .addCondition(condition)
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
    
    func keyTitle(condition: EvaluationCondition) -> String {
        switch condition.technicalIndicator {
        case .movingAverage(period: let period):
            return "Close \(condition.aboveOrBelow) \(period) day moving average"
        case .profitTarget(value: let value):
            return "Profit above \(value)%"
        case .RSI(period: let period, value: let value):
            return "\(period) period RSI \(condition.aboveOrBelow) value"
        case .bollingerBands(percentage: let percentage):
            return "Close \(condition.aboveOrBelow) \(percentage) percent B"
        case .movingAverageOperation(period1: let period1, period2: let period2):
            return "\(period1) day moving average \(condition.aboveOrBelow) \(period2) day moving average"
        default:
            return "Donald Trump"
        }
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
        case "MAOperation":
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
        case "MAOperation":
            transitionState(state: MACrossover())
        default:
            fatalError()
        }
    }
}


