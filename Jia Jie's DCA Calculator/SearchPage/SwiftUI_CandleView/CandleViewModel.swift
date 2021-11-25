//
//  CandleViewModel.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import SwiftUI

enum CandleMode {
    case days5
    case months1
    case months3
    case months6
}

class CandleViewModel: ObservableObject {
    
    @Published var sorted: [OHLC]? {
        didSet { self.id = UUID() }
    }
    
    let height: CGFloat = .init(350).hScaled()
    let width: CGFloat = .init(420).wScaled()
    
    @Published var selectedIndex: Int?
    
    @Published var renderer: CandleRenderer?
    @Published var barGraphRendererV2: BarGraphRendererV2?
    @Published var candles: [Candle]?
    
    @Published var modeChanged: ((CandleMode) -> ())?
    
    @Published var id = UUID()
    
    lazy var padding: CGFloat = 0.05 * width
    
    @Published var tradingAlgo: TradeAlgo?
    
    @Published var OHLCMeta: OHLCMeta?
    
    @Published var volumeGraph: Path?
    @Published var movingAverageGraph: Path?
    
    let barHeight: CGFloat = .init(45).hScaled()
    
    
    
    
    
}

struct OHLCMeta {
    let maxVolume: Double
    let minVolume: Double
    let maxClose: Double
    let minClose: Double
}
