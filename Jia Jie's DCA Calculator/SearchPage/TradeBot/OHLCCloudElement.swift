//
//  OHLCCloudElement.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 4/12/21.
//

import Foundation

struct OHLCCloudElement {
    var stamp: String
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var RSI: Double
    var movingAverage: Double
    var standardDeviation: Double
    var upperBollingerBand: Double
    var lowerBollingerBand: Double
    func valueAtPercent(percent: Double) -> Double {
        return ( upperBollingerBand - lowerBollingerBand ) * percent
    }
    func green() -> Bool {
        return close > open
    }
}

