//
//  TechnicalIndicators.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 26/12/21.
//

import Foundation
enum TechnicalIndicators: Hashable {

    case movingAverage(period: Int),
         bollingerBands(percentage: Double),
         RSI(period: Int, value: Double),
         lossTarget(value: Double),
         profitTarget(value: Double),
         holdingPeriod(value: Int),
         movingAverageOperation(period1: Int, period2: Int)
    
    var rawValue: Double {
        switch self {
        case let .movingAverage(period: period):
            return Double(period * 2)
        case let .bollingerBands(percentage: percentage):
            return percentage
        case let .RSI(period: period, value: value):
            return Double(2 * period) + (value)
        case .lossTarget(value: let value):
            return value + 1000000
        case .profitTarget(value: let value):
            return value + 2
        case .holdingPeriod(value: let value):
            return Double(10000000 + value)
        case .movingAverageOperation(period1: let period1, period2: let period2):
            return Double(Int("\(period1)\(period2)")!)
        }
    }
    
    static func build(rawValue: Double) -> Self {
        
        switch rawValue {
        case let x where x >= 10000000:
            return holdingPeriod(value: Int(rawValue - 10000000))
            
        case let x where x >= 1000000:
            return .lossTarget(value: rawValue - 1000000)
            
        case let x where x >= 2020 && x <= 200200:
            let decoded = MAOperationDecoder.decode(rawValue: rawValue)
            return .movingAverageOperation(period1: decoded.period1, period2: decoded.period2)
            
        case let x where x >= 40:
            return .movingAverage(period: Int(rawValue / 2))
            
        case let x where x >= 4 && x <= 29:
            let period = floor(rawValue) * 0.5
            let value = Int(rawValue) % 2 == 0 ? rawValue - floor(rawValue) : 1
            return .RSI(period: Int(period), value: value)
       
        case let x where x >= 2:
            return .profitTarget(value: rawValue - 2)
       
        default:
            return .bollingerBands(percentage: rawValue)
        }
    }
}
