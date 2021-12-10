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
        
    static func cgf<T: CustomNumeric>(_ value: T) -> CGFloat {
        return CGFloat(fromNumeric: value)
    }
    
    enum ChartType {
        case allNegative
        case allPositive
        case negativePositive
    }
    
    static private func type<T: CustomNumeric>(min: T, max: T) -> ChartType {
        let allNegativeOrAllPositive: ChartType = min < 0 && max < 0 ? .allNegative : .allPositive
        let chartType: ChartType = min < 0 && max >= 0 ? .negativePositive : allNegativeOrAllPositive
        return chartType
    }
   
    
    private static func render<T: ChartPointSpecified>(data: [T], max: T.T? = nil, min: T.T? = nil) {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
    }
    
    private static func getYPosition<T: ChartPointSpecified>(data: [T], index: Int, heightBounds: CGFloat, max: T.T? = nil, min: T.T? = nil) -> CGFloat {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
        let range = cgf(max - min)
        
        let type = type(min: min, max: max)
        
        let deviation = abs(data[index].valueForPlot - max)
        let share = cgf(deviation) / range
        let untranslatedScaled = CGFloat(share) * heightBounds
        let translation = cgf(min/max) * heightBounds
        return 2
    }
    
    private static func getYPosition<T: ChartPointSpecified>(data: [T], heightBounds: CGFloat, index: Int, max: T.T, min: T.T) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
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
}
   



struct Test: ChartPointSpecified {
    var open: Double?
    
    var high: Double?
    
    var low: Double?
    
    var close: Double?
    
    typealias T = Double
    
    var valueForPlot: Double = 4
    
}


