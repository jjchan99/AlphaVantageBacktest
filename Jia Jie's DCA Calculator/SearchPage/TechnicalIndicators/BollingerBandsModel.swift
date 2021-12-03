//
//  BollingerBandsModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 30/11/21.
//

import Foundation
struct BollingerBandCalculator {
    
    let window: Int
    var array: [BollingerBand] = []
    var movingAverageCalculator: SimpleMovingAverageCalculator
    
    init(window: Int) {
        self.window = window
        self.movingAverageCalculator = .init(window: window)
    }
    
    private mutating func generate(indexData: Double) -> BollingerBand {
        let simpleMovingAverage: Double? = {
            var avg: Double?
            movingAverageCalculator.movingAverage(data: indexData) { average in
                avg = array.count >= window ? average : nil
            }
            return avg
        }()
        
        let standardDeviation: Double? = {
            guard let simpleMovingAverage = simpleMovingAverage else { return nil }
            return movingAverageCalculator.stdev(avg: simpleMovingAverage)
        }()
        
        let upperBollingerBand: Double? = {
            guard let simpleMovingAverage = simpleMovingAverage, let standardDeviation = standardDeviation else { return nil }
            return simpleMovingAverage + standardDeviation * 2
        }()
        
        let lowerBollingerBand: Double? = {
            guard let simpleMovingAverage = simpleMovingAverage, let standardDeviation = standardDeviation else { return nil }
            return simpleMovingAverage - standardDeviation * 2
        }()
        
        return .init(simpleMovingAverage: simpleMovingAverage, standardDeviation: standardDeviation, upperBollingerBand: upperBollingerBand, lowerBollingerBand: lowerBollingerBand)
    }
    
    mutating func append(indexData: Double) {
        array.append(generate(indexData: indexData))
    }
    
    
    
    
    
    
    struct BollingerBand {
        var simpleMovingAverage: Double?
        var standardDeviation: Double?
        var upperBollingerBand: Double?
        var lowerBollingerBand: Double?
        func valueAtPercent(percent: Double) -> Double? {
            guard upperBollingerBand != nil, lowerBollingerBand != nil else { return nil }
            return ( upperBollingerBand! - lowerBollingerBand! ) * percent
        }
    }
    
}


