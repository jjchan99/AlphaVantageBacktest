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
        var spacing = (0.5) * columns > maxWidth ? maxWidth : (0.5) * columns
        spacing = columns <= 5.0 ? 1 : spacing
        return spacing
    }()
    
    lazy var maxWidth: CGFloat = {
        0.06 * adjustedWidth
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
       let indexPoint = CGPoint(x: xPosition, y: yPosition)
       
       if index == 0 {
        movingAverageChart.points.append(indexPoint)
        movingAverageChart.path.move(to: indexPoint)
        movingAverageChart.area.move(to: indexPoint)
            
        } else {
         
            if data.count < 3 {
                movingAverageChart.path.addLine(to: indexPoint)
            } else {
            let controlPoints = getControlPoints(index: index-1)
            movingAverageChart.points.append(indexPoint)
            movingAverageChart.path.addCurve(to: indexPoint, control1: controlPoints.0, control2: controlPoints.1)
            movingAverageChart.area.addLine(to: indexPoint)
            }
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

extension ChartLibrary {
    private mutating func getControlPoints(index: Int) -> (CGPoint, CGPoint) {
        var points: [Int: CGPoint] = [:]
        for idx in index - 1...index + 2 {
            let withinRange = data.indices.contains(idx)
            if withinRange {
                points[idx] = CGPoint(x: getXPosition(index: idx), y: analysis.getYPosition(mode: .movingAverage, heightBounds: specifications.specifications[.line]!.height, index: idx))
            }
        }
        
        if points[index-1] == nil {
            let calc = ControlPoint(centerPoint: points[index + 1]!, previousPoint: points[index]!, nextPoint: points[index + 2]!)
            return ((calc.staticControlPoints().staticPoint1, calc.translateControlPoints().controlPoint1))
        } else if points[index + 2] == nil {
            let calc = ControlPoint(centerPoint: points[index]!, previousPoint: points[index - 1]!, nextPoint: points[index + 1]!)
            return ((calc.translateControlPoints().controlPoint2, calc.staticControlPoints().staticPoint2))
        } else {
            let CP1Calc = ControlPoint(centerPoint: points[index]!, previousPoint: points[index - 1]!, nextPoint: points[index + 1]!)
            let CP2Calc = ControlPoint(centerPoint: points[index + 1]!, previousPoint: points[index]!, nextPoint: points[index + 2]!)
            return ((CP1Calc.translateControlPoints().controlPoint2, CP2Calc.translateControlPoints().controlPoint1))
        }
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
    var tradingVolume: MaxMinRange
    var movingAverage: MaxMinRange
    var highLow: MaxMinRange
    
    lazy var ultimateMaxMinRange: MaxMinRange = {
        
        let ultimateMax: Double = {
            return highLow.max > movingAverage.max ? highLow.max : movingAverage.max
        }()
        
        let ultimateMin: Double = {
            return highLow.min < movingAverage.min ? highLow.min : movingAverage.min
        }()
    
        let ultimateRange: Double = {
            let lowerBound = highLow.min < movingAverage.min ? highLow.min : movingAverage.min
            let upperBound = highLow.max > movingAverage.max ? highLow.max : movingAverage.max
            return upperBound - lowerBound
        }()
        
        return .init(max: ultimateMax, min: ultimateMin, range: ultimateRange)
    }()
   
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
            let deviation = abs(movingAverageData[index] - ultimateMaxMinRange.max)
            let share = deviation / ultimateMaxMinRange.range
            let scaled = CGFloat(share) * heightBounds
            return scaled
        }
    }
    
    mutating func getYPosition(heightBounds: CGFloat, index: Int) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = ultimateMaxMinRange.range
        let open = Double(data[index].open)!
        let high = Double(data[index].high!)!
        let low = Double(data[index].low!)!
        let close = Double(data[index].close)!
        let yOpen = CGFloat((abs(open - ultimateMaxMinRange.max)) / range) * heightBounds
        let yHigh = CGFloat((abs(high - ultimateMaxMinRange.max)) / range) * heightBounds
        let yLow = CGFloat((abs(low - ultimateMaxMinRange.max)) / range) * heightBounds
        let yClose = CGFloat((abs(close - ultimateMaxMinRange.max)) / range) * heightBounds
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
    
    internal struct MaxMinRange {
        let max: Double
        let min: Double
        lazy var range: Double = {
            max - min
        }()
    }
}


struct ControlPoint {
    
    let scaleFactor: CGFloat = 0.7
    
    init(centerPoint: CGPoint, previousPoint: CGPoint, nextPoint: CGPoint) {
        self.centerPoint = centerPoint
        self.previousPoint = previousPoint
        self.nextPoint = nextPoint
    }
    
    let centerPoint: CGPoint
    let previousPoint: CGPoint
    let nextPoint: CGPoint
    
    func staticControlPoints() -> (staticPoint1: CGPoint, staticPoint2: CGPoint) {
        let x1 = previousPoint.x + (centerPoint.x - previousPoint.x) * (1 - scaleFactor)
        let y1 = previousPoint.y + (centerPoint.y - previousPoint.y) * (1 - scaleFactor)
        let controlPoint1: CGPoint = .init(x: x1, y: y1)
        
        let x2 = centerPoint.x + (nextPoint.x - centerPoint.x) * (scaleFactor)
        let y2 = centerPoint.y + (nextPoint.y - centerPoint.y) * (scaleFactor)
        let controlPoint2: CGPoint = .init(x: x2, y: y2)
        return (controlPoint1, controlPoint2)
    }
    
    private func getControlPoints() -> (controlPoint1: CGPoint, controlPoint2: CGPoint) {
        let x1 = previousPoint.x + (centerPoint.x - previousPoint.x) * scaleFactor
        let y1 = previousPoint.y + (centerPoint.y - previousPoint.y) * scaleFactor
        let controlPoint1: CGPoint = .init(x: x1, y: y1)
        
        let x2 = centerPoint.x + (nextPoint.x - centerPoint.x) * (1 - scaleFactor)
        let y2 = centerPoint.y + (nextPoint.y - centerPoint.y) * (1 - scaleFactor)
        let controlPoint2: CGPoint = .init(x: x2, y: y2)
        return (controlPoint1, controlPoint2)
    }
    
    func translateControlPoints() -> (controlPoint1: CGPoint, controlPoint2: CGPoint) {
        let cp = getControlPoints()
        let MM: CGPoint = .init(x: 2 * centerPoint.x - cp.controlPoint1.x, y: 2 * centerPoint.y - cp.controlPoint1.y)
        let NN: CGPoint = .init(x: 2 * centerPoint.x - cp.controlPoint2.x, y: 2 * centerPoint.y - cp.controlPoint2.y)
        
        let translatedControlPoint1 = CGPoint(x: (NN.x + cp.controlPoint1.x)/2, y: (NN.y + cp.controlPoint1.y)/2)
        let translatedControlPoint2 = CGPoint(x: (MM.x + cp.controlPoint2.x)/2, y: (MM.y + cp.controlPoint2.y)/2)
        
        return ((controlPoint1: translatedControlPoint1, controlPoint2: translatedControlPoint2))
    }
    
}
