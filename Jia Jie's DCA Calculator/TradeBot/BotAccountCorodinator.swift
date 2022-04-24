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
        let exitTrigger: EvaluationCondition = .init(technicalIndicator: .holdingPeriod(value: 99999999), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [])!
        
        let conditionZ: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceBelow, enterOrExit: .exit, andCondition: [exitTrigger])!
        
        let conditionY: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.5), aboveOrBelow: .priceAbove, enterOrExit: .exit, andCondition: [BotFactory.copyCondition(exitTrigger)])!
//
        let conditionX: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 50), aboveOrBelow: .priceBelow, enterOrExit: .enter, andCondition: [])!
//
//        let conditionY: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.7), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: [])!
        
        
        
        let f = BotFactory()
            .setBudget(42000)
            .setCashBuyPercentage(1)
            .setSharesSellPercentage(1)
            .addCondition(conditionZ)
            .addCondition(conditionX)
            .addCondition(conditionY)
            .setholdingPeriod(afterDays: -10)
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
    
    static func upload(tb: TradeBot, completion: @escaping () -> Void) {
        
        CloudKitUtility.add(item: tb) { value in
            CloudKitUtility.saveArray(array: tb.conditions, for: tb) { value in
                let group = DispatchGroup()
                for index in tb.conditions.indices {
                    group.enter()
                    CloudKitUtility.saveArray(array: tb.conditions[index].andCondition, for: tb.conditions[index]) { value in
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
    
    static func delete(tb: TradeBot, completion: @escaping () -> Void) {
        CloudKitUtility.delete(item: tb)
            .sink { success in
                completion()
            } receiveValue: { success in
                
            }
            .store(in: &BotAccountCoordinator.subs)
    }
}

class BotFactory {
    var budget: Double = 0
    var cashBuyPercentage: Double = 0
    var sharesSellPercentage: Double = 0
    var evaluationConditions: [EvaluationCondition] = []
    var holdingPeriod: Int?
    
    func setBudget(_ value: Double) -> BotFactory {
        self.budget = value
        return self
    }
    
    func setholdingPeriod(afterDays: Int) -> BotFactory {
        self.holdingPeriod = afterDays
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
    
//    func setAndCondition(value: EvaluationCondition) -> BotFactory {
//        self.evaluationConditions.append(value)
//        return self
//    }
    
    func build() -> TradeBot {
        let bot = TradeBot(account: .init(budget: budget, cash: budget, accumulatedShares: 0), conditions: evaluationConditions, holdingPeriod: holdingPeriod)
        return bot!
    }
    
    static func copyCondition(_ e: EvaluationCondition) -> EvaluationCondition {
        return EvaluationCondition.init(technicalIndicator: e.technicalIndicator, aboveOrBelow: e.aboveOrBelow, enterOrExit: e.enterOrExit, andCondition: e.andCondition)!
    }
}
