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
    let yPositionFactory: YPositionFactory
    
    //MARK: OUTPUT
    private(set) var candles: [Candle] = []
    private(set) var volumeChart = Path()
    private(set) var movingAverageChart: (path: Path, area: Path, points: [CGPoint]) = (path: Path(), area: Path(), points: [])
    
    init(specifications: ChartSpecifications, data: [OHLC], movingAverage: [Double], analysis: ChartMetaAnalysis) {
        self.specifications = specifications
        self.data = data
        self.movingAverage = movingAverage
        self.analysis = analysis
        self.yPositionFactory = .init(analysis: analysis, data: data, movingAverageData: movingAverage)
        
        self.adjustedWidth = specifications.specifications[.line]!.width - (2 * specifications.padding)
        self.columns = adjustedWidth / CGFloat(data.count - 1)
        self.maxWidth = 0.06 * adjustedWidth
        self.spacing = columns <= 5.0 ? 1 : (0.5) * columns > maxWidth ? maxWidth : (0.5) * columns
    }
    
    let columns: CGFloat
    
    let adjustedWidth: CGFloat
    
    let spacing: CGFloat
    
    let maxWidth: CGFloat
    
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
        let yPosition = yPositionFactory.getYPosition(mode: .tradingVolume, heightBounds: specifications.specifications[.bar]!.height, index: index) - (0.05 * specifications.specifications[.bar]!.height)
        
        volumeChart.move(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
        volumeChart.addLine(to: .init(x: xPosition + (0.5 * spacing), y: yPosition))
        volumeChart.addLine(to: .init(x: xPosition + (0.5 * spacing), y: specifications.specifications[.bar]!.height))
        volumeChart.addLine(to: .init(x: xPosition - (0.5 * spacing), y: specifications.specifications[.bar]!.height))
        volumeChart.addLine(to: .init(x: xPosition - (0.5 * spacing), y: yPosition))
        volumeChart.closeSubpath()
    }
    
    private mutating func renderLinePath(index: Int) {
       let xPosition = getXPosition(index: index)
       let yPosition = yPositionFactory.getYPosition(mode: .movingAverage, heightBounds: specifications.specifications[.line]!.height, index: index)
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
        let yPosition = yPositionFactory.getYPosition(heightBounds: specifications.specifications[.candle]!.height, index: index)
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
                points[idx] = CGPoint(x: getXPosition(index: idx), y: yPositionFactory.getYPosition(mode: .movingAverage, heightBounds: specifications.specifications[.line]!.height, index: idx))
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
    
    init(tradingVolume: ChartMetaAnalysis.MaxMinRange, movingAverage: ChartMetaAnalysis.MaxMinRange, highLow: ChartMetaAnalysis.MaxMinRange) {
        self.tradingVolume = tradingVolume
        self.movingAverage = movingAverage
        self.highLow = highLow
        
        let ultimateMax: Double = {
            return highLow.max > movingAverage.max ? highLow.max : movingAverage.max
        }()
        
        let ultimateMin: Double = {
            return highLow.min < movingAverage.min ? highLow.min : movingAverage.min
        }()
        
        self.ultimateMaxMinRange = .init(max: ultimateMax, min: ultimateMin)
    }
    
    //MARK: STATISTICAL META DATA
    let tradingVolume: MaxMinRange
    let movingAverage: MaxMinRange
    let highLow: MaxMinRange
    
    let ultimateMaxMinRange: MaxMinRange
   
    struct MaxMinRange {
      
        enum ChartType {
            case allNegative
            case allPositive
            case negativePositive
        }
        
        let max: Double
        let min: Double
        var range: Double {
            max - min
        }
        var type: ChartType {
            let allNegativeOrAllPositive: ChartType = min < 0 && max < 0 ? .allNegative : .allPositive
            let chartType: ChartType = min < 0 && max >= 0 ? .negativePositive : allNegativeOrAllPositive
            return chartType
        }
    }
}

extension ChartMetaAnalysis.MaxMinRange {
    func getZeroPosition(height: CGFloat) -> CGFloat {
        switch type {
        case .allNegative:
            return 0
        case .allPositive:
            return height
        case .negativePositive:
            return ( CGFloat((range + min)/range) * height )
        }
    }
}
