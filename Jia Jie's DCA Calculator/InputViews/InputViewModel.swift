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
    var repo = InputRepository()
    var window: [Int] = [20, 50, 100, 200]
    var position: [AboveOrBelow] = [.priceAbove, .priceBelow]
   
    
    //MARK: - INPUT STATES
    @Published var section: Int = 0 { didSet {
//        Log.queue(action: "section: \(section)")
    }}
    @Published var index: Int = 0 { didSet {
//        Log.queue(action: "index: \(index)")
    }}
    
    @Published var selectedWindowIdx: Int = 0 { didSet {
//        Log.queue(action: "selected window: \(selectedWindowIdx)")
    }}
    @Published var selectedPositionIdx: Int = 0 { didSet {
        validationState = updateValidationState()
    }}
    @Published var selectedPercentage: Double = 0 { didSet {
//        Log.queue(action: "selected percentage: \(selectedPercentage)")
        validationState = updateValidationState()
    }}
    
    @Published var selectedDictIndex: Int = 0
    
    @Published var entry: Bool = true
    
    @Published var validationState: Bool = true
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
    let description: [String] = ["The stock's captured average change over a specified window", "The stock's upper and lower deviations", "Signals about bullish and bearish price momentum"]
    
    let titlesSection2: [String] = ["Profit/Loss Target", "Setup Price", "Define holding period"]
    let descriptionSection2: [String] = ["Your account's net worth less invested funds", "Constrain orders based on a targeted price", "Automatically close a position after x days"]
    
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
        let validationResult = InputValidation.validate(entry ? repo.exitTriggers[repo.getKey(for: condition)] : repo.entryTriggers[repo.getKey(for: condition)], condition)
        let validationResult2 = InputValidation.validate(entry ? repo.exitTrade[repo.getKey(for: condition)] : repo.entryTrade[repo.getKey(for: condition)], condition)
        
        switch (validationResult, validationResult2) {
        case (.success, .success):
            if let action = action {
                action(condition)
            }
            return true
        default:
            return false
        }
    }
    
    func updateValidationState() -> Bool {
        switch section {
        case 0:
            switch self.index {
            case 0:
                let condition = EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                return validate(condition: condition, action: nil)
            case 1:
                let condition = EvaluationCondition(technicalIndicator: .bollingerBands(percentage: selectedPercentage * 0.01), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                return validate(condition: condition, action: nil)
            case 2:
                let condition = EvaluationCondition(technicalIndicator: .RSI(period: window[selectedWindowIdx], value: selectedPercentage), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                return validate(condition: condition, action: nil)
            default:
                fatalError()
          
            }
        case 1:
            switch self.index {
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
        return validationState
    }
    
    func actionOnSet() {
        let dict = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        let action = repo.getAction(dict: dict)
        
        switch section {
        case 0:
            switch self.index {
            case 0:
                let condition = EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                validate(condition: condition, action: action)
            case 1:
                let condition = EvaluationCondition(technicalIndicator: .bollingerBands(percentage: selectedPercentage * 0.01), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                validate(condition: condition, action: action)
            case 2:
                let condition = EvaluationCondition(technicalIndicator: .RSI(period: window[selectedWindowIdx], value: selectedPercentage), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!
                validate(condition: condition, action: action)
            default:
                fatalError()
          
            }
        case 1:
            switch self.index {
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
        default:
            fatalError()
        }
    }
    
    func resetInputs() {
        selectedPercentage = 0
        selectedPositionIdx = 0
        selectedWindowIdx = 0
    }
    
    func resetIndexPath() {
        section = 0
        index = 0
    }
    //MARK: - RESTORATION OPERATIONS
    
    func restoreInputs() {
        let dict = repo.getDict(index: entry ? selectedDictIndex : selectedDictIndex + 2)
        switch section {
        case 0:
            switch index {
            case 0:
                restoreMA(for: dict)
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
                    selectedWindowIdx = window.firstIndex(of: period)!
                default:
                    fatalError()
                }
            }
        }
}
