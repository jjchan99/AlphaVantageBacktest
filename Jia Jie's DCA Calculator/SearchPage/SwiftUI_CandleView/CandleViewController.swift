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
            OHLC(mode: mode)
            
        }
        view.backgroundColor = .white
    }
    
    func OHLC(mode: CandleMode) {
        guard let sorted = sorted else { fatalError() }
        var array: [OHLC] = []
        var book = AlgorithmBook()
        let key = getMode(mode: mode)
        let count = book.binarySearch(sorted, key: key, range: 0..<sorted.count)
        
        var movingAverageCalculator = SimpleMovingAverageCalculator(window: 200)
        
        var maxVolume: Double = 0
        var minVolume: Double = .infinity
    
        var maxHigh: Double = 0
        var minLow: Double = .infinity
        
        
        guard let count = count else { fatalError() }
        for idx in 0...count {
            let index = idx
            let idx = count - idx
            guard idx <= sorted.count - 1 else { break }
            array.append(.init(meta: daily!.meta!, stamp: sorted[idx].key, open: sorted[idx].value.open, high: sorted[idx].value.high, low: sorted[idx].value.low, close: sorted[idx].value.close, adjustedClose: sorted[idx].value.adjustedClose, volume: sorted[idx].value.volume, dividendAmount: sorted[idx].value.dividendAmount, splitCoefficient: sorted[idx].value.splitCoefficient))
    
            movingAverageCalculator.movingAverage(data: Double(sorted[idx].value.adjustedClose)!, index: index)
            metaAnalyze(data: Double(sorted[idx].value.high)!, previousMax: &maxHigh)
            metaAnalyze(data: Double(sorted[idx].value.low)!, previousMin: &minLow)
            metaAnalyze(data: Double(sorted[idx].value.volume)!, previousMax: &maxVolume, previousMin: &minVolume)
        }
        viewModel.sorted = array
        viewModel.charts = .init(specifications: .init(padding: viewModel.padding, set: { dict in
            dict[.bar] = (height: viewModel.barHeight, width: viewModel.width)
            dict[.line] = (height: viewModel.height, width: viewModel.width)
            dict[.candle] = (height: viewModel.height, width: viewModel.width)
        }), data: array, movingAverage: movingAverageCalculator.array, analysis: .init(data: array, movingAverageData: movingAverageCalculator.array, tradingVolume: .init(max: maxVolume, min: minVolume, range: nil), movingAverage: .init(max: movingAverageCalculator.max, min: movingAverageCalculator.min, range: nil), highLow: .init(max: maxHigh, min: minLow, range: nil)))
        viewModel.charts!.iterateOverData()
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
    
    
    private func getMode(mode: CandleMode) -> String {
        switch mode {
        case .days5:
            let daysAgo5 = Date.init(timeIntervalSinceNow: -86400 * 6)
            let year = Calendar.current.component(.year, from: daysAgo5)
            let month = Calendar.current.component(.month, from: daysAgo5)
            let day = Calendar.current.component(.day, from: daysAgo5)
            return constructKey(month: month, year: year, day: day)
            
        case .months1:
            let monthsAgo1 = Date.init(timeIntervalSinceNow: -86400 * 31)
            let year = Calendar.current.component(.year, from: monthsAgo1)
            let month = Calendar.current.component(.month, from: monthsAgo1)
            let day = Calendar.current.component(.day, from: monthsAgo1)
            return constructKey(month: month, year: year, day: day)
        
        case .months3:
            let monthsAgo3 = Date.init(timeIntervalSinceNow: -(86400 * 30 * 3) - 86400)
            let year = Calendar.current.component(.year, from: monthsAgo3)
            let month = Calendar.current.component(.month, from: monthsAgo3)
            let day = Calendar.current.component(.day, from: monthsAgo3)
            return constructKey(month: month, year: year, day: day)
            
        case .months6:
            let monthsAgo6 = Date.init(timeIntervalSinceNow: -(86400 * 30 * 6) - 86400)
            let year = Calendar.current.component(.year, from: monthsAgo6)
            let month = Calendar.current.component(.month, from: monthsAgo6)
            let day = Calendar.current.component(.day, from: monthsAgo6)
            return constructKey(month: month, year: year, day: day)
        }
    }
    
   
    
   
}
