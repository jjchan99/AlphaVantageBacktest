//
//  CandleRenderer.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 10/11/21.
//

import Foundation
import CoreGraphics
import SwiftUI

struct CandleRenderer {
    
    let sorted: [OHLC]
    let height: CGFloat
    let width: CGFloat
    let converter: Converter
    let dependencies: (analysis: Analysis, array: [CandleOHLC])
    let padding: CGFloat
    
    init(sorted: [OHLC], height: CGFloat, width: CGFloat) {
        self.sorted = sorted
        self.height = height
        self.width = width
        padding = 0.05 * width
        
        self.converter = .init(sorted)
        let dependencies = converter.analyze()
        self.dependencies = dependencies
        
        Log.queue(action: "init candle renderer")
    }
    
    func render() -> [Candle] {
        var candles: [Candle] = []
        for idx in dependencies.array.indices {
            let candle = generateCandle(data: dependencies.array[idx], index: idx)
            candles.append(candle)
        }
        return candles
    }
    
    func generateCandle(data: CandleOHLC, index: Int) -> Candle {
        
        //MARK: 3N = V / 2
        var stick = Path()
        var body = Path()
        
        let width = width - (2 * padding)
        let maxWidth = 0.03 * width
        let position = getDailyYPosition(data: data)
        let pillars = width / CGFloat(dependencies.array.count - 1)
            
        var spacing = (1/3) * pillars > maxWidth ? maxWidth : (1/3) * pillars
        let xPosition = index == 0 ? padding : (pillars * CGFloat(index)) + padding
        spacing = pillars <= 5.0 ? 1 : spacing
        let green: Bool = data.close > data.open
        
        body.move(to: .init(x: xPosition - (0.5 * spacing), y: green ? position.close : position.open))
        body.addLine(to: .init(x: xPosition + (0.5 * spacing), y: green ? position.close : position.open))
        body.addLine(to: .init(x: xPosition + (0.5 * spacing), y: green ? position.open : position.close))
        body.addLine(to: .init(x: xPosition - (0.5 * spacing), y: green ? position.open : position.close))
        body.addLine(to: .init(x: xPosition - (0.5 * spacing), y: green ? position.close : position.open))
     
        stick.move(to: .init(x: xPosition, y: position.high))
        stick.addLine(to: .init(x: xPosition, y: position.low))
    
//        print("candle: x: \(xPosition)")
        
        return .init(data: data, body: body, stick: stick)
    }
    
    func getDailyYPosition(data: CandleOHLC) -> (open: CGFloat, high: CGFloat, low: CGFloat, close: CGFloat) {
        let range = dependencies.analysis.range
        let yOpen = CGFloat((abs(data.open - dependencies.analysis.max)) / range) * height
        let yHigh = CGFloat((abs(data.high - dependencies.analysis.max)) / range) * height
        let yLow = CGFloat((abs(data.low - dependencies.analysis.max)) / range) * height
        let yClose = CGFloat((abs(data.close - dependencies.analysis.max)) / range) * height
//        print("yOpen: \(yOpen) yHigh: \(yHigh) yLow: \(yLow) yClose: \(yClose)")
        return ((yOpen, yHigh, yLow, yClose))
    }
    
   
}

struct Candle {
    let data: OHLC
    let body: Path
    let stick: Path
}

struct Converter {

    let sorted: [OHLC]
    
    
    init(_ sorted: [OHLC]) {
        self.sorted = sorted
    }
    
    func analyze() -> (analysis: Analysis, array: [CandleOHLC]) {
        
        var max: Double = 0
        var min: Double = .infinity
        var array: [CandleOHLC] = []
  
        for idx in 0..<sorted.count {
         
                let open: Double = Double(sorted[idx].open)!
                let close: Double = Double(sorted[idx].close)!
                
                let low: Double = Double(sorted[idx].low!)!
                let high: Double = Double(sorted[idx].high!)!
                
                let newHigh: Bool = high > max
                let newLow: Bool = low < min
                
                if newHigh { max = high }
                if newLow { min = low }
                
            array.append(.init(stamp: sorted[idx].stamp, open: open, high: high, low: low, close: close))
            }
        
        return ((.init(max: max, min: min), array))
    }
}

struct Analysis {
    var max: Double
    var min: Double
    var range: Double {
        max - min
    }
}

struct CandleOHLC {
    var stamp: String
    var open: Double
    var high: Double
    var low: Double
    var close: Double
    var green: Bool {
        return close > open
    }
    var range: Double {
        return high - low
    }
}

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^ : PowerPrecedence
func ^^ (radix: CGFloat, power: CGFloat) -> CGFloat {
    return CGFloat(pow(Double(radix), Double(power)))
}


