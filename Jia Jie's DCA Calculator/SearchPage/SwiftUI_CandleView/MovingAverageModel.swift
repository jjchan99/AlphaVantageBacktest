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
