//
//  CandleViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import UIKit
import SwiftUI
import Combine

class CandleViewController: UIViewController {
    
    private enum StatisticsMode: CaseIterable {
        case tradingVolume, highLow, movingAverage
    }
    
    let symbol: String
    let viewModel = CandleViewModel()
    var hc: UIHostingController<AnyView>?
    var subscribers = Set<AnyCancellable>()
    var daily: Daily?
    var sorted: [(key: String, value: TimeSeriesDaily)]?
    
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
    
    private var statsLookUp: [StatisticsMode: [CandleMode: MaxMinRange]]?
    private var dataDependencies: [CandleMode: DataDependencies]?
    
    init(symbol: String) {
        self.symbol = symbol
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        hc = UIHostingController(rootView: AnyView(CandleView().environmentObject(viewModel)))
        view.addSubview(hc!.view)
        hc!.view.activateConstraints(reference: view, constraints: [.top(), .leading()], identifier: "hc")
        OHLC(mode: .days5)
        
        
        viewModel.modeChanged = { [unowned self] mode in
            print("You pressed the button")
            viewModel.selectedIndex = 0
            OHLC(mode: mode)
        }
        view.backgroundColor = .white
    }
    
    func initalizeStatsLookUpDict() {
        for cases in StatisticsMode.allCases {
            for mode in CandleMode.allCases {
            statsLookUp = [cases : [mode : .init(max: 0, min: .infinity, range: nil)]]
        }
    }
    }
    
    func initializeDependenciesDict() {
        for cases in CandleMode.allCases {
            dataDependencies = [cases : .init(OHLC: [], movingAverage: [])]
        }
    }
    
