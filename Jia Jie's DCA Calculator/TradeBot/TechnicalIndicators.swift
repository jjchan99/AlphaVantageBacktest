//
//  TechnicalIndicators.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 26/12/21.
//

import Foundation
enum TechnicalIndicators: Hashable, CustomStringConvertible {

    case movingAverage(period: Int),
         bollingerBands(percentage: Double),
         RSI(period: Int, value: Double),
         lossTarget(value: Double),
         profitTarget(value: Double),
         exitTrigger(value: Int),
         movingAverageOperation(period1: Int, period2: Int)

    var description: String {
        switch self {
        case let .movingAverage(period: period):
            return ("\(period) day moving average")
        case let .bollingerBands(percentage: percentage):
            return ("bollingerBand percent")
        case let .RSI(period: period, value: value):
            return "\(period) period RSI"
        case .lossTarget(value: let value):
            return "exit at loss"
        case .profitTarget(value: let value):
            return "exit at profit"
        case .exitTrigger(value: let value):
            return "exit date"
        case .movingAverageOperation:
            return ""
        }
    }
    

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
        case .exitTrigger(value: let value):
            return Double(value)
        case .movingAverageOperation(period1: let period1, period2: let period2):
            return Double(Int("\(period1)\(period2)")!)
        }
    }
    
    static func build(rawValue: Double) -> Self {
        
        switch rawValue {
        case let x where x >= 10000000:
            return exitTrigger(value: Int(rawValue))
            
        case let x where x >= 1000000:
            return .lossTarget(value: rawValue - 1000000)
            
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
