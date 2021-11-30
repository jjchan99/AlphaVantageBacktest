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
        let simpleMovingAverage: Double? = { movingAverageCalculator.movingAverage(data: indexData) { average in return average
        }
        }()
        
    }
    
    
    
    
    
    
    struct BollingerBand {
        var simpleMovingAverage: Double?
        var standardDeviation: Double?
        var upperBollingerBand: Double?
        var lowerBollingerBand: Double?
    }
    
}
