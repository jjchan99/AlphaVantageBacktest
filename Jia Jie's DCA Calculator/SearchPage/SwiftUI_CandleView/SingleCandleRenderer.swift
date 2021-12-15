////
////  ChartLibrary.swift
////  Jia Jie's DCA Calculator
////
////  Created by Jia Jie Chan on 25/11/21.
////
//
import Foundation
import SwiftUI
import CoreGraphics

struct SingleCandleRenderer {

    init(movingAverage: SingleCandleRenderer.MaxMinRange, highLow: SingleCandleRenderer.MaxMinRange, candles: [Candle<OHLCCloudElement>], spec: Specifications<Double>) {
     
        self.movingAverage = movingAverage
        self.highLow = highLow

        let ultimateMax: Double = {
            return highLow.max > movingAverage.max ? highLow.max : movingAverage.max
        }()

        let ultimateMin: Double = {
            return highLow.min < movingAverage.min ? highLow.min : movingAverage.min
        }()

        self.ultimateMaxMinRange = .init(max: ultimateMax, min: ultimateMin)
        self.candles = candles
        self.spec = spec
    }

    let movingAverage: MaxMinRange
    let highLow: MaxMinRange
    let ultimateMaxMinRange: MaxMinRange
    let candles: [Candle<OHLCCloudElement>]
    let spec: Specifications<Double>
    
    struct MaxMinRange {

        let max: Double
        let min: Double
        var range: Double {
            max - min
        }
    }
    
    func getOffset(idx: Int) -> CGPoint {
    let ultimateRange = ultimateMaxMinRange.range
    let ultimateMax = ultimateMaxMinRange.max

    let shareOfHeight = CGFloat(candles[idx].data.range()) / CGFloat(ultimateRange) * spec.height
    let columns: CGFloat = spec.columns
        let xPosition = idx == 0 ? spec.padding : (columns * CGFloat(idx)) + spec.padding
    let scaleFactor = spec.height / shareOfHeight
    let x: CGFloat = -1 * xPosition
    let y = scaleFactor * -CGFloat((abs(candles[idx].data.high - ultimateMax)) / ultimateRange) * spec.height
        return .init(x: x, y: y)
    }

    func transform(idx: Int) -> CGPoint {
        let range = ultimateMaxMinRange.range
        let shareOfHeight = CGFloat(candles[idx].data.range()) / CGFloat(range) * spec.height
        let scaleFactor = spec.height / shareOfHeight
        let xStretch: CGFloat = 20 / spec.spacing
        return .init(x: xStretch, y: scaleFactor)
    }
}
