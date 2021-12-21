//
//  BotAccountCorodinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 3/12/21.
//

import Foundation
import Combine

class BotAccountCoordinator {

    static var subs = Set<AnyCancellable>()
     
    static func specimen() -> TradeBot {
     //MARK: - CONDITION (CONST) && (CONDITION 2 || CONDITION 3)
//        let condition69: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.33), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: [])!
//        let condition0: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.33), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: [])!
//        let condition2: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.33), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: [])!
//
//        let condition3: EvaluationCondition = .init(technicalIndicator: .bollingerBands(percentage: 0.40), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: [])!
//
        let exitTrigger: EvaluationCondition = .init(technicalIndicator: .exitTrigger(value: 99999999), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
        
        let conditionZ: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: [exitTrigger])!
        
//
//        let conditionX: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: [condition3])!
//
//        let conditionY: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.7), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
        
        
        
        let f = BotFactory()
            .setBudget(42000)
            .setCashBuyPercentage(1)
            .setSharesSellPercentage(1)
            .addCondition(conditionZ)
            .setExitTrigger(afterDays: 10)
            .build()
//        print(f)
        return f
    }
    
    static func inspect(for bot: TradeBot) {
        bot.conditions.forEach { condition in
            print("""
The bot has \(bot.conditions.count) conditions. That is:
Condition: \(condition). And condition: \(condition.andCondition)
""")
        }
    }
    
    static func fetchBot() -> Future<TradeBot, Error> {
        Future { promise in
            fetchBot() { (tradeBot: TradeBot) in
                promise(.success(tradeBot))
                print("Here is the bot: \(tradeBot)")
                inspect(for: tradeBot)
            }
        }
    }

    static private func fetchBot(completion: @escaping (TradeBot) -> Void) {
        let predicate: NSPredicate = NSPredicate(value: true)
        CloudKitUtility.fetch(predicate: predicate, recordType: "TradeBot")
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { (value: [TradeBot]) in
                switch value.first == nil {
                case true:
                       return
                case false:
                    fetchConditions(for: value.first!) { tradeBot in
                        completion(tradeBot)
                    }
                }
            }
            .store(in: &BotAccountCoordinator.subs)
    }
    
    static private func fetchAndConditions(parent: EvaluationCondition, completion: @escaping ([EvaluationCondition]) -> Void) {
          CloudKitUtility.fetchChildren(parent: parent, children: "EvaluationCondition")
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { (value: [EvaluationCondition]) in
                completion(value)
            }
            .store(in: &BotAccountCoordinator.subs)
    }
        
        static private func fetchConditions(for bot: TradeBot, completion: @escaping (TradeBot) -> Void) {
            CloudKitUtility.fetchChildren(parent: bot, children: "EvaluationCondition")
                .sink { result in
                    switch result {
                    case .failure(let error):
                       print(error)
                    case .finished:
                        break
                    }
                } receiveValue: { (value: [EvaluationCondition]) in
                    var bot = bot
                    let group = DispatchGroup()
                    var list: [EvaluationCondition] = []
            
                    value.forEach { condition in
                        var copy = condition
                        group.enter()
                        fetchAndConditions(parent: condition) { andCondition in
                            copy.andCondition = andCondition
                            list.append(copy)
                            group.leave()
                        }
                    }
                    
                    group.wait()
                    bot.conditions = list
                    completion(bot)
                }
                .store(in: &BotAccountCoordinator.subs)
        }
    
    static func upload(completion: @escaping () -> Void) {
        let specimen = specimen()
        
        CloudKitUtility.add(item: specimen) { value in
            CloudKitUtility.saveArray(array: specimen.conditions, for: specimen) { value in
                let group = DispatchGroup()
                for index in specimen.conditions.indices {
                    group.enter()
                    CloudKitUtility.saveArray(array: specimen.conditions[index].andCondition, for: specimen.conditions[index]) { value in
                        Log.queue(action: "AND condition uploaded")
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion()
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
    var exitTrigger: Int?
    
    func setBudget(_ value: Double) -> BotFactory {
        self.budget = value
        return self
    }
    
    func setExitTrigger(afterDays: Int) -> BotFactory {
        self.exitTrigger = afterDays
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
        let bot = TradeBot(budget: budget, account: .init(cash: budget, accumulatedShares: 0), conditions: evaluationConditions, cashBuyPercentage: cashBuyPercentage, sharesSellPercentage: sharesSellPercentage, effectiveAfter: "2021-12-05", exitTrigger: exitTrigger)
        return bot!
    }
}
