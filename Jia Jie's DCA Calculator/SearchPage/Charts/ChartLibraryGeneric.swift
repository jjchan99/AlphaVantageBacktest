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
    case bar
    case line
    case candle
}

protocol ChartPointSpecified: Comparable {
    associatedtype T where T: CustomNumeric
    var valueForPlot: T { get }
    var open: T? { get }
    var high: T? { get }
    var low: T? { get }
    var close: T? { get }
    
    //    associatedtype SomeEnumType: RawRepresentable where SomeEnumType.RawValue: StringProtocol
    //    func pathToValueForChart(key: SomeEnumType) -> T
    static var itemsToPlot: [KeyPath<Self, T>] { get }
}

extension ChartPointSpecified {
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard type(of: lhs.valueForPlot) == type(of: rhs.valueForPlot) else { fatalError("You did not use matching types.") }
        return lhs.valueForPlot < rhs.valueForPlot
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
           return lhs.valueForPlot == rhs.valueForPlot
    }
}


struct ChartLibraryGeneric {
    
    struct Specifications<T: ChartPointSpecified> {
        let data: [T]
        var height: CGFloat = YFactory.height
        var width: CGFloat = XFactory.width
        var padding: CGFloat = XFactory.padding
        var maxWidth: CGFloat = XFactory.maxWidth()
    }
    
    
    static func render<T: ChartPointSpecified>(data: [T], max: T.T? = nil, min: T.T? = nil, setValuesForKeys: [String : Specifications<T>]) {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
        
        var path = Path()
        for index in data.indices {
            path = renderBarPath(index: index, count: data.count, data: data, max: max, min: min, path: path)
        }
    }

    
    
    private static func renderBarPath<T: ChartPointSpecified>(index: Int, count: Int, data: [T], max: T.T? = nil, min: T.T? = nil, path: Path) -> Path {

        let xPosition = XFactory.getXPosition(index: index, dataCount: count)
        let yPosition = YFactory.getYPosition(data: data, index: index, heightBounds: YFactory.barHeight)
        
        var path = path
        let spacing = 0.5 * XFactory.spacing(columns: XFactory.columns(dataCount: data.count))
        path.move(to: .init(x: xPosition - spacing, y: yPosition))
        path.addLine(to: .init(x: xPosition + spacing, y: yPosition))
        path.addLine(to: .init(x: xPosition + spacing, y: YFactory.height))
        path.addLine(to: .init(x: xPosition - spacing, y: YFactory.height))
        path.addLine(to: .init(x: xPosition - spacing, y: yPosition))
        path.closeSubpath()
        return path
    }
    
    private mutating func renderLinePath<T: ChartPointSpecified>(index: Int, count: Int, data: [T], max: T.T? = nil, min: T.T? = nil) {
       let xPosition = XFactory.getXPosition(index: index, dataCount: count)
       let yPosition = YFactory.getYPosition(data: data, index: index)
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
            movingAverageChart.area.addLine(to: CGPoint(x: 0, y: (1 - (CGFloat((data[0].movingAverage / analysis.movingAverage.range)))) * specifications.specifications[.line]!.height))
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
    
    
    
    func setup<T: ChartPointSpecified>(data: [T], spec: CGPoint, type: Charts) {
        
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
    
    static func spacing(maxWidth: CGFloat = maxWidth(), columns: CGFloat) -> CGFloat {
        columns <= 5.0 ? 1 : (0.5) * columns > maxWidth ? maxWidth : (0.5) * columns
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
    
    static func type<T: CustomNumeric>(min: T, max: T) -> ChartType {
        let allNegativeOrAllPositive: ChartType = min < 0 && max < 0 ? .allNegative : .allPositive
        let chartType: ChartType = min < 0 && max >= 0 ? .negativePositive : allNegativeOrAllPositive
        return chartType
    }
    
    static func getYPosition<T: ChartPointSpecified>(data: [T], heightBounds: CGFloat = height, index: Int, max: T.T, min: T.T) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = cgf(max - min)
        
        let open = data[index].open
        let high = data[index].high
        let low = data[index].low
        let close = data[index].close
        let yOpen = (abs(cgf(open! - max)) / range) * heightBounds
        let yHigh = (abs(cgf(high! - max)) / range) * heightBounds
        let yLow = (abs(cgf(low! - max)) / range) * heightBounds
        let yClose = (abs(cgf(close! - max)) / range) * heightBounds
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
    
    static func getYPosition<T: ChartPointSpecified>(data: [T], index: Int, heightBounds: CGFloat = height, max: T.T? = nil, min: T.T? = nil) -> CGFloat {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
        let range = cgf(max - min)
        
        let type = type(min: min, max: max)
        
        let deviation = abs(data[index].valueForPlot - max)
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
            let shareOfRange = cgf(max - data[index][keyPath: T.itemsToPlot[0]]) / range
            let untranslated = shareOfRange * heightBounds
            return untranslated + minShareOfHeight
        }
    }
    
    static func getZeroPosition<T: CustomNumeric>(min: T, max: T, heightBounds: CGFloat = height) -> CGFloat {
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
   



struct Test: ChartPointSpecified {
    static var itemsToPlot: [KeyPath<Test, Double>] = [\Test.open!, \Test.close!]
    
    var open: Double?
    
    var high: Double?
    
    var low: Double?
    
    var close: Double?
    
    typealias T = Double
    
    var valueForPlot: Double = 4
    
}


