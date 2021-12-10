//
//  ChartLibraryGeneric.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/12/21.
//

import Foundation
import SwiftUI
import CoreGraphics

enum ChartType {
    case bar
    case line
    case candle
}

protocol ChartPointSpecified: Comparable {
    associatedtype T where T: Numeric, T: Comparable
    var valueForPlot: T { get }
    var open: T? { get }
    var high: T? { get }
    var low: T? { get }
    var close: T? { get }
}

extension ChartPointSpecified {
    static func < (lhs: Self, rhs: Self) -> Bool {
        guard type(of: lhs.valueForPlot) == type(of: rhs.valueForPlot) else {}
        return lhs.valueForPlot < rhs.valueForPlot
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
           return lhs.valueForPlot == rhs.valueForPlot
    }
}

struct ChartLibraryGeneric {
    
    private static func render<T: ChartPointSpecified>(data: [T], max: T.T? = nil, min: T.T? = nil) {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
        
        
    }
    
    private static func getYPosition<T: ChartPointSpecified>(data: [T], index: Int, max: T.T? = nil, min: T.T? = nil) {
        let max = max ?? data.max()!.valueForPlot
        let min = min ?? data.min()!.valueForPlot
        let range
        
        let deviation = data[index].valueForPlot - max
        let share = deviation / analysis.tradingVolume.range
        let scaled = CGFloat(share) * heightBounds
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

    
   
