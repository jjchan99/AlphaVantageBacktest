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
    let viewModel = CandleViewModel<OHLCCloudElement>()
    var hc: UIHostingController<AnyView>?
    var subscribers = Set<AnyCancellable>()
    var daily: Daily?
    var sorted: [(key: String, value: TimeSeriesDaily)]?
    weak var coordinator: GraphManager?
    
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
        coordinator!.iterate()
        OHLC(mode: .days5)
      
        //MARK: DICT CHANGES WILL NOT BE REFELCTED UNTIL VIEWDIDLOAD IS FINISHED. THREAD SAFETY MECHANISM
        viewModel.modeChanged = { [unowned self] mode in
            print("You pressed the button")
            viewModel.selectedIndex = 0
            OHLC(mode: mode)
        }
        view.backgroundColor = .white
        
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
        
        OHLCCloudElement.itemsToPlot = [
            \OHLCCloudElement.movingAverage : .init(type: .line, title: "movingAverage", min: movingAverage.min, max: movingAverage.max),
             \OHLCCloudElement.volume : .init(type: .bar, title: "volume", min: tradingVolume.min, max: tradingVolume.max),
             \OHLCCloudElement.emptyKey : .init(type: .candle, title: "daily", min: min(movingAverage.min, low.min), max: max(movingAverage.max, high.max))
        ]
        
        viewModel.chartsOutput = ChartLibraryGeneric.render(OHLC: OHLC)
        
        Log.queue(action: "I expect the app to crash")
    }
}
 
