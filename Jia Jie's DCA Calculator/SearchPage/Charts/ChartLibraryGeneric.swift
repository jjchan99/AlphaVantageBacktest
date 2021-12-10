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
    
    private static func render<T: ChartPointSpecified>(data: [T], max: T.T? = nil, min: T.T? = nil) {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
    }
    
    private static func getYPosition<T: ChartPointSpecified>(data: [T], index: Int, max: T.T? = nil, min: T.T? = nil) -> CGFloat {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
        let range = cgf(max - min)
        
        let deviation = abs(data[index].valueForPlot - max)
        let share = cgf(deviation) / range
        let scaled = CGFloat(share) * 1
        return scaled
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


