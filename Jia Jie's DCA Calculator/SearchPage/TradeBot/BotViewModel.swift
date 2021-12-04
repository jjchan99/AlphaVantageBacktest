////
////  BotViewModel.swift
////  Jia Jie's DCA Calculator
////
////  Created by Jia Jie Chan on 3/12/21.
////
//
//import Foundation
//import SwiftUI
//
//class BotViewModel: ObservableObject {
//
//    let symbol: String = ""
//    let name: String = ""
//
//    @Published var conditions: [UUID: TradeBot.EvaluationCondition] = [:]
//    @Published var budget: Double = 0
//
//    func buildCondition(indicator: TechnicalIndicators, threshold: TradeBot.AboveOrBelow, decision: TradeBot.BuyOrSell) {
//        conditions[UUID()] = .init(technicalIndicator: indicator, aboveOrBelow: threshold, buyOrSell: decision)
//    }
//
//    func removeCondition(_ key: UUID) {
//        conditions.removeValue(forKey: key)
//    }
//
//    var createBotButtonTapped: (() -> ())?
//
//    func createBot() -> (TradeBot) {
//        var placeholder: [TradeBot.EvaluationCondition] = []
//        conditions.forEach { id, condition in
//            placeholder.append(condition)
//        }
//
//        return(.init(budget: budget, account: .init(cash: budget, accumulatedShares: 0), conditions: placeholder, database: .init(technicalIndicators: [:])))
//    }
//
//
//
//
//}
