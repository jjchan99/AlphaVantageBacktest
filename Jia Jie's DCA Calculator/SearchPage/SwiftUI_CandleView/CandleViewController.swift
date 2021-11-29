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
    
    private var statsLookUp: [StatisticsMode: [CandleMode: MaxMinRange]] = {
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
    
    private var dataDependencies: [CandleMode: DataDependencies] = {
        var dataDependenciesCopy: [CandleMode: DataDependencies] = [:]
        for cases in CandleMode.allCases {
            dataDependenciesCopy[cases] = .init(OHLC: [], movingAverage: [])
        }
        return dataDependenciesCopy
    }()
    
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
        iterateAndGetDependencies()
        OHLC(mode: .days5)
      
        //MARK: DICT CHANGES WILL NOT BE REFELCTED UNTIL VIEWDIDLOAD IS FINISHED. THREAD SAFETY MECHANISM
        viewModel.modeChanged = { [unowned self] mode in
            print("You pressed the button")
            viewModel.selectedIndex = 0
            OHLC(mode: mode)
        }
        view.backgroundColor = .white
    }
    
    func iterateAndGetDependencies() {
        //MARK: THIS METHOD HAS EXCLUSIVE ACCESS TO THE DICTIONARY
        guard let sorted = sorted else { fatalError() }
    
            var book = AlgorithmBook()
            var movingAverageCalculator = SimpleMovingAverageCalculator(window: 200)
        
            let indexPositionOf5DaysAgo = book.binarySearch(sorted, key: dateLookUp[.days5]!, range: 0..<sorted.count)!
            book.resetIndex()
            let indexPositionOf1MonthAgo = book.binarySearch(sorted, key: dateLookUp[.months1]!, range: 0..<sorted.count)!
            book.resetIndex()
            let indexPositionOf3MonthsAgo = book.binarySearch(sorted, key: dateLookUp[.months3]!, range: 0..<sorted.count)!
            book.resetIndex()
            let indexPositionOf6MonthsAgo = book.binarySearch(sorted, key: dateLookUp[.months6]!, range: 0..<sorted.count)!
            
        let rangeOf5Days: (Int) -> (Bool) = { idx in return idx > sorted.count - 1 - indexPositionOf5DaysAgo }
        let rangeOf1Month: (Int) -> (Bool) = { idx in return idx > sorted.count - 1 - indexPositionOf1MonthAgo }
        let rangeOf3Months: (Int) -> (Bool) = { idx in return idx > sorted.count - 1 - indexPositionOf3MonthsAgo }
        let rangeOf6Months: (Int) -> (Bool) = { idx in return idx > sorted.count - 1 - indexPositionOf6MonthsAgo }
        
        let updateDict: (CandleMode, Int) -> Void = { [unowned self] period, index in
            metaAnalyze(data: Double(sorted[index].value.volume)!, previousMax: statsLookUp[.tradingVolume]![period]!.max, previousMin: statsLookUp[.tradingVolume]![period]!.min) { newMax, newMin in
                    statsLookUp[.tradingVolume]![period]!.max = newMax
                    statsLookUp[.tradingVolume]![period]!.min = newMin
                
                metaAnalyze(data: Double(sorted[index].value.high)!, previousMax: statsLookUp[.highLow]![period]!.max) { newMax in statsLookUp[.highLow]![period]!.max = newMax
                }
                metaAnalyze(data: Double(sorted[index].value.low)!, previousMin: statsLookUp[.highLow]![period]!.min) { newMin in
                    statsLookUp[.highLow]![period]!.min = newMin
                }

                metaAnalyze(data: dataDependencies[period]!.movingAverage.last!, previousMin: statsLookUp[.movingAverage]![period]!.min) { newMin in
                    statsLookUp[.movingAverage]![period]!.min = newMin
                }
                metaAnalyze(data: dataDependencies[period]!.movingAverage.last!, previousMax: statsLookUp[.movingAverage]![period]!.max) { newMax in
                    statsLookUp[.movingAverage]![period]!.max = newMax
                }
            }
        }
        
        let updateDependencies: (CandleMode, Int, Double) -> Void = { [unowned self] period, index, average in
            dataDependencies[period]!.OHLC.append(.init(meta: daily!.meta!, stamp: sorted[index].key, open: sorted[index].value.open, high: sorted[index].value.high, low: sorted[index].value.low, close: sorted[index].value.close, adjustedClose: sorted[index].value.adjustedClose, volume: sorted[index].value.volume, dividendAmount: sorted[index].value.dividendAmount, splitCoefficient: sorted[index].value.splitCoefficient))
            dataDependencies[period]!.movingAverage.append(average)
        }
        
        //MARK: TEST WRITE
//        statsLookUp[.tradingVolume]![.months6]!.max = 1
        
            for index in 0..<sorted.count {
                let iterations = index
                let index = sorted.count - 1 - index
                var average: Double!
                movingAverageCalculator.movingAverage(data: Double(sorted[index].value.adjustedClose)!, index: iterations) { avg in average = avg }

                if rangeOf6Months(iterations) {
                    updateDependencies(.months6, index, average)
                    updateDict(.months6, index)
                   
                }
                if rangeOf3Months(iterations) {
                    updateDependencies(.months3, index, average)
                    updateDict(.months3, index)
                
                }
                if rangeOf1Month(iterations) {
                    updateDependencies(.months1, index, average)
                    updateDict(.months1, index)
                
                }
                if rangeOf5Days(iterations) {
                    updateDependencies(.days5, index, average)
                    updateDict(.days5, index)
                
                }
                
            }
        
//        print("Inspect: \(dataDependencies[.months6]!.OHLC.count)")
//        print("Inspect: \(dataDependencies[.days5]!.OHLC.count)")
            Log.queue(action: "DONE DICT")
        }
    
    
    func OHLC(mode: CandleMode) {
        let OHLC = dataDependencies[mode]!.OHLC
        let movingAverageData = dataDependencies[mode]!.movingAverage
        let tradingVolume = statsLookUp[.tradingVolume]![mode]!
        let movingAverage = statsLookUp[.movingAverage]![mode]!
        let highLow = statsLookUp[.highLow]![mode]!
        
        viewModel.sorted = OHLC
        var charts: ChartLibrary = .init(specifications: .init(padding: viewModel.padding, set: { dict in
            dict[.bar] = (height: viewModel.barHeight, width: viewModel.width)
            dict[.line] = (height: viewModel.height, width: viewModel.width)
            dict[.candle] = (height: viewModel.height, width: viewModel.width)
        }), data: OHLC, movingAverage: movingAverageData, analysis: .init(data: OHLC, movingAverageData: movingAverageData, tradingVolume: .init(max: tradingVolume.max, min: tradingVolume.min, range: nil), movingAverage: .init(max: movingAverage.max, min: movingAverage.min, range: nil), highLow: .init(max: highLow.max, min: highLow.min, range: nil)))
        charts.iterateOverData()
        viewModel.charts = charts
        
        Log.queue(action: "I expect the app to crash")
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
    
  
}

struct DataDependencies {
    var OHLC: [OHLC] = []
    var movingAverage: [Double] = []
}

struct MaxMinRange {
    var max: Double
    var min: Double
    lazy var range: Double = {
        max - min
    }()
}

enum StatisticsMode: CaseIterable {
    case tradingVolume, highLow, movingAverage
}
