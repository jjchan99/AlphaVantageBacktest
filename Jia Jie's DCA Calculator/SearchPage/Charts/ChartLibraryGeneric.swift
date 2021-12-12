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

enum ChartType: CaseIterable {
    case bar
    case line
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
//    var open: T? { get }
//    var high: T? { get }
//    var low: T? { get }
//    var close: T? { get }
    
    static var itemsToPlot: [KeyPath<Self, T> : Specifications<T>] { get }
}

struct Specifications<T: CustomNumeric> {
    var type: ChartType
    let title: String
    var height: CGFloat = YFactory.height
    var width: CGFloat = XFactory.width
    var padding: CGFloat = XFactory.padding
    var maxWidth: CGFloat = XFactory.maxWidth()
    let min: T
    let max: T
}

struct ChartLibraryGeneric {
    static func cgf<T: CustomNumeric>(_ value: T) -> CGFloat {
        return CGFloat(fromNumeric: value)
    }

    static func render<T: ChartPointSpecified>(data: [T]) -> ChartLibraryOutput<T> {
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
                default:
                    fatalError("Data must conform to CandlePointSpecified protocl to render Candles chart")
                }
            }
        }
        
        return .init(bars: bars, candles: candles, lines: lines)
    }
    
    static func render<T: CandlePointSpecified>(OHLC data: [T]) -> ChartLibraryOutput<T> {
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
        let xPosition = XFactory.getXPosition(index: index, dataCount: count)
        let yPosition = YFactory.getYPosition(data: data, index: index, heightBounds: spec.height, max: spec.max, min: spec.min, key: key)
        
        var path = path
        let spacing = 0.5 * XFactory.spacing(maxWidth: spec.maxWidth, dataCount: data.count)
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
       let xPosition = XFactory.getXPosition(index: index, dataCount: count)
       let yPosition = YFactory.getYPosition(data: data, index: index, heightBounds: spec.height, max: spec.max, min: spec.min, key: key)
       let indexPoint = CGPoint(x: xPosition, y: yPosition)
       let range = spec.max - spec.min
        
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
                let controlPoints = getControlPoints(index: index-1, data: data, max: spec.max, min: spec.min, key: key, height: spec.height)
            points.append(indexPoint)
            path.addCurve(to: indexPoint, control1: controlPoints.0, control2: controlPoints.1)
            area.addLine(to: indexPoint)
            }
        }

        if index == data.count {
            area.addLine(to: CGPoint(x: xPosition, y: spec.height))
            area.addLine(to: CGPoint(x: 0, y: spec.height))
            area.addLine(to: CGPoint(x: 0, y: (1 - (cgf(data[0][keyPath: key] / range))) * spec.height))
            area.closeSubpath()
        }
        
        return ((path, area))
    }
    
    static private func renderCandlePath<T: CandlePointSpecified>(index: Int, data: [T], spec: Specifications<T.T>) -> Candle<T> {
        var stick = Path()
        var body = Path()
        let xPosition = XFactory.getXPosition(index: index, dataCount: data.count)
        let yPosition = YFactory.getYPosition(data: data, heightBounds: spec.height, index: index, max: spec.max, min: spec.min)
        let green = cgf(data[index].close) > cgf(data[index].open)
        
        body.move(to: .init(x: xPosition - (0.5 * XFactory.spacing(maxWidth: spec.maxWidth, dataCount: data.count)), y: green ? yPosition.close : yPosition.open))
        body.addLine(to: .init(x: xPosition + (0.5 * XFactory.spacing(maxWidth: spec.maxWidth, dataCount: data.count)), y: green ? yPosition.close : yPosition.open))
        body.addLine(to: .init(x: xPosition + (0.5 * XFactory.spacing(maxWidth: spec.maxWidth, dataCount: data.count)), y: green ? yPosition.open : yPosition.close))
        body.addLine(to: .init(x: xPosition - (0.5 * XFactory.spacing(maxWidth: spec.maxWidth, dataCount: data.count)), y: green ? yPosition.open : yPosition.close))
        body.addLine(to: .init(x: xPosition - (0.5 * XFactory.spacing(maxWidth: spec.maxWidth, dataCount: data.count)), y: green ? yPosition.close : yPosition.open))
     
        stick.move(to: .init(x: xPosition, y: yPosition.high))
        stick.addLine(to: .init(x: xPosition, y: yPosition.low))
        
        return(.init(data: data[index], body: body, stick: stick))
    }
    
    
    
    func setup<T: ChartPointSpecified>(data: [T], spec: CGPoint, type: ChartType) {
        
    }
}

extension ChartLibraryGeneric {
    static private func getControlPoints<T: ChartPointSpecified>(index: Int, data: [T], max: T.T, min: T.T, key: KeyPath<T, T.T>, height: CGFloat) -> (CGPoint, CGPoint) {
        var points: [Int: CGPoint] = [:]
        for idx in index - 1...index + 2 {
            let withinRange = data.indices.contains(idx)
            if withinRange {
                points[idx] = CGPoint(x: XFactory.getXPosition(index: index, dataCount: data.count), y: YFactory.getYPosition(data: data, index: index, heightBounds: height, max: max, min: min, key: key))
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

fileprivate struct XFactory {
    static let width: CGFloat = .init(420).wScaled()
    static let padding: CGFloat = 0.05 * width
    
    static func adjustedWidth(width: CGFloat = width, padding: CGFloat = padding) -> CGFloat {
        width - (2 * padding)
    }
    
    static func columns(dataCount: Int) -> CGFloat {
        adjustedWidth() / CGFloat(dataCount - 1)
    }
    
    static func maxWidth() -> CGFloat {
        0.06 * adjustedWidth()
    }
    
    static func spacing(maxWidth: CGFloat, dataCount: Int) -> CGFloat {
        let columns = columns(dataCount: dataCount)
        return columns <= 5.0 ? 1 : (0.5) * columns > maxWidth ? maxWidth : (0.5) * columns
    }
    
    static func getXPosition(index: Int, padding: CGFloat = padding, dataCount: Int) -> CGFloat {
        let columns = columns(dataCount: dataCount)
        return index == 0 ? padding : (columns * CGFloat(index)) + padding
    }
}

fileprivate struct YFactory {
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
    
    static func getYPosition<T: ChartPointSpecified>(data: [T], index: Int, heightBounds: CGFloat, max: T.T, min: T.T, key: KeyPath<T, T.T>) -> CGFloat {
        let range = cgf(max - min)
        let type = type(min: min, max: max)
        
        let deviation = abs(data[index][keyPath: key] - max)
        let share = cgf(deviation) / range
        let scaled = CGFloat(share) * heightBounds
        
        switch type {
        case .allPositive:
            let translation = cgf(min/max) * heightBounds
            return scaled - translation
        case .negativePositive:
            return scaled
        case .allNegative:
            let minShareOfHeight = cgf(max/min) * heightBounds
            let shareOfRange = cgf(max - data[index][keyPath: key]) / range
            let untranslated = shareOfRange * heightBounds
            return untranslated + minShareOfHeight
        }
    }
    
    static func getZeroPosition<T: CustomNumeric>(min: T, max: T, heightBounds: CGFloat) -> CGFloat {
        let type = type(min: min, max: max)
        let range = cgf(max - min)
        switch type {
        case .allNegative:
            return 0
        case .allPositive:
            return heightBounds
        case .negativePositive:
            return (range + cgf(min))/range * heightBounds
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


