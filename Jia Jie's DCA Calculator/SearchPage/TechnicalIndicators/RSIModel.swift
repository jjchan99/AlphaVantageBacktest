//
//  RSIModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 30/11/21.
//

import Foundation

struct RSICalculator {
    
    var array: [RSI]
    let period: Int
    
    init(period: Int, indexData: Double) {
        self.period = period
        array = []
        array.append(.init(indexData: indexData, upwardMovement: nil, downwardMovement: nil, averageUpwardMovement: nil, averageDownwardMovement: nil, relativeStrength: nil, relativeStrengthIndex: nil))
    }
    
    private func generate(indexData: Double) -> RSI {
        let previous = array.last!
        
        let upwardMovement =
            indexData > previous.indexData ?
            indexData - previous.indexData
            : 0
        
        
        let downwardMovement =
            indexData < previous.indexData ?
            previous.indexData - indexData
            : 0
       
        
        let averageUpwardMovement: Double? = {
            let averageUpwardMovement: () -> (Double) = {
                (previous.averageUpwardMovement! * Double(period - 1)
                    + upwardMovement) / Double(period)
            }
            return array.count > period + 1 ?
               averageUpwardMovement()
            : array.count < period + 1 ?
            nil
            : array.reduce(0) {
                $0 + $1.indexData/Double(array.count)
            }
        }()
        
        let averageDownwardMovement: Double? = {
            let averageDownwardMovement: () -> (Double) = {
                (previous.averageDownwardMovement! * Double(period - 1)
                    + downwardMovement) / Double(period)
            }
            return array.count > period + 1 ?
               averageDownwardMovement()
            : array.count < period + 1 ?
            nil
            : array.reduce(0) {
                $0 + $1.indexData/Double(array.count)
            }
        }()
        
        let relativeStrength: Double? = {
           guard let averageUpwardMovement = averageUpwardMovement, let averageDownwardMovement = averageDownwardMovement else { return nil }
           return averageUpwardMovement / averageDownwardMovement
        }()
        
        let relativeStrengthIndex: Double? = {
            guard let relativeStrength = relativeStrength else { return nil }
            return 100 - ( 100 / (relativeStrength + 1) )
        }()
        
        
        return .init(indexData: indexData, upwardMovement: upwardMovement, downwardMovement: downwardMovement, averageUpwardMovement: averageUpwardMovement, averageDownwardMovement: averageDownwardMovement, relativeStrength: relativeStrength, relativeStrengthIndex: relativeStrengthIndex)
    }
    
    mutating func append(indexData: Double) {
        array.append(generate(indexData: indexData))
    }
    
    
    struct RSI {
        let indexData: Double
        let upwardMovement: Double?
        let downwardMovement: Double?
        let averageUpwardMovement: Double?
        let averageDownwardMovement: Double?
        let relativeStrength: Double?
        let relativeStrengthIndex: Double?
    }
    
}
