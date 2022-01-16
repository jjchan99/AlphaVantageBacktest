//
//  OHLCCloudElement.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 4/12/21.
//

import Foundation

struct OHLCCloudElement {
    let stamp: String
    let open: Double
    let high: Double
    let low: Double
    let close: Double
    let volume: Double
 
    let percentageChange: Double?
    let RSI: [Int: Double]
    let movingAverage: [Int: Double] 
    let standardDeviation: Double?
    let upperBollingerBand: Double?
    let lowerBollingerBand: Double?
    
    func valueAtPercent(percent: Double) -> Double? {
        guard upperBollingerBand != nil, lowerBollingerBand != nil else { return nil }
        return lowerBollingerBand! + (( upperBollingerBand! - lowerBollingerBand! ) * percent)
    }
    func green() -> Bool {
        return close > open
    }
    
    func range() -> Double {
        return high - low
    }
    
    var emptyKey: Double = 0
}

extension OHLCCloudElement: CandlePointSpecified {
    typealias T = Double
    
    static var itemsToPlot: [KeyPath<OHLCCloudElement, Double> : Specifications<Double>] = [:]
   
}

extension OHLCCloudElement: Plottable, OpHLC {
    
}
