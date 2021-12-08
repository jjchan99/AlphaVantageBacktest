//
//  BotAccountCorodinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import Combine

class BotAccountCoordinator: NSObject {

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
    
    func inspect(for bot: TradeBot) {
        bot.conditions!.forEach { condition in
            print("Condition: \(condition). And condition: \(condition.andCondition)")
        }
    }
    
    func fetchBot() -> Future<TradeBot, Error> {
        Future { [unowned self] promise in
            fetchBot() { (tradeBot: TradeBot) in
                promise(.success(tradeBot))
                print("Here is the bot: \(tradeBot)")
                inspect(for: tradeBot)
            }
        }
    }

    private func fetchBot(completion: @escaping (TradeBot) -> Void) {
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
            } receiveValue: { [unowned self] (value: [TradeBot]) in
                switch value.first == nil {
                case true:
                       return
                case false:
                    fetchConditions(for: value.first!) { tradeBot in
                        completion(tradeBot)
                    }
                }
            }
            .store(in: &subscribers)
    }
    
    private func fetchAndConditions(for bot: TradeBot, completion: @escaping (TradeBot) -> Void) {
        bot.conditions!.indices.forEach { index in
            CloudKitUtility.fetchChildren(parent: bot.conditions![index], children: "EvaluationCondition")
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { (value: [EvaluationCondition]) in
                bot.conditions![index].andCondition = value.first
                if index == bot.conditions!.indices.last {
                    completion(bot)
                }
            }
            .store(in: &subscribers)
        }
    }
    
    private func fetchConditions(for bot: TradeBot, completion: @escaping (TradeBot) -> Void) {
        CloudKitUtility.fetchChildren(parent: bot, children: "EvaluationCondition")
            .receive(on: DispatchQueue.main)
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { [unowned self] (value: [EvaluationCondition]) in
                var copy = bot
                copy.conditions = value
                fetchAndConditions(for: copy) { tradeBot in
                    completion(tradeBot)
                }
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
