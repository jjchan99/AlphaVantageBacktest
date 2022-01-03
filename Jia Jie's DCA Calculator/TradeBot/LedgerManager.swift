//
//  DescriptionManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/12/21.
//

import Foundation
import CloudKit

class LedgerManager {
    var entries: [LedgerRecord] = []
    
    func append(description: String, latest: OHLCCloudElement, bot: TradeBot, condition: EvaluationCondition) {
        let deltaShares = condition.enterOrExit == .enter ? bot.account.cash / latest.close : -1 * bot.account.accumulatedShares
        let deltaCash = condition.enterOrExit == .exit ? bot.account.accumulatedShares * latest.close : -1 * bot.account.cash
        entries.append(.init(description: description, stamp: latest.stamp, deltaCash: deltaCash, deltaShares: deltaShares))
    }
}

struct LedgerRecord {

    init(description: String, stamp: String, deltaCash: Double, deltaShares: Double) {
        self.description = description
        self.stamp = stamp
        self.deltaCash = deltaCash
        self.deltaShares = deltaShares
    }
    
    let description: String
    let stamp: String
    let deltaCash: Double
    let deltaShares: Double
}