    func iterateAndGetDependencies() {
        guard let sorted = sorted else { fatalError() }
            initalizeStatsLookUpDict()
            initializeDependenciesDict()
            var array: [OHLC] = []
            var book = AlgorithmBook()
            var movingAverageCalculator = SimpleMovingAverageCalculator(window: 200)
        
            let indexPositionOf5DaysAgo = book.binarySearch(sorted, key: dateLookUp[.days5]!, range: 0..<sorted.count)!
            book.resetIndex()
            let indexPositionOf1MonthAgo = book.binarySearch(sorted, key: dateLookUp[.months1]!, range: 0..<sorted.count)!
            book.resetIndex()
            let indexPositionOf3MonthsAgo = book.binarySearch(sorted, key: dateLookUp[.months3]!, range: 0..<sorted.count)!
            book.resetIndex()
            let indexPositionOf6MonthsAgo = book.binarySearch(sorted, key: dateLookUp[.months6]!, range: 0..<sorted.count)!
            
        let rangeOf5Days: (Int) -> (Bool) = { idx in return idx < sorted.count - 1 - indexPositionOf5DaysAgo }
        let rangeOf1Month: (Int) -> (Bool) = { idx in return idx < sorted.count - 1 - indexPositionOf1MonthAgo }
        let rangeOf3Months: (Int) -> (Bool) = { idx in return idx < sorted.count - 1 - indexPositionOf3MonthsAgo }
        let rangeOf6Months: (Int) -> (Bool) = { idx in return idx < sorted.count - 1 - indexPositionOf6MonthsAgo }
        
            for index in 0..<sorted.count {
                let iterations = index
                let index = sorted.count - 1 - index
                movingAverageCalculator.movingAverage(data: Double(sorted[index].value.adjustedClose)!, index: iterations)
                
                if rangeOf6Months(index) {
                    metaAnalyze(data: Double(sorted[index].value.volume)!, previousMax: &statsLookUp![.tradingVolume]![.months6]!.max, previousMin: &statsLookUp![.tradingVolume]![.months6]!.min)
                    metaAnalyze(data: Double(sorted[index].value.high)!, previousMax: &statsLookUp![.highLow]![.months6]!.max)
                    metaAnalyze(data: Double(sorted[index].value.low)!, previousMin: &statsLookUp![.highLow]![.months6]!.min)
                    
                    metaAnalyze(data: movingAverageCalculator.min, previousMin: &statsLookUp![.movingAverage]![.months6]!.min)
                    metaAnalyze(data: movingAverageCalculator.max, previousMin: &statsLookUp![.movingAverage]![.months6]!.max)
                    
                    dataDependencies![.months6]!.OHLC.append(.init(meta: daily!.meta!, stamp: sorted[index].key, open: sorted[index].value.open, high: sorted[index].value.high, low: sorted[index].value.low, close: sorted[index].value.close, adjustedClose: sorted[index].value.adjustedClose, volume: sorted[index].value.volume, dividendAmount: sorted[index].value.dividendAmount, splitCoefficient: sorted[index].value.splitCoefficient))
                }
                if rangeOf3Months(index) {
                    metaAnalyze(data: Double(sorted[index].value.volume)!, previousMax: &statsLookUp![.tradingVolume]![.months3]!.max, previousMin: &statsLookUp![.tradingVolume]![.months3]!.min)
                    metaAnalyze(data: Double(sorted[index].value.high)!, previousMax: &statsLookUp![.highLow]![.months3]!.max)
                    metaAnalyze(data: Double(sorted[index].value.low)!, previousMin: &statsLookUp![.highLow]![.months3]!.min)
                    
                    metaAnalyze(data: movingAverageCalculator.min, previousMin: &statsLookUp![.movingAverage]![.months3]!.min)
                    metaAnalyze(data: movingAverageCalculator.max, previousMin: &statsLookUp![.movingAverage]![.months3]!.max)
                    
                    dataDependencies![.months3]!.OHLC.append(.init(meta: daily!.meta!, stamp: sorted[index].key, open: sorted[index].value.open, high: sorted[index].value.high, low: sorted[index].value.low, close: sorted[index].value.close, adjustedClose: sorted[index].value.adjustedClose, volume: sorted[index].value.volume, dividendAmount: sorted[index].value.dividendAmount, splitCoefficient: sorted[index].value.splitCoefficient))
                }
                if rangeOf1Month(index) {
                    metaAnalyze(data: Double(sorted[index].value.volume)!, previousMax: &statsLookUp![.tradingVolume]![.months1]!.max, previousMin: &statsLookUp![.tradingVolume]![.months1]!.min)
                    metaAnalyze(data: Double(sorted[index].value.high)!, previousMax: &statsLookUp![.highLow]![.months1]!.max)
                    metaAnalyze(data: Double(sorted[index].value.low)!, previousMin: &statsLookUp![.highLow]![.months1]!.min)
                    
                    metaAnalyze(data: movingAverageCalculator.min, previousMin: &statsLookUp![.movingAverage]![.months1]!.min)
                    metaAnalyze(data: movingAverageCalculator.max, previousMin: &statsLookUp![.movingAverage]![.months1]!.max)
                    
                    dataDependencies![.months1]!.OHLC.append(.init(meta: daily!.meta!, stamp: sorted[index].key, open: sorted[index].value.open, high: sorted[index].value.high, low: sorted[index].value.low, close: sorted[index].value.close, adjustedClose: sorted[index].value.adjustedClose, volume: sorted[index].value.volume, dividendAmount: sorted[index].value.dividendAmount, splitCoefficient: sorted[index].value.splitCoefficient))
                    
                }
                if rangeOf5Days(index) {
                    metaAnalyze(data: Double(sorted[index].value.volume)!, previousMax: &statsLookUp![.tradingVolume]![.days5]!.max, previousMin: &statsLookUp![.tradingVolume]![.days5]!.min)
                    metaAnalyze(data: Double(sorted[index].value.high)!, previousMax: &statsLookUp![.highLow]![.days5]!.max)
                    metaAnalyze(data: Double(sorted[index].value.low)!, previousMin: &statsLookUp![.highLow]![.days5]!.min)
                    
                    metaAnalyze(data: movingAverageCalculator.min, previousMin: &statsLookUp![.movingAverage]![.days5]!.min)
                    metaAnalyze(data: movingAverageCalculator.max, previousMin: &statsLookUp![.movingAverage]![.days5]!.max)
                    
                    dataDependencies![.days5]!.OHLC.append(.init(meta: daily!.meta!, stamp: sorted[index].key, open: sorted[index].value.open, high: sorted[index].value.high, low: sorted[index].value.low, close: sorted[index].value.close, adjustedClose: sorted[index].value.adjustedClose, volume: sorted[index].value.volume, dividendAmount: sorted[index].value.dividendAmount, splitCoefficient: sorted[index].value.splitCoefficient))
                    
                }
                
            }
        }
    
    
    func OHLC(mode: CandleMode) {
//        guard let sorted = sorted else { fatalError() }
//        var array: [OHLC] = []
//        var book = AlgorithmBook()
//        let key = getMode(mode: mode)
//        let count = book.binarySearch(sorted, key: key, range: 0..<sorted.count)
//
//        var movingAverageCalculator = SimpleMovingAverageCalculator(window: 200)
//
//        var maxVolume: Double = 0
//        var minVolume: Double = .infinity
//
//        var maxHigh: Double = 0
//        var minLow: Double = .infinity
//
//
//        guard let count = count else { fatalError() }
//        for idx in 0...count {
//            let index = idx
//            let idx = count - idx
//            guard idx <= sorted.count - 1 else { break }
//            array.append(.init(meta: daily!.meta!, stamp: sorted[idx].key, open: sorted[idx].value.open, high: sorted[idx].value.high, low: sorted[idx].value.low, close: sorted[idx].value.close, adjustedClose: sorted[idx].value.adjustedClose, volume: sorted[idx].value.volume, dividendAmount: sorted[idx].value.dividendAmount, splitCoefficient: sorted[idx].value.splitCoefficient))
//
//            movingAverageCalculator.movingAverage(data: Double(sorted[idx].value.adjustedClose)!, index: index)
//            metaAnalyze(data: Double(sorted[idx].value.high)!, previousMax: &maxHigh)
//            metaAnalyze(data: Double(sorted[idx].value.low)!, previousMin: &minLow)
//            metaAnalyze(data: Double(sorted[idx].value.volume)!, previousMax: &maxVolume, previousMin: &minVolume)
//        }
//        viewModel.sorted = array
//        viewModel.charts = .init(specifications: .init(padding: viewModel.padding, set: { dict in
//            dict[.bar] = (height: viewModel.barHeight, width: viewModel.width)
//            dict[.line] = (height: viewModel.height, width: viewModel.width)
//            dict[.candle] = (height: viewModel.height, width: viewModel.width)
//        }), data: array, movingAverage: movingAverageCalculator.array, analysis: .init(data: array, movingAverageData: movingAverageCalculator.array, tradingVolume: .init(max: maxVolume, min: minVolume, range: nil), movingAverage: .init(max: movingAverageCalculator.max, min: movingAverageCalculator.min, range: nil), highLow: .init(max: maxHigh, min: minLow, range: nil)))
//        viewModel.charts!.iterateOverData()
    }
    
    private func metaAnalyze(data: Double, previousMax: inout Double, previousMin: inout Double) {
        previousMax = data > previousMax ? data : previousMax
        previousMin = data < previousMin ? data : previousMin
    }
    
    private func metaAnalyze(data: Double, previousMax: inout Double) {
        previousMax = data > previousMax ? data : previousMax
    }
    
    private func metaAnalyze(data: Double, previousMin: inout Double) {
        previousMin = data < previousMin ? data : previousMin
    }
    
    private func constructKey(month: Int, year: Int, day: Int) -> String {
        
        let day: String = day < 10 ? "0\(day)" : "\(day)"
        let month: String = month < 10 ? "0\(month)" : "\(month)"
        
        return "\(year)-\(month)-\(day)"
    }
    
    
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
    
    private struct MaxMinRange {
        var max: Double
        var min: Double
        lazy var range: Double = {
            max - min
        }()
    }
    
    struct DataDependencies {
        var OHLC: [OHLC] = []
        var movingAverage: [Double] = []
    }
}
