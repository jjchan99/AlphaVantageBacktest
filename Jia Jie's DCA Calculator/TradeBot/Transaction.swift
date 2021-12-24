//
//  Transaction.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 21/12/21.
//

import Foundation
struct Timeline {
    let stamp: String
    var previousCash: Double
    var newCash: Double
    var previousShares: Double
    var newShares: Double
}

struct TBAlgoDescription {
    let outcome: Bool
    let description: String
    let stamp: String
}
