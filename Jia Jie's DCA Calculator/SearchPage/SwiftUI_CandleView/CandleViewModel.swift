//
//  CandleViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

enum CandleMode: CaseIterable {
    case days5
    case months1
    case months3
    case months6
}

class CandleViewModel: ObservableObject {
    
    let height: CGFloat = .init(350).hScaled()
    let width: CGFloat = .init(420).wScaled()
    let barHeight: CGFloat = .init(45).hScaled()
    lazy var heightScaledForSingleCandleView: CGFloat = 0.5 * width
    
//    @Published var charts: ChartLibrary? { didSet {
//        Log.queue(action: "Charts are ready")
//        indicator = .init(height: height, width: width, dataToDisplay: charts!.candles)
//    }}
    
    @Published var selectedIndex: Int?
    
    @Published var modeChanged: ((CandleMode) -> ())?
    
//    @Published var singleCandleRenderer: SingleCandleRenderer?
    
    @Published var RC: RenderClient<OHLCCloudElement>?
    
    @Published var indicator: CandleIndicator?
    
    @Published var daily: Daily? {
        didSet {
            print("daily set")
        }
    }
    
    lazy var padding: CGFloat = 0.05 * width
    
    func backtest() {
        Backtest.from(date: "2022-01-01", daily: self.daily!, bot: BotAccountCoordinator.specimen())
    }
}


