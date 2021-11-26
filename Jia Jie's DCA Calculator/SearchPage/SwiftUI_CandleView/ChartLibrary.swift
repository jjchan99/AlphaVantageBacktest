//
//  ChartLibrary.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 25/11/21.
//

import Foundation
import SwiftUI
import CoreGraphics

enum Charts {
    case bar
    case line
    case candle
}

struct ChartLibrary {
   
    
    //MARK: VIEW DEPENDENCIES
    let specifications: ChartSpecifications
    
    //MARK: DATA DEPENDENCIES
    let data: [OHLC]
    let movingAverage: [Double]
    
    //MARK: BOUND DEPENDENCIES
    let analysis: ChartMetaAnalysis
    
    //MARK: OUTPUT
    var candles: [Candle] = []
    var volumeChart = Path()
    var movingAverageChart = Path()
    
    init(specifications: ChartSpecifications, data: [OHLC], movingAverage: [Double], analysis: ChartMetaAnalysis) {
        self.specifications = specifications
        self.data = data
        self.movingAverage = movingAverage
        self.analysis = analysis
    }
    
    //MARK: ALL-IN-ONE RENDER
    func iterateOverData() {
        let width = specifications.specifications[.line]!.width - (2 * specifications.padding)
        let maxWidth = 0.03 * width
        let pillars = width / CGFloat(data.count - 1)
            
        var spacing = (1/3) * pillars > maxWidth ? maxWidth : (1/3) * pillars
        spacing = pillars <= 5.0 ? 1 : spacing
        
        
        for index in data.indices {
            let xPosition = index == 0 ? specifications.padding : (pillars * CGFloat(index)) + specifications.padding
            
        }
    }
    
    func getXPosition(index: Int) -> CGFloat {
        return index == 0 ? specifications.padding : (pillars * CGFloat(index)) + specifications.padding
    }
    
    mutating func renderBarPath(index: Int) {
        let width = width - (2 * padding)
        let maxWidth = 0.03 * width
        let yPosition = getYPosition(index: index)
        let pillars = width / CGFloat(data.count - 1)
        
        var spacing = (1/3) * pillars > maxWidth ? maxWidth : (1/3) * pillars
        let xPosition = index == 0 ? padding : (pillars * CGFloat(index)) + padding
        spacing = pillars <= 5.0 ? 1 : spacing
        
        path.move(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
        path.addLine(to: .init(x: xPosition + (0.5 * spacing), y: yPosition))
        path.addLine(to: .init(x: xPosition + (0.5 * spacing), y: height))
        path.addLine(to: .init(x: xPosition - (0.5 * spacing), y: height))
        path.addLine(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
        path.closeSubpath()
    }
    
    mutating func renderLinePath(index: Int) {
        
    }
    
    mutating func renderCandlePath(index: Int) {
        
    }
    
}

struct ChartSpecifications {
    
    init(padding: CGFloat, set: ([Charts: (height: CGFloat, width: CGFloat)]) -> ()) {
        set(self.specifications)
        self.padding = padding
    }
    
    private(set) var specifications: [Charts: (height: CGFloat, width: CGFloat)] = [:]
    let padding: CGFloat
}



struct ChartMetaAnalysis {
    
    //MARK: DATA DEPENDENCIES
    let data: [OHLC]
    let movingAverageData: [Double]
    
    
    //MARK: STATISTICAL META DATA
    let tradingVolume: TradingVolume
    let movingAverage: MovingAverage
    let highLow: HighLow
    
    
    //MARK: MODE SELECTION
    enum Mode {
        case tradingVolume, movingAverage
    }
    
    func getYPosition(mode: Mode, bounds height: CGFloat, index: Int) -> CGFloat {
        switch mode {
        case .tradingVolume:
            let deviation = abs(Double(data[index].volume!)! - tradingVolume.max)
            let share = deviation / tradingVolume.range
            let scaled = CGFloat(share) * height
            return scaled
        case .movingAverage:
            let deviation = abs(movingAverageData[index] - movingAverage.max)
            let share = deviation / movingAverage.range
            let scaled = CGFloat(share) * height
            return scaled
        }
    }
    
    func getYPosition(bounds height: CGFloat, index: Int) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = highLow.range
        let open = Double(data[index].open)!
        let high = Double(data[index].high!)!
        let low = Double(data[index].low!)!
        let close = Double(data[index].close)!
        let yOpen = CGFloat((abs(open - highLow.max)) / range) * height
        let yHigh = CGFloat((abs(high - highLow.max)) / range) * height
        let yLow = CGFloat((abs(low - highLow.max)) / range) * height
        let yClose = CGFloat((abs(close - highLow.max)) / range) * height
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
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
