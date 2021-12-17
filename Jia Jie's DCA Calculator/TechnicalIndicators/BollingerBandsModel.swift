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
    
    mutating func generate(indexData: Double) -> BollingerBand {
        let simpleMovingAverage: Double? = {
            var avg: Double?
            let average = movingAverageCalculator.generate(indexData: indexData)
            avg = array.count >= window ? average : nil
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
        
        let bollingerBand: BollingerBand = .init(simpleMovingAverage: simpleMovingAverage, standardDeviation: standardDeviation, upperBollingerBand: upperBollingerBand, lowerBollingerBand: lowerBollingerBand)
        array.append(bollingerBand)
        return bollingerBand
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


