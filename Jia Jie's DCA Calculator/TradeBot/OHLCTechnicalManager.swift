//
//  OHLCTechnicalManager.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 9/12/21.
//

import Foundation
class OHLCTechnicalManager {
    
    var movingAverageCalculator: [Int: SimpleMovingAverageCalculator] = [20: SimpleMovingAverageCalculator(window: 20), 50: SimpleMovingAverageCalculator(window: 50), 100: SimpleMovingAverageCalculator(window: 100), 200: SimpleMovingAverageCalculator(window: 200)]
    var bollingerBandsCalculator = BollingerBandCalculator(window: 20)
    var rsiCalculator: RSICalculator?
    
    func addOHLCCloudElement(key: String, value: TimeSeriesDaily) -> OHLCCloudElement {
        let open = Double(value.open)!
        let high = Double(value.high)!
        let low = Double(value.low)!
        let close = Double(value.close)!
        let stamp: String = key
        let volume: Double = Double(value.volume)!
        
        
        //MARK: TECHNICAL INDICATORS
        if rsiCalculator == nil {
            rsiCalculator = .init(period: 14, indexData: close)
        }
        
        var movingAverage = [Int: Double]()
        movingAverage[20] = movingAverageCalculator[20]!.generate(indexData: close)
        movingAverage[50] = movingAverageCalculator[50]!.generate(indexData: close)
        movingAverage[100] = movingAverageCalculator[100]!.generate(indexData: close)
        movingAverage[200] = movingAverageCalculator[200]!.generate(indexData: close)
        
        let bollingerBand = bollingerBandsCalculator.generate(indexData: close)
        let rsi = rsiCalculator!.generate(indexData: close)
        
        let element: OHLCCloudElement = .init(stamp: stamp, open: open, high: high, low: low, close: close, volume: volume, percentageChange: nil, RSI: rsi.relativeStrengthIndex, movingAverage: movingAverage, standardDeviation: bollingerBand.standardDeviation, upperBollingerBand: bollingerBand.upperBollingerBand, lowerBollingerBand: bollingerBand.lowerBollingerBand)
        return element
        
    }
}
