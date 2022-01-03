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
    var rsiCalculator: [Int: RSICalculator] = [:]
    
    func addOHLCCloudElement(key: String, value: TimeSeriesDaily) -> OHLCCloudElement {
        let open = Double(value.open)!
        let high = Double(value.high)!
        let low = Double(value.low)!
        let close = Double(value.close)!
        let stamp: String = key
        let volume: Double = Double(value.volume)!
        
        
        //MARK: TECHNICAL INDICATORS
        if rsiCalculator.isEmpty {
            for idx in 2..<15 {
                rsiCalculator[idx] = .init(period: idx, indexData: close)
            }
        }
        
        var movingAverage = [Int: Double]()
        movingAverage[20] = movingAverageCalculator[20]!.generate(indexData: close)
        movingAverage[50] = movingAverageCalculator[50]!.generate(indexData: close)
        movingAverage[100] = movingAverageCalculator[100]!.generate(indexData: close)
        movingAverage[200] = movingAverageCalculator[200]!.generate(indexData: close)
        
        let bollingerBand = bollingerBandsCalculator.generate(indexData: close)
        
        var rsi = [Int: Double]()
        
        for idx in 2..<15 {
            rsi[idx] = rsiCalculator[idx]!.generate(indexData: close).relativeStrengthIndex
        }
        
        let element: OHLCCloudElement = .init(stamp: stamp, open: open, high: high, low: low, close: close, volume: volume, percentageChange: nil, RSI: rsi, movingAverage: movingAverage, standardDeviation: bollingerBand.standardDeviation, upperBollingerBand: bollingerBand.upperBollingerBand, lowerBollingerBand: bollingerBand.lowerBollingerBand)
        return element
        
    }
}
