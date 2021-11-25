//
//  DCAResultMeta.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 23/10/21.
//

import Foundation

struct DCAResultMeta {
    var minYield: Double
    var maxYield: Double
    var minGain: Double
    var maxGain: Double
    var minAnnualReturn: Double
    var maxAnnualReturn: Double
    var minCurrentValue: Double
    var maxCurrentValue: Double
    
    func mode(mode: Mode, min: Bool) -> Double {
        switch mode {
        case .gain:
            if min {
                return minGain
            } else {
                return maxGain
            }
        case .yield:
            if min {
                return minYield
            } else {
                return maxYield
            }
        case .annualReturn:
        if min {
            return minAnnualReturn
        } else {
            return maxAnnualReturn
        }
        }
    }
}
