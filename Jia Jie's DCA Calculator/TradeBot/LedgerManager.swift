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
    
    func append(description: String, context: ContextObject, condition: EvaluationCondition) {
        let deltaShares = condition.enterOrExit == .enter ? context.tb.account.cash / context.mostRecent.close : -1 * context.account.accumulatedShares
        let deltaCash = condition.enterOrExit == .exit ? context.tb.account.accumulatedShares * context.mostRecent.close : -1 * context.tb.account.cash
        entries.append(.init(description: description, stamp: context.mostRecent.stamp, deltaCash: deltaCash, deltaShares: deltaShares))
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
