//
//  FetchLatest.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 4/12/21.
//

import Foundation

protocol OHLCManager {
    var sorted: [(key: String, value: TimeSeriesDaily)] { get }
    var manager: OHLCTechnicalManager { get }
}

class FetchLatest: OHLCManager {
    
    let sorted: [(key: String, value: TimeSeriesDaily)] = []
    let manager = OHLCTechnicalManager(window: 200)
    
}

class GraphManager: OHLCManager {
    let sorted: [(key: String, value: TimeSeriesDaily)] = []
    let manager = OHLCTechnicalManager(window: 200)
    
    let OHLCDataForRelevantPeriod: [CandleMode: [OHLCCloudElement]] = {
        var placeholder: [CandleMode: [OHLCCloudElement]] = [:]
        for cases in CandleMode.allCases {
            placeholder[cases] = []
        }
        return placeholder
    }()
}

class OHLCTechnicalManager {
    
    let window: Int
    
    init(window: Int) {
        self.window = window
        self.movingAverageCalculator = .init(window: window)
        self.bollingerBandsCalculator = .init(window: window)
    }
    
    var movingAverageCalculator: SimpleMovingAverageCalculator
    var bollingerBandsCalculator: BollingerBandCalculator
    var rsiCalculator: RSICalculator?
    
    func addOHLCCloudElement(key: String, value: TimeSeriesDaily) -> OHLCCloudElement {
        let open = Double(value.open)!
        let high = Double(value.high)!
        let low = Double(value.low)!
        let close = Double(value.close)!
        let stamp: String = key
        let adjustedClose: Double = Double(value.adjustedClose)!
        let volume: Double = Double(value.volume)!
        let dividendAmount: Double = Double(value.dividendAmount)!
        let splitCoefficient: Double = Double(value.splitCoefficient)!
        
        
        //MARK: TECHNICAL INDICATORS
        if rsiCalculator == nil { rsiCalculator = .init(period: window, indexData: close) }
        let movingAverage = movingAverageCalculator.generate(indexData: close)
        let bollingerBand = bollingerBandsCalculator.generate(indexData: close)
        let rsi = rsiCalculator!.generate(indexData: close)
        
        let element: OHLCCloudElement = .init(stamp: stamp, open: open, high: high, low: low, close: close, adjustedClose: adjustedClose, volume: volume, dividendAmount: dividendAmount, splitCoefficient: splitCoefficient, percentageChange: nil, RSI: rsi.relativeStrengthIndex, movingAverage: movingAverage, standardDeviation: bollingerBand.standardDeviation, upperBollingerBand: bollingerBand.upperBollingerBand, lowerBollingerBand: bollingerBand.lowerBollingerBand)
        return element
        
    }
}
