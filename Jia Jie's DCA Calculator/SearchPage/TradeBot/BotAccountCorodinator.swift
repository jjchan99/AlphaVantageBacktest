//
//  BotAccountCorodinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import Combine

class BotAccountCoordinator: NSObject {

    @Published var bot: TradeBot? { didSet {
        print("Here's the bot: \(bot!)")
    }}
    
    @Published var conditions: [EvaluationCondition]? { didSet {
        print("Here's the conditions: \(conditions!)")
    }}

    var subscribers = Set<AnyCancellable>()
     
    func specimen() -> TradeBot {
     //MARK: - CONDITION (CONST) && (CONDITION 2 || CONDITION 3)
        
        let condition2: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.33), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: nil)!
        
        let condition3: EvaluationCondition = .init(technicalIndicator: .bollingerBands(percentage: 0.20), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: nil)!
        
        let conditionZ: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: condition2)!
        
        let conditionX: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: condition3)!
        
        let f = BotFactory()
            .setBudget(42000)
            .setCashBuyPercentage(1)
            .setSharesSellPercentage(0.5)
            .addCondition(conditionZ)
            .addCondition(conditionX)
            .build()
        print(f)
        return f
    }

    func fetchBot() {
        let predicate: NSPredicate = NSPredicate(value: true)
        CloudKitUtility.fetch(predicate: predicate, recordType: "TradeBot")
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                bot = value.first
            }
            .store(in: &subscribers)
    }
    
    func fetchAndConditions() {
        guard let bot = bot, let conditions = bot.conditions else { return }
        let parents: [EvaluationCondition] = conditions.compactMap ({ condition in
            if condition.andCondition != nil { return condition } else { return nil }
        })
        parents.forEach { parent in
            CloudKitUtility.fetchChildren(parent: parent, children: "EvaluationConditions")
                .receive(on: DispatchQueue.main)
                .sink { result in
                    switch result {
                    case .failure(let error):
                       print(error)
                    case .finished:
                        break
                    }
                } receiveValue: { value in
                    parent.andCondition = value.first!
                }
                .store(in: &subscribers)
        }
    }
    
    func fetchConditions() {
        guard self.bot != nil else { return }
        CloudKitUtility.fetchChildren(parent: bot!, children: "EvaluationCondition")
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] value in
                bot!.conditions = value
            }
            .store(in: &subscribers)
    }
    
    func upload() {
        let specimen = specimen()
        let andParents: [EvaluationCondition] = specimen.conditions!.compactMap { condition in
            if condition.andCondition != nil { return condition } else { return nil }
        }
        
        CloudKitUtility.add(item: specimen) { value in
            CloudKitUtility.saveArray(array: specimen.conditions!, for: specimen) { value in
                for index in andParents.indices {
                    CloudKitUtility.saveChild(child: andParents[index].andCondition!, for: andParents[index]) { value in
                        Log.queue(action: "Success! \(value)")
                    }
                }
            }
        }
    }
}

class BotFactory {
    var budget: Double = 0
    var cashBuyPercentage: Double = 0
    var sharesSellPercentage: Double = 0
    var evaluationConditions: [EvaluationCondition] = []
    
    func setBudget(_ value: Double) -> BotFactory {
        self.budget = value
        return self
    }
    
    func setCashBuyPercentage(_ value: Double) -> BotFactory {
        self.cashBuyPercentage = value
        return self
    }
    
    func setSharesSellPercentage(_ value: Double) -> BotFactory {
        self.sharesSellPercentage = value
        return self
    }
    
    func addCondition(_ value: EvaluationCondition) -> BotFactory {
        self.evaluationConditions.append(value)
        return self
    }
    
//    func setAndCondition(value: EvaluationCondition, indexPath: Int) -> BotFactory {
//        self.evaluationConditions[indexPath].andCondition = value
//        return self
//    }
    
    func build() -> TradeBot {
        let bot = TradeBot(budget: budget, account: .init(cash: budget, accumulatedShares: 0), conditions: evaluationConditions, cashBuyPercentage: cashBuyPercentage, sharesSellPercentage: sharesSellPercentage)
        print(bot)
        return bot!
    }
}
