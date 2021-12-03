//
//  CandleCoordinator.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 2/12/21.
//

import Foundation
class CandleCoordinator: NSObject, Coordinator {
    
    var sorted: [(key: String, value: TimeSeriesDaily)]
    var daily: Daily
    
    init(sorted: [(key: String, value: TimeSeriesDaily)], daily: Daily) {
        self.sorted = sorted
        self.daily = daily
    }
    
    private func metaAnalyze(data: Double, previousMax: Double, previousMin: Double, completion: (Double, Double) -> Void) {
        let newMax = data > previousMax ? data : previousMax
        let newMin = data < previousMin ? data : previousMin
        
//        previousMax = newMax
//        previousMin = newMin
        
        completion(newMax, newMin)
    }
    
    private func metaAnalyze(data: Double, previousMax: Double, completion: (Double) -> Void) {
        let newMax = data > previousMax ? data : previousMax
//        previousMax = newMax
        completion(newMax)
    }
    
    private func metaAnalyze(data: Double, previousMin: Double, completion: (Double) -> Void) {
        let newMin = data < previousMin ? data : previousMin
//        previousMin = newMin
        completion(newMin)
    }
    
    var statsLookUp: [StatisticsMode: [CandleMode: MaxMinRange]] = {
        var nestedDict: [CandleMode: MaxMinRange] = [:]
        var statsLookUpCopy: [StatisticsMode: [CandleMode: MaxMinRange]] = [:]
        
        for mode in CandleMode.allCases {
            nestedDict[mode] = .init(max: 0, min: .infinity, range: nil)
            for cases in StatisticsMode.allCases {
                statsLookUpCopy[cases] = nestedDict
            }
    }
        
        return statsLookUpCopy
    }()
    
    var percentageChangeDependencies: [CandleMode: PercentageChange] = [:]
    
    var movingAverageDependencies: [CandleMode: [Double]] = {
        var dataDependenciesCopy: [CandleMode: [Double]] = [:]
        for cases in CandleMode.allCases {
            dataDependenciesCopy[cases] = []
        }
        return dataDependenciesCopy
    }()
    
    var OHLCDependencies: [CandleMode: [OHLC]] = {
        var dataDependenciesCopy: [CandleMode: [OHLC]] = [:]
        for cases in CandleMode.allCases {
            dataDependenciesCopy[cases] = []
        }
        return dataDependenciesCopy
    }()
    
    
    
   
    
}

extension CandleCoordinator {
    func updateStats(period: CandleMode, index: Int) {
        metaAnalyze(data: Double(sorted[index].value.volume)!, previousMax: statsLookUp[.tradingVolume]![period]!.max, previousMin: statsLookUp[.tradingVolume]![period]!.min) { newMax, newMin in
                statsLookUp[.tradingVolume]![period]!.max = newMax
                statsLookUp[.tradingVolume]![period]!.min = newMin
            
            metaAnalyze(data: Double(sorted[index].value.high)!, previousMax: statsLookUp[.highLow]![period]!.max) { newMax in statsLookUp[.highLow]![period]!.max = newMax
            }
            metaAnalyze(data: Double(sorted[index].value.low)!, previousMin: statsLookUp[.highLow]![period]!.min) { newMin in
                statsLookUp[.highLow]![period]!.min = newMin
            }

            metaAnalyze(data: movingAverageDependencies[period]!.last!, previousMin: statsLookUp[.movingAverage]![period]!.min) { newMin in
                statsLookUp[.movingAverage]![period]!.min = newMin
            }
            metaAnalyze(data: movingAverageDependencies[period]!.last!, previousMax: statsLookUp[.movingAverage]![period]!.max) { newMax in
                statsLookUp[.movingAverage]![period]!.max = newMax
            }
        }
    }
    
    func updateMovingAverage(period: CandleMode, average: Double) {
        movingAverageDependencies[period]!.append(average)
    }
    
    func updateOHLCArray(period: CandleMode, index: Int) {
        OHLCDependencies[period]!.append(.init(meta: daily.meta!, stamp: sorted[index].key, open: sorted[index].value.open, high: sorted[index].value.high, low: sorted[index].value.low, close: sorted[index].value.close, adjustedClose: sorted[index].value.adjustedClose, volume: sorted[index].value.volume, dividendAmount: sorted[index].value.dividendAmount, splitCoefficient: sorted[index].value.splitCoefficient, percentageChange: percentageChangeDependencies[period]?.percentageChangeArray.last))
    }
    
    func updatePercentageChange(period: CandleMode, index: Int) {
        guard percentageChangeDependencies[period] != nil else { percentageChangeDependencies[period] = .init(first: Double(sorted[index].value.close)!)
            return
        }
        percentageChangeDependencies[period]!.percentageChange(new: Double(sorted[index].value.close)!)
    }
}
