//
//  YPositionFactory.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 1/12/21.
//

import Foundation
import CoreGraphics

struct YPositionFactory {
    let analysis: ChartMetaAnalysis
    
    //MARK: DATA DEPENDENCIES
    let data: [OHLCCloudElement]
    
    init(analysis: ChartMetaAnalysis, data: [OHLCCloudElement]) {
        self.analysis = analysis
        self.data = data
    }
    
    enum Mode {
        case tradingVolume, movingAverage
    }
    
    func getYPosition(mode: Mode, heightBounds: CGFloat, index: Int) -> CGFloat {
        switch mode {
        case .tradingVolume:
            let deviation = abs(data[index].volume - analysis.tradingVolume.max)
            let share = deviation / analysis.tradingVolume.range
            let scaled = CGFloat(share) * heightBounds
            return scaled
        case .movingAverage:
            let deviation = abs(data[index].movingAverage - analysis.ultimateMaxMinRange.max)
            let share = deviation / analysis.ultimateMaxMinRange.range
            let scaled = CGFloat(share) * heightBounds
            return scaled
        }
    }
    
    func getYPosition(heightBounds: CGFloat, index: Int) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = analysis.ultimateMaxMinRange.range
        let open = data[index].open
        let high = data[index].high
        let low = data[index].low
        let close = data[index].close
        let yOpen = CGFloat((abs(open - analysis.ultimateMaxMinRange.max)) / range) * heightBounds
        let yHigh = CGFloat((abs(high - analysis.ultimateMaxMinRange.max)) / range) * heightBounds
        let yLow = CGFloat((abs(low - analysis.ultimateMaxMinRange.max)) / range) * heightBounds
        let yClose = CGFloat((abs(close - analysis.ultimateMaxMinRange.max)) / range) * heightBounds
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
}

