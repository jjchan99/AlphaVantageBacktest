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
    weak var coordinator: CandleCoordinator?
    
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
        
        testBot()
    }
    
    func testBot() {
        let condition: TradeBot.EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceBelow, buyOrSell: .buy)
//        let condition2: TradeBot.EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .sell)
                
        var bot = TradeBot(budget: 10000, account: .init(cash: 10000, accumulatedShares: 0), conditions: [condition])
                
        for data in coordinator!.OHLCDependencies[.months6]! {
                    bot.evaluate(latest: data)
        }
        print("Bot account at the end is: \(bot.account)")
    }

    
    
    func iterateAndGetDependencies() {
        //MARK: THIS METHOD HAS EXCLUSIVE ACCESS TO THE DICTIONARY
        guard let sorted = sorted else { fatalError() }
        guard let coordinator = coordinator else { fatalError() }
    
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
        
        //MARK: TEST WRITE
//        statsLookUp[.tradingVolume]![.months6]!.max = 1
        
            for index in 0..<sorted.count {
                let iterations = index
                let index = sorted.count - 1 - index
                var average: Double = movingAverageCalculator.movingAverage(data: Double(sorted[index].value.adjustedClose)!)

                if rangeOf6Months(iterations) {
                    coordinator.updatePercentageChange(period: .months6, index: index)
                    coordinator.updateMovingAverage(period: .months6, average: average)
                    coordinator.updateOHLCArray(period: .months6, index: index)
                    coordinator.updateStats(period: .months6, index: index)
                   
                }
                if rangeOf3Months(iterations) {
                    coordinator.updatePercentageChange(period: .months3, index: index)
                    coordinator.updateMovingAverage(period: .months3, average: average)
                    coordinator.updateOHLCArray(period: .months3, index: index)
                    coordinator.updateStats(period: .months3, index: index)
                
                }
                if rangeOf1Month(iterations) {
                    coordinator.updatePercentageChange(period: .months1, index: index)
                    coordinator.updateMovingAverage(period: .months1, average: average)
                    coordinator.updateOHLCArray(period: .months1, index: index)
                    coordinator.updateStats(period: .months1, index: index)
                
                }
                if rangeOf5Days(iterations) {
                    coordinator.updatePercentageChange(period: .days5, index: index)
                    coordinator.updateMovingAverage(period: .days5, average: average)
                    coordinator.updateOHLCArray(period: .days5, index: index)
                    coordinator.updateStats(period: .days5, index: index)
                
                }
                
            }
        
//        print("Inspect: \(dataDependencies[.months6]!.OHLC.count)")
//        print("Inspect: \(dataDependencies[.days5]!.OHLC.count)")
            Log.queue(action: "DONE DICT")
        }
    
    
    func OHLC(mode: CandleMode) {
        guard let coordinator = coordinator else { fatalError() }
        
        let OHLC = coordinator.OHLCDependencies[mode]!
        let movingAverageData = coordinator.movingAverageDependencies[mode]!
        let tradingVolume = coordinator.statsLookUp[.tradingVolume]![mode]!
        let movingAverage = coordinator.statsLookUp[.movingAverage]![mode]!
        let highLow = coordinator.statsLookUp[.highLow]![mode]!
        
        viewModel.sorted = OHLC
        var charts: ChartLibrary = .init(specifications: .init(padding: viewModel.padding, set: { dict in
            dict[.bar] = (height: viewModel.barHeight, width: viewModel.width)
            dict[.line] = (height: viewModel.height, width: viewModel.width)
            dict[.candle] = (height: viewModel.height, width: viewModel.width)
        }), data: OHLC, movingAverage: movingAverageData, analysis: .init(tradingVolume: .init(max: tradingVolume.max, min: tradingVolume.min), movingAverage: .init(max: movingAverage.max, min: movingAverage.min), highLow: .init(max: highLow.max, min: highLow.min)))
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
