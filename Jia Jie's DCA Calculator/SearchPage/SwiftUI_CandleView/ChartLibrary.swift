//
//  ChartLibrary.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/11/21.
//

import Foundation
import SwiftUI
import CoreGraphics

struct ChartLibrary {
    
    let height: CGFloat
    let width: CGFloat
    let padding: CGFloat
    let data: [OHLC]
    let analysis: ChartMetaAnalysis
    
    var candles: [Candle]
    var volumeChart: Path
    var movingAverageChart: Path
    
    func iterateOverData() {
        let width = width - (2 * padding)
        let maxWidth = 0.03 * width
        let pillars = width / CGFloat(data.count - 1)
            
        var spacing = (1/3) * pillars > maxWidth ? maxWidth : (1/3) * pillars
        spacing = pillars <= 5.0 ? 1 : spacing
        
        
        for index in data.indices {
            let xPosition = index == 0 ? padding : (pillars * CGFloat(index)) + padding
            
        }
    }
    
    mutating func renderBarPath(index: Int) {
        
    }
    
    mutating func renderLinePath(index: Int) {
        
    }
    
    mutating func renderCandlePath(index: Int) {
        
    }
    
}



struct ChartMetaAnalysis {
    
    let tradingVolume: TradingVolume
    let movingAverage: MovingAverage
    let highLow: HighLow
    
    enum Mode {
        case tradingVolume, movingAverage, highLow
    }
    
    func getYPosition(mode: Mode, data: OHLC, height: CGFloat) -> CGFloat {
        switch mode {
        case .tradingVolume:
            let deviation = abs(Double(data.volume!)! - tradingVolume.max)
            let share = deviation / tradingVolume.range
            let scaled = CGFloat(share) * height
            return scaled
        case .movingAverage:
            let deviation = abs(Double(data.volume!)! - tradingVolume.max)
            let share = deviation / tradingVolume.range
            let scaled = CGFloat(share) * height
            return scaled
        case .highLow:
            let deviation = abs(Double(data.volume!)! - tradingVolume.max)
            let share = deviation / tradingVolume.range
            let scaled = CGFloat(share) * height
            return scaled
        }
    }
    
    internal struct TradingVolume {
        let max: Double
        let min: Double
        var range: Double {
            max - min
        }
    }
    
    internal struct MovingAverage {
        let max: Double
        let min: Double
        var range: Double {
            max - min
        }
    }
    
    internal struct HighLow {
        let max: Double
        let min: Double
        var range: Double {
            max - min
        }
    }
}
