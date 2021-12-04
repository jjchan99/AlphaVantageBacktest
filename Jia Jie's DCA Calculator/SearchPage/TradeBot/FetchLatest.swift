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

class OHLCStatisticsManager {
    enum Metric: CaseIterable {
        case movingAverage, bollingerBands, RSI, highLow
    }
    
    var maxMinRange: [CandleMode: [Metric: ChartMetaAnalysis.MaxMinRange]] = {
        var nestedDict: [Metric: ChartMetaAnalysis.MaxMinRange] = [:]
        var placeholder: [CandleMode: [Metric: ChartMetaAnalysis.MaxMinRange]] = [:]
            for cases in CandleMode.allCases {
                for m in Metric.allCases {
                    nestedDict[m] = .init(max: 0, min: .infinity)
                }
                placeholder[cases] = nestedDict
        }
        return placeholder
    }()
    
    private func newMaxNewMin(data: Double, previousMax: Double, previousMin: Double) -> (newMax: Double, newMin: Double) {
        let newMax = data > previousMax ? data : previousMax
        let newMin = data < previousMin ? data : previousMin
        
//        previousMax = newMax
//        previousMin = newMin
        
        return ((newMax, newMin))
    }
    
    private func newMax(data: Double, previousMax: Double) -> Double {
        let newMax = data > previousMax ? data : previousMax
//        previousMax = newMax
        return newMax
    }
    
    private func newMin(data: Double, previousMin: Double) -> Double {
        let newMin = data < previousMin ? data : previousMin
//        previousMin = newMin
        return newMin
    }
    
    func evaluate(period: CandleMode, value: TimeSeriesDaily) {
        for m in Metric.allCases {
            maxMinRange[period]![m]
        }
    }
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
