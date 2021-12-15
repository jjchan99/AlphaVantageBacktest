//
//  ChartLibraryGeneric.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/12/21.
//

import Foundation
import SwiftUI
import CoreGraphics
import Algorithms

enum ChartType {
    case bar(zero: Bool)
    case line(zero: Bool)
    case candle
}

protocol CandlePointSpecified: ChartPointSpecified {
    var open: T { get }
    var high: T { get }
    var low: T { get }
    var close: T { get }
    var emptyKey: T { get }
}

protocol ChartPointSpecified {
    associatedtype T where T: CustomNumeric
    static var itemsToPlot: [KeyPath<Self, T> : Specifications<T>] { get set }
}

struct Specifications<T: CustomNumeric> {
    
    init(count: Int, type: ChartType, title: String, height: CGFloat, width: CGFloat, padding: CGFloat, max: T, min: T) {
        self.type = type
        self.title = title
        self.height = height
        self.width = width
        self.padding = padding
        self.max = max
        self.min = min
        
        adjustedWidth = width - (2 * padding)
        columns = adjustedWidth / CGFloat(count - 1)
        maxWidth = 0.06 * adjustedWidth
        spacing = columns <= 5.0 ? 1 : (0.5) * columns > maxWidth ? maxWidth : (0.5) * columns
    }
    
    let type: ChartType
    let title: String
    let height: CGFloat
    let width: CGFloat
    let padding: CGFloat
    
    var maxWidth: CGFloat
    var spacing: CGFloat
    var adjustedWidth: CGFloat
    var columns: CGFloat
   
    let min: T
    let max: T
}

struct ChartLibraryGeneric {
    static func cgf<T: CustomNumeric>(_ value: T) -> CGFloat {
        return CGFloat(fromNumeric: value)
    }

    static func render<T: ChartPointSpecified>(data: [T], setItemsToPlot: [KeyPath<T, T.T> : Specifications<T.T>]) -> ChartLibraryOutput<T> {
        T.itemsToPlot = setItemsToPlot
        var bars: [String: Path] = [:]
        var lines: [String: (path: Path, area: Path)] = [:]
        
        for index in data.indices {
            for (key, spec) in T.itemsToPlot {
                switch spec.type {
                case .bar:
                    let previous = bars[spec.title] ?? Path()
                    let new = renderBarPath(index: index, data: data, key: key, spec: spec, path: previous)
                    bars[spec.title] = new
                case .line:
                    let previous = lines[spec.title] ?? (path: Path(), area: Path())
                    let new = renderLinePath(index: index, data: data, key: key, spec: spec, previous: previous)
                    lines[spec.title] = new
                default:
                    fatalError("Data must conform to CandlePointSpecified protocl to render Candles chart")
                }
            }
        }
        
        return .init(bars: bars, lines: lines)
    }
    
    static func render<T: CandlePointSpecified>(OHLC data: [T], setItemsToPlot: [KeyPath<T, T.T> : Specifications<T.T>]) -> CandleLibraryOutput<T> {
        T.itemsToPlot = setItemsToPlot
        var bars: [String: Path] = [:]
        var candles: [String: [Candle<T>]] = [:]
        var lines: [String: (path: Path, area: Path)] = [:]
        
        for index in data.indices {
            for (key, spec) in T.itemsToPlot {
                switch spec.type {
                case .bar:
                    let previous = bars[spec.title] ?? Path()
                    let new = renderBarPath(index: index, data: data, key: key, spec: spec, path: previous)
                    bars[spec.title] = new
                case .line:
                    let previous = lines[spec.title] ?? (path: Path(), area: Path())
                    let new = renderLinePath(index: index, data: data, key: key, spec: spec, previous: previous)
                    lines[spec.title] = new
                case .candle:
                    if candles[spec.title] == nil { candles[spec.title] = [] }
                    let new = renderCandlePath(index: index, data: data, spec: spec)
                    candles[spec.title]!.append(new)
                }
            }
        }
        
        return .init(bars: bars, candles: candles, lines: lines)
    }

    private static func renderBarPath<T: ChartPointSpecified>(index: Int, data: [T], key: KeyPath<T, T.T>, spec: Specifications<T.T>, path: Path) -> Path {
        let count = data.count
        let xPosition = XFactory.getXPosition(index: index, spec: spec, dataCount: count)
        let yPosition = YFactory.getYPosition(data: data, index: index, spec: spec, key: key)
        
        var path = path
        let spacing = 0.5 * spec.spacing
        path.move(to: .init(x: xPosition - spacing, y: yPosition))
        path.addLine(to: .init(x: xPosition + spacing, y: yPosition))
        path.addLine(to: .init(x: xPosition + spacing, y: spec.height))
        path.addLine(to: .init(x: xPosition - spacing, y: spec.height))
        path.addLine(to: .init(x: xPosition - spacing, y: yPosition))
        path.closeSubpath()
        return path
    }
    
