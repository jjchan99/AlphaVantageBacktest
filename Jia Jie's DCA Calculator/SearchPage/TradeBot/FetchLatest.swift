//
//  FetchLatest.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 4/12/21.
//

import Foundation

class FetchLatest {
    
    let sorted: [(key: String, value: TimeSeriesDaily)] = []
    
    
    
    
    
}

class OHLCTechnicalManager {
    
    var array: [OHLCCloudElement] = []
    var movingAverageCalculator = SimpleMovingAverageCalculator(window: 200)
    var bollingerBandsCalculator = BollingerBandCalculator(window: 200)
    var rsiCalculator: RSICalculator?
    
    func addOHLCCloudElement(value: TimeSeriesDaily) {
        let close = Double(value.close)!
        let movingAverage = movingAverageCalculator.generate(indexData: close)
        let bollingerBand = bollingerBandsCalculator.generate(indexData: close)
        let rsi = rsiCalculator?.generate(indexData: close)
    }
}
