//
//  FetchLatest.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 4/12/21.
//

import Foundation
import Combine

protocol OHLCManager {
    
}


class GraphManager: NSObject, OHLCManager, Coordinator {
    func iterate() {
        for idx in 0..<sorted.count {
            let iterations = idx
            let idx = sorted.count - 1 - idx
            let OHLCCloudElement = technicalManager.addOHLCCloudElement(key: sorted[idx].key, value: sorted[idx].value)
            
            if rangeOf6Months(iterations) {
                OHLCDataForRelevantPeriod[.months6]!.append(OHLCCloudElement)
                statisticsManager.evaluate(period: .months6, value: OHLCCloudElement)
            }
            
            if rangeOf3Months(iterations) {
                OHLCDataForRelevantPeriod[.months3]!.append(OHLCCloudElement)
                statisticsManager.evaluate(period: .months3, value: OHLCCloudElement)
            }
            
            if rangeOf1Month(iterations) {
                OHLCDataForRelevantPeriod[.months1]!.append(OHLCCloudElement)
                statisticsManager.evaluate(period: .months1, value: OHLCCloudElement)
            }
            
            if rangeOf5Days(iterations) {
                OHLCDataForRelevantPeriod[.days5]!.append(OHLCCloudElement)
                statisticsManager.evaluate(period: .days5, value: OHLCCloudElement)
            }
        }
    }
    
    let sorted: [(key: String, value: TimeSeriesDaily)]
    let technicalManager = OHLCTechnicalManager(window: 200)
    let statisticsManager = OHLCStatisticsManager()
    
    var OHLCDataForRelevantPeriod: [CandleMode: [OHLCCloudElement]] = {
        var placeholder: [CandleMode: [OHLCCloudElement]] = [:]
        for cases in CandleMode.allCases {
            placeholder[cases] = []
        }
        return placeholder
    }()
    
    init(sorted: [(key: String, value: TimeSeriesDaily)]) {
        self.sorted = sorted
    }
    
    
    lazy var rangeOf5Days: (Int) -> (Bool) = { [unowned self] idx in
        var book = AlgorithmBook()
        let indexPositionOf5DaysAgo = book.binarySearch(sorted, key: dateLookUp[.days5]!, range: 0..<sorted.count)!
        return idx > sorted.count - 1 - indexPositionOf5DaysAgo
    }
    
    lazy var rangeOf1Month: (Int) -> (Bool) = { [unowned self] idx in
        var book = AlgorithmBook()
        let indexPositionOf1MonthAgo = book.binarySearch(sorted, key: dateLookUp[.months1]!, range: 0..<sorted.count)!
        return idx > sorted.count - 1 - indexPositionOf1MonthAgo
    }
    lazy var rangeOf3Months: (Int) -> (Bool) = { [unowned self] idx in
        var book = AlgorithmBook()
        let indexPositionOf3MonthsAgo = book.binarySearch(sorted, key: dateLookUp[.months3]!, range: 0..<sorted.count)!
        return idx > sorted.count - 1 - indexPositionOf3MonthsAgo
    }
    
    lazy var rangeOf6Months: (Int) -> (Bool) = { [unowned self] idx in
        var book = AlgorithmBook()
        let indexPositionOf6MonthsAgo = book.binarySearch(sorted, key: dateLookUp[.months6]!, range: 0..<sorted.count)!
        return idx > sorted.count - 1 - indexPositionOf6MonthsAgo
    }
    
    //MARK: DATE IS INITIALIZED WHEN VC IS INITIALIZED
    let daysAgo5 = Date.init(timeIntervalSinceNow: -86400 * 6)
    let monthsAgo1 = Date.init(timeIntervalSinceNow: -86400 * 31)
    let monthsAgo3 = Date.init(timeIntervalSinceNow: -(86400 * 30 * 3) - 86400)
    let monthsAgo6 = Date.init(timeIntervalSinceNow: -(86400 * 30 * 6) - 86400)
    
    lazy var dateLookUp: [CandleMode : String] = {
        let dict: [CandleMode: String] = [
            .days5 : getDate(mode: .days5),
            .months1 : getDate(mode: .months1),
            .months3 : getDate(mode: .months3),
            .months6 : getDate(mode: .months6)
        ]
        return dict
    }()
    
    private func getDate(mode: CandleMode) -> String {
        switch mode {
        case .days5:
            let year = Calendar.current.component(.year, from: daysAgo5)
            let month = Calendar.current.component(.month, from: daysAgo5)
            let day = Calendar.current.component(.day, from: daysAgo5)
            return constructKey(month: month, year: year, day: day)
            
        case .months1:
            let year = Calendar.current.component(.year, from: monthsAgo1)
            let month = Calendar.current.component(.month, from: monthsAgo1)
            let day = Calendar.current.component(.day, from: monthsAgo1)
            return constructKey(month: month, year: year, day: day)
        
        case .months3:
            let year = Calendar.current.component(.year, from: monthsAgo3)
            let month = Calendar.current.component(.month, from: monthsAgo3)
            let day = Calendar.current.component(.day, from: monthsAgo3)
            return constructKey(month: month, year: year, day: day)
            
        case .months6:
            let year = Calendar.current.component(.year, from: monthsAgo6)
            let month = Calendar.current.component(.month, from: monthsAgo6)
            let day = Calendar.current.component(.day, from: monthsAgo6)
            return constructKey(month: month, year: year, day: day)
        }
    }
    
    private func constructKey(month: Int, year: Int, day: Int) -> String {
        
        let day: String = day < 10 ? "0\(day)" : "\(day)"
        let month: String = month < 10 ? "0\(month)" : "\(month)"
        
        return "\(year)-\(month)-\(day)"
    }
}

class OHLCStatisticsManager {
    enum Metric: CaseIterable {
        case movingAverage, upperBollingerBand, lowerBollingerBand, RSI, high, low, tradingVolume
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
    
    private func getValueFromMetric(metric: Metric, value: OHLCCloudElement) -> Double? {
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
        case .tradingVolume:
            return value.volume
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