    private static func renderLinePath<T: ChartPointSpecified>(index: Int, data: [T], key: KeyPath<T, T.T>, spec: Specifications<T.T>, previous: (Path, Path)) -> ((Path, Path)) {
       let count = data.count
        let xPosition = XFactory.getXPosition(index: index, spec: spec, dataCount: count)
        let yPosition = YFactory.getYPosition(data: data, index: index, spec: spec, key: key)
       let indexPoint = CGPoint(x: xPosition, y: yPosition)
        
       var path = previous.0
       var area = previous.1
       var points: [CGPoint] = []
       
       if index == 0 {
        points.append(indexPoint)
        path.move(to: indexPoint)
        area.move(to: indexPoint)

        } else {
            
            if data.count < 3 {
                path.addLine(to: indexPoint)
            } else {
                let controlPoints = getControlPoints(index: index-1, data: data, spec: spec, key: key, height: spec.height)
            points.append(indexPoint)
            path.addCurve(to: indexPoint, control1: controlPoints.0, control2: controlPoints.1)
            area.addCurve(to: indexPoint, control1: controlPoints.0, control2: controlPoints.1)
            }
        }

        if index == data.count - 1 {
            let y = YFactory.getZeroPosition(spec: spec)
            area.addLine(to: CGPoint(x: xPosition, y: y))
            area.addLine(to: CGPoint(x: 0, y: y))
            area.addLine(to: CGPoint(x: 0, y: YFactory.getYPosition(data: data, index: 0, spec: spec, key: key)))
            area.closeSubpath()
        }
        
        return ((path, area))
    }
    
    static private func renderCandlePath<T: CandlePointSpecified>(index: Int, data: [T], spec: Specifications<T.T>) -> Candle<T> {
        var stick = Path()
        var body = Path()
        let xPosition = XFactory.getXPosition(index: index, spec: spec, dataCount: data.count)
        let yPosition = YFactory.getYPosition(data: data, heightBounds: spec.height, index: index, max: spec.max, min: spec.min)
        let green = cgf(data[index].close) > cgf(data[index].open)
        
        body.move(to: .init(x: xPosition - (0.5 * spec.spacing), y: green ? yPosition.close : yPosition.open))
        body.addLine(to: .init(x: xPosition + (0.5 * spec.spacing), y: green ? yPosition.close : yPosition.open))
        body.addLine(to: .init(x: xPosition + (0.5 * spec.spacing), y: green ? yPosition.open : yPosition.close))
        body.addLine(to: .init(x: xPosition - (0.5 * spec.spacing), y: green ? yPosition.open : yPosition.close))
        body.addLine(to: .init(x: xPosition - (0.5 * spec.spacing), y: green ? yPosition.close : yPosition.open))
     
        stick.move(to: .init(x: xPosition, y: yPosition.high))
        stick.addLine(to: .init(x: xPosition, y: yPosition.low))
        
        return(.init(data: data[index], body: body, stick: stick))
    }
    
}

extension ChartLibraryGeneric {
    static private func getControlPoints<T: ChartPointSpecified>(index: Int, data: [T], spec: Specifications<T.T>, key: KeyPath<T, T.T>, height: CGFloat) -> (CGPoint, CGPoint) {
        var points: [Int: CGPoint] = [:]
        for idx in index - 1...index + 2 {
            let withinRange = data.indices.contains(idx)
            if withinRange {
                points[idx] = CGPoint(x: XFactory.getXPosition(index: index, spec: spec, dataCount: data.count), y: YFactory.getYPosition(data: data, index: index, spec: spec, key: key))
            }
        }
        
        if points[index-1] == nil {
            let centerPoint = points[index + 1]!
            let previousPoint = points[index]!
            let nextPoint = points[index + 2]!
            let staticPoint1 = ControlPoint.staticControlPoints(centerPoint: centerPoint, previousPoint: previousPoint, nextPoint: nextPoint).staticPoint1
            let controlPoint1 = ControlPoint.translateControlPoints(centerPoint: centerPoint, previousPoint: previousPoint, nextPoint: nextPoint).controlPoint1
            return ((staticPoint1, controlPoint1))
        } else if points[index + 2] == nil {
            let centerPoint = points[index]!
            let previousPoint = points[index - 1]!
            let nextPoint = points[index + 1]!
            let staticPoint2 = ControlPoint.staticControlPoints(centerPoint: centerPoint, previousPoint: previousPoint, nextPoint: nextPoint).staticPoint2
            let controlPoint2 = ControlPoint.translateControlPoints(centerPoint: centerPoint, previousPoint: previousPoint, nextPoint: nextPoint).controlPoint2
            return ((controlPoint2, staticPoint2))
        } else {
            let controlPoint2 = ControlPoint.translateControlPoints(centerPoint: points[index]!, previousPoint: points[index - 1]!, nextPoint: points[index + 1]!).controlPoint2
            let controlPoint1 = ControlPoint.translateControlPoints(centerPoint: points[index + 1]!, previousPoint: points[index]!, nextPoint: points[index + 2]!).controlPoint1
            return ((controlPoint2, controlPoint1))
        }
    }
}

