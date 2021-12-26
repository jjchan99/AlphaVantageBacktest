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
         monthlyPeriodic,
         stopOrder(value: Double),
         profitTarget(value: Double),
         exitTrigger(value: Int)

    var description: String {
        switch self {
        case let .movingAverage(period: period):
            return ("\(period) day moving average")
        case let .bollingerBands(percentage: percentage):
            return ("\(percentage)%B")
        case let .RSI(period: period, value: value):
            return "\(period) period RSI value of \(value)"
        case .monthlyPeriodic:
            return "monthly end investment"
        case .stopOrder(value: let value):
            return "stop order initiates at \(value)"
        case .profitTarget(value: let value):
            return "stop order initiates when profit is at \(value)"
        case .exitTrigger(value: let value):
            return "exiting on \(value)"
        }
    }

    var rawValue: Double {
        switch self {
        case let .movingAverage(period: period):
            return Double(period)
        case let .bollingerBands(percentage: percentage):
            return percentage
        case let .RSI(period: period, value: value):
            return Double(2 * period) + (value)
        case .monthlyPeriodic:
            return 69
        case .stopOrder(value: let value):
            return value + 1000000
        case .profitTarget(value: let value):
            return value + 2
        case .exitTrigger(value: let value):
            return Double(value)
        }
    }
    
    static func build(rawValue: Double) -> Self {
        
        switch rawValue {
        case let x where x >= 10000000:
            return exitTrigger(value: Int(rawValue))
            
        case let x where x >= 1000000:
            return .stopOrder(value: rawValue - 1000000)
            
        case let x where x >= 50:
            return .movingAverage(period: Int(rawValue))
            
        case let x where x == 69:
            return .monthlyPeriodic
            
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
