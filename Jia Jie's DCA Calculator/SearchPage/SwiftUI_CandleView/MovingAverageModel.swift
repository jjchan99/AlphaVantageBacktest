//
//  TradeAlgo.swift
//  Jia Jie's DCA Calculator
//
//  Created by Jia Jie Chan on 24/11/21.
//

import Foundation
import CoreGraphics
import SwiftUI

struct SimpleMovingAverageCalculator {
    
    let window: Int
    var windowSum: Double = 0
    var queue: [Double] = []
    var max: Double = 0
    var min: Double = .infinity
    var array: [Double] = []
    
    init(window: Int) {
        self.window = window
    }
    
    mutating func dequeue() -> Double {
        guard queue.count > 0 else { fatalError() }
        let first = queue[0]
        queue.remove(at: 0)
        return first
    }
    
    mutating func movingAverage(data: Double, index: Int) {
    
        windowSum += data
        queue.append(data)
        let window = index < self.window ? index + 1 : self.window
        if index >= window {
            windowSum -= dequeue()
        }
        let average = Double(windowSum) / Double(window)
        self.max = average > max ? average : max
        self.min = average < min ? average : min
        array.append(average)
//        print("Average for \(queue.count) numbers \(queue) is \(average)")
    }
    
    
}

//struct LineGraph {
//    let data: [Double]
//    let height: CGFloat
//    let width: CGFloat
//    let max: Double
//    let min: Double
//    let range: Double
//    let padding: CGFloat
//
//    init(data: [Double], height: CGFloat, width: CGFloat, max: Double, min: Double) {
//        self.data = data
//        self.height = height
//        self.width = width
//        self.max = max
//        self.min = min
//        self.range = max - min
//        padding = 0.05 * width
//    }
//
//    func getYPosition(range: Double, index: Int) -> CGFloat {
//        let untranslated = (1 - (CGFloat((data[index] - min) / range))) * height
//        return untranslated
//    }
//
//
//    func render() -> (path: Path, area: Path, points: [CGPoint]) {
//        var pointArray: [CGPoint] = []
//        var path = Path()
//        var area = Path()
//        let width = width - (2 * padding)
//        for index in data.indices {
//
//        let pillars = width / CGFloat(data.count - 1)
//
//        let xPosition: CGFloat = index == 0 ? padding : (pillars * CGFloat(index)) + padding
//        let yPosition = getYPosition(range: range, index: index)
//
//        if index == 0 {
//            pointArray.append(CGPoint(x: xPosition, y: yPosition))
//            path.move(to: CGPoint(x: xPosition, y: yPosition))
//            area.move(to: CGPoint(x: xPosition, y: yPosition))
//
//        } else {
//            pointArray.append(CGPoint(x: xPosition, y: yPosition))
//            path.addLine(to: CGPoint(x: xPosition, y: yPosition))
//
//            area.addLine(to: CGPoint(x: xPosition, y: yPosition))
//        }
//
//        if index == data.count {
//            area.addLine(to: CGPoint(x: xPosition, y: height))
//            area.addLine(to: CGPoint(x: 0, y: height))
//            area.addLine(to: CGPoint(x: 0, y: (1 - (CGFloat((data[0] / range)))) * height))
//            area.closeSubpath()
//        }
//
////            print("tradeAlgo: x: \(xPosition)")
//    }
//    return (path, area, pointArray)
//    }
//
//
//}

