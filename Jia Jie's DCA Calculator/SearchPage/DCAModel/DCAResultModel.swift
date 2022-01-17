//
//  DCAResultModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 15/9/21.
//

import Foundation

public struct DCAResult: CustomStringConvertible, Identifiable, MonthSpecified {
    public let id = UUID()
    
    let symbol: String
    let currentValue: Double
    let accumulatedInvestment: Double
    let gain: Double
    let yield: Double
    let annualReturn: Double
    
    let month: String
    
    public var description: String {
        return """
            === Displaying results for \(symbol) ===
            
            month: \(month)
            
            currentValue: $\(currentValue)
            accumulatedInvestment: $\(accumulatedInvestment)
            gain: $\(gain)
            yield: \(yield)%
            annualReturn: \(annualReturn)%
            """
    }
    
    func mode(mode: Mode) -> Double {
        switch mode {
        case .gain:
            return gain
        case .yield:
            return yield
        case .annualReturn:
            return annualReturn
        }
    }
    
    func format(mode: Mode) -> String {
        switch mode {
        case .gain:
            return gain.roundedWithAbbreviations
        case .yield:
            return (yield).percentageFormat
        case .annualReturn:
            return (annualReturn).percentageFormat
        }
        
    }
}