struct XFactory {
    static func getXPosition<T: CustomNumeric>(index: Int, spec: Specifications<T>, dataCount: Int) -> CGFloat {
        return index == 0 ? spec.padding : (spec.columns * CGFloat(index)) + spec.padding
    }
}

struct YFactory {
    static let height: CGFloat = .init(350).hScaled()
    static let barHeight: CGFloat = .init(45).hScaled()
    
    enum ChartType {
        case allNegative
        case allPositive
        case negativePositive
    }
    
    static func cgf<T: CustomNumeric>(_ value: T) -> CGFloat {
        return CGFloat(fromNumeric: value)
    }
    
    static private func type<T: CustomNumeric>(min: T, max: T) -> ChartType {
        let allNegativeOrAllPositive: ChartType = min < 0 && max < 0 ? .allNegative : .allPositive
        let chartType: ChartType = min < 0 && max >= 0 ? .negativePositive : allNegativeOrAllPositive
        return chartType
    }
    
    static func getYPosition<T: CandlePointSpecified>(data: [T], heightBounds: CGFloat, index: Int, max: T.T, min: T.T) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = cgf(max - min)
        
        let open = data[index].open
        let high = data[index].high
        let low = data[index].low
        let close = data[index].close
        let yOpen = (abs(cgf(open - max)) / range) * heightBounds
        let yHigh = (abs(cgf(high - max)) / range) * heightBounds
        let yLow = (abs(cgf(low - max)) / range) * heightBounds
        let yClose = (abs(cgf(close - max)) / range) * heightBounds
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
    
    static private func getRange<T: CustomNumeric>(type: YFactory.ChartType, spec: Specifications<T>) -> CGFloat {
      
        switch type {
        case .allNegative:
            return cgf(abs(spec.min))
        case .allPositive:
            return cgf(spec.max)
        case .negativePositive:
            return cgf(spec.max - spec.min)
        }
        
    }
    
    static func getYPosition<T: ChartPointSpecified>(data: [T], index: Int, spec: Specifications<T.T>, key: KeyPath<T, T.T>) -> CGFloat {
        switch spec.type {
        case .bar(let zero), .line(let zero):
            
        let type = type(min: spec.min, max: spec.max)
        let range = zero ? getRange(type: type, spec: spec) : cgf(spec.max - spec.min)
        let deviation = abs(data[index][keyPath: key] - spec.max)
        let share = cgf(deviation) / range
        let scaled = CGFloat(share) * spec.height
       
        switch type {
        case .allPositive:
//            let translation = cgf(spec.min/spec.max) * spec.height
            return scaled
        case .negativePositive:
            return scaled
        case .allNegative:
            let minShareOfHeight = cgf(spec.max/spec.min) * spec.height
            let shareOfRange = cgf(spec.max - data[index][keyPath: key]) / range
            let untranslated = shareOfRange * spec.height
            return zero ? untranslated + minShareOfHeight : untranslated
        }
        default:
            fatalError()
        }
    }
    
    static func getZeroPosition<T: CustomNumeric>(spec: Specifications<T>) -> CGFloat {
        switch spec.type {
        case .bar(let zero), .line(let zero):
        let type = type(min: spec.min, max: spec.max)
        let range = zero ? getRange(type: type, spec: spec) : cgf(spec.max - spec.min)
      
        switch type {
        case .allNegative:
            return 0
        case .allPositive:
            return spec.height
        case .negativePositive:
            return (range + cgf(spec.min))/range * spec.height
        }
        default:
            fatalError()
        }
        
    }
}
   



//struct Test: ChartPointSpecified {
//
//    static var itemsToPlot: [KeyPath<Test, Double> : Specifications<Double>] = [
//        \Test.open! : .init(type: .bar, min: 4, max: 6) ,
//         \Test.close! : .init(type: .line, min: 6, max: 5)
//    ]
//
//    var open: Double?
//
//    var high: Double?
//
//    var low: Double?
//
//    var close: Double?
//
//    typealias T = Double
//
//}


