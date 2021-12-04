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
        case movingAverage, upperBollingerBand, lowerBollingerBand, RSI, high, low
    }
    
    struct MaxMinRange {
        var max: Double
        var min: Double
    }
    
    var maxMinRange: [CandleMode: [Metric: OHLCStatisticsManager.MaxMinRange]] = {
        var nestedDict: [Metric: OHLCStatisticsManager.MaxMinRange] = [:]
        var placeholder: [CandleMode: [Metric: OHLCStatisticsManager.MaxMinRange]] = [:]
            for cases in CandleMode.allCases {
                for m in Metric.allCases {
                    nestedDict[m] = .init(max: 0, min: .infinity)
                }
                placeholder[cases] = nestedDict
        }
        return placeholder
    }()
    
    private func newMaxNewMin(evaluate data: Double, previousMax: Double, previousMin: Double) -> (newMax: Double, newMin: Double) {
        let newMax = data > previousMax ? data : previousMax
        let newMin = data < previousMin ? data : previousMin
        
//        previousMax = newMax
//        previousMin = newMin
        
        return ((newMax, newMin))
    }
    
    func evaluate(period: CandleMode, value: OHLCCloudElement) {
        for m in Metric.allCases {
            guard let evaluate = getValueFromMetric(metric: m, value: value) else { continue }
            let result = newMaxNewMin(evaluate: evaluate, previousMax: maxMinRange[period]![m]!.max, previousMin: maxMinRange[period]![m]!.min)
            maxMinRange[period]![m]!.max = result.newMax
            maxMinRange[period]![m]!.min = result.newMin
        }
    }
    
    func getValueFromMetric(metric: Metric, value: OHLCCloudElement) -> Double? {
        switch metric {
        case .high:
            return value.high
        case .low:
            return value.low
        case .movingAverage:
            return value.movingAverage
        case .RSI:
            return value.RSI
        case .upperBollingerBand:
            return value.upperBollingerBand
        case .lowerBollingerBand:
            return value.lowerBollingerBand
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
