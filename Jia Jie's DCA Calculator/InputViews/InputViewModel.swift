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
    var window: [Int] = [20, 50, 100, 200]
    var position: [AboveOrBelow] = [.priceAbove, .priceBelow]
    
    //MARK: - STATE CONTAINERS
    var repo = InputRepository()
    var inputState = InputState()
    var indexPathState = IndexPathState()
    var validationState = ValidationState()
    
    @Published var entry: Bool = true
    
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
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
            validationState.validationMessage = previouslySetTriggerCondition?.validationMessage ?? previouslySetTradeCondition!.validationMessage
            return false
        }
    }
    
    func updateValidationState() -> Bool {
        let section = indexPathState.section
        let index = indexPathState.index
        let selectedTabIndex = indexPathState.selectedTabIndex
        let selectedWindowIdx = inputState.selectedWindowIdx
        let selectedPositionIdx = inputState.selectedPositionIdx
        let selectedPercentage = inputState.selectedPercentage
        let stepperValue = inputState.stepperValue
        
        switch section {
        case 0:
            switch index {
            case 0:
                switch selectedTabIndex {
                case 0:
                let condition = EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                return validate(condition: condition, action: nil)
                
                case 1:
                   break
                default:
                    fatalError()
                }
            case 1:
                let condition = EvaluationCondition(technicalIndicator: .bollingerBands(percentage: selectedPercentage * 0.01), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                return validate(condition: condition, action: nil)
            case 2:
                let condition = EvaluationCondition(technicalIndicator: .RSI(period: stepperValue, value: selectedPercentage), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                return validate(condition: condition, action: nil)
            default:
                fatalError()
          
            }
        case 1:
            switch index {
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
    
    func actionOnSet() {
        let selectedDictIndex = indexPathState.selectedDictIndex
        let section = indexPathState.section
        let index = indexPathState.index
        let selectedPositionIdx = inputState.selectedPositionIdx
        let selectedTabIndex = indexPathState.selectedTabIndex
        let selectedWindowIdx = inputState.selectedWindowIdx
        let selectedPercentage = inputState.selectedPercentage
        let anotherSelectedWindowIdx = inputState.anotherSelectedWindowIdx
        let stepperValue = inputState.stepperValue
        
        let dict = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        let action = repo.getAction(dict: dict)
        
        switch section {
        case 0:
            switch index {
            case 0:
                switch selectedTabIndex {
                case 0:
                let condition = EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                action(condition)
                case 1:
                let condition = EvaluationCondition(technicalIndicator: .movingAverageOperation(period1: window[selectedWindowIdx], period2: window[anotherSelectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                action(condition)
                default:
                    fatalError()
                }
            case 1:
                let condition = EvaluationCondition(technicalIndicator: .bollingerBands(percentage: selectedPercentage * 0.01), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                action(condition)
            case 2:
                let condition = EvaluationCondition(technicalIndicator: .RSI(period: stepperValue, value: selectedPercentage), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                action(condition)
            default:
                fatalError()
          
            }
        case 1:
            switch index {
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

    
    func restoreIndexPath(condition: EvaluationCondition?) {
        guard let condition = condition else { return }
        let key = repo.getKey(for: condition)
        switch key {
        case "MA":
            section = 0
            index = 0
            selectedTabIndex = 0
        case "BB":
            section = 0
            index = 1
        case "RSI":
            section = 0
            index = 2
        case "stopOrder":
            section = 1
            index = 0
        case "exitTrigger":
            section = 1
            index = 1
        case "profitTarget":
            section = 1
            index = 2
        case "MAOperation":
            section = 0
            index = 0
            selectedTabIndex = 1
        default:
            fatalError()
        }
    }
    
    func resetInputs() {
        selectedPercentage = 0
        selectedPositionIdx = 0
        selectedWindowIdx = 0
        anotherSelectedWindowIdx = 0
        stepperValue = 2
    }
    
    func resetIndexPath() {
        section = 0
        index = 0
        selectedTabIndex = 0
    }
    //MARK: - RESTORATION OPERATIONS
    
    func restoreInputs() {
        let dict = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        switch section {
        case 0:
            switch index {
            case 0:
                switch selectedTabIndex {
                case 0:
                    restoreMA(for: dict)
                case 1:
                    restoreMACrossover(for: dict)
                default:
                    fatalError()
                }
            case 1:
                restoreBB(for: dict)
            case 2:
                restoreRSI(for: dict)
            default:
                fatalError()
                
            }
        case 1:
            switch index {
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
    
    func restoreMACrossover(for dict: InputRepository.Dict) {
        let dict = repo.get(dict: dict)
        if let input = dict["MAOperation"] {
            let i = input.technicalIndicator
            switch i {
            case .movingAverageOperation(period1: let period1, period2: let period2):
                selectedWindowIdx = window.firstIndex(of: period1)!
                anotherSelectedWindowIdx = window.firstIndex(of: period2)!
            default:
                fatalError()
            }
        }
        
        if let input2 = dict["MAOperation"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                selectedPositionIdx = 1
            case .priceAbove:
                selectedPositionIdx = 0
            }
        }
    }
    
    func restoreMA(for dict: InputRepository.Dict) {
        let dict = repo.get(dict: dict)
        if let input = dict["MA"] {
            let i = input.technicalIndicator
            switch i {
            case .movingAverage(period: let period):
                selectedWindowIdx = window.firstIndex(of: period)!
            default:
                fatalError()
            }
        }
        
        if let input2 = dict["MA"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                selectedPositionIdx = 1
            case .priceAbove:
                selectedPositionIdx = 0
            }
        }
    }
    
    func restoreBB(for dict: InputRepository.Dict) {
        let dict = repo.get(dict: dict)
        if let input = dict["BB"] {
            let i = input.technicalIndicator
            switch i {
            case .bollingerBands(percentage: let percentage):
                selectedPercentage = percentage * 100
            default:
                fatalError()
            }
        }
        
        if let input2 = dict["BB"] {
            let i = input2.aboveOrBelow
            switch i {
            case .priceBelow:
                selectedPositionIdx = 1
            case .priceAbove:
                selectedPositionIdx = 0
            }
        }
    }
        
    func restoreRSI(for dict: InputRepository.Dict) {
        let dict = repo.get(dict: dict)
        if let input = dict["RSI"] {
                let i = input.technicalIndicator
                switch i {
                case .RSI(period: let period, value: let percentage):
                    selectedPercentage = percentage
                    stepperValue = period
                default:
                    fatalError()
                }
            }
        
        if let input2 = dict["RSI"] {
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
