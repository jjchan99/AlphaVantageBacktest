//
//  CandleViewController.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//
//SUN 12 DEC: 7:09 PM. SEEMS TO WORK

import Foundation
import UIKit
import SwiftUI
import Combine

class CandleViewController: UIHostingController<AnyView> {
    
    let symbol: String
    let viewModel = CandleViewModel()
    var hc: UIHostingController<AnyView>?
    var subscribers = Set<AnyCancellable>()
    var daily: Daily?
    var sorted: [(key: String, value: TimeSeriesDaily)]?
    weak var coordinator: GraphManager?
    
    init(symbol: String) {
        self.symbol = symbol
        super.init(rootView: AnyView(CandleView().environmentObject(viewModel)))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        coordinator!.iterate()
        OHLC(mode: .days5)
      
        //MARK: DICT CHANGES WILL NOT BE REFELCTED UNTIL VIEWDIDLOAD IS FINISHED. THREAD SAFETY MECHANISM
        viewModel.modeChanged = { [unowned self] mode in
            print("You pressed the button")
            viewModel.selectedIndex = 0
            OHLC(mode: mode)
        }
        view.backgroundColor = .white
        overrideUserInterfaceStyle = .light
        
//        testBot()
    }
    
//    func testBot() {
//        let condition: TradeBot.EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceBelow, buyOrSell: .buy)
////        let condition2: TradeBot.EvaluationCondition = .init(technicalIndicator: .movingAverage(period: 200), aboveOrBelow: .priceAbove, buyOrSell: .sell)
//
//        var bot = TradeBot(budget: 10000, account: .init(cash: 10000, accumulatedShares: 0), conditions: [condition])
//
//        for data in coordinator!.OHLCDependencies[.months6]! {
//                    bot.evaluate(latest: data)
//        }
//        print("Bot account at the end is: \(bot.account)")
//    }
 
    func OHLC(mode: CandleMode) {
        guard let coordinator = coordinator else { fatalError() }
        
        let OHLC = coordinator.OHLCDataForRelevantPeriod[mode]!
        let tradingVolume = coordinator.statisticsManager.maxMinRange[mode]![.tradingVolume]!
        let movingAverage = coordinator.statisticsManager.maxMinRange[mode]![.movingAverage]!
        let high = coordinator.statisticsManager.maxMinRange[mode]![.high]!
        let low = coordinator.statisticsManager.maxMinRange[mode]![.low]!
        
  
        
//        OHLCCloudElement.itemsToPlot = [
//            \OHLCCloudElement.movingAverage : .init(count: OHLC.count, type: .line(zero: false), title: "movingAverage", height: viewModel.height, width: viewModel.width, padding: viewModel.padding, max: max(movingAverage.max, high.max), min: min(movingAverage.min, low.min)),
//             \OHLCCloudElement.volume : .init(count: OHLC.count, type: .bar(zero: false), title: "volume", height: viewModel.barHeight, width: viewModel.width, padding: viewModel.padding, max: tradingVolume.max, min: tradingVolume.min),
//             \OHLCCloudElement.emptyKey : .init(count: OHLC.count, type: .candle, title: "daily", height: viewModel.height, width: viewModel.width, padding: viewModel.padding, max: max(movingAverage.max, high.max), min: min(movingAverage.min, low.min))
//        ]
        
        let RC = RenderClient(data: OHLC)
        RC.add(title: "movingAverage", state: LineState(data: OHLC, frame: .init(count: OHLC.count, height: viewModel.height, width: viewModel.width, padding: viewModel.padding), mmr: .init(max: max(movingAverage.max, high.max), min: min(movingAverage.min, low.min)), setKeyPath: \OHLCCloudElement.movingAverage[200]!))
        RC.add(title: "dailyTicker", state: CandleState(data: OHLC, frame: .init(count: OHLC.count, height: viewModel.height, width: viewModel.width, padding: viewModel.padding), mmr: .init(max: max(movingAverage.max, high.max), min: min(movingAverage.min, low.min)), setKeyPath: \OHLCCloudElement.movingAverage[200]!))
        RC.add(title: "volume", state: BarState(data: OHLC, frame: .init(count: OHLC.count, height: viewModel.height * 0.5, width: viewModel.width, padding: viewModel.padding), mmr: .init(max: tradingVolume.max, min: tradingVolume.min), setKeyPath: \OHLCCloudElement.volume))
        RC.startRender {
            viewModel.RC = RC
        }
  
        
        
//        viewModel.chartsOutput = ChartLibraryGeneric.render(OHLC: OHLC, setItemsToPlot: [
//            \OHLCCloudElement.movingAverage[200]! : .init(count: OHLC.count, type: .line(zero: false), title: "movingAverage", height: viewModel.height, width: viewModel.width, padding: viewModel.padding, max: max(movingAverage.max, high.max), min: min(movingAverage.min, low.min)),
//             \OHLCCloudElement.volume : .init(count: OHLC.count, type: .bar(zero: false), title: "volume", height: viewModel.barHeight, width: viewModel.width, padding: viewModel.padding, max: tradingVolume.max, min: tradingVolume.min),
//             \OHLCCloudElement.emptyKey : .init(count: OHLC.count, type: .candle, title: "daily", height: viewModel.height, width: viewModel.width, padding: viewModel.padding, max: max(movingAverage.max, high.max), min: min(movingAverage.min, low.min))
//        ])
//        viewModel.indicator = .init(height: viewModel.height, width: viewModel.width, dataToDisplay: viewModel.chartsOutput!.candles["daily"]!)
//        viewModel.singleCandleRenderer = SingleCandleRenderer(movingAverage: .init(max: movingAverage.max, min: movingAverage.min), highLow: .init(max: high.max, min: low.min), candles: viewModel.chartsOutput!.candles["daily"]!, spec: OHLCCloudElement.itemsToPlot[\OHLCCloudElement.emptyKey]!)
        
        Log.queue(action: "I expect the app to crash")
    }
}
 
