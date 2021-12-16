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
        
        let condition2: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.33), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: nil)!
        
        let condition3: EvaluationCondition = .init(technicalIndicator: .bollingerBands(percentage: 0.40), aboveOrBelow: .priceBelow, buyOrSell: .buy, andCondition: nil)!
        
        let conditionZ: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: condition2)!
        
        let conditionX: EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .buy, andCondition: condition3)!
        
        let conditionY: EvaluationCondition = .init(technicalIndicator: .RSI(period: 14, value: 0.7), aboveOrBelow: .priceAbove, buyOrSell: .sell, andCondition: nil)!
        
        let f = BotFactory()
            .setBudget(42000)
            .setCashBuyPercentage(1)
            .setSharesSellPercentage(0.5)
            .addCondition(conditionZ)
            .addCondition(conditionX)
            .addCondition(conditionY)
            .build()
//        print(f)
        return f
    }
    
    static func inspect(for bot: TradeBot) {
        bot.conditions.forEach { condition in
//            print("Condition: \(condition). And condition: \(condition.next)")
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
    
    static private func traverseFetch(list: LinkedList<EvaluationCondition>, parent: EvaluationCondition, completion: @escaping (LinkedList<EvaluationCondition>) -> Void) {
        CloudKitUtility.fetchChildren(parent: parent, children: "EvaluationCondition")
            .sink { result in
                switch result {
                case .failure(let error):
                   print(error)
                case .finished:
                    break
                }
            } receiveValue: { (value: [EvaluationCondition]) in
                if value.first != nil {
                    list.append(value: value.first!)
                    traverseFetch(list: list, parent: value.first!, completion: { list in })
                } else {
                    completion(list)
                }
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
                    var list: [LinkedList<EvaluationCondition>] = []
                    var bot = bot
                    let group = DispatchGroup()
            
                    value.forEach { condition in
                        group.enter()
                        traverseFetch(list: LinkedList<EvaluationCondition>(head: condition), parent: condition) { completeList in
                            list.append(completeList)
                            group.leave()
                        }
                    }
                    
                    group.wait()
                    bot.conditions = list
                    completion(bot)
                }
                .store(in: &BotAccountCoordinator.subs)
        }
    
    static func traverseSave(child: EvaluationCondition, for parents: EvaluationCondition) {
        CloudKitUtility.saveChild(child: child, for: parents) { value in
            Log.queue(action: "AND condition uploaded")
            
         
        }
    }
    
    
    
    
    
    static func upload(completion: @escaping () -> Void) {
        let specimen = specimen()
        let andParents: [EvaluationCondition] = specimen.conditions.compactMap { condition in
            if condition.next != nil { return condition } else { return nil }
        }
        
        CloudKitUtility.add(item: specimen) { value in
            CloudKitUtility.saveArray(array: specimen.conditions!, for: specimen) { value in
                let group = DispatchGroup()
                for index in andParents.indices {
                    group.enter()
                    CloudKitUtility.saveChild(child: andParents[index].next!, for: andParents[index]) { value in
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
        let bot = TradeBot(budget: budget, account: .init(cash: budget, accumulatedShares: 0), conditions: evaluationConditions, cashBuyPercentage: cashBuyPercentage, sharesSellPercentage: sharesSellPercentage, effectiveAfter: "2021-12-05")
        return bot!
    }
}
