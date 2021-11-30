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
           
            
        }()
        
    }
    
    
    
    
    
    
    struct BollingerBand {
        var simpleMovingAverage: Double?
        var standardDeviation: Double?
        var upperBollingerBand: Double?
        var lowerBollingerBand: Double?
    }
    
}


