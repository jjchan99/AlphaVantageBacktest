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
        let open = Double(value.open)!
        let high = Double(value.high)!
        let low = Double(value.low)!
        
        let adjustedClose: Double
        let volume: Double
        let dividendAmount: Double
        let splitCoefficient: Double
        let percentageChange: Double
        
        let information: String
        let symbol: String
        let lastRefreshed: String
        let outputSize: String
        let timeZone: String
        
        
        
        
        //MARK: TECHNICAL INDICATORS
        let close = Double(value.close)!
        let movingAverage = movingAverageCalculator.generate(indexData: close)
        let bollingerBand = bollingerBandsCalculator.generate(indexData: close)
        let rsi = rsiCalculator?.generate(indexData: close)
        
    }
}
