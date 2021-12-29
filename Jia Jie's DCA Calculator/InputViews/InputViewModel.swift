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
//        Log.queue(action: "selected position: \(selectedPositionIdx)")
    }}
    @Published var selectedPercentage: Double = 0 { didSet {
//        Log.queue(action: "selected percentage: \(selectedPercentage)")
    }}
    
    let titles: [String] = ["Moving Average", "Bollinger Bands®" , "Relative Strength Index"]
    let description: [String] = ["The stock's captured average change over a specified window", "The stock's upper and lower deviations", "Signals about bullish and bearish price momentum"]
    
    let titlesSection2: [String] = ["Profit/Loss Target", "Setup Price", "Define holding period"]
    let descriptionSection2: [String] = ["Your account's net worth less invested funds", "Constrain orders based on a targeted price", "Automatically close a position after x days"]
    
    var titleFrame: [[String]] {
        return [titles, titlesSection2]
    }
    
    //MARK: - INDEXPATH OPERATIONS
    
    func actionOnSet() {
        switch section {
        case 0:
            switch self.index {
            case 0:
                repo.createEntryTrigger(for: EvaluationCondition(technicalIndicator: .movingAverage(period: window[selectedWindowIdx]), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!)
            case 1:
                repo.createEntryTrigger(for: EvaluationCondition(technicalIndicator: .bollingerBands(percentage: selectedPercentage * 0.01), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!)
            case 2:
                repo.createEntryTrigger(for: EvaluationCondition(technicalIndicator: .RSI(period: window[selectedWindowIdx], value: selectedPercentage), aboveOrBelow: position[selectedPositionIdx], enterOrExit: .enter, andCondition: [])!)
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
        selectedPercentage = 0
        selectedPositionIdx = 0
        selectedWindowIdx = 0
        
        index = 0
        section = 0
    }
    
    //MARK: - RESTORATION OPERATIONS
    
    func restoreInputs() {
        switch section {
        case 0:
            switch index {
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
    
    func restoreMA() {
        if let input = repo.entryTriggers["movingAverage"] {
            let i = input.technicalIndicator
            switch i {
            case .movingAverage(period: let period):
                selectedWindowIdx = window.firstIndex(of: period)!
            default:
                fatalError()
            }
        }
        
        if let input2 = repo.entryTriggers["movingAverage"] {
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
        if let input = repo.entryTriggers["bb"] {
            let i = input.technicalIndicator
            switch i {
            case .bollingerBands(percentage: let percentage):
                selectedPercentage = percentage * 100
            default:
                fatalError()
            }
        }
        
        if let input2 = repo.entryTriggers["bb"] {
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
        if let input = repo.entryTriggers["RSI"] {
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
   
    
    
    
//    func setValue(key: String, value: EvaluationCondition, entry: Bool) {
//
//        switch value.technicalIndicator {
//        case .RSI:
//            if entry {
//            guard exitInputs["RSI"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            } else {
//            guard entryInputs["RSI"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            }
//        case .bollingerBands:
//            if entry {
//            guard exitInputs["bb"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            } else {
//            guard entryInputs["bb"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            }
//        case .movingAverage:
//            if entry {
//            guard exitInputs["movingAverage"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            } else {
//            guard entryInputs["movingAverage"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            }
//        case .stopOrder:
//            if entry {
//            guard exitInputs["stopOrder"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            } else {
//            guard entryInputs["stopOrder"]?.aboveOrBelow != value.aboveOrBelow else { return }
//            }
//        default:
//            break
//        }
//
//        if entry {
//           entryInputs[key] = value
//        } else {
//           exitInputs[key] = value
//        }
//    }
   
    
//    var _enterInputs: [String: EvaluationCondition] {
//        var copy: [String: EvaluationCondition] = [:]
//        for conditions in bot.conditions where conditions.enterOrExit == .enter {
//            for andConditions in conditions.andCondition where conditions.andCondition.count > 0 {
//                switch andConditions.technicalIndicator {
//            case .movingAverage:
//                    break
//            case .exitTrigger:
//                    break
//            case .RSI:
//                    break
//            case .bollingerBands:
//                    break
//            case .profitTarget:
//                    break
//            case .stopOrder:
//                    break
//                }
//            }
//
//            switch conditions.technicalIndicator {
//            case .movingAverage:
//                copy["movingAverage"] = conditions
//            case .exitTrigger:
//                copy["exitTrigger"] = conditions
//            case .RSI:
//                copy["RSI"] = conditions
//            case .bollingerBands:
//                copy["bb"] = conditions
//            case .profitTarget:
//                copy["profitTarget"] = conditions
//            case .stopOrder:
//                copy["stopOrder"] = conditions
//            }
//
//
//        }
//        return copy
//    }
}
