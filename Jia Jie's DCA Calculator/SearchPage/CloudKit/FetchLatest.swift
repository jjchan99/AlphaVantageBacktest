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

class OHLCDataManager {
    
    var array: [OHLCCloudElement] = []
    var movingAverageCalculator = SimpleMovingAverageCalculator(window: 200)
    var bollingerBandsCalculator = BollingerBandCalculator(window: 200)
    var rsiCalculator: RSICalculator?
    
    func addOHLCCloudElement(value: TimeSeriesDaily) {
        let close = Double(value.close)!
        var average: Double!
        movingAverageCalculator.movingAverage(data: close) { avg in
            average = avg
        }
        bollingerBandsCalculator.generate(indexData: close)
        
    }
    
    
}
