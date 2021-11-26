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
    var analysis: ChartMetaAnalysis
    
    //MARK: OUTPUT
    private(set) var candles: [Candle] = []
    private(set) var volumeChart = Path()
    private(set) var movingAverageChart: (path: Path, area: Path, points: [CGPoint]) = (path: Path(), area: Path(), points: [])
    
    init(specifications: ChartSpecifications, data: [OHLC], movingAverage: [Double], analysis: ChartMetaAnalysis) {
        self.specifications = specifications
        self.data = data
        self.movingAverage = movingAverage
        self.analysis = analysis
    }
    
    lazy var columns: CGFloat = {
        let columns = adjustedWidth / CGFloat(data.count - 1)
        return columns
    }()
    
    lazy var adjustedWidth: CGFloat = {
        specifications.specifications[.line]!.width - (2 * specifications.padding)
    }()
    
    lazy var spacing: CGFloat = {
        var spacing = (1/3) * columns > maxWidth ? maxWidth : (1/3) * columns
        spacing = columns <= 5.0 ? 1 : spacing
        return spacing
    }()
    
    lazy var maxWidth: CGFloat = {
        0.03 * adjustedWidth
    }()
    
    //MARK: ALL-IN-ONE RENDER
    mutating func iterateOverData() {
        
        for index in data.indices {
            renderBarPath(index: index)
            renderLinePath(index: index)
            renderCandlePath(index: index)
            
        }
    }
    
    private mutating func getXPosition(index: Int) -> CGFloat {
        return index == 0 ? specifications.padding : (columns * CGFloat(index)) + specifications.padding
    }
    
    private mutating func renderBarPath(index: Int) {

        let xPosition = getXPosition(index: index)
        let yPosition = analysis.getYPosition(mode: .tradingVolume, heightBounds: specifications.specifications[.bar]!.height, index: index) - (0.05 * specifications.specifications[.bar]!.height)
        
        volumeChart.move(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
        volumeChart.addLine(to: .init(x: xPosition + (0.5 * spacing), y: yPosition))
        volumeChart.addLine(to: .init(x: xPosition + (0.5 * spacing), y: specifications.specifications[.bar]!.height))
        volumeChart.addLine(to: .init(x: xPosition - (0.5 * spacing), y: specifications.specifications[.bar]!.height))
        volumeChart.addLine(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
        volumeChart.closeSubpath()
    }
    
    private mutating func renderLinePath(index: Int) {
       let xPosition = getXPosition(index: index)
       let yPosition = analysis.getYPosition(mode: .movingAverage, heightBounds: specifications.specifications[.line]!.height, index: index)
       
       if index == 0 {
        movingAverageChart.points.append(CGPoint(x: xPosition, y: yPosition))
        movingAverageChart.path.move(to: CGPoint(x: xPosition, y: yPosition))
        movingAverageChart.area.move(to: CGPoint(x: xPosition, y: yPosition))
            
        } else {
            movingAverageChart.points.append(CGPoint(x: xPosition, y: yPosition))
            movingAverageChart.path.addLine(to: CGPoint(x: xPosition, y: yPosition))
            movingAverageChart.area.addLine(to: CGPoint(x: xPosition, y: yPosition))
        }

        if index == data.count {
            movingAverageChart.area.addLine(to: CGPoint(x: xPosition, y: specifications.specifications[.line]!.height))
            movingAverageChart.area.addLine(to: CGPoint(x: 0, y: specifications.specifications[.line]!.height))
            movingAverageChart.area.addLine(to: CGPoint(x: 0, y: (1 - (CGFloat((movingAverage[0] / analysis.movingAverage.range)))) * specifications.specifications[.line]!.height))
            movingAverageChart.area.closeSubpath()
        }
    }
    
    private mutating func renderCandlePath(index: Int) {
        var stick = Path()
        var body = Path()
        let xPosition = getXPosition(index: index)
        let yPosition = analysis.getYPosition(heightBounds: specifications.specifications[.candle]!.height, index: index)
        let green = data[index].green()
        
        body.move(to: .init(x: xPosition - (0.5 * spacing), y: green ? yPosition.close : yPosition.open))
        body.addLine(to: .init(x: xPosition + (0.5 * spacing), y: green ? yPosition.close : yPosition.open))
        body.addLine(to: .init(x: xPosition + (0.5 * spacing), y: green ? yPosition.open : yPosition.close))
        body.addLine(to: .init(x: xPosition - (0.5 * spacing), y: green ? yPosition.open : yPosition.close))
        body.addLine(to: .init(x: xPosition - (0.5 * spacing), y: green ? yPosition.close : yPosition.open))
     
        stick.move(to: .init(x: xPosition, y: yPosition.high))
        stick.addLine(to: .init(x: xPosition, y: yPosition.low))
        
        candles.append(.init(data: data[index], body: body, stick: stick))
        
    }
    
}

struct ChartSpecifications {
    
    init(padding: CGFloat, set: (inout [Charts: (height: CGFloat, width: CGFloat)]) -> ()) {
        set(&self.specifications)
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
    var tradingVolume: TradingVolume
    var movingAverage: MovingAverage
    var highLow: HighLow
    
    
    //MARK: MODE SELECTION
    enum Mode {
        case tradingVolume, movingAverage
    }
    
    mutating func getYPosition(mode: Mode, heightBounds: CGFloat, index: Int) -> CGFloat {
        switch mode {
        case .tradingVolume:
            let deviation = abs(Double(data[index].volume!)! - tradingVolume.max)
            let share = deviation / tradingVolume.range
            let scaled = CGFloat(share) * heightBounds
            return scaled
        case .movingAverage:
            let deviation = abs(movingAverageData[index] - movingAverage.max)
            let share = deviation / movingAverage.range
            let scaled = CGFloat(share) * heightBounds
            return scaled
        }
    }
    
    mutating func getYPosition(heightBounds: CGFloat, index: Int) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = highLow.range
        let open = Double(data[index].open)!
        let high = Double(data[index].high!)!
        let low = Double(data[index].low!)!
        let close = Double(data[index].close)!
        let yOpen = CGFloat((abs(open - highLow.max)) / range) * heightBounds
        let yHigh = CGFloat((abs(high - highLow.max)) / range) * heightBounds
        let yLow = CGFloat((abs(low - highLow.max)) / range) * heightBounds
        let yClose = CGFloat((abs(close - highLow.max)) / range) * heightBounds
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
    
    internal struct TradingVolume {
        let max: Double
        let min: Double
        lazy var range: Double = {
            max - min
        }()
    }
    
    internal struct MovingAverage {
        let max: Double
        let min: Double
        lazy var range: Double = {
            max - min
        }()
    }
    
    internal struct HighLow {
        let max: Double
        let min: Double
        lazy var range: Double = {
            max - min
        }()
    }
}
